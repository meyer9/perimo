------------------------------------------------------------------------------
--	FILE:	  main.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Entry point for Perimo server
------------------------------------------------------------------------------

local Server = require('server')
local socket = require('socket')
local network = require

local server = Server:new()

while true do
	server:update()
end
