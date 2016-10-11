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
  for objectId, subentity in ipairs(self.subentities) do
    subentity:load()
  end
end

function Entity:update(dt)
  for objectId, subentity in ipairs(self.subentities) do
    subentity:update(dt)
  end
end

function Entity:draw()
  for objectId, subentity in ipairs(self.subentities) do
    subentity:draw()
  end
end

function Entity:addSubentity(entity)
  entity.superentity = self
  table.insert(self.subentities,entity)
end

return Entity
