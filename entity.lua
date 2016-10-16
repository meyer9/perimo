------------------------------------------------------------------------------
--	FILE:	  entity.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base entity class for Perimo
------------------------------------------------------------------------------

-- Third-party imports
local class = require 'middleclass'

local Entity = class('Entity')

function Entity:initialize()
  self.subentities = {}
end

function Entity:load()
end

function Entity:update()
end

function Entity:draw()
end

function Entity:end_draw()
end

function Entity:call_load()
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      subentity:call_load()
    end
  end
  self:load()
end

function Entity:call_update(dt)
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      subentity:call_update(dt)
    end
  end
  self:update(dt)
end

function Entity:call_draw()
  self:draw()
  if self.subentities then
    for objectId, subentity in ipairs(self.subentities) do
      subentity:call_draw()
    end
  end
  self:end_draw()
end

function Entity:addSubentity(entity)
  entity.superentity = self
  table.insert(self.subentities, entity)
end

return Entity
