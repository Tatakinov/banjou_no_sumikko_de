local StringBuffer  = require("string_buffer")
local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "")
  data.command = Command
  return data
end

local options = {
  "btime", "wtime", "byoyomi", "binc", "winc",
}

function M.tostring(data)
  assert(data.command == Command.GO)
  local str = StringBuffer("go")
  if data.ponder then
    str:append(" "):append("ponder")
  end
  if data.infinite then
    str:append(" "):append("infinite")
  else
    data.btime  = data.btime or 0
    data.wtime  = data.wtime or 0
  end
  if data.mate then
    str:append(" "):append("mate")
    if tonumber(data.mate) or data.mate == "infinite" then
      str:append(" "):append(data.mate)
    end
  end
  for i = 1, #options do
    if data[options[i]] then
      str:append(" "):append(options[i])
          :append(" "):append(data[options[i]])
    end
  end
  return str:tostring()
end

return M
