-------------------------------------------------
-- Keeps track of all entities sent by the server.
--
-- @classmod MultiplayerEntities
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

local class = require 'middleclass'
local Entity = require 'entity'
local MultiplayerEntity = require 'multiplayer_entity'
local MultiplayerPlayer = require 'multiplayer_player'
local util = require 'util'

local MultiplayerEntities = class('MultiplayerEntities', Entity)

-- maps type string to class
-- ex. player -> PlayerMP
ENTITY_CLASSES = {
  player = MultiplayerPlayer
}

-------------------------------------------------
-- Initializes MultiplayerEntities class
-------------------------------------------------
function MultiplayerEntities:load()
  self.entities = {}
end

-------------------------------------------------
-- Adds an entity based on server delta of the entity
-- or full update of that entity.
-- @tparam string entityUUID UUID of entity to add.
-- @tparam tab state State to update.
-------------------------------------------------
function MultiplayerEntities:addOrUpdate(entityUUID, state)
  for eUUID, e in pairs(self.entities) do
    if eUUID == entityUUID then
      self.entities[entityUUID]:updateState(state)
      return
    end
  end
  local entityClass = ENTITY_CLASSES[state.type] or MultiplayerEntity
  local entity = entityClass:new(state)
  self.entities[entityUUID] = entity
  self:addSubentity(entity)
end

return MultiplayerEntities
