------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base server class for perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local socket = require('socket')
local class = require('middleclass')
