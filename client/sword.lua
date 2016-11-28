-------------------------------------------------
-- Class to represent a sword the player is holding
--
-- @classmod Player
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Third-party Imports
local class = require 'lib.middleclass'

-- Local Imports
local Entity = require 'common.entity'
local Animation = require 'client.animation'
local util = require 'common.util'

local Sword = class('Sword', Entity)

-------------------------------------------------
-- Initializes a new sword.
-- @tparam number sword_duration duration in seconds of sword swing
-- @tparam int reach number of pixels the sword should reach
-- @tparam number angle spread in radians of sword
-------------------------------------------------
function Sword:initialize(sword_duration, reach, angle)
  Entity.initialize(self)
  self.duration = sword_duration
  self.reach = reach
  self.angle = angle
  self.start_swing_angle = 0
  self.current_swing_angle = 0
  self.swinging = false
  self.end_swing_angle = 0
  self.controllable = true
end

-------------------------------------------------
-- Sets up player graphics, fonts, and initial properties.
-------------------------------------------------
function Sword:load()
  self.sword = love.graphics.newImage("resources/sword.png")
end

-------------------------------------------------
-- Updates the player position using interpolation.
-- @tparam number dt Amount of time in seconds passed since last update.
-------------------------------------------------
function Sword:update(dt)
  if love.mouse.isDown(1) and self.swinging == false and self.controllable then
    local angle = self.superentity.rot
    self.game.multiplayer:sendCommand("swing", angle)
    self.start_swing_angle = angle - self.angle / 2 + math.pi / 2
    self.end_swing_angle = angle + self.angle / 2 + math.pi / 2
    self.current_swing_angle = self.start_swing_angle
    self.swinging = true
  end
  if self.swinging then
    if self.current_swing_angle >= self.end_swing_angle then
      self.swinging = false
    end
    self.current_swing_angle = self.current_swing_angle + (self.angle / self.duration) * dt
  end
end

-------------------------------------------------
-- Sends commands to the server if necessary.
-------------------------------------------------
-- function Sword:mpTick()
-- end

-------------------------------------------------
-- Draws the player using the players current X and Y.
-------------------------------------------------
function Sword:draw()
  -- draw torso
  if self.swinging then
    love.graphics.arc("line", self.superentity.x, self.superentity.y, self.reach, self.start_swing_angle - math.pi / 2, self.end_swing_angle - math.pi / 2)
    love.graphics.draw(self.sword, self.superentity.x, self.superentity.y, self.current_swing_angle, 1, 1, 3, 64)
  end
end

return Sword
