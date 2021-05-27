local StringBuffer  = require("string_buffer")
local M = {}

function M.rgb(r, g, b)
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  assert(0 <= r and 255 >= r)
  assert(0 <= g and 255 >= g)
  assert(0 <= b and 255 >= b)
  local str = StringBuffer()
  str:append(r):append(","):append(g):append(","):append(b)
  return str:tostring()
end

function M.rgbp(r, g, b)
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  assert(0 <= r and 100 >= r)
  assert(0 <= g and 100 >= g)
  assert(0 <= b and 100 >= b)
  local str = StringBuffer()
  str:append(r):append("%,"):append(g):append("%,"):append(b):append("%")
  return str:tostring()
end

local defined_color = {
  red = "#ff0000",
}

function M.color(str)
  assert(defined_color[str])
end

return M
