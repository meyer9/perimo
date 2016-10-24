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

function GameMap:drawTile(tile_to_draw, x, y)
  if tile_to_draw.random then
    math.randomseed(x + 100 * y)
    randNum = math.floor(math.random() * (1 + #tile_to_draw.random))
    if randNum == 0 then
      love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
    else
      love.graphics.draw(self.spritesheet, tile_to_draw.random[randNum].quad, (x - 1) * 32, (y - 1) * 32)
    end
  else
    if tile_to_draw.animated then
      local frameNum = math.ceil(self.currentTime / tile_to_draw.animated.time_between_frames) % (#tile_to_draw.animated.frames + 1)
      if frameNum == 0 then
        love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
      else
        love.graphics.draw(self.spritesheet, tile_to_draw.animated.frames[frameNum].quad, (x - 1) * 32, (y - 1) * 32)
      end
    else
      love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 32, (y - 1) * 32)
    end
  end
end

function GameMap:draw()
  local camera = self.superentity.camera
  local visible_tile_x = math.ceil((camera.x - love.graphics.getWidth() / 2 / camera.scale) / 32)
  local visible_tile_y = math.ceil((camera.y - love.graphics.getHeight() / 2 / camera.scale) / 32)
  local visible_tile_width = math.ceil(love.graphics.getWidth() / 32 / camera.scale)
  local visible_tile_height = math.ceil(love.graphics.getHeight() / 32 / camera.scale)
  for x = visible_tile_x, visible_tile_x + visible_tile_width do
    for y = visible_tile_y, visible_tile_y + visible_tile_height do
      tile_to_draw = Tiles.Data[self:get_tile(x, y)]
      if tile_to_draw.should_draw ~= false then
        adjCode = ""
        if not tile_to_draw.edges then
          self:drawTile(tile_to_draw, x, y)
        else
          edges = tile_to_draw.edges
          adjCode = ""
          tile = nil
          if edges[self:get_tile(x, y - 1)] then
            adjCode = adjCode .. 't'
            tile = self:get_tile(x, y - 1)
          end
          if edges[self:get_tile(x, y + 1)] and (tile == nil or tile == self:get_tile(x, y + 1)) then
            adjCode = adjCode .. 'b'
            tile = self:get_tile(x, y + 1)
          end
          if edges[self:get_tile(x - 1, y)] and (tile == nil or tile == self:get_tile(x - 1, y)) then
            adjCode = adjCode .. 'l'
            tile = self:get_tile(x - 1, y)
          end
          if edges[self:get_tile(x + 1, y)] and (tile == nil or tile == self:get_tile(x + 1, y)) then
            adjCode = adjCode .. 'r'
            tile = self:get_tile(x + 1, y)
          end
          if edges[self:get_tile(x - 1, y - 1)] and #adjCode == 0 then
            adjCode = 'dtl'
            tile = self:get_tile(x - 1, y - 1)
          end
          if edges[self:get_tile(x + 1, y - 1)] and #adjCode == 0 then
            adjCode = 'dtr'
            tile = self:get_tile(x + 1, y - 1)
          end
          if edges[self:get_tile(x - 1, y + 1)] and #adjCode == 0 then
            adjCode = 'dbl'
            tile = self:get_tile(x - 1, y + 1)
          end
          if edges[self:get_tile(x + 1, y + 1)] and #adjCode == 0 then
            adjCode = 'dbr'
            tile = self:get_tile(x + 1, y + 1)
          end
          if tile and adjCode and tile_to_draw.edges[tile][adjCode] then
            self:drawTile(Tiles.Data[tile], x, y)
            self:drawTile(tile_to_draw.edges[tile][adjCode], x, y)
          else
            self:drawTile(tile_to_draw, x, y)
          end
        end
        -- print(tile_to_draw)
      end
    end
  end
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
