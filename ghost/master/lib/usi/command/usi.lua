local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "usi")
  data.command = Command.USI
  return data
end

function M.tostring(data)
  assert(data.command == Command.USI)
  return "usi"
end

return M
