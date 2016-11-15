-------------------------------------------------
-- Class to handle player interactions during a game.
--
-- @classmod Player
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Animation = require 'animation'
local util = require 'util'

local Player = class('Player', Entity)

-------------------------------------------------
-- Initializes a new player.
-- @tparam bool controllable Whether the user should be controlled using the current client.
-- @tparam string name name of the player
-------------------------------------------------
function Player:initialize(controllable, name)
  Entity.initialize(self)
  self.controllable = controllable
  self.name = name
end

-------------------------------------------------
-- Sets up player graphics, fonts, and initial properties.
-------------------------------------------------
function Player:load()
  self.torsoAnimation = Animation:new('player.png', 16, 16, 4, 0.3)
  self.legAnimation = Animation:new('legs_anim.png', 16, 16, 9, 0.07)

  self.anim_index = 0
  self.x = 0
  self.y = 0
  self.speed = 100
  self.dx = 0 -- how much moved in frame
  self.dy = 0
  self.legSmooth = 0
  self.reload = 1000
  self.toReload = self.reload
  self.playerFont = love.graphics.newFont(10)
  self.rot = 0
end

-------------------------------------------------
-- Updates the player position using interpolation.
-- @tparam number dt Amount of time in seconds passed since last update.
-------------------------------------------------
function Player:update(dt)
  local playerUUID = self.game.multiplayer.client:getUserValue("player_uuid")
  local interpolation = self.game.multiplayer.interpolation
  local interpX = self.game.multiplayer.gamestate_runner:getFrameProp(playerUUID, 'x', self.game.multiplayer:getTick() + 1)
  local interpY = self.game.multiplayer.gamestate_runner:getFrameProp(playerUUID, 'y', self.game.multiplayer:getTick() + 1)
  if interpX and interpY then
    self.x = interpX
    self.y = interpY
  end
  local mousePositionX, mousePositionY = self.game.camera:mousePosition()
  self.rot = math.atan2(self.y - mousePositionY, self.x - mousePositionX) + math.pi
end

-------------------------------------------------
-- Sends commands to the server if necessary.
-------------------------------------------------
function Player:mpTick()
  if self.controllable then
    if love.keyboard.isDown("w") then
      self.game.multiplayer:sendCommand("forward", nil, true)
    elseif love.keyboard.isDown("s") then
      self.game.multiplayer:sendCommand("backward", nil, true)
    end
    if love.keyboard.isDown("a") then
      self.game.multiplayer:sendCommand("left", nil, true)
    elseif love.keyboard.isDown("d") then
      self.game.multiplayer:sendCommand("right", nil, true)
    end
    local mousePositionX, mousePositionY = self.game.camera:mousePosition()
    local rot = math.atan2(self.y - mousePositionY, self.x - mousePositionX) + math.pi
    self.game.multiplayer:sendCommand("look", rot, true)
  end
end

-------------------------------------------------
-- Draws the player using the players current X and Y.
-------------------------------------------------
function Player:draw()
  -- draw torso

  local legRot = 0.2 * (math.pi + math.atan2(self.dy, self.dx)) + 0.8 * self.legSmooth

  love.graphics.draw(self.legAnimation.spritesheet, self.legAnimation:getCurrentQuad(), self.x, self.y, legRot, 2, 2, 8, 8)
  love.graphics.draw(self.torsoAnimation.spritesheet, self.torsoAnimation:getCurrentQuad(), self.x, self.y, self.rot, 2, 2, 8, 8)
  love.graphics.setFont(self.playerFont)
  love.graphics.printf(self.name, self.x - 250, self.y + 16, 500, 'center')


  self.legSmooth = legRot
end

return Player
