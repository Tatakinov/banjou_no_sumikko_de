local Clipboard = require("clipboard")
local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = KifuPlayer.Color
local CSA   = KifuPlayer.CSA
local IP    = KifuPlayer.InitialPreset
local Misc  = require("shiori.misc")
local Rand  = require("rand")

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
--- 盤面初期化,振り駒
  {
    id  = "OnShogiGameInit",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer(SS():C():p(0):c())
      --local str = StringBuffer(SS():p(0):c())
      local player  = KifuPlayer.getInstance()
      local game_option = __("GameOption")
      if game_option.preset ~= IP.HIRATE then
        __("_PlayerColor", Color.BLACK)
        str:append(SS():raise("OnShogiGameStart"))
      elseif game_option.player_color == "furigoma" then
        player:setPosition("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PP5PP/1B5R1/LNSGKGSNL b - 1")
        str:append(shiori:talk("OnShogiViewMinimal"))
        str:append("\\p[0]それじゃあ振り駒するね…………\\n")
            :append(SS():raise("OnShogiGameFurigoma"))
      else
        __("_PlayerColor", game_option.player_color)
        str:append(SS():raise("OnShogiGameStart"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameFurigoma",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer(SS():C())
      --local str = StringBuffer(SS():p(0))
      local player  = KifuPlayer.getInstance()
      local fu_num  = math.random(1, 5)
      local color = Color.BLACK

      str:append(SS():p(0))

      if fu_num < 3 then
        color = Color.WHITE
      end
      __("_PlayerColor", color)

      local pos_list = {}
      while #pos_list < 5 do
        local pos = {
          x = math.random(40, 130),
          y = math.random(40, 100),
        }
        local valid = true
        for i = 1, #pos_list do
          if (pos.x-pos_list[i].x)^2 + (pos.y-pos_list[i].y)^2 <= 28^2 then
            valid = false
          end
        end
        if valid then
          table.insert(pos_list, pos)
        end
      end

      for i = 1, #pos_list do
        local pos = pos_list[i]
        local filename  = "image/shogi/furigoma1.png"
        if i > fu_num then
          filename  = "image/shogi/furigoma2.png"
        end
        local x = math.random(0, 3)
        local y = math.random(0, 3)
        str:append(SS():_b({
          filename, pos.x, pos.y,
          clipping = (x * 28) .. " " .. (y * 28) .. " " .. ((x + 1) * 28) .. " " .. ((y + 1) * 28),
          --clipping = "0 0 28 28",
          use_self_alpha  = true,
        }))
      end
      --print(str:tostring())

      if color == Color.BLACK then
        str:append(SS():_w(math.random(1400, 1500)))
            :append("歩が"):append(fu_num):append("枚だから")
            :append("ユーザーが先手だよ。")
            :append(SS():_w(math.random(1400, 1500)))
      elseif color == Color.WHITE then
        str:append(SS():_w(math.random(1400, 1500)))
            :append("と金が"):append(5 - fu_num):append("枚だから")
            :append("私が先手だね。")
            :append(SS():_w(math.random(1400, 1500)))
      end

      player:setPosition()
      str:append(shiori:talk("OnShogiViewMinimal"))

      str:append(SS():raise("OnShogiGameStart"))

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      --local str = StringBuffer(SS():C():p(0):c())
      local str = StringBuffer(SS():C())
      local player  = KifuPlayer.getInstance()
      local game_option = __("GameOption")
      __("_Quiet", "Shogi")
      __("_InGame", true)
      __("_ScoreList", {})
      player:setPosition(game_option.preset)
      str:append(shiori:talk("OnShogiViewMinimal"))
      local player_color  = __("_PlayerColor")
      local reverse = player_color == Color.WHITE
      __("_BoardReverse", reverse)
      local moves  = {
        nodes = 0,
        pv  = {},
      }
      __("_CurrentMoves", moves)
      __("_CurrentScore", 0)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      --print("InitColor: " .. player:getTeban())
      shiori:talk("OnSetFanID")
      str:append(SS():p(0):c())
      str:append("よろしくお願いします。"):append(SS():_w(500))
      str:append(SS():b(-1):c())
      str:append(SS():raise("OnShogiGameTurnBegin"))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameResign",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local player    = KifuPlayer.getInstance()
      player:appendMove("resign")
      --[[
      -- ユーザーの操作で投了する場合は
      -- 詰みとは限らないのでScoreは追加しない。
      table.insert(__("_ScoreList"), {
        tesuu = player:getTesuu(),
        score = 9999,
      })
      --]]
      local score = __("成績")[__("SelectedEngine")]
      score.lose  = score.lose + 1
      shiori:talk("OnShogiEngineGameOver", "win")
      shiori:talk("OnQuitShogiEngine")
      str:append(shiori:talk("OnShogiRenderPlayerTurnEnd"))
      str:append(SS():p(0):s("座り_素")):append("ありがとうございました。@")
          :append(SS():_w(2000))
          :append(shiori:talk("OnShogiView", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameSennichite",
    content = function(shiori, ref)
      local str       = StringBuffer()
      local player    = KifuPlayer.getInstance()
      player:appendMove("千日手")
      shiori:talk("OnShogiEngineGameOver", "draw")
      shiori:talk("OnQuitShogiEngine")
      str:append(SS():p(0):s("座り_素")):append("千日手だよ。")
          :append(SS():_w(2000))
          :append(shiori:talk("OnShogiView", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameTurnBegin",
    content = function(shiori, ref)
      local __            = shiori.var
      --local str           = StringBuffer(SS():C())
      local str           = StringBuffer()
      local player        = KifuPlayer.getInstance()
      local player_color  = __("_PlayerColor")
      __("_GameState", "begin")
      print("sfen: " .. player:toSfen())
      --if player:getTeban() == Color.BLACK or true then
      if player:getTeban() == player_color then
        -- user
        str:append(SS():raise("OnShogiGamePlayerTurnBegin"))
      else
        -- engine
        str:append(SS():raise("OnShogiGameEngineTurnBegin"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameController",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiRenderGameController", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnTalkAnalysisResult",
    content = function(shiori, tbl)
      local __  = shiori.var
      local player  = KifuPlayer.getInstance()

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
      local player        = KifuPlayer.getInstance()
      local hwnd  = __("_hwnd")
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
        local player        = KifuPlayer.getInstance()
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
