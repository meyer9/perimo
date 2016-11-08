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
local util = require 'util'

local Player = class('Player', Entity)

function Player:initialize(controllable, name)
  Entity.initialize(self)
  self.controllable = controllable
  self.name = name
end

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
end

function Player:update(dt)
  local playerUUID = self.game.multiplayer.client:getUserValue("player_uuid")
  local gamestate = self.game.multiplayer.gamestate_runner:run(dt)
  if gamestate and gamestate:getObjectProp(playerUUID, "x") then
    -- util.remove_value(self.game.multiplayer.needs_update, playerUUID)
    self.x = gamestate:getObjectProp(playerUUID, "x")
    self.y = gamestate:getObjectProp(playerUUID, "y")
  end
  if love.keyboard.isDown("w") then
    self.y = self.y - dt * 100
  elseif love.keyboard.isDown("s") then
    self.y = self.y + dt * 100
  end
  if love.keyboard.isDown("a") then
    self.x = self.x - dt * 100
  elseif love.keyboard.isDown("d") then
    self.x = self.x + dt * 100
  end
end

function Player:mpTick()
  local dt = 1 / self.game.tickrate
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
  end
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
