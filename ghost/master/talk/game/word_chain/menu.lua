local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(WordChain)",
    content = nil,
  },
  {
    id  = "OnWordChainGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str = StringBuffer(SS():_q(true))

      shiori:talk("OnWordChainGameInitialize")

      local game_option = __("WordChainGameOption") or {
        player_color  = 1,
        variant = "survival",
        insensitive = true,
      }
      __("WordChainGameOption", game_option)

      if ref[0] == "teban" then
        if game_option.player_color == 1 then
          game_option.player_color  = 2
        elseif game_option.player_color == 2 then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = 1
        end
      end

      if ref[0] == "variant" then
        if game_option.variant == "survival" then
          game_option.variant = "maximum"
        elseif game_option.variant == "maximum" then
          game_option.variant = "survival"
        end
      end

      if ref[0] == "insensitive" then
        game_option.insensitive = not(game_option.insensitive)
      end

      local color
      if game_option.player_color == "random" then
        color = "ランダム"
      elseif game_option.player_color == 1 then
        color = "先手"
      elseif game_option.player_color == 2 then
        color = "後手"
      end
      str:append(SS():_l(20)):append("ユーザーの手番:")
          :append(SS():_l(120))
          :append(color)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnWordChainGameMenu", "teban"))
          :append("】")
          :append("\\n")

      local variant = {
        survival  = "サバイバル",
        maximum   = "マキシマム",
      }

      str:append(SS():_l(20)):append("ルール:")
          :append(SS():_l(120))
          :append(variant[game_option.variant])
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnWordChainGameMenu", "variant"))
          :append("】")
          :append("\\n")

      local insensitive = {
        [true]  = "しない",
        [false] = "する",
      }

      str:append(SS():_l(20)):append("濁点などの区別:")
          :append(SS():_l(120))
          :append(insensitive[game_option.insensitive])
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnWordChainGameMenu", "insensitive"))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(WordChain)") or {}
      __("成績(WordChain)", score_list)
      local score = score_list["ふつう"]
      if score == nil then
        score_list["ふつう"]  = {win = 0, lose = 0}
        score = score_list["ふつう"]
      end
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
      str:append(score.win):append("勝"):append(score.lose):append("敗")
      str:append("\\n")
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnWordChainGameStart"))
      str:append("  \\![*]"):append(SS():q("ルール説明", "OnWordChainGameExplanation"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append("      ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      str:append("\\![set,balloontimeout,0]\\![set,choicetimeout,0]")

      return str:tostring()
    end,
  },
  {
    id  = "OnWordChainGameExplanation",
    content = [[
\0
\_q【ルール説明】\n
\n
\![*]サバイバル\_q\n
50音のひらがなを1回ずつ使って先に言葉が思いつかなくなった方が負けのルールだよ。\n
ただし、1語の中では同じ文字を何回使ってもOK。
濁点半濁点小文字の区別はつけないよ。
また、伸ばし棒は母音に変換して考えるよ。\n
\n
\x
\_q【ルール説明】\n
\n
\![*]マキシマム\_q\n
基本的なルールはサバイバルと一緒だけど、
ゲーム終了までに使った文字の数が多い方が勝ちのルールだよ。
パスは有りで、両者がパスしたらその時点でゲームが終了するよ。\n
\n
\![*]\q[戻る,OnWordChainGameMenu]
]],
  },
}
