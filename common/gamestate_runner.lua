-------------------------------------------------
-- A module to keep track of gamestates received by the server
-- and interpolate between them.
--
-- @classmod GamestateRunner
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory


local class = require 'lib.middleclass'
local Gamestate = require 'common.gamestate'
local COMMANDS = require 'common.commands'
local Util = require 'common.util'

local GamestateRunner = class('GamestateRunner')

-------------------------------------------------
-- Constructor function of GamestateRunner module
--
-- @tparam int tickrate the tick rate of the client
-------------------------------------------------
function GamestateRunner:initialize(tickrate)
  self.state_history = {}
  self.command_history = {}
  self.max_frames = 10
  self.tickrate = tickrate
end

-------------------------------------------------
-- Runs gamestate based on latest tick from server and
-- past client commands
--
-- @treturn Gamestate predicted gamestate of client at latest tick
-------------------------------------------------
function GamestateRunner:run()
  if #self.state_history == 0 then
    return Gamestate:new()
  end
  if #self.command_history == 0 then
    return self.state_history[#self.state_history]
  end
  local last_gamestate = self.state_history[#self.state_history]
  local new_gamestate = last_gamestate:clone()
  for idx, command_and_player in pairs(self.command_history) do
    local cmd = command_and_player.cmd
    local player_uuid = command_and_player.player
    local params = command_and_player.params
    local tick = command_and_player.tick
    if tick > new_gamestate:getObjectProp('server', 'tick') then
      new_gamestate:updateState('server', 'tick', tick)
    end
    if cmd == COMMANDS.forward then
      local currentY = new_gamestate:getObjectProp(player_uuid, "y")
      new_gamestate:updateState(player_uuid, "y", currentY - 100 / self.tickrate)
    elseif cmd == COMMANDS.backward then
      local currentY = new_gamestate:getObjectProp(player_uuid, "y")
      new_gamestate:updateState(player_uuid, "y", currentY + 100 / self.tickrate)
    end
    if cmd == COMMANDS.left then
      local currentX = new_gamestate:getObjectProp(player_uuid, "x")
      new_gamestate:updateState(player_uuid, "x", currentX - 100 / self.tickrate)
    elseif cmd == COMMANDS.right then
      local currentX = new_gamestate:getObjectProp(player_uuid, "x")
      new_gamestate:updateState(player_uuid, "x", currentX + 100 / self.tickrate)
    end
    self.command_history[idx] = nil
  end
  return new_gamestate
end

-------------------------------------------------
-- Adds command to pending commands that were sent to the server
-- but no response has been received.
--
-- @tparam string entity_uuid UUID of entity to add the command for
-- @tparam string command Command name to add
-- @tparam int tick Tick to add the command for
-- @tparam tab params Any params sent for processing a specific command
-- @treturn Gamestate predicted gamestate of client at latest tick
-------------------------------------------------
function GamestateRunner:addCommand(entity_uuid, command, tick, params)
  self.player_id = entity_uuid
  table.insert(self.command_history, {player=entity_uuid, cmd = command, params = params, tick = tick})
end

-------------------------------------------------
-- Gets or interpolates a property for a specific tick
--
-- @tparam string entity UUID of entity to add the command for
-- @tparam string property Property of the entity to interpolate
-- @tparam tab exactTick Exact tick to interpolate to
-- @return Interpolated property for a specific tick
-------------------------------------------------
function GamestateRunner:getFrameProp(entity, property, exactTick)
  local interpStart = nil
  local interpEnd = nil
  local bestInterpAmountStart = 99999
  local bestInterpAmountEnd = 99999
  for _, frame in pairs(self.state_history) do
    if frame:getTick() < exactTick and bestInterpAmountStart > exactTick - frame:getTick() then
      bestInterpAmountStart = exactTick - frame:getTick()
      interpStart = frame
    end
    if frame:getTick() > exactTick and bestInterpAmountEnd > frame:getTick() - exactTick then
      bestInterpAmountEnd = frame:getTick() - exactTick
      interpEnd = frame
    end
  end
  if bestInterpAmountEnd == 99999 then
    local interpEnd = self:run()
  end
  if interpEnd and interpStart then
    local percentBetween = (exactTick - interpStart:getTick()) / (interpEnd:getTick() - interpStart:getTick())
    local propStart = interpStart:getObjectProp(entity, property)
    local propEnd = interpEnd:getObjectProp(entity, property)
    if propStart and propEnd then
      return Util.lerp(propStart, propEnd, percentBetween)
    else
      return nil
    end
  end
  return nil
end

-------------------------------------------------
-- Adds a server update to the current states
--
-- @tparam tab gamestate Gamestate to add to the history
-- @tparam int tick Tick to add the state for
-------------------------------------------------
function GamestateRunner:receivedUpdate(gamestate, tick)
  for idx, command_and_player in pairs(self.command_history) do
    if command_and_player.tick <= tick then
      self.command_history[idx] = nil
    end
  end
  table.insert(self.state_history, gamestate:clone())
  if #self.state_history > self.max_frames then
    table.remove(self.state_history, 1)
  end
end

return GamestateRunner
