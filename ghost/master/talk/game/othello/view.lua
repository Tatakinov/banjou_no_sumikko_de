local Render  = require("talk.game.othello._render")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local function getCategory(x, y)
  return "OTHELLO" .. (x + 1) .. (y + 1)
end

local function getDummyCategory(x, y)
  return "DUMMY_OTHELLO" .. (x + 1) .. (y + 1)
end

local M = {
  {
    id  = "OnOthelloView",
    content = function(shiori, ref)
      local othello = shiori:saori("othello")
      local index = 0
      Render.OnOthelloViewRenderClear()
      Render.OnOthelloViewRenderClearCollision()
      for c in string.gmatch(othello("board")(), "%d+") do
        c = tonumber(c)
        local x = index % 8
        local y = math.floor(index / 8)
        Render.OnOthelloViewRenderSquare(x, y, c)
        index = index + 1
      end
      return "\\p[5]\\s[17000]" .. shiori:talk("OnOthelloViewCommit")
    end,
  },
  {
    id  = "OnOthelloViewCollision",
    content = function(shiori, ref)
      Render.OnOthelloViewRenderCollision(tonumber(ref[0]), tonumber(ref[1]))
    end,
  },
  {
    id  = "OnOthelloViewCommit",
    content = function(shiori, ref)
      return Render.OnOthelloViewRenderCommit()
    end,
  },
}

for x = 0, 7 do
  for y = 0, 7 do
    table.insert(M, {
      id  = "5" .. getDummyCategory(x, y) .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        if __("_Othello_State") == "begin" then
          __("_Othello_State", "select")
          return SS():raise("OnOthelloGamePlayerTurnEnd", x, y)
        end
      end,
    })
  end
end

return M
