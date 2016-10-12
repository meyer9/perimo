------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  To provide tile data for Perimo
------------------------------------------------------------------------------

-- EDIT ONLY BETWEEN HERE
local Tiles = {
  EMPTY = {
    width = 16,
    height = 16,
    should_draw = false
  },
  GRASS = {
    width = 16,
    height = 16,
    x = 85,
    y = 0
  },
  WATER = {
    width = 16,
    height = 16,
    x = 0,
    y = 0
  }
}
-- AND HERE


-- generates tiles using spritesheet width (sw), and spritesheet height (sh)
function Tiles.generate_tiles(sw, sh)
  for i, tile in pairs(Tiles) do
    if type(tile) ~= 'function' and tile.should_draw ~= false then
      Tiles[i].quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, sw, sh)
    end
  end
  return tiles
end

return Tiles
