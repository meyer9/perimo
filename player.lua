------------------------------------------------------------------------------
--	FILE:	  player.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Player entity for Perimo
------------------------------------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Animation = require 'animation'
local Bullet = require 'bullet'

local Player = class('Player', Entity)

function Player:initialize(controllable, name)
  Entity.initialize(self)
  self.controllable = controllable
  self.name = name
end

function Player:load()
  self.torsoAnimation = Animation:new('player.png', 16, 16, 4, 0.3)
  self.legAnimation = Animation:new('legs_anim.png', 16, 16, 9, 0.07)

  if not controllable then controllable = false end
  self.anim_index = 0
  self.x = 4000
  self.y = 4000
  self.speed = 100
  self.dx = 0 -- how much moved in frame
  self.dy = 0
  self.legSmooth = 0
  self.reload = 100
  self.toReload = self.reload
  self.playerFont = love.graphics.newFont(10)
end

function Player:update(dt)
  if self.controllable then
    self.dx = 0
    self.dy = 0
    if love.keyboard.isDown("w") then
      self.dy = -self.speed * dt
    elseif love.keyboard.isDown("s") then
      self.dy = self.speed * dt
    end
    if love.keyboard.isDown("a") then
      self.dx = -self.speed * dt
    elseif love.keyboard.isDown("d") then
      self.dx = self.speed * dt
    end

    self.y = self.y + self.dy
    self.x = self.x + self.dx

    if love.keyboard.isDown("w") or love.keyboard.isDown("a") or love.keyboard.isDown("s") or love.keyboard.isDown("d") then
      self.torsoAnimation:update(dt)
      self.legAnimation:update(dt)
    else
      self.torsoAnimation:resetAnimation(1)
      self.legAnimation:resetAnimation()
    end
    self.toReload = self.toReload - 1
    if love.mouse.isDown(1) and self.toReload < 0 then
      self.toReload = self.reload
      local mousePositionX, mousePositionY = self.superentity.camera:mousePosition()
      local bullet = Bullet:new(self.x, self.y)
      self:addSubentity(bullet)
      bullet:shoot(mousePositionX - self.x, mousePositionY - self.y)
    end
  end
end

function Player:mpTick()
  print(self.game.multiplayer.client.authKey)
  -- self.game.multiplayer.client:setUserValue("x", self.x)
  -- self.game.multiplayer.client:setUserValue("y", self.y)
end

function Player:draw()
  -- draw torso
  local mousePositionX, mousePositionY = self.game.camera:mousePosition()
  local rot = math.atan2(self.y - mousePositionY, self.x - mousePositionX) + math.pi

  local legRot = 0.2 * (math.pi + math.atan2(self.dy, self.dx)) + 0.8 * self.legSmooth

  love.graphics.draw(self.legAnimation.spritesheet, self.legAnimation:getCurrentQuad(), self.x, self.y, legRot, 2, 2, 8, 8)
  love.graphics.draw(self.torsoAnimation.spritesheet, self.torsoAnimation:getCurrentQuad(), self.x, self.y, rot, 2, 2, 8, 8)
  love.graphics.setFont(self.playerFont)
  love.graphics.printf(self.name, self.x - 250, self.y + 16, 500, 'center')


  self.legSmooth = legRot
end

return Player
