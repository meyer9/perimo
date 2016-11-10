-------------------------------------------------
-- Base entity class for Perimo
--
-- @classmod Animation
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

-- Third-party imports
local class = require 'middleclass'

local Entity = class('Entity')

-------------------------------------------------
-- Initializes a new entity
-------------------------------------------------
function Entity:initialize()
  self.subentities = {}
end

-------------------------------------------------
-- Hook to be called when entity is loaded
-------------------------------------------------
function Entity:load()
end

-------------------------------------------------
-- Hook to be called when entity is updated
-- @tparam number dt the number of frames that have passed since the last update
-------------------------------------------------
function Entity:update(dt)
end

-------------------------------------------------
-- Hook to be called when the entity is drawn
-------------------------------------------------
function Entity:draw()
end

-------------------------------------------------
-- Hook to be called after the entity is drawn
-------------------------------------------------
function Entity:end_draw()
end

-------------------------------------------------
-- Hook to be called every mpTick
-------------------------------------------------
function Entity:mpTick()
end

-------------------------------------------------
-- Call the load hook
-------------------------------------------------
function Entity:call_load()
  self:load()
end

-------------------------------------------------
-- Call the update hook for self and all subentities (calling self first then all subentities)
-- @tparam number dt time in seconds that has passed since last update
-------------------------------------------------
function Entity:call_update(dt)
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      if subentity ~= nil then
        subentity:call_update(dt)
      end
    end
  end
  self:update(dt)
end

-------------------------------------------------
-- Call the draw hook for self and all subentities (calling self first, all subentities, then end_draw on self)
-------------------------------------------------
function Entity:call_draw()
  self:draw()
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      if subentity ~= nil then
        subentity:call_draw()
      end
    end
  end
  self:end_draw()
end

-------------------------------------------------
-- Add a subentity which will receive calls from self
-- @tparam Entity entity the entity to add
-------------------------------------------------
function Entity:addSubentity(entity)
  entity.superentity = self
  local foundGame = false
  local gameCandidate = self
  if self.game == nil then
    while foundGame == false do
      if gameCandidate.superentity ~= nil then
        gameCandidate = entity.superentity
      else
        foundGame = true
      end
    end
  else
    gameCandidate = self.game
  end
  entity.game = gameCandidate
  table.insert(self.subentities, entity)
  entity:load()
end

-------------------------------------------------
-- Calls the multiplayer tick hook for self and
-- all subentities (calling self first then all subentities)
-------------------------------------------------
function Entity:call_mpTick()
  self:mpTick()
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      if subentity ~= nil then
        subentity:call_mpTick()
      end
    end
  end
end

return Entity
