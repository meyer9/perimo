------------------------------------------------------------------------------
--	FILE:	  player_multiplayer.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Class to represent an online player
------------------------------------------------------------------------------

local class = require 'middleclass'
local Player = require 'player'
local COMMANDS = require 'common.commands'

local PlayerMP = class('PlayerMP', Player)

function PlayerMP:initialize(player)
  Player.initialize(self, false, player.playerName)
  self.player_data = player
end

function PlayerMP:runCommand(command, parms)
  -- if command == COMMANDS.player_at then
  --   self.x = parms.x
  --   self.y = parms.y
  -- end
end

function PlayerMP:mpTick()
  if self.player_data.customData.x ~= nil then
    self.x = self.player_data.customData.x
  end
  if self.player_data.customData.y ~= nil then
    self.y = self.player_data.customData.y
  end
end
return PlayerMP
