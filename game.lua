------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base game class for Perimo
------------------------------------------------------------------------------

-- Third-party Libraries
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local GameMap = require 'gamemap'
local Multiplayer = require 'multiplayer_handler'
local Player = require 'player'
local Camera = require 'camera'


local Game = class('Game', Entity)

function Game:initialize()
  Entity.initialize(self)
  love.graphics.setDefaultFilter('nearest', 'nearest')

  self.map = GameMap:new()
  self:addSubentity(self.map)

  self.multiplayer = Multiplayer:new()
  self:addSubentity(self.multiplayer)

  self.player = Player:new(true)
  self:addSubentity(self.player)

  self.camera = Camera(0, 0, 2)

end

function Game:load()
  self.multiplayer:connect()
end

-- function Game:playerJoin()
--   table.insert(self.players
-- end

function Game:update(dt)
  self.multiplayer:update()
  local smoother = Camera.smooth.damped(4)
  if self.player.x < love.graphics.getWidth() / 4 then
    self.camera:lockX(love.graphics.getWidth() / 4, smoother)
  elseif self.player.x > (self.map.width * 16) - love.graphics.getWidth() / 4 then
    self.camera:lockX((self.map.width * 16) - love.graphics.getWidth() / 4, smoother)
  else
    self.camera:lockX(self.player.x, smoother)
  end
  if self.player.y < love.graphics.getHeight() / 4 then
    self.camera:lockY(love.graphics.getHeight() / 4, smoother)
  elseif self.player.y > (self.map.height * 16) - love.graphics.getHeight() / 4 then
    self.camera:lockY((self.map.height * 16) - love.graphics.getHeight() / 4, smoother)
  else
    self.camera:lockY(self.player.y, smoother)
  end
end

function Game:draw()
  self.camera:attach()
end

function Game:end_draw()
  self.camera:detach()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

return Game
