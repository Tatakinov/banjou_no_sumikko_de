local Mancala       = require("mancala")
local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Mancala)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnMancalaGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "盤面モードのメニュー(Mancala)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnMancalaGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnMancalaGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str         = StringBuffer()
      local game_option = __("MancalaGameOption") or {
        player_color  = 1,
        variant       = "Kalah",
        cpu_level     = 1,
      }

      __("MancalaGameOption", game_option)

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
        local cpu_level = tonumber(ref[1]) or 1
        if cpu_level >= 1 and cpu_level <= 16 then
          game_option.cpu_level = cpu_level
        end
      end

      __("_Mancala", Mancala(game_option.variant))
      shiori:saori("mancala")("variant", game_option.variant)
      str:append(shiori:talk("OnMancalaView"))
      str:append(SS():_q(true):p(0):s("座り_素"):c())

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
          :append(SS():q("変更", "OnMancalaGameMenu", "teban"))
          :append("】")
          :append("\\n")

      str:append(SS():_l(20)):append("CPUの強さ:")
          :append(SS():_l(120))
          :append(game_option.cpu_level)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnMancalaGameConfig", "cpu_level"))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Mancala)") or {}
      __("成績(Mancala)", score_list)
      local score = score_list[game_option.variant]
      if score == nil then
        score_list[game_option.variant] = {win = 0, lose = 0}
        score = score_list[game_option.variant]
      end
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
      str:append(score.win):append("勝"):append(score.lose):append("敗")
      str:append("\\n")
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnMancalaGameStart"))
      str:append("  \\![*]"):append(SS():q("ルールとかの説明", "OnMancalaGameExplanation"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnMancalaGameConfig",
    content = function(shiori, ref)
      return string.format([=[\![open,inputbox,OnMancalaGameConfig_%s]]=], ref[0])
    end,
  },
  {
    id  = "OnMancalaGameConfig_cpu_level",
    content = function(shiori, ref)
      return string.format([=[\![raise,OnMancalaGameMenu,cpu_level,%s]]=], ref[0])
    end,
  },
  {
    id  = "OnMancalaGameExplanation",
    content = [[
\0
\![*]陣地\n
    わたしの陣地は上側の穴と左の大穴(ストア)、\n
    ${User}の陣地は下側の穴と右のストアだよ。\n
\n
\![*]基本的な動かし方(ラップ)\n
    石のある穴を左クリックすると選択出来るよ。\n
    選択した穴にある石を反時計周りに1つずつ\n
    蒔いていくのが基本的な動作になるよ。\n
\n
次からはルール説明だよ。\n
\x
\_q\![*]カラハ\_q\n
    * 勝利条件\n
      自分のストアの数字が相手より大きければ勝ちだよ。\n
    * 決着\n
      どちらかの陣地の穴が空になった時点で決着がついて、\n
      その時穴に残っている石は\n
      その陣地の所有者のストアに移動するよ。\n
\n
\n
- 続く -\n
\x
\_q\![*]カラハ\_q\n
    * 手番\n
      基本的には交互にラップを行うけど、\n
      最後に蒔いた石が自分のストアだった場合、\n
      もう一回動けるよ。\n
    * ラップ\n
      ラップを行う時、自分のストアには石を蒔くけど、\n
      相手のストアには蒔かないよ。\n
\n
- 続く -\n
\x
\_q\![*]カラハ\_q\n
    * 特殊な石取り\n
      ラップが自陣で終わったとき、\n
      最後の石を蒔いた場所が蒔く前は空で、\n
      その場所の反対側の相手陣の穴に石がある場合、\n
      その石と最後に蒔いた石を自分のストアに\n
      入れることが出来るよ。\n
\p[9]
\![bind,MANCALA0101,0,1]
\![bind,MANCALA0102,2,1]
\![bind,MANCALA0103,0,1]
\![bind,MANCALA0104,0,1]
\![bind,MANCALA0105,0,1]
\![bind,MANCALA0106,0,1]
\![bind,MANCALA0201,0,1]
\![bind,MANCALA0202,0,1]
\![bind,MANCALA0203,3,1]
\![bind,MANCALA0204,0,1]
\![bind,MANCALA0205,0,1]
\![bind,MANCALA0206,0,1]
\0
      図の場合、自分の石1つと相手の石3つを\n
      自分のストアに入れられるよ。\n
\n
\![*]\q[戻る,OnMancalaGameMenu]
]],
  },
}
