local Class = require("class")

local M   = Class()
M.__index = M

function M:_init()
  self.data = {}
  self.prev_num = 0
end

function M:add(talk)
  talk.id = talk.id or ""
  --print("id: <" .. talk.id .. ">")
  if talk.id then
    if self.data[talk.id] == nil then
      self.data[talk.id]  = {}
    end
    table.insert(self.data[talk.id], talk)
  end
end

function M:get(id)
  id  = id or ""
  local list  = self.data[id]
  if list == nil then
    return nil
  end
  return list[math.random(#list)]
end

function M:rawget(id)
  id  = id or ""
  return self.data[id]
end

return M
