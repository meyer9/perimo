------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base game class for Perimo
------------------------------------------------------------------------------

-- Third-party Libraries
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'
local Map = require 'map'


local Game = class('Game', Entity)

function Game:initialize()
  Entity.initialize(self)
  local map = Map:new()
  self:addSubentity(map)
end

function Game:load()
end

function Game:update(dt)
end

function Game:draw()
end

return Game
