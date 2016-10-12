------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  To provide tile data for Perimo
------------------------------------------------------------------------------


-- generates tiles using spritesheet width (sw), and spritesheet height (sh)
function generate_tiles(sw, sh)
  local tiles = {
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
  for i, tile in pairs(tiles) do
    if tile.should_draw ~= false then
      tiles[i].quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, sw, sh)
    end
  end
  return tiles
end

return generate_tiles
