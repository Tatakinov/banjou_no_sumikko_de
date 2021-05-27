local Command  = require("usi.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "option")
  data.command = Command.OPTION

  local index = 2
  local in_name = true
  while index <= #list do
    if list[index] == "name" then
      index = index + 1
      data.name = list[index]
      in_name = true
    elseif list[index] == "type" then
      index = index + 1
      data.type = list[index]
    elseif list[index] == "default" then
      index = index + 1
      if data.type == "string" or data.type == "combo" 
          or data.type == "filename" then
        data.default  = list[index]
      elseif data.type == "check" then
        assert(list[index] == "true" or list[index] == "false")
        data.default  = list[index] == "true"
      elseif data.type == "spin" then
        data.default  = assert(tonumber(list[index]))
      end
    elseif list[index] == "min" then
      index = index + 1
      data.min  = assert(tonumber(list[index]))
    elseif list[index] == "max" then
      index = index + 1
      data.max  = assert(tonumber(list[index]))
    elseif list[index] == "var" then
      index = index + 1
      assert(data.type == "combo")
      if data.var == nil then
        data.var  = {}
      end
      table.insert(data.var, list[index])
    elseif in_name then
      data.name = data.name .. " " .. list[index]
    end
    index = index + 1
  end

  return data
end

return M
