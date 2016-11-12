-------------------------------------------------
-- Class to keep track of gamestate objects and
-- transferred between client and server
--
-- @classmod Gamestate
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require('middleclass')
local uuid = require('uuid')
local util = require('util')
local messagepack = require('msgpack.MessagePack')

local Gamestate = class('Gamestate')

-------------------------------------------------
-- Constructor function of Gamestate class
--
-- @tparam int tick the tick from which the gamestate was taken
-------------------------------------------------
function Gamestate:initialize(tick)
  self._state = {server = {tick = 0}}
  self.updated = false
end

-------------------------------------------------
-- Serialize the gamestate into a string to send
-- to the server
--
-- @treturn string serialized gamestate
-------------------------------------------------
function Gamestate:serialize()
  -- util.print_r(self._state)
  return messagepack.pack(self._state)
end

-------------------------------------------------
-- Deserialize string into a gamestate
--
-- @tparam string packed_state Serialized gamestate
-------------------------------------------------
function Gamestate:deserialize(packed_state)
  -- print(packed_state)
  self._state = messagepack.unpack(packed_state)
  self.updated = true
end

-------------------------------------------------
-- Helper function to get the current tick of a
-- gamestate
--
-- @treturn int Current tick
-------------------------------------------------
function Gamestate:getTick()
  local tick = self:getObjectProp('server', 'tick')
  return tick
end

-------------------------------------------------
-- Calculate a delta between two gamestates using
-- itself as the new gamestate
--
-- @tparam Gamestate old_gamestate Gamestate to calculate delta from
-- @treturn tab delta
-------------------------------------------------
function Gamestate:delta(old_gamestate)
  local old_state = old_gamestate._state
  local delta = {}
  for k, v in pairs(self._state) do
    for key, value in pairs(v) do
      if not old_state[k] or old_state[k][key] ~= self._state[k][key] then
        if not delta[k] then delta[k] = {} end
        delta[k][key] = self._state[k][key]
      end
    end
  end
  if #old_state ~= #self._state then
    for k, v in pairs(old_state) do
      if old_gamestate[k] and not self._state[k] then
        delta[k] = "remove"
      end
    end
  end
  return delta
end

-------------------------------------------------
-- Calculate a delta between two gamestates, then
-- serialize that delta
--
-- @tparam Gamestate old_gamestate Gamestate to calculate delta from
-- @treturn string delta
-------------------------------------------------
function Gamestate:deltaSerialize(old_gamestate)
  local delta = self:delta(old_gamestate)
  return messagepack.pack(delta)
end

-------------------------------------------------
-- Deserialize a delta ** does not apply it **
--
-- @tparam string delta_str String to deserialize delta from
-- @treturn tab delta
-------------------------------------------------
function Gamestate:deserializeDelta(delta_str)
  return messagepack.unpack(delta_str)
end

-------------------------------------------------
-- Apply a serialized delta to the current gamestate
--
-- @tparam string delta_str String to deserialize delta from
-------------------------------------------------
function Gamestate:deserializeDeltaAndUpdate(delta_str)
  local delta = self:deserializeDelta(delta_str)
  self:deltaUpdate(delta)
end

-------------------------------------------------
-- Update state using delta
--
-- @tparam tab delta Delta to update using
-------------------------------------------------
function Gamestate:deltaUpdate(delta)
  for entity_uuid, props in pairs(delta) do
    if props == "remove" then
      self._state[entity_uuid] = nil
    else
      for prop, val in pairs(props) do
        if self._state[entity_uuid] == nil then self._state[entity_uuid] = {} end
        self._state[entity_uuid][prop] = val
      end
    end
  end
end

-------------------------------------------------
-- Update property in gamestate. If object doesn't exist,
-- create it.
--
-- @tparam string objectID object UUID to update
-- @tparam string prop property to update
-- @param state state to change the property to
-------------------------------------------------
function Gamestate:updateState(objectID, prop, state)
  if not self._state[objectID] then self._state[objectID] = {} end
  self._state[objectID][prop] = state
end

-------------------------------------------------
-- Gets the property of an object if it exists, otherwise
-- returns nil
--
-- @tparam string objectID object UUID to retrieve
-- @tparam string prop property to retrieve
-- @return property value of object
-------------------------------------------------
function Gamestate:getObjectProp(objectID, prop)
  if self._state[objectID] and self._state[objectID][prop] then
    return self._state[objectID][prop]
  else
    return nil
  end
end

-------------------------------------------------
-- Deep clone the current object
--
-- @treturn Gamestate cloned gamestate
-------------------------------------------------
function Gamestate:clone()
  local new_gamestate = Gamestate:new()
  new_gamestate._state = util.clone(self._state)
  return new_gamestate
end

-------------------------------------------------
-- Adds and object to the state and returns its
-- UUID.
--
-- @tparam string type type of object to create
-- @treturn UUID of newly created object
-------------------------------------------------
function Gamestate:addObject(type)
  objectUUID = uuid()
  self._state[objectUUID] = {type=type}
  return objectUUID
end

function Gamestate:removeFromState(uuid)
  self._state[uuid] = nil
end

return Gamestate
