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
local util = require('util')

local COMMANDS = require('common.commands')
local Map = require('common.map')
local Gamestate = require('common.gamestate')

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

  function callUserFullyConnected(...)
    return self:userFullyConnected(...)
  end

  function callTick(...)
    return self:mpTick(...)
  end

  self.server.callbacks.received = callHandle
  self.server.callbacks.authorize = callAuth
  self.server.callbacks.synchronize = callSync
  self.server.callbacks.customDataChanged = newUserData
  self.server.callbacks.userFullyConnected = callUserFullyConnected
  self.server.callbacks.tick = callTick

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

  self.dt = 0
  self.time = socket.gettime()
  self.server.tickrate = 30

  self.lastGamestate = nil
  self.currentGamestate = Gamestate:new(self.tick)
end

function Server:userFullyConnected(user)
  local player_uuid = self.currentGamestate:addObject()
  self.server:setUserValue(user, 'player_uuid', player_uuid)
  self.currentGamestate:updateState(player_uuid, "x", 0)
  self.currentGamestate:updateState(player_uuid, "y", 0)
  local serialized_state = self.currentGamestate:serialize()
  self.server:send(COMMANDS.full_update, serialized_state)
end

function Server:auth(user, authMsg)
  return true
end

function Server:handle_message(cmd, parms, user)
  local player_uuid = user.customData.player_uuid
  local dt = 1 / self.server.tickrate
  if player_uuid then
    print(cmd, parms)
    if cmd == COMMANDS.forward then
      local currentY = self.currentGamestate:getObjectProp(player_uuid, "y")
      self.currentGamestate:updateState(player_uuid, "y", currentY - 100 * dt)
    elseif cmd == COMMANDS.backward then
      local currentY = self.currentGamestate:getObjectProp(player_uuid, "y")
      self.currentGamestate:updateState(player_uuid, "y", currentY + 100 * dt)
    end
    if cmd == COMMANDS.left then
      local currentX = self.currentGamestate:getObjectProp(player_uuid, "x")
      self.currentGamestate:updateState(player_uuid, "x", currentX - 100 * dt)
    elseif cmd == COMMANDS.right then
      local currentX = self.currentGamestate:getObjectProp(player_uuid, "x")
      self.currentGamestate:updateState(player_uuid, "x", currentX + 100 * dt)
    end
  end
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
	-- socket.sleep( 0.0001 )
end

function Server:mpTick(tick)
  self.currentGamestate:updateState('server', 'tick', tick)
  local users = self.server:getUsers()

  if self.lastGamestate then
    local delta = self.currentGamestate:deltaSerialize(self.lastGamestate)
    self.server:send(COMMANDS.delta_update, delta, false, true) -- send udp packets to all users with delta gamestate
  else -- server doesn't have last ticks gamestate so send a full update to all clients
    local serialized_state = self.currentGamestate:serialize()
    self.server:send(COMMANDS.full_update, serialized_state, false, true)
  end
  self.lastGamestate = self.currentGamestate:clone()
end
return Server
