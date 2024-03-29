-------------------------------------------------
-- Client-side map representation
--
-- @classmod GameMap
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Third-party Imports
local class = require 'lib.middleclass'

-- Local Imports
local Entity = require 'common.entity'
local Util = require 'common.util'
local Map = require 'common.map'
local Tiles = require 'common.tile_data'

local GameMap = class('GameMap', Map)

-------------------------------------------------
-- Initializes the tileset and generates the tiles for
-- the map on the client.
-------------------------------------------------
function GameMap:load()

  -- local w, h = self.spritesheet:getWidth(), self.spritesheet:getHeight()
  -- self.spritesheet_with_depth = self.game.lightworld:newImage(self.spritesheet, w, h)
  -- self.spritesheet_with_depth:setNormalMap(self.spritesheet_normal)
  -- local spritesheet_width, spritesheet_height = self.spritesheet:getDimensions()
  Tiles.generate_tiles(320, 320)

  -- pre render the canvas
  -- self:render_map()

  self.dirty = false -- set to true when re-rendering is needed
  self.hasnttriggered = true
  self.currentTime = 0
end

-------------------------------------------------
-- Called when the map changes
-------------------------------------------------
function GameMap:changed()
  local camera = self.superentity.camera
  for x = 0, self.width do
    for y = 0, self.height do
      if Tiles.Data[self:get_tile(x, y)].image then
        image = self.game.lightworld:newImage(Tiles.Data[self:get_tile(x, y)].image, 32 * x - 16, 32 * y - 16, 32,32)
        if Tiles.Data[self:get_tile(x, y)].normal_image then
          image:setNormalMap(Tiles.Data[self:get_tile(x, y)].normal_image)
        end
      end
    end
  end
end

-------------------------------------------------
-- Updates the current time of the map (for time based animations)
-- @tparam number dt time in seconds passed since last update
-------------------------------------------------
function GameMap:update(dt)
  self.currentTime = self.currentTime + dt
end

-------------------------------------------------
-- Draws a single tile at a tile coordinate
-- @tparam tab tile_to_draw Tiledata to draw
-- @tparam int x X-Coordinate to draw tile at
-- @tparam int y Y-Coordinate to draw tile at
-------------------------------------------------
function GameMap:drawTile(tile_to_draw, x, y)
  -- love.graphics.setColor(255 * ((x + y) % 2), 255 * ((x + y) % 2), 255 * ((x + y) % 2))
  -- love.graphics.rectangle('fill', (x - 1) * 32, (y - 1) * 32, 32, 32)
  -- love.graphics.setColor(255, 255, 255)
  -- if tile_to_draw.random then
  --   math.randomseed(x + 100 * y)
  --   randNum = math.floor(math.random() * (1 + #tile_to_draw.random))
  --   if randNum == 0 then
  --     love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
  --   else
  --     love.graphics.draw(self.spritesheet, tile_to_draw.random[randNum].quad, (x - 1) * 32, (y - 1) * 32)
  --   end
  -- else
  --   if tile_to_draw.animated then
  --     local frameNum = math.ceil(self.currentTime / tile_to_draw.animated.time_between_frames) % (#tile_to_draw.animated.frames + 1)
  --     if frameNum == 0 then
  --       love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
  --     else
  --       love.graphics.draw(self.spritesheet, tile_to_draw.animated.frames[frameNum].quad, (x - 1) * 32, (y - 1) * 32)
  --     end
  --   else
  --     love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
  --   end
  -- end
end

-------------------------------------------------
-- Draws whole map
-------------------------------------------------
function GameMap:draw()
  love.graphics.clear(255, 255, 255)
  -- local camera = self.superentity.camera
  -- local visible_tile_x = math.ceil((camera.x - love.graphics.getWidth() / 2 / camera.scale) / 32)
  -- local visible_tile_y = math.ceil((camera.y - love.graphics.getHeight() / 2 / camera.scale) / 32)
  -- local visible_tile_width = math.ceil(love.graphics.getWidth() / 32 / camera.scale)
  -- local visible_tile_height = math.ceil(love.graphics.getHeight() / 32 / camera.scale)

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
