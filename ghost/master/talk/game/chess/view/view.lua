local ChessPlayer = require("chess_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = ChessPlayer.Color
local Misc  = require("shiori.misc")

--[[
--  minimal:  盤,持ち駒,手番
--  header:   対局者,指し手,時間
--  control1: 一手進める,一手戻る,初手,最終手[,分岐]
--  control2: 中断,待った,投了[,入玉宣言]
--  control3: control1 + 検討,本筋,エンジン
--
--  ChessPlay
--    -- minimal + header + control1
--  ChessGame
--    -- minimal + header + control2
--  ChessConsider
--    -- minimal + header + control3
--]]

return {
  {
    id  = "OnChessDisplayMinimal",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = ChessPlayer.getInstance()
      local data    = player:getPosition()
      local str = StringBuffer()
      local fen     = player:toSfen()
      -- debug
      __("_Fen", nil)
      -- debug
      if __("_Fen") == nil then
        str:append(shiori:talk("OnChessRenderInitialize"))
      end
      --[[
      if __("_Fen") == fen then
        return shiori:talk("OnChessRenderShow")
      end
      --]]

      --print("current: " .. fen)
      --print("prev:    " .. tostring(__("_Sfen")))
      __("_Fen", fen)

      str:append(shiori:talk("OnChessRenderPre"))
      str:append(shiori:talk("OnChessRenderClear"))
      -- 盤
      do
        str:append(shiori:talk("OnChessRenderBoard"))
      end
      -- ハイライト
      -- 駒の表示前に表示させると文字の部分にハイライトの
      -- 色がのらないので見やすい
      do
        local move_format = player:getCurrentMoveFormat()
        local move  = move_format.move
        if move and move.to then
          str:append(shiori:talk("OnChessRenderSquare", move.to.x, move.to.y, "highlight"))
        end
      end
      -- 盤面 (reverseあり)
      for i = 1, 8 do
        for j = 1, 8 do
          local piece = data.board[i][j]
          --if piece.kind and piece.color then
            str:append(shiori:talk("OnChessRenderSquare", i, j, piece))
          --end
        end
      end
      --[[
      -- 持ち駒 (reverseあり)
      for _, color in ipairs(Color.LIST) do
        for _, kind in ipairs(CSA.HAND) do
          local num = data.hands[color][kind]
          --  駒の表示
          str:append(shiori:talk("OnChessRenderHand", color, kind, num))
        end
      end
      --]]
      str:append(shiori:talk("OnChessRenderPost"))

      return str:tostring()
    end,
  },
  {
    id  = "OnChessDisplayHeader",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = ChessPlayer.getInstance()
      -- 対局者情報[optional] (reverseなし)
      local t = {}
      for _, v in ipairs(Color.LIST) do
        t[v]  = player:getHeader(Color.k(v))
      end
      if t[Color.BLACK] and t[Color.WHITE] then
        str:append(shiori:talk("OnChessRenderPlayerName", Misc.toArgs(t)))
      end

      -- 指し手の情報 (reverseなし)
      do
        str:append(shiori:talk("OnChessRenderMoveInfo", player:getTesuu(), player:getSashite()))
      end

      return str:tostring()
    end,
  },
  {
    id  = "OnChessViewControl",
    content = function(shiori, ref)
      local str = StringBuffer()
      if ref[0] == "move" then
        local player  = ChessPlayer.getInstance()
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
        local player  = ChessPlayer.getInstance()
        if      ref[1] == "TORYO" then
          str:append(shiori:talk("OnChessGameResign"))
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
    id  = "OnChessViewController",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnChessRenderController", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessViewComments",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = ChessPlayer.getInstance()
      local comments  = player:getComments()

      if comments then
        str:append(table.concat(comments, "\\n")):append(SS():n():n())
      end
      if player:getForksNum() > 1 then
        for i, v in ipairs(player:getForks()) do
          str:append(SS():q("【" .. player:getSashite(v) .. "】", "OnChessView", "move", "forward", i - 1))
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
    id  = "OnChessViewMinimal",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnChessDisplayMinimal", ref))
      str:append(shiori:talk("OnChessDisplayHeader", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessView",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnChessViewControl", ref))
        :append(shiori:talk("OnChessDisplayMinimal", ref))
        :append(shiori:talk("OnChessDisplayHeader", ref))
        :append(shiori:talk("OnChessViewController", ref))
        :append(shiori:talk("OnChessViewComments", ref))
      return str:tostring()
    end,
  },
}
