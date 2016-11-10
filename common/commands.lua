-------------------------------------------------
-- Module to keep track of server <-> client communication commands
--
-- @module Commands
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

-- start from 13

COMMANDS = {
  map = 13,
  forward = 14,
  backward = 15,
  left = 16,
  right = 17,
  delta_update = 18,
  full_update = 19,
  handshake = 255
}

return COMMANDS
