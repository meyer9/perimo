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
  self.message_pieces = {}
end

function Multiplayer:connect(host, port)
  if not host then host = 'localhost' end
  if not port then port = 1337 end
  print('Connecting to ' .. host .. ':' .. port)
  self.client, err = network:startClient( host, "player" .. math.floor(math.random() * 100), port, "authed" )
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
  self.client.callbacks.connected = callConnected
  self.client.callbacks.received = callReceived
end

function Multiplayer:connected()
  print('Connected to server.')
end

function Multiplayer:received(cmd, parms)
  if cmd == COMMANDS['map'] then
    print("Loaded map...")
    self.superentity.map:deserialize(parms)
  end
  if cmd == 'playerJoin' then
  end
end

function Multiplayer:update(dt)
  self.client:update(dt)
end

return Multiplayer
