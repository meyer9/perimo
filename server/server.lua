-------------------------------------------------
-- Class to handle server setup and logic.
--
-- @classmod Server
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

local network = require('affair.network')
local class = require('middleclass')
local uuid = require('uuid')
local socket = require('socket')
local util = require('util')

local COMMANDS = require('common.commands')
local Map = require('common.map')
local Gamestate = require('common.gamestate')

log = require 'common.log'

local Server = class('Server')

uuid.seed()

local currentClients = {}

-------------------------------------------------
-- Creates a new server and connects it to a port based on
-- arg.
-------------------------------------------------
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

  function callUserDisconnected(...)
    return self:userDisconnected(...)
  end

  self.server.callbacks.received = callHandle
  self.server.callbacks.authorize = callAuth
  self.server.callbacks.synchronize = callSync
  self.server.callbacks.customDataChanged = newUserData
  self.server.callbacks.userFullyConnected = callUserFullyConnected
  self.server.callbacks.tick = callTick
  self.server.callbacks.disconnectedUser = callUserDisconnected

  if not self.server then
    print('Server creation failed.')
    print(err)
    os.exit(0)
  end

  self.running = true

  self.map = Map:new(200, 200)

  log.debug("Generating map...")
  self.map:generate_island()
  log.debug("Finished.")

  self.dt = 0
  self.time = socket.gettime()
  self.server.tickrate = 30

  self.lastGamestate = nil
  self.currentGamestate = Gamestate:new(self.tick)
end

-------------------------------------------------
-- Initializes player data for a new player in the game.
-- @tparam tab user User who joined the game.
-------------------------------------------------
function Server:userFullyConnected(user)
  local player_uuid = self.currentGamestate:addObject("player")
  self.server:setUserValue(user, 'player_uuid', player_uuid)
  self.currentGamestate:updateState(player_uuid, "x", 0)
  self.currentGamestate:updateState(player_uuid, "y", 0)
  self.currentGamestate:updateState(player_uuid, "name", user.playerName)
  local serialized_state = self.currentGamestate:serialize()
  self.server:send(COMMANDS.full_update, serialized_state)
end

-------------------------------------------------
-- Removes user from server game representation.
-- @tparam tab user User who left the game.
-------------------------------------------------
function Server:userDisconnected(user)
  self.currentGamestate:removeFromState(user.customData.player_uuid)
end

-------------------------------------------------
-- Authorizes a player to join the game.
-- @tparam tab user User who is trying to join.
-- @tparam string authMsg from user who is trying to join.
-------------------------------------------------
function Server:auth(user, authMsg)
  return true
end

-------------------------------------------------
-- Handles messages sent to the server. [deprecated]
-- @tparam int cmd Command received.
-- @tparam string parms Parameters received.
-- @tparam tab user User data of client sending data.
-------------------------------------------------
function Server:handle_message(cmd, parms, user)
  local player_uuid = user.customData.player_uuid
  local dt = 1 / self.server.tickrate
  if player_uuid then
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
    elseif cmd == COMMANDS.look then
      self.currentGamestate:updateState(player_uuid, "yaw", tonumber(parms))
    end
  end
end

-------------------------------------------------
-- Sends the map to the user.
-- @tparam tab user User that needs to be synchronized.
-------------------------------------------------
function Server:synchronize(user)
  local serialized_map = self.map:serialize()
  self.server:send(COMMANDS['map'], serialized_map, user)
end

-------------------------------------------------
-- Updates the server every 10000th of a second.
-------------------------------------------------
function Server:update()
  self.server:update(self.dt)

	self.dt = socket.gettime() - self.time
	self.time = socket.gettime()

	-- This is important. Play with this value to fit your need.
	-- If you don't use this sleep command, the CPU will be used as much as possible, you'll probably run the game loop WAY more often than on the clients (who also require time to render the picture - something you don't need)
	socket.sleep( 0.0001 )
end

-------------------------------------------------
-- Updates the gamestate and sends it to all clients in the game
-- @tparam int tick Tick number to send.
-------------------------------------------------
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
