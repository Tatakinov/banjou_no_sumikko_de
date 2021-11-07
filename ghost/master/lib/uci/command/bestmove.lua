local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "bestmove")
  data.command = Command.BESTMOVE
  data.bestmove = list[2]
  local index = 3
  while #list >= index do
    if list[index] == "ponder" then
      index = index + 1
      data.ponder = list[index]
    end
    index = index + 1
  end
  return data
end

return M
