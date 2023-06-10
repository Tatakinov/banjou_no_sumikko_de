local SSBindUpdater = require("ss_bind_updater")
local StringBuffer  = require("string_buffer")

local updater = SSBindUpdater()

local M = {}

function M.initialize()
  updater = SSBindUpdater()
end

function M.clear()
  for i = 0, 25 do
    updater:set("POINT" .. i, nil, 0)
    updater:set("POINT" .. i .. "_DUMMY", nil, 0)
  end
  for i = 1, 2 do
    updater:set("DICE" .. i, nil, 0)
    updater:set("DICE" .. i .. "_DUMMY", nil, 0)
  end
  updater:set("DOUBLE_WHITE", nil, 0)
  updater:set("DOUBLE_BLACK", nil, 0)
end

function M.renderPiece(i, color, point)
  local str = StringBuffer()
  if color == 1 then
    if point > 0 then
      updater:set("POINT" .. i, "W" .. point, 1)
    else
      for index = 1, 15 do
        updater:set("POINT" .. i, "W" .. index, 0)
      end
    end
  elseif color == 2 then
    if point > 0 then
      updater:set("POINT" .. (25 - i), "B" .. point, 1)
    else
      for index = 1, 15 do
        updater:set("POINT" .. (25 - i), "B" .. index, 0)
      end
    end
  end
  return str
end

function M.renderDice(index, color, value)
  local str = StringBuffer()
  updater:set("DICE" .. index, color .. value, 1)
  return str
end

function M.renderSwap()
  local str = StringBuffer()
  for i = 1, 2 do
    updater:set("DICE" .. i .. "_DUMMY", "DUMMY", 1)
  end
  return str
end

function M.renderMovable(move)
  local str = StringBuffer()
  updater:set("POINT" .. move.from .. "_DUMMY", "DUMMY", 1)
  return str
end

function M.update()
  return [[
\p[3]\s[14000]
]] .. updater:toSS()
end

function M.renderDouble(color, rate)
  local s = {"WHITE", "BLACK"}
  updater:set("DOUBLE_" .. s[color], tostring(rate), 1)
end

return M
