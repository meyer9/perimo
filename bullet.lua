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

local Bullet = class('Bullet', Entity)

function Bullet:initialize(x, y)
  self.anim_index = 0
  self.x = x
  self.y = y
  self.speed = 500
  self.dx = 0 -- how much moved in frame
  self.dy = 0
end

function Bullet:load()
  self.sprite = love.graphics.newImage("bullet.png")
end

function Bullet:update(dt)
  self.x = self.x + self.dx
  self.y = self.y + self.dy
end

function Bullet:draw()
  -- draw torso
  local mousePositionX, mousePositionY = self.superentity.superentity.camera:mousePosition()
  local rot = math.atan2(self.dy, self.dx)

  love.graphics.draw(self.sprite, self.x, self.y, rot, 2, 2, 3, 2)
end

function Bullet:shoot(dx, dy)
  self.dx = (dx / (dx ^ 2 + dy ^ 2)) * self.speed
  self.dy = (dy / (dx ^ 2 + dy ^ 2)) * self.speed
end

return Bullet
