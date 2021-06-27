local Class = require("class")

local M   = Class()
M.__index = M

function M:_init()
  self._data = {}
end

function M:add(talk)
  talk.id = talk.id or ""
  --print("id: <" .. talk.id .. ">")
  if talk.id then
    if self._data[talk.id] == nil then
      self._data[talk.id]  = {}
    end
    table.insert(self._data[talk.id], talk)
  end
end

function M:get(id)
  id  = id or ""
  local list  = self._data[id]
  if list == nil then
    return nil
  end
  return list[math.random(#list)]
end

function M:rawget(id)
  id  = id or ""
  return self._data[id]
end

return M
