-------------------------------------------------
-- Keeps track of all entities sent by the server.
--
-- @classmod MultiplayerEntities
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local Entity = require 'entity'

local MultiplayerEntities = class('MultiplayerEntities', Entity)

function MultiplayerEntities:initialize()
end

function MultiplayerEntities:update()
end

function MultiplayerEntities:draw()
end

return MultiplayerEntities
