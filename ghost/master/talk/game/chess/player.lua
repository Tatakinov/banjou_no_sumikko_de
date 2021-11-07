local ChessPlayer = require("chess_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = ChessPlayer.Color
local CSA   = ChessPlayer.CSA
local Misc  = require("shiori.misc")

return {
  {
    id  = "OnChessGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()

      str:append(shiori:talk("OnChessDisplayMinimal", ref))
          :append(shiori:talk("OnChessDisplayHeader", ref))
          :append(shiori:talk("OnChessGameController", ref))

      local player  = ChessPlayer.getInstance()
      local moves   = player:generateMoves()

      local player_moves  = {}
      __("_PlayerMoves", player_moves)

      for _, move in ipairs(moves) do
        local id1 = move.piece
        if move.from then
          id1 = move.from.x * 10 + move.from.y
        end
        if player_moves == nil then
          player_moves  = {}
        end
        if player_moves[id1] == nil then
          player_moves[id1] = {}
        end
        local id2 = move.to.x * 10 + move.to.y
        player_moves[id1][id2]  = move
      end

      --[[
      for k, v in pairs(player_moves) do
        print("From: " .. k)
      end
      --]]

      str:append(shiori:talk("OnChessRenderPlayerTurnBeginPre"))
      --print("render1")

      for k, v in pairs(player_moves) do
        if type(k) == "number" then
          local x = k // 10
          local y = k %  10
          local piece = player:getPiece(x, y)
          local color = player:getTeban()
          --print("render id1: " .. tostring(x) .. ", " .. tostring(y))
          assert(piece.color == color)
          str:append(shiori:talk("OnChessRenderPlayerTurnBeginSquare", color, x, y, k))
        elseif type(k) == "string" then
          local piece = k
          local color = player:getTeban()
          str:append(shiori:talk("OnChessRenderPlayerTurnBeginHand", color, piece))
        else
          error("unknown type: " .. type(k))
        end
      end

      str:append(shiori:talk("OnChessRenderPlayerTurnBeginPost"))

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnChessGamePlayerSelectPiece",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      local player  = ChessPlayer.getInstance()
      str:append(shiori:talk("OnChessDisplayMinimal", ref))
          :append(shiori:talk("OnChessDisplayHeader", ref))
          :append(shiori:talk("OnChessGameController", ref))
      --print("Caution: " .. str:tostring())

      --local id      = ref[0]
      local id  = __("_GamePieceFrom")
      id  = tonumber(id) or id
      --print("id(" .. type(id) .. "): " .. id)
      local list    = __("_PlayerMoves")[id]

      --[[
      for k, v in pairs(list) do
        print("To:   " .. k)
      end
      --]]

      str:append(shiori:talk("OnChessRenderSelectPiecePre"))
      str:append(shiori:talk("OnChessRenderSelectPiece", id, player:getTeban()))
      str:append(shiori:talk("OnChessRenderSelectPiecePost"))

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnChessGamePlayerSelectPromote",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      str:append(shiori:talk("OnChessDisplayMinimal", ref))
          :append(shiori:talk("OnChessDisplayHeader", ref))
          :append(shiori:talk("OnChessGameController", ref))

      --local id1     = ref[1]
      --local id2     = ref[2]
      local id1 = __("_GamePieceFrom")
      local id2 = __("_GamePieceTo")

      id1 = assert(tonumber(id1) or id1)
      id2 = assert(tonumber(id2))

      local move  = assert(__("_PlayerMoves")[id1][id2])

      local promote, force
      if move.from then
        promote, force  = ChessPlayer.Misc.canPromote(move.color, move.from.y, move.to.y, move.piece)
      end

      if promote == true and force == false then
        str:append(shiori:talk("OnChessRenderSelectPromotePre"))
        str:append(shiori:talk("OnChessRenderSelectPromote", id1, id2))
        str:append(shiori:talk("OnChessRenderSelectPromotePost"))
      else
        str:append(SS():raise("OnChessGamePlayerTurnEnd", id1, id2, promote))
      end

      return str:tostring()
    end,
  },
  {
    id  = "OnChessGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      --local id1     = ref[0]
      --local id2     = ref[1]
      local id1 = __("_GamePieceFrom")
      local id2 = __("_GamePieceTo")
      local promote = ref[2] == "true"
      local player  = ChessPlayer.getInstance()

      id1 = assert(tonumber(id1) or id1)
      id2 = assert(tonumber(id2))

      local move  = assert(__("_PlayerMoves")[id1][id2])
      if promote then
        move.promote  = promote
      end

      player:appendMove(move)

      -- バルーンで描画する場合は必要
      str:append(shiori:talk("OnChessDisplayMinimal", ref))
      str:append(shiori:talk("OnChessDisplayHeader", ref))

      str:append(shiori:talk("OnChessRenderPlayerTurnEnd"))

      if player:isSennichite() then
        str:append(SS():raise("OnChessGameSennichite"))
      else
        str:append(SS():raise("OnChessGameTurnBegin"))
      end

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
}
