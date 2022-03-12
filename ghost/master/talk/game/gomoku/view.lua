local Render  = require("talk.game.gomoku._render")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local function getCategory(x, y)
  return "GOMOKU" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local function getDummyCategory(x, y)
  return "DUMMY_GOMOKU" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local M = {
  {
    id  = "OnGomokuView",
    content = function(shiori, ref)
      local __  = shiori.var
      local gomoku = shiori:saori("gomoku")
      local index = 0
      Render.OnGomokuViewRenderClear()
      Render.OnGomokuViewRenderClearCollision()
      for c in string.gmatch(gomoku("board")(), "%d+") do
        c = tonumber(c)
        local x = index % 15
        local y = math.floor(index / 15)
        Render.OnGomokuViewRenderSquare(x, y, c)
        index = index + 1
      end
      local put = __("_LatestPut")
      if put then
        print("highlight:", put.x, put.y)
        Render.OnGomokuViewRenderHighlight(put.x, put.y)
      end
      return "\\p[7]\\s[19000]" .. shiori:talk("OnGomokuViewCommit")
    end,
  },
  {
    id  = "OnGomokuViewCollision",
    content = function(shiori, ref)
      Render.OnGomokuViewRenderCollision(tonumber(ref[0]), tonumber(ref[1]))
    end,
  },
  {
    id  = "OnGomokuViewCommit",
    content = function(shiori, ref)
      return Render.OnGomokuViewRenderCommit()
    end,
  },
}

for x = 0, 14 do
  for y = 0, 14 do
    table.insert(M, {
      id  = "7" .. getDummyCategory(x, y) .. "Left",
      content = function(shiori, ref)
        print("Click: ", x, y)
        local __  = shiori.var
        if __("_Gomoku_State") == "begin" then
          __("_Gomoku_State", "select")
          return SS():raise("OnGomokuGamePlayerTurnEnd", x, y)
        end
      end,
    })
  end
end

return M
