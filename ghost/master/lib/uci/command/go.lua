local StringBuffer  = require("string_buffer")
local Command  = require("uci.command")

local M = {}

local options = {
  "btime", "wtime", "binc", "winc",
}

function M.parse(list)
  local data  = {}
  assert(list[1] == "go")
  data.command = Command.GO
  local index = 2
  while index <= #list do
    for _, v in ipairs(options) do
      if list[index] == v then
        data[v] = tonumber(list[index + 1])
        index   = index + 2
        break
      end
    end
  end
  return data
end

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
