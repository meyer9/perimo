-------------------------------------------------
-- Represents another player sent from the server.
--
-- @classmod MultiplayerPlayer
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local MultiplayerEntity = require 'multiplayer_entity'
local Player = require 'player'
local MultiplayerPlayer = class('MultiplayerPlayer', MultiplayerEntity)

function MultiplayerPlayer:load()
  Player.load(self)
  self.name = "test"
  self.x = -1000
  self.y = -1000
end

function MultiplayerPlayer:update()
end

function MultiplayerEntity:updateState(state)
  if state.x then self.x = state.x end
  if state.y then self.y = state.y end
end

function MultiplayerPlayer:draw()
  Player.draw(self)
end


return MultiplayerPlayer
