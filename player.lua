------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Player entity for Perimo
------------------------------------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'

local Player = class('Player', Entity)

function Player:load(controllable)
  self.spritesheet_torso = love.graphics.newImage("player.png")
  if not controllable then controllable = false end
  self.controllable = controllable
  self.anim_index = 0
  self.x = 0
  self.y = 0
  self.speed = 100
  self.anim_time = 0
end

function Player:incr_anim()
  if self.anim_time > 0.3 then
    self.anim_index = (self.anim_index + 1) % 3
    self.anim_time = 0
  end
end

function Player:update(dt)
  self.anim_time = self.anim_time + dt
  -- self.x = 100
  if love.keyboard.isDown("w") then
    self.y = self.y - (self.speed * dt)
    self:incr_anim()
  elseif love.keyboard.isDown("s") then
    self.y = self.y + (self.speed * dt)
    self:incr_anim()
  end
  if love.keyboard.isDown("a") then
    self.x = self.x - (self.speed * dt)
    self:incr_anim()
  elseif love.keyboard.isDown("d") then
    self.x = self.x + (self.speed * dt)
    self:incr_anim()
  end
  if love.keyboard.isDown("w") or love.keyboard.isDown("a") or love.keyboard.isDown("s") or love.keyboard.isDown("d") then
    self:incr_anim()
  else
    self.anim_index = 1
  end
end

function Player:draw()
  -- draw torso
  local rot = math.atan2(self.y - love.mouse.getY() / 2, self.x - love.mouse.getX() / 2) + math.pi
  love.graphics.draw(self.spritesheet_torso, love.graphics.newQuad(self.anim_index * 32, 0, 32, 32, 128, 32), self.x, self.y, rot, 1, 1, 11, 13)
end

return Player
