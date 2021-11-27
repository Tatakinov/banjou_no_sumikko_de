local Class = require("class")

local M = Class()
M.__index = M
M.__call  = function(self, id)
  return assert(self._data[id][self._language])
end

function M:_init()
  self._data  = {}
end

function M:set(language)
  self._language  = language
end

function M:add(data)
  if not(self._data[data.id]) then
    self._data[data.id] = {}
  end
  for k, v in pairs(data.content) do
    self._data[data.id][k]  = v
  end
end

return M
