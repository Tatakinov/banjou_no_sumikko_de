local Command       = require("uci.command")
local None          = require("uci.command.none")
local Error         = require("uci.command.error")

local M = {}

M.Command = Command

-- きわめて謎だがrequireが失敗することがあるので先にloadしておく
for _, v in pairs(Command) do
  require("uci.command." .. v)
end

--
--  str uciで送受信する文字列
--
--  table
function M.parse(str)
  local list  = {}
  local data  = None.parse()
  if str == nil then
    return data
  end
  for s in string.gmatch(str, "[%g]+") do
    table.insert(list, s)
  end
  if #list == 0 then
    return data
  end

  local s, class  = pcall(require, "uci.command." .. list[1])
  if not(s) then
    --print(class)
    print("Failed to require: " .. list[1])
    return Error.parse(class)
  end
  local tmp  = class.parse(list)
  if tmp == nil then
    return data
  end
  data  = tmp
  return data
end

function M.tostring(data)
  assert(data.command)
  local s, class  = pcall(require, "uci.command." .. data.command)
  if not(s) then
    --print(class)
    print("Failed to require: " .. data.command)
    return nil
  end
  return class.tostring(data)
end

return M
