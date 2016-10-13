------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base game class for Perimo
------------------------------------------------------------------------------

-- Third-party Libraries
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local GameMap = require 'gamemap'
local Multiplayer = require 'multiplayer_handler'


local Game = class('Game', Entity)

function Game:initialize()
  Entity.initialize(self)
  love.graphics.setDefaultFilter('nearest', 'nearest')

  local map = GameMap:new()
  self:addSubentity(map)

  self.multiplayer = Multiplayer:new()
  self.multiplayer:connect()
end

function Game:load()
end

function Game:update(dt)
  self.multiplayer:update()
end

function Game:draw()
end

return Game