-------------------------------------------------
-- Class to handle an online player during a multiplayer
-- game.
--
-- @classmod PlayerMP
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local Player = require 'player'
local COMMANDS = require 'common.commands'

local PlayerMP = class('PlayerMP', Player)

-------------------------------------------------
-- Initializes a new multiplayer player using player data sent from the
-- server.
-- @tparam tab player Player data.
-------------------------------------------------
function PlayerMP:initialize(player)
  Player.initialize(self, false, player.playerName)
  self.player_data = player
end

-------------------------------------------------
-- Called every multiplayer tick on the client.
-------------------------------------------------
function PlayerMP:mpTick()
end
return PlayerMP
