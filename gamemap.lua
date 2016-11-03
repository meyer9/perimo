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

  gridSize = 10 -- if less than 20, strange behavior may occur.
  variance = 0
  points = {}
  triangles = {}
  numTilesRow = visible_tile_width / gridSize + 5
  numTilesCol = visible_tile_height / gridSize + 5

  local startPosY = math.ceil(visible_tile_y / gridSize) - 2
  --pointy things
  for m = startPosY,  math.ceil((visible_tile_y + visible_tile_height) / gridSize) + 2 do
    for n = math.ceil(visible_tile_x / gridSize) - 2,  math.ceil((visible_tile_x + visible_tile_width) / gridSize) + 2 do
      math.randomseed(m + 1000* n)
      table.insert(points, {n * gridSize + (m % 2) * gridSize / 2 + math.random() * variance, m * gridSize + math.random() * variance})
    end
  end

  for n = 1, #points do
    if n < #points - numTilesRow and n % numTilesRow ~= 0  and n % numTilesRow ~= 1 then
      tile_offset = (math.ceil(n / numTilesRow) % 2) + ((startPosY + 1) % 2)
      if tile_offset == 2 then tile_offset = 0 end
      -- if points[n][1] - points[n + numTilesRow - 1][1] < -400 then
      --   print(n % numTilesRow)
      -- end
      local tri1 = {points[n][1], points[n][2], points[n + 1][1], points[n + 1][2], points[n + numTilesRow + tile_offset][1], points[n + numTilesRow + tile_offset][2]}
      local tri2 = {points[n][1], points[n][2], points[n + numTilesRow + tile_offset - 1][1], points[n + numTilesRow + tile_offset - 1][2], points[n + numTilesRow + tile_offset][1], points[n + numTilesRow][2]}

      local tri1_centroid = {(tri1[1] + tri1[3] + tri1[5]) / 3 + visible_tile_x, (tri1[2] + tri1[3] + tri1[4]) / 3 + visible_tile_y}
      local tri2_centroid = {(tri2[1] + tri2[3] + tri2[5]) / 3 + visible_tile_x, (tri2[2] + tri2[3] + tri2[4]) / 3 + visible_tile_y}

      love.graphics.setColor(0,0,0)
      if self:get_tile(math.ceil(tri1_centroid[1] / gridSize), math.ceil(tri1_centroid[2] / gridSize)) == Tiles.ID.WATER then
        love.graphics.setColor(0,0,255)
      else
        love.graphics.setColor(0,255,0)
      end
      love.graphics.polygon('fill', tri1)
      love.graphics.polygon('line', tri1)
      if self:get_tile(math.ceil(tri2_centroid[1] / gridSize), math.ceil(tri2_centroid[2] / gridSize)) == Tiles.ID.WATER then
        love.graphics.setColor(0,0,255)
      else
        love.graphics.setColor(0,255,0)
      end
      love.graphics.polygon('fill', tri2)
      love.graphics.polygon('line', tri2)
      -- love.graphics.setColor(0,0,0)
      -- love.graphics.polygon('fill', tri2)
      -- love.graphics.setColor(255, 255, 255)
      -- love.graphics.polygon('line', tri2)
    end
  end
  love.graphics.setColor(255, 255, 255)
end



  -- for _, point in pairs(points) do
  --   love.graphics.points(point)
  -- end
  -- Util.print_r({{'test'}})

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

return GameMap
