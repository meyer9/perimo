------------------------------------------------------------------------------
--	FILE:	  gamestate_history.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Class to keep track of and interpolate past game states
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require 'middleclass'
local util = require 'util'

local GamestateHistory = class('GamestateHistory')

function GamestateHistory:initialize(max_frames)
  if not max_frames then self.max_frames = 2 else self.max_frames = max_frames end
  assert(self.max_frames >= 2, "Must be greater than 2 frames for interpolation.")
  self.frames = {}
end

function GamestateHistory:newFrame(frame)
  -- util.print_r(frame._state)
  table.insert(self.frames, {frame:getObjectProp("server", "tick"), frame})
  if #self.frames > self.max_frames then
    table.remove(self.frames, 1)
  end
end

function lerp(v0, v1, t)
  return (1-t) * v0 + t * v1
end

function GamestateHistory:interpolate(entity, prop, exactTick)
  if #self.frames == self.max_frames then
    local last_frame = self.frames[self.max_frames]
    local last_frame_tick = last_frame[1]
    local last_frame_prop = last_frame[2]:getObjectProp(entity, prop)
    local two_frames_ago = self.frames[self.max_frames - 1]
    -- print(two_frames_ago[1], two_frames_ago[2])
    local two_frames_ago_tick = two_frames_ago[1]
    local two_frames_ago_prop = two_frames_ago[2]:getObjectProp(entity, prop)
    if not last_frame_prop or not two_frames_ago_prop then
      return last_frame_prop or two_frames_ago_prop
    end
    local propBetween = (exactTick - two_frames_ago_tick) / (last_frame_tick - two_frames_ago_tick)
    -- print(exactTick - two_frames_ago_tick)
    return lerp(two_frames_ago_prop, last_frame_prop, propBetween)
  elseif #self.frames == 1 then
    local frame_prop = self.frames[1].getObjectProp(prop)
    if frame_prop then return frame_prop end
  end
end

return GamestateHistory
