local StringBuffer  = require("string_buffer")
local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "id")
  data.command = Command.ID

  local index = 2
  while index <= #list do
    if list[index] == "name" then
      index = index + 1
      local str = StringBuffer(list[index])
      for i = index + 1, #list do
        str:append(" "):append(list[i])
      end
      index = #list
      data.name = str:tostring()
    elseif list[index] == "author" then
      index = index + 1
      local str = StringBuffer(list[index])
      for i = index + 1, #list do
        str:append(" "):append(list[i])
      end
      index = #list
      data.author  = str:tostring()
    end
    index = index + 1
  end
  return data
end

return M
