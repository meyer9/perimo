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

local Multiplayer = class('Multiplayer', Entity)

function Multiplayer:load()
  self.start_tick = socket.gettime()
  self.tickrate = self.superentity.tickrate
  self.isConnected = false
  self.time_until_next_tick = 0
  self.previous_game_states = {}
  self.currentGamestate = Gamestate:new()
  self.max_gamestate_history = 2
end

function Multiplayer:getFractionalTick()
  return self.client.tick + ((socket.gettime() - self.start_tick) / 1000000)
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
    table.insert(self.previous_game_states, self.currentGamestate:clone())
    if #self.previous_game_states > self.max_gamestate_history then
      table.remove(self.previous_game_states, 1)
    end
    self.currentGamestate:deserialize(parms)
  end
  if cmd == COMMANDS.delta_update then
    table.insert(self.previous_game_states, self.currentGamestate:clone())
    if #self.previous_game_states > self.max_gamestate_history then
      table.remove(self.previous_game_states, 1)
    end
    self.currentGamestate:deserializeDeltaAndUpdate(parms)
    -- util.print_r(self.currentGamestate._state)
  end
end

function Multiplayer:newUser(user)
  -- if user.id ~= self.client.clientID then
  --   self.superentity.multiplayer_players:playerJoin(user)
  -- end
end

function Multiplayer:update(dt)
  self.time_until_next_tick = self.time_until_next_tick - dt
  if self.isConnected then
    if self.time_until_next_tick <= 0 then
      self.client.tick = self.client.tick + 1
      self.start_tick = socket.gettime()
      self.time_until_next_tick = 1 / self.tickrate
      -- util.print_r(self.currentGamestate._state)
      self.game:call_mpTick()
    end
  end
  self.client:update(dt)
end

return Multiplayer
