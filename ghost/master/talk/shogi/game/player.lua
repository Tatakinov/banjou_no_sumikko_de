local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = KifuPlayer.Color
local CSA   = KifuPlayer.CSA
local Misc  = require("shiori.misc")

return {
  {
    id  = "OnShogiGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
          :append(shiori:talk("OnShogiDisplayHeader", ref))
          :append(shiori:talk("OnShogiGameController", ref))

      local player  = KifuPlayer.getInstance()
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

      str:append(shiori:talk("OnShogiRenderPlayerTurnBeginPre"))
      --print("render1")

      for k, v in pairs(player_moves) do
        if type(k) == "number" then
          local x = k // 10
          local y = k %  10
          local piece = player:getPiece(x, y)
          local color = player:getTeban()
          --print("render id1: " .. tostring(x) .. ", " .. tostring(y))
          assert(piece.color == color)
          str:append(shiori:talk("OnShogiRenderPlayerTurnBeginSquare", color, x, y, k))
        elseif type(k) == "string" then
          local piece = k
          local color = player:getTeban()
          str:append(shiori:talk("OnShogiRenderPlayerTurnBeginHand", color, piece))
        else
          error("unknown type: " .. type(k))
        end
      end

      str:append(shiori:talk("OnShogiRenderPlayerTurnBeginPost"))

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGamePlayerSelectPiece",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
          :append(shiori:talk("OnShogiDisplayHeader", ref))
          :append(shiori:talk("OnShogiGameController", ref))
      --print("Caution: " .. str:tostring())

      local id      = ref[0]
      local id  = __("_GamePieceFrom")
      id  = tonumber(id) or id
      --print("id(" .. type(id) .. "): " .. id)
      local list    = __("_PlayerMoves")[id]

      --[[
      for k, v in pairs(list) do
        print("To:   " .. k)
      end
      --]]

      str:append(shiori:talk("OnShogiRenderSelectPiecePre"))
      str:append(shiori:talk("OnShogiRenderSelectPiece", id, player:getTeban()))
      str:append(shiori:talk("OnShogiRenderSelectPiecePost"))

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGamePlayerSelectPromote",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
          :append(shiori:talk("OnShogiDisplayHeader", ref))
          :append(shiori:talk("OnShogiGameController", ref))

      local id1     = ref[1]
      local id2     = ref[2]
      local id1 = __("_GamePieceFrom")
      local id2 = __("_GamePieceTo")

      id1 = assert(tonumber(id1) or id1)
      id2 = assert(tonumber(id2))

      local move  = assert(__("_PlayerMoves")[id1][id2])

      local promote, force
      if move.from then
        promote, force  = KifuPlayer.Misc.canPromote(move.color, move.from.y, move.to.y, move.piece)
      end

      if promote == true and force == false then
        str:append(shiori:talk("OnShogiRenderSelectPromotePre"))
        str:append(shiori:talk("OnShogiRenderSelectPromote", id1, id2))
        str:append(shiori:talk("OnShogiRenderSelectPromotePost"))
      else
        str:append(SS():raise("OnShogiGamePlayerTurnEnd", id1, id2, promote))
      end

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():_q(true))
      local str = StringBuffer()
      local id1     = ref[0]
      local id2     = ref[1]
      local id1 = __("_GamePieceFrom")
      local id2 = __("_GamePieceTo")
      local promote = ref[2] == "true"
      local player  = KifuPlayer.getInstance()

      id1 = assert(tonumber(id1) or id1)
      id2 = assert(tonumber(id2))

      local move  = assert(__("_PlayerMoves")[id1][id2])
      if promote then
        move.promote  = promote
      end

      player:appendMove(move)

      -- バルーンで描画する場合は必要
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
      str:append(shiori:talk("OnShogiDisplayHeader", ref))

      str:append(shiori:talk("OnShogiRenderPlayerTurnEnd"))

      if player:isSennichite() then
        str:append(SS():raise("OnShogiGameSennichite"))
      else
        str:append(SS():raise("OnShogiGameTurnBegin"))
      end

      --str:append(SS():_q(false))

      return str:tostring()
    end,
  },
}
