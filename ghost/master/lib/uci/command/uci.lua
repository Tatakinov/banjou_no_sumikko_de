local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "uci")
  data.command = Command.UCI
  return data
end

function M.tostring(data)
  assert(data.command == Command.UCI)
  return "uci"
end

return M
