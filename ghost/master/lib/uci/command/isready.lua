local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "isready")
  data.command = Command.ISREADY
  return data
end

function M.tostring(data)
  assert(data.command == Command.ISREADY)
  return "isready"
end

return M
