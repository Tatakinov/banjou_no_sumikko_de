local Updater = require("ss_bind_updater")

local updater = Updater()

local function getCategory(x, y)
  return "OTHELLO" .. (x + 1) .. (y + 1)
end

local function getDummyCategory(x, y)
  return "DUMMY_OTHELLO" .. (x + 1) .. (y + 1)
end

local M = {}

function M.OnOthelloViewRenderClear()
  for x = 0, 7 do
    for y = 0, 7 do
      updater:set(getCategory(x, y), nil, 0)
    end
  end
end

function M.OnOthelloViewRenderClearCollision()
  for x = 0, 7 do
    for y = 0, 7 do
      updater:set(getDummyCategory(x, y), nil, 0)
    end
  end
end

function M.OnOthelloViewRenderSquare(x, y, c)
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

function M.OnOthelloViewRenderCollision(x, y)
  updater:set(getDummyCategory(x, y), "DUMMY", 1)
end

function M.OnOthelloViewRenderCommit()
  return updater:toSS()
end

return M
