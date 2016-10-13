------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  To provide tile data for Perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local Tiles = {}
-- EDIT ONLY BETWEEN HERE

Tiles.ID = {
  EMPTY = 1,
  GRASS = 2,
  WATER = 3
}

Tiles.Data = {
  [1] = {
    width = 16,
    height = 16,
    should_draw = false
  },
  [2] = {
    width = 16,
    height = 16,
    x = 85,
    y = 0
  },
  [3] = {
    width = 16,
    height = 16,
    x = 0,
    y = 0
  }
}
-- AND HERE


-- generates tiles using spritesheet width (sw), and spritesheet height (sh)
function Tiles.generate_tiles(sw, sh)
  for i, tile in pairs(Tiles.Data) do
    if type(tile) ~= 'function' and tile.should_draw ~= false then
      Tiles.Data[i].quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, sw, sh)
    end
  end
  return tiles
end

function Tiles.tile(id)
  return Tiles.Data[Tiles.ID[id]]
end

return Tiles
