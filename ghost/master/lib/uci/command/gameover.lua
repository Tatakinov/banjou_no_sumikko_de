local StringBuffer  = require("string_buffer")
local Command  = require("uci.command")

local M = {}

function M.tostring(data)
  assert(data.command == Command.GAMEOVER)
  local str = StringBuffer(data.command)
  assert(data.result)
  str:append(" "):append(data.result)
  return str:tostring()
end

return M
