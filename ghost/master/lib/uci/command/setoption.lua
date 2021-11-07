local StringBuffer  = require("string_buffer")
local Command          = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "setoption")
  data.command = Command.SETOPTION

  local index = 2
  while index <= #list do
    if list[index] == "name" then
      index = index + 1
      data.name = list[index]
    elseif list[index] == "value" then
      index = index + 1
      data.value  = list[index]
    end
    index = index + 1
  end

  return data
end

function M.tostring(data)
  assert(data.command == Command.SETOPTION)
  assert(data.name)
  local str = StringBuffer("setoption"):append(" ")
  str:append("name"):append(" "):append(data.name)
  if data.value ~= nil then
    str:append(" "):append("value"):append(" "):append(data.value)
  end
  return str:tostring()
end

return M
