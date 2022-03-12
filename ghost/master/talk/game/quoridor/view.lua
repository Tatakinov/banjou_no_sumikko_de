local Render  = require("talk.game.quoridor._render")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

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


local M = {
  {
    id  = "OnQuoridorView",
    content = function(shiori, ref)
      local __  = shiori.var
      local r = __("_BoardReverse")
      local quoridor  = shiori:saori("quoridor")
      Render.OnQuoridorViewRenderClear()
      Render.OnQuoridorViewRenderClearCollision()
      local index = 0
      for c in string.gmatch(quoridor("board")(), "%d+") do
        c = tonumber(c)
        local x = index % 9
        local y = math.floor(index / 9)
        Render.OnQuoridorViewRenderSquare(x, y, c, r)
        index = index + 1
      end
      local h = quoridor("getHBar")
      for i = 0, tonumber(h()) - 1 do
        local x, y  = string.match(h[i], "(%d+),(%d+)")
        Render.OnQuoridorViewRenderBar("H", tonumber(x), tonumber(y), r)
      end
      local v = quoridor("getVBar")
      for i = 0, tonumber(v()) - 1 do
        local x, y  = string.match(v[i], "(%d+),(%d+)")
        Render.OnQuoridorViewRenderBar("V", tonumber(x), tonumber(y), r)
      end
      return "\\p[6]\\s[18000]" .. shiori:talk("OnQuoridorViewCommit")
    end,
  },
  {
    id  = "OnQuoridorViewCollision",
    content = function(shiori, ref)
      local __  = shiori.var
      local r = __("_BoardReverse")
      Render.OnQuoridorViewRenderCollision(tonumber(ref[0]), tonumber(ref[1]), r)
    end,
  },
  {
    id  = "OnQuoridorViewHighlight",
    content = function(shiori, ref)
      local __  = shiori.var
      local r = __("_BoardReverse")
      Render.OnQuoridorViewRenderHighlight(tonumber(ref[0]), tonumber(ref[1]), r)
    end,
  },
  {
    id  = "OnQuoridorViewCollisionHBar",
    content = function(shiori, ref)
      local __  = shiori.var
      local r = __("_BoardReverse")
      local x, y  = string.match(ref[0], "(%d+),(%d+)")
      Render.OnQuoridorViewRenderCollisionHBar(x, y, r)
    end,
  },
  {
    id  = "OnQuoridorViewCollisionVBar",
    content = function(shiori, ref)
      local __  = shiori.var
      local r = __("_BoardReverse")
      local x, y  = string.match(ref[0], "(%d+),(%d+)")
      Render.OnQuoridorViewRenderCollisionVBar(x, y)
    end,
  },
  {
    id  = "OnQuoridorViewCommit",
    content = function(shiori, ref)
      return Render.OnQuoridorViewRenderCommit()
    end,
  },
  {
    id  = "6Right",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quoridor_State") == "select" then
        return SS():raise("OnQuoridorGamePlayerTurnBegin")
      end
    end,
  },
}

for x = 0, 8 do
  for y = 0, 8 do
    table.insert(M, {
      id  = "6" .. getDummyCategory(x, y) .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        local x, y  = x, y
        if __("_Quoridor_State") == "begin" then
          __("_Quoridor_State", "begin2")
          if __("_BoardReverse") then
            x = 8 - x
            y = 8 - y
          end
          return SS():raise("OnQuoridorGamePlayerTurnSelectPiece", x, y)
        elseif __("_Quoridor_State") == "select" then
          if __("_BoardReverse") then
            x = 8 - x
            y = 8 - y
          end
          return SS():raise("OnQuoridorGamePlayerTurnEnd", "move", x, y)
        end
      end,
    })
  end
end

for x = 0, 7 do
  for y = 0, 7 do
    table.insert(M, {
      id  = "6" .. getDummyBarHCategory(x, y) .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        local x, y  = x, y
        if __("_Quoridor_State") == "begin" then
          __("_Quoridor_State", "select")
          if __("_BoardReverse") then
            x = 7 - x
            y = 7 - y
          end
          return SS():raise("OnQuoridorGamePlayerTurnEnd", "put", x, y, "H")
        end
      end,
    })
    table.insert(M, {
      id  = "6" .. getDummyBarVCategory(x, y) .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        local x, y  = x, y
        if __("_Quoridor_State") == "begin" then
          __("_Quoridor_State", "select")
          if __("_BoardReverse") then
            x = 7 - x
            y = 7 - y
          end
          return SS():raise("OnQuoridorGamePlayerTurnEnd", "put", x, y, "V")
        end
      end,
    })
  end
end

return M
