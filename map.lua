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
local generate_tiles = require 'tile_data'

local Map = class('Map', Entity)

function Map:initialize(width, height)
  -- generate tile data and spritesheet quads from spritesheet image
  self.spritesheet = love.graphics.newImage("spritesheet.png")
  local spritesheet_width, spritesheet_height = self.spritesheet:getDimensions()
  self.tiles = generate_tiles(spritesheet_width, spritesheet_height)

  -- generate initial map data
  if not width then self.width = 1000 else self.width = width end
  if not height then self.height = 1000 else self.height = height end
  self.map_data = {}
  for i = 1, self.width do
    self.map_data[i] = {}
    for j = 1, self.height do
      self.map_data[i][j] = self.tiles.EMPTY
    end
  end
end

function Map:get_tile(x, y)
  if self.map_data[x] and self.map_data[x][y] then
    return self.map_data[x][y]
  else
    return self.tiles.EMPTY
  end
end

function Map:set_tile(x, y, tile)
  self.map_data[x][y] = tile
end

function Map:load()
  self:generate_map()
end

function Map:generate_map()
  self:generate_island()
end

-- use cellular automata to generate an island
function Map:generate_island()
  cycles = 3
  center_weight = 10
  math.randomseed(os.time() - os.clock() * 1000)

  for x = 1, self.width do
    for y = 1, self.height do
      tile = self.tiles.GRASS
      if math.random() > 0.5 then tile = self.tiles.WATER end
      self:set_tile(x, y, tile)
    end
  end
  for x = 1, cycles do
    new_map = {}
    for x = 1, self.width do
      new_map[x] = {}
      for y = 1, self.height do
        numNeighbors = 0
        if self:get_tile(x + 1, y) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y + 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y - 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y + 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y - 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y + 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y - 1) == self.tiles.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if (numNeighbors > 3 and self:get_tile(x, y) == self.tiles.GRASS) or (numNeighbors > 4 and self:get_tile(x, y) == self.tiles.WATER) then
            new_map[x][y] = self.tiles.GRASS
        else
          new_map[x][y] = self.tiles.WATER
        end
      end
    end
    self.map_data = new_map
    new_map = nil
  end
end

function Map:update(dt)
end

function Map:draw()
  for x = 1, self.width do
    for y = 1, self.height do
      tile_to_draw = self:get_tile(x, y)
      if tile_to_draw.should_draw ~= false then
        love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
      end
    end
  end
end

return Map
