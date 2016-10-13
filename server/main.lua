------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Entry point for Perimo server
------------------------------------------------------------------------------

local Server = require('server')

local server = Server:new()

while server.running do
  server:loop()
end
