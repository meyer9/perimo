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
local Map = require 'map'
local Tiles = require 'tile_data'

local GameMap = class('GameMap', Map)

function GameMap:load()
  -- load spritesheet data
  self.spritesheet = love.graphics.newImage("spritesheet.png")
  local spritesheet_width, spritesheet_height = self.spritesheet:getDimensions()
  Tiles.generate_tiles(spritesheet_width, spritesheet_height)
  self:generate_map()
end

function GameMap:generate_map()
  for x = 1, self.width do
    for y = 1, self.height do
      tile = Tiles.GRASS
      if math.random() > 0.5 then tile = Tiles.WATER end
      self:set_tile(x, y, tile)
    end
  end
end

-- use cellular automata to generate an island
function GameMap:generate_island()
  cycles = 3
  center_weight = 10
  math.randomseed(os.time() - os.clock() * 1000)

  for x = 1, self.width do
    for y = 1, self.height do
      tile = Tiles.GRASS
      if math.random() > 0.5 then tile = Tiles.WATER end
      self:set_tile(x, y, tile)
    end
  end
  for x = 1, cycles do
    new_map = {}
    for x = 1, self.width do
      new_map[x] = {}
      for y = 1, self.height do
        numNeighbors = 0
        if self:get_tile(x + 1, y) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y + 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y - 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y + 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y - 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y + 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y - 1) == Tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if (numNeighbors > 3 and self:get_tile(x, y) == Tiles.GRASS) or (numNeighbors > 4 and self:get_tile(x, y) == Tiles.WATER) then
            new_map[x][y] = Tiles.GRASS
        else
          new_map[x][y] = Tiles.WATER
        end
      end
    end
    self.map_data = new_map
    new_map = nil
  end
end

function GameMap:update(dt)
end

function GameMap:draw()
  for x = 1, self.width do
    for y = 1, self.height do
      tile_to_draw = self:get_tile(x, y)
      if tile_to_draw.should_draw ~= false then
        love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
      end
    end
  end
end

return GameMap
