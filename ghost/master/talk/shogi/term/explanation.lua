local KifuPlayer  = require("kifu_player")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋用語_解説",
    content = [[
\0
\_q
【形勢判断】\n
指しやすい ○○持ち 作戦勝ち\n
互角 有利 優勢 勝勢 難解\n
\n
【序盤】\n
飛車先 角道\n
\n
【中盤】\n
先手を取る\n
捌く 手順に\n
紐がついている\n
遊び駒 離れ駒\n
一手遅れている\n
\n
【終盤】\n
一手一手 即詰み 寄る\n
頑張る\n
大体詰み\n
\n
【その他】\n
数が足りていない\n
利き\n
自玉\n
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n
\_q
]],
  },
  {
    anchor  = true,
    id  = "大体詰み",
    content = [[
\0
ぱっと見詰みだし、解説者が読んだ範囲では詰んでいるけど、
絶対に詰み！@……とは言いきれない状態のこと。\n
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n
]],
  },
  {
    anchor  = true,
    id  = "指しやすい",
    content = [[
\0
形勢判断の一種。\n
ほぼ互角だけど、ちょっといい…かな？@くらいの感じ。
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n
]],
  },
  {
    anchor  = true,
    id  = "○○持ち",
    content = [[
\0
形勢判断の一種。\n
少し劣勢〜有利くらいの感覚。
この言葉が使われているなら勝負はまだこれから！って感じかな。\n
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n
]],
  },
  {
    anchor  = true,
    id  = "作戦勝ち",
    content = [[
\0
形勢判断の一種。\n
序盤で有利を築いた状態で、このまま有利を維持できれば勝てそう、な感じ。
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n
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
