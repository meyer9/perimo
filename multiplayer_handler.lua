------------------------------------------------------------------------------
--	FILE:	  main.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Multiplayer handler for Perimo
------------------------------------------------------------------------------

-- Local Imports
local class = require 'middleclass'
local socket = require 'socket'

local Multiplayer = class('Multiplayer')

function Multiplayer:initialize()
  self.sock = socket.udp()
  self.sock:settimeout(0)
end

function Multiplayer:send(...)
  self.sock:send(table.concat({...}, " "))
end

function Multiplayer:connect(host, port)
  if not host then host = 'localhost' end
  if not port then port = 1337 end
  self.sock:setpeername(host, port)
  print('Connecting to ' .. host .. ':' .. port)
  print('Handshaking...')
  self.ping1 = os.clock()
  self:send('handshake 1.0.0')
end

function Multiplayer:update()
  -- self:send('handshake')
  repeat
		data, msg = self.sock:receive()

		if data then
			cmd, parms = data:match("^(%S*) (.*)")
			if cmd == 'handshake' then
        print('Handshake complete')
        print("Ping: ".. tostring((os.clock() - self.ping1) * 1000) .. ' ms')
      end
      -- if cmd
      -- end
		elseif msg ~= 'timeout' then
			error("Network error: " .. tostring(msg))
		end
	until not data
end

return Multiplayer
