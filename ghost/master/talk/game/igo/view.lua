local IgoPlayer = require("igo_player")
local Render  = require("talk.game.gomoku._render")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
--local Updater = require("ss_bind_updater")

--local updater = Updater()

local function getCategory(x, y)
  return "IGO" .. string.format("%02d%02d", x, y)
end

local function getDummyCategory(x, y)
  return "DUMMY_IGO" .. string.format("%02d%02d", x, y)
end

local M = {
  {
    id  = "OnIgoView",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local player  = __("_Igo")
      str:append([=[\p[10]\s[22000]]=])
      -- 盤面の描画
      for x = 1, player:getBoardSize() do
        for y = 1, player:getBoardSize() do
          local e = player:get(x, y)
          local tag = getCategory(x, y)
          if e == 0 then
            str:append(SS():bind(tag, nil, 0))
          elseif e == 1 then
            str:append(SS():bind(tag, "BLACK", 1))
          elseif e == 2 then
            str:append(SS():bind(tag, "WHITE", 1))
          end
          str:append(SS():bind("HIGHLIGHT_" .. tag, nil, 0))
          str:append(SS():bind("DUMMY_" .. tag, nil, 0))
        end
      end
      -- 直前の指し手のハイライト
      local last = __("_LastPut")
      if last then
        local tag = getCategory(last.x, last.y)
        str:append(SS():bind(tag, "HIGHLIGHT", 1))
      end
      -- ユーザの手番の時の当たり判定
      if ref[0] == "playable" then
        local list  = player:generateMoves()
        for _, v in ipairs(list) do
          local tag = getCategory(v.x, v.y)
          str:append(SS():bind("DUMMY_" .. tag, "DUMMY", 1))
        end
      end
      return str
    end,
  },
}

for x = 0, 9 do
  for y = 0, 9 do
    table.insert(M, {
      id  = "10" .. getDummyCategory(x, y) .. "Left",
      content = function(shiori, ref)
        print("Click: ", x, y)
        return SS():raise("OnIgoGamePlayerTurnEnd", x, y)
      end,
    })
  end
end

return M
