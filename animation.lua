------------------------------------------------------------------------------
--	FILE:	  animation.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base entity class for Perimo
------------------------------------------------------------------------------

local class = require 'middleclass'

local Animation = class('Animation')

function Animation:initialize(spritesheet, tileWidth, tileHeight, numTiles, timeBetweenFrames)
  self.spritesheet = love.graphics.newImage(spritesheet)
  self.frames = {}
  self.tileWidth = tileWidth
  self.tileHeight = tileHeight
  self.numTiles = numTiles
  self.currentFrame = 0
  self.timeBetweenFrames = timeBetweenFrames
  self.timeAfterPreviousFrame = 0
  self:generateAnimationQuads()
end

function Animation:generateAnimationQuads()
  for i = 0, self.numTiles - 1 do
    table.insert(self.frames, love.graphics.newQuad(i * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.numTiles * self.tileWidth, self.tileHeight))
  end
end

function Animation:getCurrentQuad()
  return self.frames[self.currentFrame + 1]
end

function Animation:update(dt)
  self.timeAfterPreviousFrame = self.timeAfterPreviousFrame + dt
  if self.timeAfterPreviousFrame > self.timeBetweenFrames then
    self.timeAfterPreviousFrame = 0
    self.currentFrame = (self.currentFrame + 1) % (self.numTiles)
  end
end

function Animation:resetAnimation(frame)
  if not frame then frame = 0 end
  self.currentFrame = frame
end

return Animation
