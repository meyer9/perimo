-------------------------------------------------
-- Entry point for Perimo.
--
-- @module ClientMain
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

-- Local Imports
local Game = require 'client.game'

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
