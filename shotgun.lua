------------------------------------------------------------------------------
--	FILE:	  shotgun.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Shotgun Weapon for Perimo
------------------------------------------------------------------------------

local class = require 'middleclass'
local Weapon = require 'weapon'

local Shotgun = class('Shotgun', 'weapon')

function Shotgun:initialize()
  Weapon.initialize(self)
  self.reload_time = 2 -- second
  self.shells_in_clip = 0
  self.max_shells_in_clip = 4
  self.total_ammo = 20
  self.num_shots =  3 -- bullets
  self.spread = 20 -- degrees
  self.time_between_shots = 0.2 -- second
  self.waiting_for_shot = 0
  self.reloading_for = 0
end

function Shotgun:shoot()
  if self.reloading_for > self.reload_time then
    self.reloading_for = 0
    local ammo_reloaded = self.max_shells_in_clip - self.shells_in_clip
    if ammo_reloaded <= self.total_ammo then
      self.shells_in_clip = self.max_shells_in_clip
      self.total_ammo = self.total_ammo - ammo_reloaded
    else
      self.shells_in_clip = self.total_ammo
      self.total_ammo = 0
    end
  end
end

function Shotgun:update(dt)
  self.reloading_for = self.reloading_for + dt
  self.waiting_for_shot = self.waiting_for_shot + dt
end

return Shotgun
