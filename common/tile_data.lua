------------------------------------------------------------------------------
--	FILE:	  tile_data.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  To provide tile data for Perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local Tiles = {}
-- EDIT ONLY BETWEEN HERE

Tiles.ID = {
  EMPTY = 1,
  GRASS = 2,
  WATER = 3,
  TREE = 4,
  FOLIAGE = 5
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
    y = 0,
    random = {
      [1] = {
        x = 85,
        y = 17
      }
    }
  },
  [3] = {
    width = 16,
    height = 16,
    x = 0,
    y = 0,
    edges = {
      [2] = {
        tl = {
          x = 34,
          y = 0
        },
        t = {
          x = 51,
          y = 0
        },
        tr = {
          x = 68,
          y = 0
        },
        r = {
          x = 68,
          y = 17
        },
        br = {
          x = 68,
          y = 34
        },
        b = {
          x = 51,
          y = 34
        },
        bl = {
          x = 34,
          y = 34
        },
        l = {
          x = 34,
          y = 17
        },
        dbl = {
          x = 17,
          y = 17
        },
        dbr = {
          x = 0,
          y = 17
        },
        dtl = {
          x = 17,
          y = 34
        },
        dtr = {
          x = 0,
          y = 34
        },
        tbl = {
          x = 119,
          y = 0
        },
        tbr = {
          x = 102,
          y = 17
        },
        tlr = {
          x = 119,
          y = 17
        },
        blr = {
          x = 102,
          y = 0
        },
        tb = {
          x = 85,
          y = 34
        },
        lr = {
          x = 102,
          y = 34
        }
      }
    }
  },
  [4] = {
    width = 51,
    height = 51,
    x = 1,
    y = 51,
  },
  [5] = {
    x = 52,
    y = 51,
    width = 14,
    height = 20,
    random = {
      [1] = {
        x = 64,
        y = 51
      },
      [2] = {
        x = 88,
        y = 51
      }
    }
  }
}
-- AND HERE


-- generates tiles using spritesheet width (sw), and spritesheet height (sh)
function Tiles.generate_tiles(sw, sh)
  for i, tile in pairs(Tiles.Data) do
    if type(tile) ~= 'function' and tile.should_draw ~= false then
      Tiles.Data[i].quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, sw, sh)
      if tile.edges then
        for n, edge_tile in pairs(tile.edges) do
          for z, edge_tile_permutation in pairs(edge_tile) do
            Tiles.Data[i].edges[n][z].quad = love.graphics.newQuad(edge_tile_permutation.x, edge_tile_permutation.y, tile.width, tile.height, sw, sh)
          end
        end
      end
      if tile.random then
        for n, random_tile in pairs(tile.random) do
          Tiles.Data[i].random[n].quad = love.graphics.newQuad(random_tile.x, random_tile.y, tile.width, tile.height, sw, sh)
        end
      end
    end
  end
end

function Tiles.tile(id)
  return Tiles.Data[Tiles.ID[id]]
end

return Tiles
