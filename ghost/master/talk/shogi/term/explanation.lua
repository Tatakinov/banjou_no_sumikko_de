local KifuPlayer  = require("kifu_player")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋用語_解説",
    content = [[
\0
\_q
一手一手 即詰み 寄る\n
頑張る\n
大体詰み\n
数が足りていない\n
先手を取る\n
飛車先 角道\n
捌く\n
紐がついている\n
手順に\n
遊び駒\n
離れ駒\n
利き\n
一手遅れている\n
自玉\n
\n
【形勢判断】
指しやすい ○○持ち 作戦勝ち\n
互角 有利 優勢 勝勢 難解\n
\_q\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n\_q
\_q
]],
  },
  {
    anchor  = true,
    id  = "頑張る",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln3ksnl/1r1sg1gb1/p2pppppp/2p6/7S1/9/PPPPPPP1P/1BG4R1/LNS1KG1NL b Pp 1")
      player:appendMove("P*2d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【頑張る】\_q\w9\n
自分の指し手の主張を通すために少し無理をすること。
\n
\![*]\q[戻る,将棋用語_解説] \![*]\q[閉じる,閉じる]\n
]])
    return str
    end,
  },
}
