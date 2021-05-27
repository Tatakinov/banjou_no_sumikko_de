local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "usiok")
  data.command = Command.USIOK
  return data
end

return M
