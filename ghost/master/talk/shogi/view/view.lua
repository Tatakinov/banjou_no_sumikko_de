local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = KifuPlayer.Color
local CSA   = KifuPlayer.CSA
local Misc  = require("shiori.misc")

--[[
--  minimal:  盤,持ち駒,手番
--  header:   対局者,指し手,時間
--  control1: 一手進める,一手戻る,初手,最終手[,分岐]
--  control2: 中断,待った,投了[,入玉宣言]
--  control3: control1 + 検討,本筋,エンジン
--
--  ShogiPlay
--    -- minimal + header + control1
--  ShogiGame
--    -- minimal + header + control2
--  ShogiConsider
--    -- minimal + header + control3
--]]

return {
  {
    id  = "OnShogiDisplayMinimal",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = KifuPlayer.getInstance()
      local data    = player:getPosition()
      local str = StringBuffer()

      local sfen    = player:toSfen()
      if __("_Sfen") == nil then
        str:append(shiori:talk("OnShogiRenderInitialize"))
      end
      --[[
      if __("_Sfen") == sfen then
        return shiori:talk("OnShogiRenderShow")
      end
      --]]

      --print("current: " .. sfen)
      --print("prev:    " .. tostring(__("_Sfen")))
      __("_Sfen",sfen)

      str:append(shiori:talk("OnShogiRenderPre"))
      str:append(shiori:talk("OnShogiRenderClear"))
      -- 盤
      do
        str:append(shiori:talk("OnShogiRenderBoard"))
      end
      -- ハイライト
      -- 駒の表示前に表示させると文字の部分にハイライトの
      -- 色がのらないので見やすい
      do
        local move_format = player:getCurrentMoveFormat()
        local move  = move_format.move
        if move and move.to then
          str:append(shiori:talk("OnShogiRenderSquare", move.to.x, move.to.y, "highlight"))
        end
      end
      -- 盤面 (reverseあり)
      for i = 1, 9 do
        for j = 1, 9 do
          local piece = data.board[i][j]
          --if piece.kind and piece.color then
            str:append(shiori:talk("OnShogiRenderSquare", i, j, piece))
          --end
        end
      end
      -- 持ち駒 (reverseあり)
      for _, color in ipairs(Color.LIST) do
        for _, kind in ipairs(CSA.HAND) do
          local num = data.hands[color][kind]
          --  駒の表示
          str:append(shiori:talk("OnShogiRenderHand", color, kind, num))
        end
      end
      str:append(shiori:talk("OnShogiRenderPost"))

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiDisplayHeader",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      -- 対局者情報[optional] (reverseなし)
      local t = {}
      for _, v in ipairs(Color.LIST) do
        t[v]  = player:getHeader(Color.k(v))
      end
      if t[Color.BLACK] and t[Color.WHITE] then
        str:append(shiori:talk("OnShogiRenderPlayerName", Misc.toArgs(t)))
      end

      -- 指し手の情報 (reverseなし)
      do
        str:append(shiori:talk("OnShogiRenderMoveInfo", player:getTesuu(), player:getSashite()))
      end

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiViewControl",
    content = function(shiori, ref)
      local str = StringBuffer()
      if ref[0] == "move" then
        local player  = KifuPlayer.getInstance()
        if      ref[1] == "head" then
          player:go(0)
        elseif  ref[1] == "backward10" then
          for i=1, 10 do
            player:backward()
          end
        elseif  ref[1] == "backward" then
          player:backward()
        elseif  ref[1] == "forward" then
          player:forward()
          if tonumber(ref[2]) ~= nil then
            player:goFork(tonumber(ref[2]))
          end
        elseif  ref[1] == "forward10" then
          for i=1, 10 do
            player:forward()
          end
        elseif  ref[1] == "tail" then
          player:tail()
      elseif ref[0] == "special" then
        local player  = KifuPlayer.getInstance()
        if      ref[1] == "TORYO" then
          str:append(shiori:talk("OnShogiGameResign"))
        end
        end
      end
      if ref[2] then
        return SS():raise(ref[2])
      end
      if str:strlen() > 0 then
        return str:tostring()
      end
    end,
  },
  {
    id  = "OnShogiViewController",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiRenderController", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiViewComments",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      local comments  = player:getComments()

      if comments then
        str:append(table.concat(comments, "\\n")):append(SS():n():n())
      end
      if player:getForksNum() > 1 then
        for i, v in ipairs(player:getForks()) do
          str:append(SS():q("【" .. player:getSashite(v) .. "】", "OnShogiView", "move", "forward", i - 1))
        end
        str:append(SS():n():n())
      end
      if str:strlen() > 0 then
        str:prepend(SS():p(0):c())
      else
        str:prepend(SS():p(0):b(-1):c())
      end
      -- http(s)のリンクは置換する
      str = str:tostring()
      str = string.gsub(str, "https?://[0-9a-zA-Z./%&()=~+-]+", function(s)
        return "\\q[" .. s .. ",OnJumpURL," .. s .. "]"
      end)
      return str
    end,
  },
  {
    id  = "OnShogiViewMinimal",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
      str:append(shiori:talk("OnShogiDisplayHeader", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiView",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiViewControl", ref))
        :append(shiori:talk("OnShogiDisplayMinimal", ref))
        :append(shiori:talk("OnShogiDisplayHeader", ref))
        :append(shiori:talk("OnShogiViewController", ref))
        :append(shiori:talk("OnShogiViewComments", ref))
      return str:tostring()
    end,
  },
}
