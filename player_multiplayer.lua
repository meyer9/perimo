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
end

function PlayerMP:mpTick()
end
return PlayerMP
