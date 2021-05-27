local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "usinewgame")
  data.command = Command.USINEWGAME
  return data
end

function M.tostring(data)
  assert(data.command == Command.USINEWGAME)
  return "usinewgame"
end

return M
