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

function GamestateRunner:initialize(tickrate)
  self.from_state = nil
  self.command_history = {}
  self.tickrate = tickrate
end

function GamestateRunner:run(dt)
  if not self.from_state then
    return Gamestate:new()
  end
  if #self.command_history == 0 then
    return self.from_state
  end
  local new_gamestate = self.from_state:clone()
  for idx, command_and_player in pairs(self.command_history) do
    local cmd = command_and_player.cmd
    local player_uuid = command_and_player.player
    local params = command_and_player.params
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

function GamestateRunner:receivedUpdate(gamestate, tick)
  local test_run = self:run()
  if self.player_id and test_run and gamestate:getObjectProp(self.player_id, "x") and test_run:getObjectProp(self.player_id, "x") then
    print(gamestate:getObjectProp(self.player_id, "x"), test_run:getObjectProp(self.player_id, "x"))
  end
  for idx, command_and_player in pairs(self.command_history) do
    if command_and_player.tick <= tick then
      self.command_history[idx] = nil
    end
  end
  self.from_state = gamestate:clone()
end

return GamestateRunner
