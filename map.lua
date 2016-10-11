------------------------------------------------------------------------------
--	FILE:	  map.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Map representation for Perimo
------------------------------------------------------------------------------

-- Third-party Imports
local class = require 'middleclass'

-- Local Imports
local Entity = require 'entity'


local Map = class('Map', Entity)

function Map:initialize()
end

function Map:load()
end

function Map:update(dt)
end

function Map:draw()
end

return Map
