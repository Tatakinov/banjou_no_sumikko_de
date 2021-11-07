local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "readyok")
  data.command = Command.READYOK
  return data
end

return M
