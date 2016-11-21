-------------------------------------------------
-- Base game class for Perimo
--
-- @classmod Game
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Third-party Libraries
local class = require 'lib.middleclass'

-- Local Imports
local Entity = require 'common.entity'
local GameMap = require 'client.gamemap'
local Multiplayer = require 'client.multiplayer_handler'
local Player = require 'client.player'
local Camera = require 'lib.camera'


local Game = class('Game', Entity)

-------------------------------------------------
-- Initializes the game, sets up graphics, multiplayer,
-- camera, and player
-------------------------------------------------
function Game:initialize()
  Entity.initialize(self)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- love.window.setMode(1280, 800, {msaa = 32, fullscreen = true})

  self.tickrate = 30

  self.map = GameMap:new()
  self:addSubentity(self.map)

  math.randomseed(os.clock())

  self.player = Player:new(true, "player" .. math.floor(math.random() * 100))
  self:addSubentity(self.player)

  self.multiplayer = Multiplayer:new()
  self:addSubentity(self.multiplayer)

  self.camera = Camera(0, 0, 2)
end

-------------------------------------------------
-- Connects to multiplayer.
-------------------------------------------------
function Game:load()
  self.multiplayer:connect()
end

-------------------------------------------------
-- Hooks into the pre update code to update the camera
-- position based on the player position.
-------------------------------------------------
function Game:call_update(dt)
  -- self.multiplayer:update(dt)
  Entity.call_update(self, dt)
  local smoother = Camera.smooth.damped(4)
  if self.player.x < love.graphics.getWidth() / 4 then
    self.camera:lockX(love.graphics.getWidth() / 4, smoother)
  elseif self.player.x > (self.map.width * 32) - love.graphics.getWidth() / 4 then
    self.camera:lockX((self.map.width * 32) - love.graphics.getWidth() / 4, smoother)
  else
    self.camera:lockX(self.player.x, smoother)
  end
  if self.player.y < love.graphics.getHeight() / 4 then
    self.camera:lockY(love.graphics.getHeight() / 4, smoother)
  elseif self.player.y > (self.map.height * 32) - love.graphics.getHeight() / 4 then
    self.camera:lockY((self.map.height * 32) - love.graphics.getHeight() / 4, smoother)
  else
    self.camera:lockY(self.player.y, smoother)
  end
end

-------------------------------------------------
-- Translates the screen to the current camera position
-------------------------------------------------
function Game:draw()
  self.camera:attach()
end

-------------------------------------------------
-- Draws an FPS counter and untranslates the screen.
-------------------------------------------------
function Game:end_draw()
  self.camera:detach()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

return Game
