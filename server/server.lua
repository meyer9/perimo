------------------------------------------------------------------------------
--	FILE:	  server.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base server class for perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local network = require('affair.network')
local class = require('middleclass')
local uuid = require('uuid')
local socket = require('socket')

local COMMANDS = require('common.commands')
local Map = require('common.map')

local Server = class('Server')

uuid.seed()

local currentClients = {}

function Server:initialize()
  local addr, port = '*', 1337
  if #arg == 1 then
    local port = arg[1]
  end

  if #arg == 2 then
    local addr = arg[1]
    local port = arg[2]
  end

  print('starting server on ' .. addr .. ':' .. port)

  -- setup udp socket
  self.server, err = network:startServer(16, port, 1)
  function callHandle(...)
    return self:handle_message(...)
  end

  function callAuth(...)
    return self:auth(...)
  end

  function callSync(...)
    return self:synchronize(...)
  end
  self.server.callbacks.received = serverReceive
  self.server.callbacks.authorize = callAuth
  self.server.callbacks.synchronize = callSync

  if not self.server then
    print('Server creation failed.')
    print(err)
    os.exit(0)
  end

  self.running = true

  self.map = Map:new(200, 200)

  print("Generating map...")
  self.map:generate_island()
  print("Finished.")

  self.time = socket.gettime()
  self.dt = 0
end

function Server:auth(user, authMsg)
  return true
end

function Server:handle_message(cmd, parms)
end

function Server:synchronize(user)
  local serialized_map = self.map:serialize()
  self.server:send(COMMANDS['map'], serialized_map, user)
end

function Server:update()
  self.server:update(self.dt)

	self.dt = socket.gettime() - self.time
	self.time = socket.gettime()

	-- This is important. Play with this value to fit your need.
	-- If you don't use this sleep command, the CPU will be used as much as possible, you'll probably run the game loop WAY more often than on the clients (who also require time to render the picture - something you don't need)
	socket.sleep( 0.05 )
end

return Server
