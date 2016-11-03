------------------------------------------------------------------------------
--	FILE:	  multiplayer_handler.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Multiplayer handler for Perimo
------------------------------------------------------------------------------

-- Local Imports
local class = require 'middleclass'
local network = require 'affair.network'
local Entity = require 'entity'
local uuid = require 'uuid'
local util = require 'util'
local COMMANDS = require('common.commands')
local Gamestate = require('common.gamestate')
local GamestateHistory = require 'common.gamestate_history'
local messagepack = require('msgpack.MessagePack')

local Multiplayer = class('Multiplayer', Entity)

function Multiplayer:load()
  self.tickrate = self.superentity.tickrate
  self.isConnected = false
  self.gamestate_history = GamestateHistory:new()
  self.currentGamestate = Gamestate:new()
  self.tick = 0
  self.time_since_dt = socket.gettime()
  self.last_tick = 0
  self.needs_update = {}
end

function Multiplayer:connect(host, port)
  if not host then host = 'localhost' end
  if not port then port = 1337 end
  print('Connecting to ' .. host .. ':' .. port)
  self.client, err = network:startClient( host, self.superentity.player.name, port, "authed" )
  if not self.client then
    print('Failed to connect to ' .. host .. ':' .. port .. '.')
    print(err)
    os.exit()
  end
  function callConnected(...)
    self:connected(...)
  end

  function callReceived(...)
    self:received(...)
  end

  function callNewUser(...)
    self:newUser(...)
  end
  self.client.callbacks.connected = callConnected
  self.client.callbacks.received = callReceived
  self.client.callbacks.newUser = callNewUser
end

function Multiplayer:sendCommand(command, parms, udp)
  if not udp then udp = false end
  self.client:send(COMMANDS[command], parms, udp)
end

function Multiplayer:connected()
  print('Connected to server.')
  self.isConnected = true
  self.client:send(COMMANDS.handshake, nil, true)
end

function Multiplayer:received(cmd, parms)
  if cmd == COMMANDS['map'] then
    print("Loaded map...")
    self.superentity.map:deserialize(parms)
  end
  if cmd == COMMANDS.full_update then
    self.gamestate_history:newFrame(self.currentGamestate:clone())
    self.currentGamestate:deserialize(parms)
    local tick = self.currentGamestate:getObjectProp('server', 'tick')
    for entity_id, _ in pairs(messagepack.unpack(parms)) do
      table.insert(self.needs_update, entity_id)
      print(entity_id)
    end
    -- print(tick)
    if tick then self.tick = tick - 2 end
  end
  if cmd == COMMANDS.delta_update then
    self.gamestate_history:newFrame(self.currentGamestate:clone())
    self.currentGamestate:deserializeDeltaAndUpdate(parms)
    local tick = self.currentGamestate:getObjectProp('server', 'tick')
    for entity_id, _ in pairs(messagepack.unpack(parms)) do
      table.insert(self.needs_update, entity_id)
    end
    if tick then self.tick = tick - 2 end
  end
end

function Multiplayer:newUser(user)
end

function Multiplayer:update(dt)
  local dt = socket.gettime() - self.time_since_dt
  self.time_since_dt = socket.gettime()
  self.tick = self.tick + (dt * self.tickrate)
  if self.last_tick ~= math.floor(self.tick) then
    self.last_tick = math.floor(self.tick)
    print('tick')
    self.needs_update = {}
    self.game:call_mpTick()
  end
  self.client:update(dt)
end

return Multiplayer
