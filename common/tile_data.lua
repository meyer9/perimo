-------------------------------------------------
-- Tile data for Perimo.
--
-- @classmod TileData
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local Tiles = {}
-- EDIT ONLY BETWEEN HERE

Tiles.ID = {
  EMPTY = 0,
  TILE = 1,
  WALL_HORIZ = 2,
  WALL_VERT = 3
}

Tiles.Data = {
  [0] = {
    width = 32,
    height = 32,
    should_draw = false
  },
  [1] = {
    width = 32,
    height = 32,
    x = 0,
    y = 0,
    normal = true
  },
  [2] = {
    width = 32,
    height = 32,
    x = 32,
    y = 0,
    random = {
      [1] = {
        x = 64,
        y = 0,
        normal = true
      }
    },
    normal = true
  },
  [3] = {
    width = 32,
    height = 32,
    x = 0,
    y = 32,
    normal = true,
    random = {
      [1] = {
        x = 0,
        y = 64,
        normal = true
      }
    }
  }
}
-- AND HERE


-------------------------------------------------
-- Generates quads for each tile in tile data and
-- sets it to the quad property of that tile.
-- @tparam int sw Spritesheet width
-- @tparam int sh Spritesheet height
-------------------------------------------------
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

-------------------------------------------------
-- Gets tiledata for a specific tile id.
-- @tparam int id Tile ID to retrieve.
-------------------------------------------------
function Tiles.tile(id)
  return Tiles.Data[Tiles.ID[id]]
end

return Tiles
