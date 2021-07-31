local BGPlayer      = require("backgammon_player")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "対局メニュー(BG)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      __("_BGPlayer", BGPlayer())
      __("_BGPlayer"):initialize()
      str:append(shiori:talk("OnBackgammonRender", "false", "false"))
      str:append([[
\_q
\0\s[素]
\![*]\q[対局開始,対局開始(BG)]\n
\![*]\q[操作説明,操作説明(BG)]\n
\n
\![*]\q[戻る,他のゲームしたい] \![*]\q[閉じる,閉じる]
\_q
]])
      return str
    end,
  },
  {
    id  = "対局開始(BG)",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append("\\![raise,OnBackgammonGameStart]")
      return str
    end,
  },
  {
    id  = "ルール説明(BG)",
    content = [[
\_q
\0
バックギャモンは歴史ある双六ゲームだよ。\n
自分の15個の駒すべてを相手の15個の駒より早くゴールさせれば勝ち。\n
\n
盤面は右上、左上、左下、右下の各6マス、計24マスから出来てて、
白番(${User}側)は右上〜右下を反時計回りに、
黒番は右下〜右上を時計回りに駒を進めていくことになるよ。\n
\n
バックギャモンにはおおまかに2つのフェーズがあるから順番に説明していくね。\n
\_q
\x
\![*]第一フェーズ(ベアリングイン)
このゲームでは、駒をゴールさせるためには、
すべての駒を1-6ポイント(白番なら右下のエリア)に集める必要があるよ。
]]
  },
  {
    id  = "操作説明(BG)",
    content = [[
\0\b[2]
\_q
\![*]駒\n
駒を移動する\n
\n
\![*]左のダイス\n
ダイス目の順番を入れ替える\n
移動した駒の確定を行う\n
\n
\![*]右のダイス\n
動かせる駒が無いときに動かせない回数分押す\n
移動した駒の確定を行う\n
\n
\![*]それいがいの部分を右クリック\n
移動した駒を戻す(undo)\n
\n
\![*]\q[戻る,対局メニュー(BG)] \![*]\q[閉じる,閉じる]
\_q
]]
  },
}
