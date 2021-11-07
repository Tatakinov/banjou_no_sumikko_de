local StringBuffer  = require("string_buffer")
local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "")
  data.command = Command
  return data
end

function M.tostring(data)
  assert(data.command == Command.POSITION)
  local str = StringBuffer("position"):append(" ")
  if data.startpos then
    str:append("startpos")
  elseif data.sfen then
    str:append("sfen"):append(" "):append(table.concat(data.sfen, " "))
  end
  if type(data.moves) == "table" and #data.moves > 0 then
    str:append(" "):append("moves")
    for i = 1, #data.moves do
      str:append(" "):append(data.moves[i])
    end
  end
  return str:tostring()
end

return M
