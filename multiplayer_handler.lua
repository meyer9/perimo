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
local COMMANDS = require('common.commands')

local Multiplayer = class('Multiplayer', Entity)

function Multiplayer:load()
  self.tick = 0
  self.tickrate = self.superentity.tickrate
  self.isConnected = false
  self.total_time = 0
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

function Multiplayer:connected()
  print('Connected to server.')
  self.isConnected = true
end

function Multiplayer:received(cmd, parms)
  if cmd == COMMANDS['map'] then
    print("Loaded map...")
    self.superentity.map:deserialize(parms)
  end
  -- not needed unless attribute is not covered by synchronization

  -- if cmd == COMMANDS['player_at'] then
  --   local player_id, x, y = parms:match("(%d+),(%d+),(%d+)")
  --   self.superentity.multiplayer_players:runCommand(player_id, cmd, {x=x, y=y})
  -- end
end

function Multiplayer:newUser(user)
  print(user.id, self.client.clientID)
  if user.id ~= self.client.clientID then
    self.superentity.multiplayer_players:playerJoin(user)
  end
end

function Multiplayer:update(dt)
  self.total_time = self.total_time + dt
  if self.isConnected then
    if self.total_time - (self.tick / self.tickrate) > 1 / self.tickrate then
      self.tick = self.tick + 1
      self.superentity:call_mpTick()
    end
  end
  self.client:update(dt)
end

return Multiplayer
