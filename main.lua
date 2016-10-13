------------------------------------------------------------------------------
--	FILE:	  main.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Main game entry point for Perimo
------------------------------------------------------------------------------

-- Local Imports
local Game = require 'Game'

local main_game = Game:new()

function love.load()
  main_game:call_load()
end

function love.update(dt)
   main_game:call_update(dt)
end

function love.draw()
  main_game:call_draw()
end