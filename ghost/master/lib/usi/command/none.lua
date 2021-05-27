local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  data.command = Command.NONE
  return data
end

return M
