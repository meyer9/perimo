------------------------------------------------------------------------------
--	FILE:	  players_multiplayer.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Class to keep track of online players locally
------------------------------------------------------------------------------

local class = require 'middleclass'
local Entity = require 'entity'
local PlayerMP = require 'player_multiplayer'

MultiplayerPlayers = class('MultiplayerPlayers', Entity)

function MultiplayerPlayers:load()
  self.players = {}
end

function MultiplayerPlayers:playerJoin(player)
  local newPlayer = PlayerMP:new(player)
  self:addSubentity(newPlayer)
  table.insert(self.players, newPlayer)
end

function MultiplayerPlayers:playerLeave(playerID)
  local i = 0
  for player in self.players do
    if player.uuid and player.uuid == playerID then
      self.players[i] = nil
    end
    i = i + 1
  end
end

function MultiplayerPlayers:runCommand(playerID, command, parms)
  for player in self.players do
    if player.uuid and player.uuid == playerID then
      player.runCommand(command, parms)
    end
  end
end

function MultiplayerPlayers:update(dt)
end

function MultiplayerPlayers:draw()
end

return MultiplayerPlayers
