-------------------------------------------------
-- Class to handle all players in a multiplayer game
-- on the client.
--
-- @classmod MultiplayerPlayers
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local Entity = require 'entity'
local PlayerMP = require 'player_multiplayer'

MultiplayerPlayers = class('MultiplayerPlayers', Entity)

-------------------------------------------------
-- Initialize the MultiplayerPlayers class.
-------------------------------------------------
function MultiplayerPlayers:load()
  self.players = {}
end

-------------------------------------------------
-- Create a new PlayerMP object and prepare it for
-- adding.
-- @tparam Player player the player to add
-------------------------------------------------
function MultiplayerPlayers:playerJoin(player)
  local newPlayer = PlayerMP:new(player)
  self:addSubentity(newPlayer)
  table.insert(self.players, newPlayer)
end

-------------------------------------------------
-- Removes a player from the game.
-- @tparam string playerID player UUID to remove from game
-------------------------------------------------
function MultiplayerPlayers:playerLeave(playerID)
  local i = 0
  for player in self.players do
    if player.uuid and player.uuid == playerID then
      self.players[i] = nil
    end
    i = i + 1
  end
end

function MultiplayerPlayers:update(dt)
end

function MultiplayerPlayers:draw()
end

return MultiplayerPlayers
