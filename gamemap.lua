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
end

function GameMap:changed()
  self.dirty = true
end

function GameMap:update(dt)
end

function GameMap:draw()
  local camera = self.superentity.camera
  local visible_tile_x = math.ceil((camera.x - love.graphics.getWidth() / 4) / 16)
  local visible_tile_y = math.ceil((camera.y - love.graphics.getHeight() / 4) / 16)
  local visible_tile_width = math.ceil(love.graphics.getWidth() / 16 / camera.scale)
  local visible_tile_height = math.ceil(love.graphics.getHeight() / 16 / camera.scale)
  for x = visible_tile_x, visible_tile_x + visible_tile_width do
    for y = visible_tile_y, visible_tile_y + visible_tile_height do
      tile_to_draw = Tiles.Data[self:get_tile(x, y)]
      if tile_to_draw.should_draw ~= false then
        adjCode = ""
        if not tile_to_draw.edges then
          if tile_to_draw.random then
            math.randomseed(x + 100 * y)
            randNum = math.floor(math.random() * (1 + #tile_to_draw.random))
            if randNum == 0 then
              love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
            else
              love.graphics.draw(self.spritesheet, tile_to_draw.random[randNum].quad, (x - 1) * 16, (y - 1) * 16)
            end
          else
            love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
          end
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
            love.graphics.draw(self.spritesheet, tile_to_draw.edges[tile][adjCode].quad, (x - 1) * 16, (y - 1) * 16)
          else
            if #adjCode > 0 then
              print(adjCode)
            end
            love.graphics.draw(self.spritesheet, tile_to_draw.quad, (x - 1) * 16, (y - 1) * 16)
          end
        end
      end
    end
  end
end

return GameMap
