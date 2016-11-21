-------------------------------------------------
-- Represents another player sent from the server.
--
-- @classmod MultiplayerPlayer
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require 'lib.middleclass'
local MultiplayerEntity = require 'client.multiplayer_entity'
local Player = require 'client.player'
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
  if state.yaw then self.rot = state.yaw end
  if state.name then self.name = state.name end
end

function MultiplayerPlayer:draw()
  Player.draw(self)
end


return MultiplayerPlayer
