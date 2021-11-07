local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "ucinewgame")
  data.command = Command.UCINEWGAME
  return data
end

function M.tostring(data)
  assert(data.command == Command.UCINEWGAME)
  return "ucinewgame"
end

return M
