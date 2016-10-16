------------------------------------------------------------------------------
--	FILE:	  gamemap.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Map drawing code for Perimo
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

  -- pre render the canvas
  -- self:render_map()

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

function GameMap:draw()
  local camera = self.superentity.camera
  local visible_tile_x = math.ceil((camera.x - love.graphics.getWidth() / 4) / 16)
  local visible_tile_y = math.ceil((camera.y - love.graphics.getHeight() / 4) / 16)
  local visible_tile_width = math.ceil(love.graphics.getWidth() / 16 / camera.scale)
  local visible_tile_height = math.ceil(love.graphics.getHeight() / 16 / camera.scale)
  for x = visible_tile_x, visible_tile_x + visible_tile_width do
    for y = visible_tile_y, visible_tile_y + visible_tile_height do
      tile_to_draw = Tiles.Data[self:get_tile(x, y)]
      if tile_to_draw.should_draw ~= false then
        love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
      end
    end
  end
end

return GameMap
