-------------------------------------------------
-- Main entry point for Perimo server.
--
-- @module ServerMain
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local Server = require('server')
local socket = require('socket')
local network = require

local server = Server:new()

while true do
	server:update()
end
