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
local Tiles = require 'tile_data'

local Map = class('Map', Entity)

function Map:initialize(width, height)
  -- generate initial map data
  if not width then self.width = 100 else self.width = width end
  if not height then self.height = 100 else self.height = height end
  self.map_data = {}
  for i = 1, self.width do
    self.map_data[i] = {}
    for j = 1, self.height do
      self.map_data[i][j] = Tiles.EMPTY
    end
  end
end

function Map:get_tile(x, y)
  if self.map_data[x] and self.map_data[x][y] then
    return self.map_data[x][y]
  else
    return Tiles.EMPTY
  end
end

function Map:set_tile(x, y, tile)
  self.map_data[x][y] = tile
end

return Map
