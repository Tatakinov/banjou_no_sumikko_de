local Render  = require("talk.game.connect6._render")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local function getCategory(x, y)
  return "CONNECT6" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local function getDummyCategory(x, y)
  return "DUMMY_CONNECT6" .. string.format("%02d%02d", (x + 1), (y + 1))
end

local M = {
  {
    id  = "OnConnect6View",
    content = function(shiori, ref)
      local __  = shiori.var
      local connect6 = shiori:saori("connect6")
      local index = 0
      Render.OnConnect6ViewRenderClear()
      Render.OnConnect6ViewRenderClearCollision()
      for c in string.gmatch(connect6("board")(), "%d+") do
        c = tonumber(c)
        local x = index % 15
        local y = math.floor(index / 15)
        Render.OnConnect6ViewRenderSquare(x, y, c)
        index = index + 1
      end
      local put = __("_LatestPut")
      if put then
        print("highlight:", put.x, put.y)
        Render.OnConnect6ViewRenderHighlight(put.x, put.y)
      end
      return "\\p[8]\\s[20000]" .. shiori:talk("OnConnect6ViewCommit")
    end,
  },
  {
    id  = "OnConnect6ViewCollision",
    content = function(shiori, ref)
      Render.OnConnect6ViewRenderCollision(tonumber(ref[0]), tonumber(ref[1]))
    end,
  },
  {
    id  = "OnConnect6ViewCommit",
    content = function(shiori, ref)
      return Render.OnConnect6ViewRenderCommit()
    end,
  },
}

for x = 0, 14 do
  for y = 0, 14 do
    table.insert(M, {
      id  = "8" .. getDummyCategory(x, y) .. "Left",
      content = function(shiori, ref)
        print("Click: ", x, y)
        local __  = shiori.var
        if __("_Connect6_State") == "begin" then
          __("_Connect6_State", "select")
          return SS():raise("OnConnect6GamePlayerTurnEnd", x, y)
        end
      end,
    })
  end
end

return M
