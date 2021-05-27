local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "ponderhit")
  data.command = Command.PONDERHIT
  return data
end

function M.tostring(data)
  assert(data.command == Command.PONDERHIT)
  return "ponderhit"
end

return M
