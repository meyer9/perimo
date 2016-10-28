------------------------------------------------------------------------------
--	FILE:	  gamemap.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Map drawing code for Perimo
------------------------------------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Util = require 'util'
local Map = require 'common.map'
local Tiles = require 'common.tile_data'

local GameMap = class('GameMap', Map)

function GameMap:load()
  -- load spritesheet data
  self.spritesheet = love.graphics.newImage("spritesheet.png")
  local spritesheet_width, spritesheet_height = self.spritesheet:getDimensions()
  Tiles.generate_tiles(spritesheet_width, spritesheet_height)

  -- pre render the canvas
  -- self:render_map()

  self.dirty = false -- set to true when re-rendering is needed
  self.hasnttriggered = true
  self.currentTime = 0
end

function GameMap:changed()
  self.dirty = true
end

function GameMap:update(dt)
  self.currentTime = self.currentTime + dt
end

-- function GameMap:drawTile(tile_to_draw, x, y)
--   gridSize = 8
--   variance = 0.4
--   points = {}
--   for n=1, 32 / gridSize do
--     for m = 1, 32 / gridSize do
--       math.randomseed(n + x * 100 + y * 1000 + m * 100000)
--       table.insert(points, (x - 1) * 32 + m * gridSize + (n % 2) * gridSize / 2 + ((0.5 - math.random()) * gridSize * variance * 2), (y - 1) * 32 + n * gridSize + ((0.5 - math.random()) * gridSize * variance * 2))
--     end
--   end
--
--   for n = 1, points.length - 32 / gridSize
--   if (((n + 1)/(1 + (sizeX + 2 * gridSize)/gridSize)) % 2 == 0 && n / ((sizeX + 2 * gridSize)/gridSize + 1) % 2 == 0)
--   {
--       tris = addTri(tris, new Triangle(points[n],points[n + 1],points[n + (sizeX + 2 * gridSize)/gridSize + 2]));
--       tris = addTri(tris, new Triangle(points[n],points[n + (sizeX + 2 * gridSize)/gridSize + 1],points[n + (sizeX + 2 * gridSize)/gridSize + 2]));
--   }
--   else if (((n + 1)/(1 + (sizeX + 2 * gridSize)/gridSize)) % 2 == 1 && n / ((sizeX + 2 * gridSize)/gridSize + 1) % 2 == 1)
--   {
--       tris = addTri(tris, new Triangle(points[n],points[n + 1],points[n + (sizeX + 2 * gridSize)/gridSize + 1]));
--       tris = addTri(tris, new Triangle(points[n + 1],points[n + (sizeX + 2 * gridSize)/gridSize + 1],points[n + (sizeX + 2 * gridSize)/gridSize + 2]));
--   }
--
--   table.graphics.points(points)
--   -- if tile_to_draw.random then
--   --   math.randomseed(x + 100 * y)
--   --   randNum = math.floor(math.random() * (1 + #tile_to_draw.random))
--   --   if randNum == 0 then
--   --     love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
--   --   else
--   --     love.graphics.draw(self.spritesheet, tile_to_draw.random[randNum].quad, (x - 1) * 32, (y - 1) * 32)
--   --   end
--   -- else
--   --   if tile_to_draw.animated then
--   --     local frameNum = math.ceil(self.currentTime / tile_to_draw.animated.time_between_frames) % (#tile_to_draw.animated.frames + 1)
--   --     if frameNum == 0 then
--   --       love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
--   --     else
--   --       love.graphics.draw(self.spritesheet, tile_to_draw.animated.frames[frameNum].quad, (x - 1) * 32, (y - 1) * 32)
--   --     end
--   --   else
--   --     love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
--   --   end
--   -- end
-- end

function GameMap:draw()
  local camera = self.superentity.camera
  local visible_tile_x = math.ceil((camera.x - love.graphics.getWidth() / 2 / camera.scale))
  local visible_tile_y = math.ceil((camera.y - love.graphics.getHeight() / 2 / camera.scale))
  local visible_tile_width = math.ceil(love.graphics.getWidth() / camera.scale)
  local visible_tile_height = math.ceil(love.graphics.getHeight() / camera.scale)
  gridSize = 20 -- if less than 20, strange behavior may occur.
  variance = 0.4
  points = {}
  triangles = {}
  numTilesRow = math.ceil((visible_tile_x + visible_tile_width + gridSize * 2) / gridSize) - math.ceil((visible_tile_x - gridSize * 2) / gridSize)
  numTilesCol = math.ceil((visible_tile_y + visible_tile_height + gridSize * 2) / gridSize) - math.ceil((visible_tile_y - gridSize * 2) / gridSize)

  --pointy things
  math.randomseed(gridSize * 100/variance)
  for m = math.ceil((visible_tile_y - gridSize * 3) / gridSize),  math.ceil((visible_tile_y + visible_tile_width + gridSize * 3) / gridSize) do
    for n = math.ceil((visible_tile_x - gridSize * 3) / gridSize),  math.ceil((visible_tile_x + visible_tile_height + gridSize * 3) / gridSize) do
      table.insert(points, {n * gridSize + (m % 2) * gridSize / 2 , m * gridSize})
    end
  end
  local sizeX = visible_tile_width
  local sizeY = visible_tile_height

  -- math.randomseed(1)

  fixer = 0

  for f = -3, 3 do
    if points[3 + numTilesRow + f][1] > points[3][1] and points[3 + numTilesRow + f][1] < points[4][1] then
      fixer = f
    end
  end

  for n = 1, #points - numTilesRow - 2 do
    if math.abs(points[n][1]-points[n+1][1]) <= gridSize and
       math.abs(points[n+1][1]-points[n + numTilesRow + fixer][1]) <= 2 * gridSize then

      if math.floor((n)/(numTilesRow -2) % 2) ~= 1 then
        table.insert(triangles, {points[n][1], points[n][2], points[n+1][1], points[n+1][2],points[n + numTilesRow + fixer][1], points[n + numTilesRow + fixer][2]})
      else
        table.insert(triangles, {points[n][1], points[n][2], points[n+1][1], points[n+1][2],points[n + numTilesRow + fixer + 1][1], points[n + numTilesRow + fixer + 1][2]})
      end
    end
  end

  for _, point in pairs(points) do
    love.graphics.points(point)
  end
  -- Util.print_r({{'test'}})

  for _, triangle in pairs(triangles) do
    love.graphics.polygon('fill', triangle)
  end

  --
  -- for n=1, 32 / gridSize do
  --   for m = 1, 32 / gridSize do
  --     math.randomseed(n + x * 100 + y * 1000 + m * 100000)
  --     table.insert(points, (x - 1) * 32 + m * gridSize + (n % 2) * gridSize / 2 + ((0.5 - math.random()) * gridSize * variance * 2), (y - 1) * 32 + n * gridSize + ((0.5 - math.random()) * gridSize * variance * 2))
  --   end
  -- end
  -- for x = visible_tile_x, visible_tile_x + visible_tile_width do
  --   for y = visible_tile_y, visible_tile_y + visible_tile_height do
  --     tile_to_draw = Tiles.Data[self:get_tile(x, y)]
  --     if tile_to_draw.should_draw ~= false then
  --       adjCode = ""
  --       if not tile_to_draw.edges then
  --         self:drawTile(tile_to_draw, x, y)
  --       else
  --         edges = tile_to_draw.edges
  --         adjCode = ""
  --         tile = nil
  --         if edges[self:get_tile(x, y - 1)] then
  --           adjCode = adjCode .. 't'
  --           tile = self:get_tile(x, y - 1)
  --         end
  --         if edges[self:get_tile(x, y + 1)] and (tile == nil or tile == self:get_tile(x, y + 1)) then
  --           adjCode = adjCode .. 'b'
  --           tile = self:get_tile(x, y + 1)
  --         end
  --         if edges[self:get_tile(x - 1, y)] and (tile == nil or tile == self:get_tile(x - 1, y)) then
  --           adjCode = adjCode .. 'l'
  --           tile = self:get_tile(x - 1, y)
  --         end
  --         if edges[self:get_tile(x + 1, y)] and (tile == nil or tile == self:get_tile(x + 1, y)) then
  --           adjCode = adjCode .. 'r'
  --           tile = self:get_tile(x + 1, y)
  --         end
  --         if edges[self:get_tile(x - 1, y - 1)] and #adjCode == 0 then
  --           adjCode = 'dtl'
  --           tile = self:get_tile(x - 1, y - 1)
  --         end
  --         if edges[self:get_tile(x + 1, y - 1)] and #adjCode == 0 then
  --           adjCode = 'dtr'
  --           tile = self:get_tile(x + 1, y - 1)
  --         end
  --         if edges[self:get_tile(x - 1, y + 1)] and #adjCode == 0 then
  --           adjCode = 'dbl'
  --           tile = self:get_tile(x - 1, y + 1)
  --         end
  --         if edges[self:get_tile(x + 1, y + 1)] and #adjCode == 0 then
  --           adjCode = 'dbr'
  --           tile = self:get_tile(x + 1, y + 1)
  --         end
  --         if tile and adjCode and tile_to_draw.edges[tile][adjCode] then
  --           self:drawTile(Tiles.Data[tile], x, y)
  --           self:drawTile(tile_to_draw.edges[tile][adjCode], x, y)
  --         else
  --           self:drawTile(tile_to_draw, x, y)
  --         end
  --       end
  --       -- print(tile_to_draw)
  --     end
  --   end
  -- end
  -- for x = visible_tile_x, visible_tile_x + visible_tile_width do
  --   for y = visible_tile_y, visible_tile_y + visible_tile_height do
  --     if self:get_tile(x, y) == Tiles.ID.SAND then
  --       can_place = true
  --       if self:get_tile(x, y - 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x, y + 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x - 1, y) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x + 1, y) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x - 1, y - 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x + 1, y - 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x - 1, y + 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       if self:get_tile(x + 1, y + 1) == Tiles.ID.WATER then
  --         can_place = false
  --       end
  --       math.randomseed(x + y * 100)
  --       if math.random() < 0.1 then -- foliage
  --         foliage_tile = Tiles.Data[Tiles.ID.FOLIAGE]
  --         randNum = math.floor(math.random() * (1 + #foliage_tile.random))
  --         if randNum == 0 then
  --           love.graphics.draw(self.spritesheet, foliage_tile.quad, (x - 1) * 32, (y - 1) * 32)
  --         else
  --           love.graphics.draw(self.spritesheet, foliage_tile.random[randNum].quad, (x - 1) * 32, (y - 1) * 32)
  --         end
  --       end
  --       if math.random() < 0.01 and can_place then -- trees
  --         love.graphics.draw(self.spritesheet, Tiles.Data[Tiles.ID.TREE].quad, (x - 1) * 32, (y - 1) * 32)
  --       end
  --     end
  --   end
  -- end
end

return GameMap
