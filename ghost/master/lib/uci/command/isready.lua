local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "")
  data.command = Command
  return data
end

function M.tostring(data)
  assert(data.command == Command.ISREADY)
  return "isready"
end

return M
