------------------------------------------------------------------------------
--	FILE:	  timeframe.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Helper library to provide interpolation and extrapolation for gamestate.
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local class = require 'middleclass'
local Util = require 'util'

local Timeframe = class('Timeframe')

function Timeframe:initialize(max_frames)
  self.start_time = 0
  self.last_snapshot = -1
  self.history = {}
  self.max_frames = max_frames
end

function Timeframe:snapshot(state, time)
  if not self.start_time then
    self.startTime = time
  end

  table.insert(self.history, {state = Util.clone(state), start_time = self.last_snapshot, end_time = time})

  if #self.history > self.max_frames then
    table.remove(self.history, 1)
  end

  self.last_snapshot = time
end

function Timeframe:at(time, interpolate)
  if interpolate == nil then interpolate = true end
  local i = #self.history
  local least_distance = math.huge
  local least_distance_index = 1

  while i > 0 do
    local frame = self.history[i]
    local duration = ((frame.end_time - frame.start_time) / 2) - 1

    local startDistance = math.sqrt(math.pow(time - frame.end_time - duration, 2))
    local endDistance = math.sqrt(math.pow(time - frame.end_time + duration, 2))

    if startDistance < least_distance or endDistance < least_distance or time == frame.end_time then
        least_distance = math.min( startDistance, endDistance )
        least_distance_index = i
    end
    i = i - 1
  end

  local frame = self.history[least_distance_index]
  local state = frame.state

  if interpolate and time ~= frame.end_time then
    local previousState = self:at(frame.start_time, false)
    local multiplier = 1
    if time > frame.end_time then
      multiplier = -(time - frame.end_time) / (frame.end_time - frame.start_time)
    else
      multiplier = (time - frame.start_time) / (frame.end_time - frame.start_time)
    end
    return previousState + (state - previousState) * multiplier
  end

  return state
end

return Timeframe
