local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  data.command = Command.NONE
  return data
end

return M
