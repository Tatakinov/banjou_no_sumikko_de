local Class = require("class")
local Native  = require("rand.native")

local M = Class()
M.__index = M
M.__call  = function(self, n)
  if n == nil then
    return self._native()
  end
  assert(type(n) == "number")
  local r = self._native() / (2 ^ 32)
  return math.floor(r * n) + 1
end

function M:_init(seed)
  self._native = Native(seed)
end

return M
