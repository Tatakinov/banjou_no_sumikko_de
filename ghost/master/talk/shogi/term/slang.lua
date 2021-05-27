local KifuPlayer    = require("kifu_player")
local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id      = "将棋用語_スラング",
    content = [[
\0
\_q
【か行】\n
クリックミス\n
\n
【な行】\n
NAGASE
\n
【は行】\n
飛車厨\n
\n
【わ行】\n
わっしょい
\n
\_q\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n\_q
\_q
]]
  },
  {
    anchor  = true,
    id      = "クリックミス",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      str:append([[
\0
\_q【クリックミス】\_q\w9\n
クリミスとも。ネット対局でたまに見られる現象。\n
]])
      player:setPosition("lnsgk1snl/1r4gb1/p1ppppppp/7p1/1p7/9/PPPPPPP1P/1BG4R1/LNS1KGSNL w p 1")
      player:appendMove("2c2d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\p[0]
図のような局面で、▲２四飛と歩を取りたかったのに、\_w[2000]操作を誤って
]])
      player:appendMove("2h2e")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\p[0]
▲２五の地点をクリックしてしまい、\_w[2000]
]])
      player:appendMove("2d2e")
      str:append(shiori:talk("OnShogiView"))
      str:append([[
\p[0]
相手に飛車を取られる…という感じのことだよ。\n
スマートフォンみたいな小さい画面だと起こりやすい印象。\n
\n
\_q\![*]\q[戻る,将棋用語_スラング] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "NAGASE",
    content = [[
\0
\_q【NAGASE】\_q\w9\n
千日手のこと。\n
由来は永瀬九段が千日手になりそうな局面で、
先手番でも喜んで千日手にすることから。
千日手にすることに関して、永瀬九段曰く、\n
「千日手にすればその分対局相手(強い人)と沢山指せて嬉しい。」だとか。\n
\n
\_q\![*]\q[戻る,将棋用語_スラング] \![*]\q[閉じる,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "飛車厨",
    content = [[
\0
\_q【飛車厨】\_q\w9\n
相手の飛車を取れるとみれば相手玉そっちのけで取りに行き、
自分の飛車が助かるのであれば自玉が詰もうが構わない、そんな人のこと。\n
\n
\_q\![*]\q[戻る,将棋用語_スラング] \![*]\q[閉じる,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "わっしょい",
    content = [[
\0
\_q【わっしょい】\_q\w9\n
持将棋のこと。\n
局面が入玉模様になってきた時に使う。\n
「これはもしかして〜ですか？」\n
（これはもしかして持将棋になりますか？）\n
\n
\_q\![*]\q[戻る,将棋用語_スラング] \![*]\q[閉じる,閉じる]\n\_q
]],
  },
}
