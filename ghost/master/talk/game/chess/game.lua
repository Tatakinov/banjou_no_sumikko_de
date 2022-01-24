local Clipboard = require("clipboard")
local ChessPlayer = require("chess_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = ChessPlayer.Color
local IP    = ChessPlayer.InitialPreset
local Misc  = require("shiori.misc")
local Rand  = require("rand")

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
--- 盤面初期化,振り駒
  {
    id  = "OnChessGameInit",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer(SS():C():p(0):c())
      --local str = StringBuffer(SS():p(0):c())
      local player  = ChessPlayer.getInstance()
      local game_option = __("ChessGameOption")
      if game_option.preset ~= IP.HIRATE then
        __("_PlayerColor", Color.WHITE)
        str:append(SS():raise("OnChessGameStart"))
      elseif game_option.player_color == "random" then
        if math.random(1, 2) == 2 then
          __("_PlayerColor", Color.WHITE)
        else
          __("_PlayerColor", Color.BLACK)
        end
        str:append(SS():raise("OnChessGameStart"))
      else
        __("_PlayerColor", game_option.player_color)
        str:append(SS():raise("OnChessGameStart"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():p(0):c())
      local str = StringBuffer(SS():C())
      local player  = ChessPlayer.getInstance()
      local game_option = __("ChessGameOption")
      __("_Quiet", "Chess")
      __("_InGame", true)
      __("_ScoreList", {})
      player:setPosition(game_option.preset)
      str:append(shiori:talk("OnChessViewMinimal"))
      local player_color  = __("_PlayerColor")
      local reverse = player_color == Color.BLACK
      print("BoardReverse", reverse)
      __("_BoardReverse", reverse)
      local moves  = {
        nodes = 0,
        pv  = {},
      }
      __("_CurrentMoves", moves)
      __("_CurrentScore", 0)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      __("_Fen", nil)
      --print("InitColor: " .. player:getTeban())
      shiori:talk("OnSetFanID")
      str:append(SS():p(0):c())
      str:append("よろしくお願いします。"):append(SS():_w(500))
      str:append(SS():b(-1):c())
      str:append(SS():raise("OnChessGameTurnBegin"))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameResign",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local player    = ChessPlayer.getInstance()
      --player:appendMove("resign")
      --[[
      -- ユーザーの操作で投了する場合は
      -- 詰みとは限らないのでScoreは追加しない。
      table.insert(__("_ScoreList"), {
        tesuu = player:getTesuu(),
        score = 9999,
      })
      --]]
      local score = __("成績(Chess)")[__("SelectedChessEngine")]
      score.lose  = score.lose + 1
      shiori:talk("OnChessEngineGameOver", "win")
      shiori:talk("OnQuitChessEngine")
      str:append(shiori:talk("OnChessRenderPlayerTurnEnd"))
      str:append(SS():p(0):s("座り_素")):append("ありがとうございました。@")
          :append(SS():_w(2000))
          :append(shiori:talk("OnChessView", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameStalemate",
    content = function(shiori, ref)
      local str       = StringBuffer()
      local player    = ChessPlayer.getInstance()
      shiori:talk("OnChessEngineGameOver", "draw")
      shiori:talk("OnQuitChessEngine")
      str:append(SS():p(0):s("座り_素")):append("ステイルメイトだよ。")
          :append(SS():_w(2000))
          :append(shiori:talk("OnChessView", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameSennichite",
    content = function(shiori, ref)
      local str       = StringBuffer()
      local player    = ChessPlayer.getInstance()
      --player:appendMove("千日手")
      shiori:talk("OnChessEngineGameOver", "draw")
      shiori:talk("OnQuitChessEngine")
      str:append(SS():p(0):s("座り_素")):append("千日手だよ。")
          :append(SS():_w(2000))
          :append(shiori:talk("OnChessView", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameTurnBegin",
    content = function(shiori, ref)
      local __            = shiori.var
      --local str           = StringBuffer(SS():C())
      local str           = StringBuffer()
      local player        = ChessPlayer.getInstance()
      local player_color  = __("_PlayerColor")
      __("_GameState", "begin")
      print("fen: " .. player:toSfen())
      --if player:getTeban() == Color.BLACK or true then
      if player:getTeban() == player_color then
        -- user
        str:append(SS():raise("OnChessGamePlayerTurnBegin"))
      else
        -- engine
        str:append(SS():raise("OnChessGameEngineTurnBegin"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnChessGameController",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnChessRenderGameController", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnTalkAnalysisResult",
    content = function(shiori, tbl)
      local __  = shiori.var
      local player  = ChessPlayer.getInstance()

      local judgement = __("_AnalysisResult_Judgement") or {}
      local dist2     = __("_AnalysisResult_JudgementDistribution2") or {0, 0, 0}
      local turn_count  = __("_AnalysisResult_TurnCount") or 0
      local last_judge  = __("_AnalysisResult_LastJudgement") or 0
      local point_move  = __("_AnalysisResult_PointMove") or {}

      local genHash = function(str)
        local num = 0
        for _, v in ipairs({str:byte(1, -1)}) do
          num = num + v
        end
        return num
      end

      local getComment  = function(array, prng)
        return array[prng(#array)]
      end

      local prng  = Rand(genHash(tostring(player:getMoveFormat(0))))

      local plus_comment = {
        "\\s[座り_ヮ]%d手目辺りで形勢が良くなった気がする。",
        "\\s[座り_ヮ]%d手目辺りで指しやすくなったかも。@",
      }
      local minus_comment = {
        "%d手目辺りで形勢が悪くなってる気がする。",
        "%d手目辺りは既にちょっとずつ押されてきてるかも…。",
      }
      local append_comment  = {
        "\\s[座り_素]その後、",
        "\\s[座り_素]そこから進んで、",
      }

      local str = StringBuffer(SS():p(0))
      for i, v in ipairs(judgement) do
        if i > 1 then
          str:append(getComment(append_comment, prng))
        end
        if v.sign == 1 then
          str:append(getComment(minus_comment, prng):format(v.n) .. "\\n")
        else
          str:append(getComment(plus_comment, prng):format(v.n) .. "\\n")
        end
      end

      local possesion_plus_comment = {
        "\\s[座り_ヮ]わたしが主導権を握る展開だったかな。",
      }
      local possesion_minus_comment = {
        "\\s[座り_素]${User}が主導権を握ってたかな。",
      }
      local possesion_both_comment  = {
        "\\s[座り_きょとん]お互い形勢の良い局面がある対局だったかな。",
      }
      local possesion_equal_comment = {
        "\\s[座り_素]最後まで互角の良い勝負が出来てたかな。",
      }

      local possesion  = dist2[1] - dist2[3]
      if possesion > 0 then
        str:append(getComment(possesion_plus_comment, prng) .. "\\n")
      elseif possesion < 0 then
        str:append(getComment(possesion_minus_comment, prng) .. "\\n")
      else
        if #judgement > 0 then
          str:append(getComment(possesion_both_comment, prng) .. "\\n")
        else
          str:append(getComment(possesion_equal_comment, prng) .. "\\n")
        end
      end
      local natural_plus_validity_comment = {
        "\\s[座り_ドヤッ]わたしがうまく勝ちきれたと思う。",
      }
      local natural_minus_validity_comment  = {
        "\\s[座り_素]${User}に最後までうまく指されちゃったね。",
      }
      local unnatural_plus_validity_comment = {
        "\\s[座り_きょとん]えっと…途中までは${User}が良かった気がする。",
      }
      local unnatural_minus_validity_comment  = {
        "\\s[座り_きょとん]途中まで良かったはずなんだけどなぁ。\\s[座り_ふむ]うーん…。",
      }
      local madamada_validity_comment = {
        "\\s[座り_きょとん]まだまだこれからって局面だった気がするけど…。",
      }
      local nankai_hawks_validity_comment = {
        "\\s[座り_素]最後は難しい局面になっちゃったね…。",
      }
      local validity = possesion * last_judge
      if validity > 0 then
        -- わざわざコメントするまでもなさそうなのでコメントアウト。
        if last_judge > 0 then
          --str:append(getComment(natural_plus_validity_comment, prng) .. "\\n")
        else
          --str:append(getComment(natural_minus_validity_comment, prng) .. "\\n")
        end
      elseif validity < 0 then
        if last_judge > 0 then
          str:append(getComment(unnatural_plus_validity_comment, prng) .. "\\n")
        else
          str:append(getComment(unnatural_minus_validity_comment, prng) .. "\\n")
        end
      else
        if #judgement == 0 then
          str:append(getComment(madamada_validity_comment, prng) .. "\\n")
        elseif last_judge == 0 then
          str:append(getComment(nankai_hawks_validity_comment, prng) .. "\\n")
        else
          -- TODO
        end
      end

      local turn_comment  = {
        "形勢が二転三転する将棋だったね。",
      }
      if turn_count > 3 then
        str:append(getComment(turn_comment, prng) .. "\\n")
      end

      if #point_move > 0 then
        str:append([[\s[座り_きょとん]対局で気になった手は……\n]])
        for _, v in ipairs(point_move) do
          if v.sign == 1 then
            str:append(v.n .. [[手目で${User}に疑問手？\n]])
          elseif v.sign == 2 then
            str:append((v.n + 1) .. [[手目で${User}が詰み逃し？\n]])
          elseif v.sign == -1 then
            str:append((v.n + 1) .. [[手目で${User}が好手！\n]])
          elseif v.sign == -2 then
            str:append(v.n .. [[手目でわたしが詰み逃し…てる？\n]])
          end
        end
        str:append([[かな。\s[座り_素]わたしもあんまり強くないから参考程度でね。]])
      end
      return str
    end,
  },
  {
    id  = "OnCopyKifuToClipboard",
    content = function(shiori, tbl)
      local __      = shiori.var
      local hwnd    = __("_hwnd")
      local player  = ChessPlayer.getInstance()
      if Clipboard.set(hwnd.ghost[1], player:toKIF("Shift_JIS")) then
        return [[\0クリップボードに棋譜をコピーしたよ。]]
      else
        return [[\0クリップボードへのコピーに失敗したよ。]]
      end
    end,
  },
  {
    id  = "OnSaveKifu",
    content = function(shiori, ref)
      local str = StringBuffer()
      if ref[0] == "save" then
        -- TODO save
        local fh  = io.open(ref[2], "wb")
        if fh == nil then
          return [[\0保存に失敗したよ。]]
        end
        local player        = ChessPlayer.getInstance()
        fh:write(player:toKIF("Shift_JIS"))
        fh:close()
        return [[\0保存したよ。]]
      elseif ref[0] == "cancel" then
        return nil
      else
        str:append(SS():dialog("save", {
          title   = "棋譜ファイルの保存",
          filter  = "棋譜ファイル|*.kif|全てのファイル|*.*",
          id      = "OnSaveKifu",
          dir     = "__system_desktop__",
        }))
      end
      return str
    end,
  },
}
