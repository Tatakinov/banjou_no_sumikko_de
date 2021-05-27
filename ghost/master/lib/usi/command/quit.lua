local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "quit")
  data.command = Command.QUIT
  return data
end

function M.tostring(data)
  assert(data.command == Command.QUIT)
  return "quit"
end

return M
