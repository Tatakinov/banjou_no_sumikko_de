-- @module Color

--- color

local UNICODE = false

local M = {}

--- 先手
-- @field BLACK
M.BLACK = 0

--- 後手
-- @field WHITE
M.WHITE = 1

M.LIST  = {M.BLACK, M.WHITE}

function M.reverse(color)
  if color == M.BLACK then
    return M.WHITE
  elseif color == M.WHITE then
    return M.BLACK
  end
end

function M.tostring(color, unicode)
  if unicode == nil then
    unicode = UNICODE
  end
  if unicode then
    if      color == M.BLACK then
      return string.char(0xe2, 0x98, 0x97)  -- ☗
    elseif  color == M.WHITE then
      return string.char(0xe2, 0x98, 0x96)  -- ☖
    end
  else
    if      color == M.BLACK then
      return string.char(0xe2, 0x96, 0xb2)  -- ▲
    elseif  color == M.WHITE then
      return string.char(0xe2, 0x96, 0xb3)  -- △
    end
  end
end

local k = {
  [M.BLACK] = "先手",
  [M.WHITE] = "後手",
}

function M.k(color)
  return assert(k[color])
end

return M
