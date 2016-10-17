------------------------------------------------------------------------------
--	FILE:	  multiplayer_handler.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Multiplayer handler for Perimo
------------------------------------------------------------------------------

-- Local Imports
local class = require 'middleclass'
local socket = require 'socket'
local Entity = require 'entity'
local uuid = require 'uuid'

local Multiplayer = class('Multiplayer', Entity)

function Multiplayer:load()
  self.message_pieces = {}
  self.sock = socket.udp()
  self.sock:settimeout(0)
end

function Multiplayer:send(...)
  local message = table.concat({...}, " ")
  local numPieces = math.ceil(#message / 7000)
  local sent = 0
  local length = math.ceil(#message / numPieces)
  local uuid_msg = uuid()
  if numPieces == 1 then
    self.sock:send(uuid_msg .. " 1 1 " .. message)
    return
  end
  for i = 0, numPieces - 1 do
    if i == numPieces - 1 then
      self.sock:send(uuid_msg .. " " .. i + 1 .. " " .. numPieces .. " " .. message:sub(i * length + 1, #message))
      print("Sending " + ((i+1) / numPieces * 100) + "%...")
    else
      self.sock:send(uuid_msg .. " " .. i + 1 .. " " .. numPieces .. " " .. message:sub(i * length + 1, (i + 1) * length))
      print("Sending " + ((i+1) / numPieces * 100) + "%...")
    end
  end
end

function Multiplayer:connect(host, port)
  if not host then host = 'localhost' end
  if not port then port = 1337 end
  self.sock:setpeername(host, port)
  print('Connecting to ' .. host .. ':' .. port)
  print('Handshaking...')
  self:send('handshake', '1.0.0')
end

function Multiplayer:update(dt)
  -- self:send('handshake')
  repeat
		data, msg = self.sock:receive()
		if data then
			local id, i, numParts, message = data:match("^(%S*) (%d*) (%d*) (.*)")
      local i = tonumber(i)
      local numParts = tonumber(numParts)
      if numParts ~= 1 then
        print("Receiving " .. math.ceil(i / numParts * 100) .. "%...")
        if numParts == i then
          self:handle_message(self.message_pieces[id] .. message)
        end
        if self.message_pieces[id] then
          self.message_pieces[id] = self.message_pieces[id] .. message
        else
          self.message_pieces[id] = message
        end
      else
        self:handle_message(message)
			end
		elseif msg ~= 'timeout' then
			error("Network error: " .. tostring(msg))
		end
	until not data
end

function Multiplayer:handle_message(message)
  cmd, parms = message:match("^(%S*) (.*)")
  if cmd == 'handshake' then
    print('Handshake complete')
    print("Retrieving map...")
    self:send('map', '1.0.0')
  end
  if cmd == 'map' then
    print("Loaded map...")
    self.superentity.map:deserialize(parms)
  end
  if cmd == 'playerJoin' then
  end
end

return Multiplayer
