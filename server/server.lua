------------------------------------------------------------------------------
--	FILE:	  game.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Base server class for perimo
------------------------------------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local socket = require('socket')
local class = require('middleclass')
local uuid = require('uuid')

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
  self.udp = socket.udp()
  self.udp:settimeout(0)
  self.udp:setsockname(addr, port)

  self.running = true

  self.map = Map:new(100, 100)

  self.map:generate_island()
end

function Server:loop()
  local data, msg_or_ip, port_or_nil = self.udp:receivefrom()
	if data then
		cmd, parms = data:match("^(%S*) (.*)") -- basic client -> server command functionality (entity, command, function)
    print(cmd)
    if cmd == 'handshake' then -- add authentication here
      client_uuid = uuid()
      currentClients[client_uuid] = {}
      self.udp:sendto('handshake ' .. client_uuid, msg_or_ip,  port_or_nil)
    end
    if cmd == 'map' then
      self.udp.sendto(self.map:serialize(), msg_or_ip, port_or_nil)
    end
    -- if cmd == 'map' then
  elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: " .. tostring(msg))
	end
  socket.sleep(0.001)
end

return Server
