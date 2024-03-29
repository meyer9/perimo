-------------------------------------------------
-- Multiplayer handler for the client side of perimo.
--
-- @classmod MultiplayerHandler
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

package.path = package.path .. ";../?.lua" -- include from top directory

-- Local Imports
local class = require 'lib.middleclass'
local network = require 'lib.affair.network'
local Entity = require 'common.entity'
local uuid = require 'lib.uuid'
local util = require 'common.util'
local COMMANDS = require 'common.commands'
local Gamestate = require 'common.gamestate'
local GamestateRunner = require 'common.gamestate_runner'
local messagepack = require 'lib.msgpack.MessagePack'
local MultiplayerEntities = require 'client.multiplayer_entities'

log = require 'common.log'

local Multiplayer = class('Multiplayer', Entity)

-------------------------------------------------
-- Sets up the multiplayer helper classes
-------------------------------------------------
function Multiplayer:load()
  self.tickrate = self.superentity.tickrate
  self.isConnected = false
  self.currentGamestate = Gamestate:new()
  self.tick = 0
  self.time_since_dt = socket.gettime()
  self.last_tick = 0
  self.gamestate_runner = GamestateRunner:new(self.game.tickrate)
  self.multiplayer_entities = MultiplayerEntities:new()
  self:addSubentity(self.multiplayer_entities)
end

-------------------------------------------------
-- Connects to a multiplayer game on host, port.
-- @tparam string host Hostname to connect to
-- @tparam int port Port to connect to
-------------------------------------------------
function Multiplayer:connect(host, port)
  if not host then host = 'localhost' end
  if not port then port = 1337 end
  log.info('Connecting to ' .. host .. ':' .. port)
  self.client, err = network:startClient( host, self.superentity.player.name, port, "authed" )
  if not self.client then
    log.error('Failed to connect to ' .. host .. ':' .. port .. '.')
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

-------------------------------------------------
-- Sends a command to the server and adds it to the client
-- representation as well.
-- @tparam string command Command to send using Commands module.
-- @tparam string parms Parameters to send.
-- @tparam bool udp Whether to use UDP or not.
-------------------------------------------------
function Multiplayer:sendCommand(command, parms, udp)
  if not udp then udp = false end
  self.client:send(COMMANDS[command], parms, udp)
  local player_uuid = self.client:getUserValue("player_uuid")
  self.gamestate_runner:addCommand(player_uuid, COMMANDS[command], self.tick, parms)
end

-------------------------------------------------
-- Called when client is connected to the server.
-------------------------------------------------
function Multiplayer:connected()
  log.info('Connected to server.')
  self.isConnected = true
  self.client:send(COMMANDS.handshake, nil, true)
end

-------------------------------------------------
-- Called whenever client receives a command.
-- @tparam int cmd Command received.
-- @tparam string parms Parameters received.
-------------------------------------------------
function Multiplayer:received(cmd, parms)
  local player_uuid = self.client:getUserValue("player_uuid")
  if cmd == COMMANDS['map'] then
    log.debug("Loaded map...")
    self.superentity.map:deserialize(parms)
  end
  if cmd == COMMANDS.full_update then
    self.currentGamestate:deserialize(parms)
    local tick = self.currentGamestate:getObjectProp('server', 'tick')
    for entity_id, state in pairs(messagepack.unpack(parms)) do
      if player_uuid and entity_id ~= player_uuid and entity_id ~= "server" then
        self.multiplayer_entities:addOrUpdate(entity_id, state)
      end
    end
    self.gamestate_runner:receivedUpdate(self.currentGamestate, tick)

    if tick then self.tick = tick - 2 end
  end
  if cmd == COMMANDS.delta_update then
    self.currentGamestate:deserializeDeltaAndUpdate(parms)
    local tick = self.currentGamestate:getObjectProp('server', 'tick')
    for entity_id, state in pairs(messagepack.unpack(parms)) do
      if player_uuid and entity_id ~= player_uuid and entity_id ~= "server" then
        self.multiplayer_entities:addOrUpdate(entity_id, state)
      end
    end
    self.gamestate_runner:receivedUpdate(self.currentGamestate, tick)
    -- local difference = socket.gettime() - self.currentGamestate:getObjectProp('server', 'timestamp')
    if tick then
      self.tick = tick - 2
    end
  end
end

-------------------------------------------------
-- Called when a new user joins.
-------------------------------------------------
function Multiplayer:newUser(user)
end

-------------------------------------------------
-- Retrieves the exact fractional tick of the current time.
-- @treturn number Exact fractional tick of current time.
-------------------------------------------------
function Multiplayer:getTick()
  local dt = socket.gettime() - self.time_since_dt
  return self.tick + (dt * self.tickrate)
end

-------------------------------------------------
-- Updates the multiplayer client and ticks if needed.
-- @tparam number dt The amount of time in seconds passed since last update
-------------------------------------------------
function Multiplayer:update(dt)
  local t = socket.gettime()
  local dt = t - self.time_since_dt
  self.time_since_dt = t
  self.tick = self.tick + (dt * self.tickrate)
  if self.last_tick ~= math.floor(self.tick) then
    self.last_tick = math.floor(self.tick)
    self.game:call_mpTick()
  end
  self.client:update(dt)
end

return Multiplayer
