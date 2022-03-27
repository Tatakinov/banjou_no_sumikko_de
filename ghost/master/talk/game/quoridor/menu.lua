local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Quoridor)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnQuoridorGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnQuoridorGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local quoridor    = shiori:saori("quoridor")
      local str         = StringBuffer()
      local game_option = __("QuoridorGameOption") or {
        player_color  = 1,
        cpu_level     = 2,
      }
      -- 互換性
      game_option.cpu_level = game_option.cpu_level or 2
      game_option.num_player  = game_option.num_player or 2

      __("QuoridorGameOption", game_option)

      if ref[0] == "num_player" then
        if game_option.num_player == 2 then
          game_option.num_player  = 3
          game_option.player_color  = 1
        elseif game_option.num_player == 3 then
          game_option.num_player  = 4
          game_option.player_color  = 1
        elseif game_option.num_player == 4 then
          game_option.num_player  = 2
          game_option.player_color  = 1
        end
      end

      if ref[0] == "teban" then
        if game_option.player_color == 1 then
          game_option.player_color  = 2
        elseif game_option.player_color == 2 then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = 1
        end
      end

      if ref[0] == "cpu_level" then
        local level = tonumber(ref[1]) or 2
        if level >= 1 and level <= 2 then
          game_option.cpu_level = level
        end
      end

      quoridor("init", game_option.num_player)
      str:append(shiori:talk("OnQuoridorView", ref))
      str:append(SS():_q(true):p(0):s("座り_素"):c())

      --str:append("メニュー\\n")
      local color
      if game_option.player_color == "random" then
        color = "ランダム"
      elseif game_option.player_color == 1 then
        color = "先手"
      elseif game_option.player_color == 2 then
        color = "後手"
      end

      str:append("\\0\\s[素]")
      str:append(SS():_l(20)):append("ユーザーの手番:")
          :append(SS():_l(120))
          :append(color)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnQuoridorGameMenu", "teban"))
          :append("】")
          :append("\\n")

      str:append(SS():_l(20)):append("CPUレベル:")
          :append(SS():_l(120))
          :append(game_option.cpu_level)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnQuoridorChangeOption", "cpu_level", game_option.cpu_level))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Quoridor)") or {}
      __("成績(Quoridor)", score_list)
      local score = score_list[game_option.cpu_level]
      if score == nil then
        score_list[game_option.cpu_level]  = {win = 0, lose = 0}
        score = score_list[game_option.cpu_level]
      end
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
      str:append(score.win):append("勝"):append(score.lose):append("敗")
      str:append("\\n")
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnQuoridorGameStart"))
      str:append("  \\![*]"):append(SS():q("ルール説明と宣伝", "OnQuoridorGameExplanation"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnQuoridorChangeOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local name      = ref[0]
      local value     = ref[1]
      assert(name and value)
      str:append(SS():C():inputbox("OnQuoridorChangedOption", 0, value))
      return str:tostring()
    end,
  },
  {
    id  = "OnQuoridorChangedOption",
    content = function(shiori, ref)
      return SS():raise("OnQuoridorGameMenu", "cpu_level", ref[0])
    end,
  },
  {
    id  = "OnQuoridorGameExplanation",
    content = [[
\0
\![*]勝敗\n
自分の駒を相手より先に反対側へ移動できたら勝ちだよ。\n
\n
\![*]手番時の行動\n
駒を上下左右のいずれかに1マス(※1※2)移動するか、\n
板を置いて盤上に通行できない場所を作るか(※3)のどちらか。\n
\n
※1: 板を飛び越えることは出来ないよ。\n
※2: 移動先に相手の駒がある場合は飛び越えることが出来るよ。\n
※3: どのプレイヤーもゴールに到達出来るようにしなければいけないよ。\n
\n
板をうまく使って相手に遠回りさせつつ自分は短距離を進めるような道を作るのがコツ。\n
\n
\x
ルールが覚えやすいのでコリドールを知らない人ともすぐに遊べて、
2人でじっくり遊ぶことも出来るし4人でワイワイ遊ぶことも出来る。\n
\_w[1000]\n
\s[ドヤッ]
そんなコリドールがなんと3740円(miniの場合)！@\n
100回遊べば1回40円！@安いね！@\n
面白いと思ったら買って友人と遊んでみてね！@\n
\n
\![*]\q[戻る,OnQuoridorGameMenu]
]],
  },
}
