local Updater = require("ss_bind_updater")

local updater = Updater()

local function getCategory(x, y, r)
  if r then
    return "QUORIDOR" .. (9 - x) .. (9 - y)
  end
  return "QUORIDOR" .. (x + 1) .. (y + 1)
end

local function getBarHCategory(x, y, r)
  if r then
    return "QUORIDOR_BAR_H_" .. (8 - x) .. (8 - y)
  end
  return "QUORIDOR_BAR_H_" .. (x + 1) .. (y + 1)
end

local function getBarVCategory(x, y, r)
  if r then
    return "QUORIDOR_BAR_V_" .. (8 - x) .. (8 - y)
  end
  return "QUORIDOR_BAR_V_" .. (x + 1) .. (y + 1)
end

local function getDummyCategory(x, y, r)
  if r then
    return "DUMMY_QUORIDOR" .. (9 - x) .. (9 - y)
  end
  return "DUMMY_QUORIDOR" .. (x + 1) .. (y + 1)
end

local function getDummyBarHCategory(x, y, r)
  if r then
    return "DUMMY_QUORIDOR_BAR_H_" .. (8 - x) .. (8 - y)
  end
  return "DUMMY_QUORIDOR_BAR_H_" .. (x + 1) .. (y + 1)
end

local function getDummyBarVCategory(x, y, r)
  if r then
    return "DUMMY_QUORIDOR_BAR_V_" .. (8 - x) .. (8 - y)
  end
  return "DUMMY_QUORIDOR_BAR_V_" .. (x + 1) .. (y + 1)
end

local function getHighlightCategory(x, y, r)
  if r then
    return "QUORIDOR_HIGHLIGHT" .. (9 - x) .. (9 - y)
  end
  return "QUORIDOR_HIGHLIGHT" .. (x + 1) .. (y + 1)
end

local M = {}

function M.OnQuoridorViewRenderClear()
  for x = 0, 8 do
    for y = 0, 8 do
      updater:set(getCategory(x, y), nil, 0)
      updater:set(getHighlightCategory(x, y), nil, 0)
    end
  end
  for x = 0, 7 do
    for y = 0, 7 do
      updater:set(getBarHCategory(x, y), nil, 0)
      updater:set(getBarVCategory(x, y), nil, 0)
    end
  end
end

function M.OnQuoridorViewRenderClearCollision()
  for x = 0, 8 do
    for y = 0, 8 do
      updater:set(getDummyCategory(x, y), nil, 0)
    end
  end
  for x = 0, 7 do
    for y = 0, 7 do
      updater:set(getDummyBarHCategory(x, y), nil, 0)
      updater:set(getDummyBarVCategory(x, y), nil, 0)
    end
  end
end

function M.OnQuoridorViewRenderSquare(x, y, c, r)
  if c == 0 then
    updater:set(getCategory(x, y, r), nil, 0)
  elseif c == 1 then
    updater:set(getCategory(x, y, r), "P1", 1)
  elseif c == 2 then
    updater:set(getCategory(x, y, r), "P2", 1)
  elseif c == 3 then
    updater:set(getCategory(x, y, r), "P3", 1)
  elseif c == 4 then
    updater:set(getCategory(x, y, r), "P4", 1)
  else
    assert(false, "c == " .. tostring(c))
  end
end

function M.OnQuoridorViewRenderBar(t, x, y, r)
  if t == "H" then
    updater:set(getBarHCategory(x, y, r), "BAR", 1)
  elseif t == "V" then
    updater:set(getBarVCategory(x, y, r), "BAR", 1)
  end
end

function M.OnQuoridorViewRenderCollision(x, y, r)
  updater:set(getDummyCategory(x, y, r), "DUMMY", 1)
end

function M.OnQuoridorViewRenderHighlight(x, y, r)
  updater:set(getHighlightCategory(x, y, r), "HIGHLIGHT", 1)
end

function M.OnQuoridorViewRenderCollisionHBar(x, y, r)
  updater:set(getDummyBarHCategory(x, y, r), "DUMMY", 1)
end

function M.OnQuoridorViewRenderCollisionVBar(x, y, r)
  updater:set(getDummyBarVCategory(x, y, r), "DUMMY", 1)
end

function M.OnQuoridorViewRenderCommit()
  return updater:toSS()
end

return M
