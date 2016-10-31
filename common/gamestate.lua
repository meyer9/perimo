------------------------------------------------------------------------------
--	FILE:	  gamestate.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Representation of game state on server
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require('middleclass')
local uuid = require('uuid')
local util = require('util')
local messagepack = require('msgpack.MessagePack')

local Gamestate = class('Gamestate')

function Gamestate:initialize()
  self._state = {}
  self.updated = false
end

function Gamestate:serialize()
  -- util.print_r(self._state)
  return messagepack.pack(self._state)
end

function Gamestate:deserialize(packed_state)
  -- print(packed_state)
  self._state = messagepack.unpack(packed_state)
  self.updated = true
end

function Gamestate:delta(old_gamestate)
  local old_state = old_gamestate._state
  local delta = {}
  for k, v in pairs(self._state) do
    for key, value in pairs(v) do
      -- print(k, key, value)
      if not old_state[k] or old_state[k][key] ~= self._state[k][key] then
        if not delta[k] then delta[k] = {} end
        delta[k][key] = self._state[k][key]
      end
    end
  end
  return delta
end

function Gamestate:deltaSerialize(old_gamestate)
  local delta = self:delta(old_gamestate)
  return messagepack.pack(delta)
end

function Gamestate:deserializeDelta(delta_str)
  return messagepack.unpack(delta_str)
end

function Gamestate:deserializeDeltaAndUpdate(delta_str)
  local delta = self:deserializeDelta(delta_str)
  self:deltaUpdate(delta)
end

function Gamestate:deltaUpdate(delta)
  for entity_uuid, props in pairs(delta) do
    for prop, val in pairs(props) do
      if self._state[entity_uuid] == nil then self._state[entity_uuid] = {} end
      self._state[entity_uuid][prop] = val
    end
  end
end

function Gamestate:updateState(objectID, prop, state)
  self._state[objectID][prop] = state
end

function Gamestate:getObjectProp(objectID, prop)
  return self._state[objectID][prop]
end

function Gamestate:clone()
  local new_gamestate = Gamestate:new()
  new_gamestate._state = util.clone(self._state)
  return new_gamestate
end

function Gamestate:addObject()
  objectUUID = uuid()
  self._state[objectUUID] = {}
  return objectUUID
end

return Gamestate
