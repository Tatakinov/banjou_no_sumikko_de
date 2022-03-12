local Updater = require("ss_bind_updater")

local updater = Updater()

local M = {}

local function getCategory(x, y)
  return "GOMOKU" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local function getDummyCategory(x, y)
  return "DUMMY_GOMOKU" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local function getHighlightCategory(x, y)
  return "HIGHLIGHT_GOMOKU" .. string.format("%02d%02d", (x + 1), (y + 1))
end

function M.OnGomokuViewRenderClear()
  for x = 0, 14 do
    for y = 0, 14 do
      updater:set(getCategory(x, y), nil, 0)
      updater:set(getHighlightCategory(x, y), nil, 0)
    end
  end
end

function M.OnGomokuViewRenderClearCollision()
  for x = 0, 14 do
    for y = 0, 14 do
      updater:set(getDummyCategory(x, y), nil, 0)
    end
  end
end

function M.OnGomokuViewRenderSquare(x, y, c)
  if c == 0 then
    updater:set(getCategory(x, y), nil, 0)
  elseif c == 1 then
    updater:set(getCategory(x, y), "BLACK", 1)
  elseif c == 2 then
    updater:set(getCategory(x, y), "WHITE", 1)
  else
    assert(false, "c == " .. tostring(c))
  end
end

function M.OnGomokuViewRenderCollision(x, y)
  updater:set(getDummyCategory(x, y), "DUMMY", 1)
end

function M.OnGomokuViewRenderHighlight(x, y)
  updater:set(getHighlightCategory(x, y), "HIGHLIGHT", 1)
end

function M.OnGomokuViewRenderCommit()
  return updater:toSS()
end

return M
