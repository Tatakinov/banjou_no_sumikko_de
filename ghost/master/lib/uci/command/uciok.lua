local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "uciok")
  data.command = Command.UCIOK
  return data
end

return M
