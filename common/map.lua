-------------------------------------------------
-- Class to represent a tiled map and generate
-- the map.
--
-- @classmod Map
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Third-party Imports
local class = require 'lib.middleclass'
local perlin = require 'common.noise'

-- Local Imports
local Entity = require 'common.entity'
local Util = require 'common.util'
local Tiles = require 'common.tile_data'

local Map = class('Map', Entity)

-------------------------------------------------
-- Constructor function of Map class. Initializes map
-- using empty tiles.
--
-- @tparam int width width of map
-- @tparam int height height of map
-------------------------------------------------
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

-------------------------------------------------
-- Gets the ID of the tile at x, y
--
-- @tparam int x X-coordinate of tile to retrieve
-- @tparam int y Y-coordinate of tile to retrieve
-- @treturn int ID of tile at coordinate
-------------------------------------------------
function Map:get_tile(x, y)
  if self.map_data[x] and self.map_data[x][y] then
    return self.map_data[x][y]
  else
    return Tiles.ID.EMPTY
  end
end

-------------------------------------------------
-- Sets a tile at x, y to tile
--
-- @tparam int x X-coordinate of tile to set
-- @tparam int y Y-coordinate of tile to set
-- @tparam int tile Tile ID to set
-------------------------------------------------
function Map:set_tile(x, y, tile)
  self.map_data[x][y] = tile
  self:changed()
end

-------------------------------------------------
-- Generates the map.
-------------------------------------------------
function Map:generate_island()
  self:set_tile(1, 1, Tiles.ID.TILE)
  self:set_tile(2, 1, Tiles.ID.WALL_HORIZ)
  self:set_tile(3, 1, Tiles.ID.WALL_HORIZ)
  self:set_tile(4, 1, Tiles.ID.WALL_HORIZ)
  self:set_tile(5, 1, Tiles.ID.WALL_HORIZ)
  self:set_tile(1, 2, Tiles.ID.WALL_VERT)
  self:set_tile(1, 3, Tiles.ID.WALL_VERT)
  self:set_tile(1, 4, Tiles.ID.WALL_VERT)
  self:set_tile(1, 5, Tiles.ID.WALL_VERT)
  -- smoothness = 20
  -- iterations = 4
  -- local n, amplitude
  -- local smoothnessx = smoothness * self.width / 30
  -- local smoothnessy = smoothness * self.height / 30

  -- local seed = math.random() * 50000
  -- for y = 1, self.height do
  --     for x = 1, self.width do -- This never repeats
  --         n = 0
  --         amplitude = 2
  --         -- Generate the terrain
  --         -- 'n' is the height value of the terrain
  --         for i = 1, iterations do
  --             n = n + (perlin.perlin(x/(smoothnessx)*amplitude,
  --                                   y/(smoothnessy)*amplitude,
  --                                   seed)+1) / amplitude
  --             amplitude = amplitude * 2
  --         end
  --         -- Make the height value go to 0 near the edge
  --         n = n * (1 - math.abs((x / self.width * 2) - 1))
  --               * (1 - math.abs((y / self.height * 2) - 1))
  --         bigness = 0.3
  --         if n > bigness + 0.1 then
  --           self:set_tile(x, y, Tiles.ID.GRASS)
  --         elseif n > bigness then
  --           self:set_tile(x, y, Tiles.ID.SAND)
  --         else
  --           self:set_tile(x, y, Tiles.ID.WATER)
  --         end
  --     end
  -- end
end

-------------------------------------------------
-- Serializes the map to send over the network
--
-- @treturn tab serialized map
-------------------------------------------------
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

-------------------------------------------------
-- Hook for map changes
-------------------------------------------------
function Map:changed()
  -- hook for map changes
end

-------------------------------------------------
-- Deserializes the map from the network.
--
-- @tparam string serialized Serialized map
-------------------------------------------------
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
    local c = map_data:sub(i * 3 + 1, i * 3 + 3)
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
