------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Map representation for Perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Util = require 'util'
local Tiles = require 'common.tile_data'

local Map = class('Map', Entity)

function Map:initialize(width, height)
  -- generate initial map data
  if not width then self.width = 500 else self.width = width end
  if not height then self.height = 500 else self.height = height end
  self.map_data = {}
  for i = 1, self.width do
    self.map_data[i] = {}
    for j = 1, self.height do
      self.map_data[i][j] = Tiles.ID.EMPTY
    end
  end
end

function Map:get_tile(x, y)
  if self.map_data[x] and self.map_data[x][y] then
    return self.map_data[x][y]
  else
    return Tiles.ID.EMPTY
  end
end

function Map:set_tile(x, y, tile)
  self.map_data[x][y] = tile
  self:changed()
end

function Map:generate_island()
  cycles = 10
  center_weight = 10
  math.randomseed(os.time() - os.clock() * 1000)

  for x = 1, self.width do
    for y = 1, self.height do
      tile = Tiles.ID.GRASS
      if math.random() > 0.5 then tile = Tiles.ID.WATER end
      self:set_tile(x, y, tile)
    end
  end
  for x = 1, cycles do
    new_map = {}
    for x = 1, self.width do
      new_map[x] = {}
      for y = 1, self.height do
        numNeighbors = 0
        if self:get_tile(x + 1, y) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y + 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x, y - 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y + 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x + 1, y - 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y + 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if self:get_tile(x - 1, y - 1) == Tiles.ID.GRASS then
          numNeighbors = numNeighbors + 1
        end
        if (numNeighbors > 3 and self:get_tile(x, y) == Tiles.ID.GRASS) or (numNeighbors > 4 and self:get_tile(x, y) == Tiles.ID.WATER) then
            new_map[x][y] = Tiles.ID.GRASS
        else
          new_map[x][y] = Tiles.ID.WATER
        end
      end
    end
    self.map_data = new_map
    self:changed()
    new_map = nil
  end
end

function Map:serialize()
  serialized_map = ''
  serialized_map = serialized_map .. self.width .. ';' .. self.height .. ';'
  for x = 1, self.width do
    for y = 1, self.height do
      serialized_map = serialized_map .. string.format("%03d", self:get_tile(x, y))
    end
    serialized_map = serialized_map
  end
  return serialized_map
end

function Map:changed()
  -- hook for map changes
end

function Map:deserialize(serialized)
  local first = string.find(serialized, ';')
  local second = string.find(serialized, ';', first + 1)
  local width = serialized:sub(1, first - 1)
  local height = serialized:sub(first + 1, second - 1)
  local new_map = {}
  new_map[1] = {}
  local y = 1
  local x = 1
  local map_data = serialized:sub(second + 1)
  for i = 0, (#map_data / 3) - 1 do
    local c = map_data:sub(i * 3 + 1,i * 3 + 3)
    new_map[x][y] = tonumber(c)
    y = y + 1
    if (i + 1) % height == 0 then
      table.insert(new_map, {})
      x = x + 1
      y = 1
    end
  end
  self.width = width
  self.height = height
  self.map_data = new_map
  self:changed()
end


return Map
