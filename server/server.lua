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

  print("Generating map...")
  self.map:generate_island()
  print("Finished.")

  self.message_pieces = {}
end

function Server:send(message, ip, port)
  local numPieces = math.ceil(#message / 7000)
  local sent = 0
  local length = math.ceil(#message / numPieces)
  local uuid_msg = uuid()
  if numPieces == 1 then
    self.udp:sendto(uuid_msg .. " 1 1 " .. message, ip, port)
    return
  end
  for i = 0, numPieces - 1 do
    if i == numPieces - 1 then
      self.udp:sendto(uuid_msg .. " " .. i + 1 .. " " .. numPieces .. " " .. message:sub(i * length + 1, #message), ip, port)
    else
      self.udp:sendto(uuid_msg .. " " .. i + 1 .. " " .. numPieces .. " " .. message:sub(i * length + 1, (i + 1) * length), ip, port)
    end
  end
end

function Server:handle_message(message, ip, port)
  cmd, parms = message:match("^(%S*) (.*)")
  if cmd == 'handshake' then -- add authentication here
    client_uuid = uuid()
    currentClients[client_uuid] = {}
    self:send('handshake ' .. client_uuid, ip,  port)
  elseif cmd == 'map' then
    local serialized_map = self.map:serialize()
    self:send('map ' .. serialized_map, ip, port)
  end
end

function Server:loop()
  local data, msg_or_ip, port_or_nil = self.udp:receivefrom()
	if data then
    local id, i, numParts, message = data:match("^(%S*) (%d*) (%d*) (.*)")
    local i = tonumber(i)
    local numParts = tonumber(numParts)
    if numParts ~= 1 then
      if numParts == i then
        self:handle_message(self.message_pieces[id] .. message, msg_or_ip, port_or_nil)
        self.message_pieces[id] = nil
      end
      if self.message_pieces[id] then
        self.message_pieces[id] = self.message_pieces[id] .. message
      else
        self.message_pieces[id] = message
      end
    else
      self:handle_message(message, msg_or_ip, port_or_nil)
    end
  elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: " .. tostring(msg))
	end
  -- socket.sleep(0.001)
end

return Server
