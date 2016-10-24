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
  SAND = 2,
  WATER = 3,
  TREE = 4,
  FOLIAGE = 5,
  GRASS = 6
}

Tiles.Data = {
  [1] = {
    width = 32,
    height = 32,
    should_draw = false
  },
  [2] = {
    width = 32,
    height = 32,
    x = 128,
    y = 32,
    edges = {
      [3] = {
        t = {
          x = 128,
          y = 0
        },
        b = {
          x = 128,
          y = 64
        },
        l = {
          x = 96,
          y = 32
        },
        r = {
          x = 160,
          y = 32
        },
        tl = {
          x = 96,
          y = 0
        },
        bl = {
          x = 96,
          y = 64
        },
        tr = {
          x = 160,
          y = 0
        },
        br = {
          x = 160,
          y = 64
        },
        dbl = {
          x = 192,
          y = 32
        },
        dbr = {
          x = 224,
          y = 32
        },
        dtl = {
          x = 192,
          y = 0
        },
        dtr = {
          x = 224,
          y = 0
        },
        tblr = {
          x = 0,
          y = 32
        }
      }
    }
  },
  [3] = {
    width = 32,
    height = 32,
    x = 0,
    y = 0,
    animated = {
      frames = {
        [1] = {
          x = 32,
          y = 0
        },
        [2] = {
          x = 64,
          y = 0
        }
      },
      time_between_frames = 0.7
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
  },
  [6] = {
    x = 128,
    y = 128,
    width = 32,
    height = 32,
    edges = {
      [2] = {
        t = {
          x = 128,
          y = 96
        },
        b = {
          x = 128,
          y = 160
        },
        l = {
          x = 96,
          y = 128
        },
        r = {
          x = 160,
          y = 128
        },
        tl = {
          x = 96,
          y = 96
        },
        bl = {
          x = 96,
          y = 160
        },
        tr = {
          x = 160,
          y = 96
        },
        br = {
          x = 160,
          y = 160
        },
        dbl = {
          x = 192,
          y = 135
        },
        dbr = {
          x = 224,
          y = 135
        },
        dtl = {
          x = 192,
          y = 103
        },
        dtr = {
          x = 224,
          y = 103
        }
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
      if tile.animated then
        for n, animated_frame in pairs(tile.animated.frames) do
          Tiles.Data[i].animated.frames[n].quad = love.graphics.newQuad(animated_frame.x, animated_frame.y, tile.width, tile.height, sw, sh)
        end
      end
    end
  end
end

function Tiles.tile(id)
  return Tiles.Data[Tiles.ID[id]]
end

return Tiles
