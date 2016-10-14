------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Map representation for Perimo
------------------------------------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Util = require 'util'
local Map = require 'common.map'
local Tiles = require 'common.tile_data'

local GameMap = class('GameMap', Map)

function GameMap:load()
  -- load spritesheet data
  self.spritesheet = love.graphics.newImage("spritesheet.png")
  local spritesheet_width, spritesheet_height = self.spritesheet:getDimensions()
  Tiles.generate_tiles(spritesheet_width, spritesheet_height)

  -- create cached canvas
  self.cached_map = love.graphics.newCanvas(self.width * 16, self.height * 16)

  -- pre render the canvas
  self:render_map()

  self.dirty = false -- set to true when re-rendering is needed
  self.hasnttriggered = true
end

function GameMap:generate_map()
  for x = 1, self.width do
    for y = 1, self.height do
      tile = Tiles.ID.GRASS
      if math.random() > 0.5 then tile = Tiles.ID.WATER end
      self:set_tile(x, y, tile)
    end
  end
end

function GameMap:changed()
  self.dirty = true
end

function GameMap:update(dt)
end

function GameMap:render_map()
  love.graphics.setCanvas(self.cached_map) -- draw on the canvas
    for x = 1, self.width do
      for y = 1, self.height do
        tile_to_draw = Tiles.Data[self:get_tile(x, y)]
        if tile_to_draw.should_draw ~= false then
          love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
        end
      end
    end
  love.graphics.setCanvas() -- draw on the screen
end

function GameMap:draw()
  if self.dirty == true then
    self:render_map()
    self.dirty = false
  end
  b = os.clock()
  love.graphics.scale(2,2)
  love.graphics.draw(self.cached_map)
end

return GameMap
