------------------------------------------------------------------------------
--	FILE:	  gamestate_runner.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Transforms gamestates using a from state and a series of commands
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory


local class = require 'middleclass'
local Gamestate = require 'common.gamestate'
local COMMANDS = require 'common.commands'

local GamestateRunner = class('GamestateRunner')

function GamestateRunner:initialize(tickrate, max_frames)
  self.state_history = {}
  self.command_history = {}
  self.max_frames = 3 or max_frames
  self.tickrate = tickrate
end

function GamestateRunner:run(dt)
  if #self.state_history then
    return Gamestate:new()
  end
  if #self.command_history == 0 then
    return self.from_state
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

function GamestateRunner:addCommand(entity_uuid, command, tick, params)
  self.player_id = entity_uuid
  table.insert(self.command_history, {player=entity_uuid, cmd = command, params = params, tick = tick})
end

function lerp(v0, v1, t)
  return (1-t) * v0 + t * v1
end

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
    interpEnd = self:run()
  end
  if interpEnd and interpStart then
    local percentBetween = (interpEnd:getTick() - exactTick) / (interpEnd:getTick() - interpStart:getTick())
    local propStart = interpStart:getObjectProp(entity, property)
    local propEnd = interpEnd:getObjectProp(entity, property)
    if propStart and propEnd then
      return lerp(propEnd, propStart, percentBetween)
    else
      return nil
    end
  end
  return nil
end

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
