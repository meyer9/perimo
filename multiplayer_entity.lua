-------------------------------------------------
-- Represents an entity sent by the server.
--
-- @classmod MultiplayerEntity
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local Entity = require 'entity'
local util = require 'util'

log = require 'common.log'

local MultiplayerEntity = class('MultiplayerEntity', Entity)

-------------------------------------------------
-- Initializes a multiplayer entity with a state
-- @tparam tab state State to update using.
-------------------------------------------------
function MultiplayerEntity:initialize(state)
  Entity.initialize(self)
  if state then self:updateState(state) end
end

-------------------------------------------------
-- Updates the entities state based on a delta sent
-- by the server, or the entire entity state.
-- @tparam tab state State to update using.
-------------------------------------------------
function MultiplayerEntity:updateState(state)
  log.warn('Not implemented: ' .. state.type)
end

return MultiplayerEntity
