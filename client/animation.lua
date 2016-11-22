-------------------------------------------------
-- Class to update animations and draw them
-- using a tile sheet.
--
-- @classmod Animation
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require 'lib.middleclass'

local Animation = class('Animation')

-------------------------------------------------
-- Constructor function of Animation class which
-- also calculates quads using a spritesheet.
--
-- @tparam string spritesheet filename of the spritesheet to use for the animation
-- @tparam int tileWidth width of each tile
-- @tparam int tileHeight height of each tile
-- @tparam int numTiles number of tiles horizontally contained in the animation
-- @tparam number timeBetweenFrames seconds between each frame in the spritesheet
-------------------------------------------------
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

-------------------------------------------------
-- Generate quads using parameters given to the
-- animation class.
-------------------------------------------------
function Animation:generateAnimationQuads()
  for i = 0, self.numTiles - 1 do
    table.insert(self.frames, love.graphics.newQuad(i * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.numTiles * self.tileWidth, self.tileHeight))
  end
end

-------------------------------------------------
-- Retrieves the quad of the current frame in the animation.
--
-- @treturn tab quad of current frame of the animation
-------------------------------------------------
function Animation:getCurrentQuad()
  return self.frames[self.currentFrame + 1]
end

-------------------------------------------------
-- Updates the state of the animation.
--
-- @tparam number dt number of seconds that have passed since the last update
-------------------------------------------------
function Animation:update(dt)
  self.timeAfterPreviousFrame = self.timeAfterPreviousFrame + dt
  if self.timeAfterPreviousFrame > self.timeBetweenFrames then
    self.timeAfterPreviousFrame = 0
    self.currentFrame = (self.currentFrame + 1) % (self.numTiles)
  end
end

-------------------------------------------------
-- Resets the animation to frame, frame, or frame 0
--
-- @tparam int[opt] frame frame to reset to
-------------------------------------------------
function Animation:resetAnimation(frame)
  if not frame then frame = 0 end
  self.currentFrame = frame
end

return Animation
