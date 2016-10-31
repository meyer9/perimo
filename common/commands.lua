------------------------------------------------------------------------------
--	FILE:	  commands.lua
--	AUTHOR:   Julian Meyer
--	PURPOSE:  Provides client <-> server commands
------------------------------------------------------------------------------

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
