local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "stop")
  data.command = Command.STOP
  return data
end

function M.tostring(data)
  assert(data.command == Command.STOP)
  return "stop"
end

return M
