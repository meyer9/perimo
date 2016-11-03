------------------------------------------------------------------------------
--	FILE:	  player_multiplayer.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Class to represent an online player
------------------------------------------------------------------------------

local class = require 'middleclass'
local Player = require 'player'
local Timeframe = require 'common.timeframe'
local COMMANDS = require 'common.commands'

local PlayerMP = class('PlayerMP', Player)

function PlayerMP:initialize(player)
  Player.initialize(self, false, player.playerName)
  self.player_data = player
  self.timeframe_x = Timeframe:new(10)
  self.timeframe_y = Timeframe:new(10)
  print('a')
end

function PlayerMP:runCommand(command, parms)
  -- if command == COMMANDS.player_at then
  --   self.x = parms.x
  --   self.y = parms.y
  -- end
end

function PlayerMP:mpTick()
end
return PlayerMP
