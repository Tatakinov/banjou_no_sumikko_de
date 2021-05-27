local KifuPlayer  = require("kifu_player")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋用語_手筋",
    content = [[
\0
底歩 合わせの歩 垂れ歩 継ぎ歩\n
田楽刺し 歩の裏から香を打て\n
ふんどしの桂 跳ね違いの桂 パンツを脱ぐ\n
銀挟み 腹銀\n
王手○○取り\n
両王手\n
\n
\_q\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id  = "底歩",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/5p3/9/2P6/1PSP5/1K3G1r1/PN7 b Ps 1")
      player:appendMove("P*4i")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【底歩】\_q\w9\n
底歩は1段目に打つ歩のことだよ。\n
歩一枚で自陣の守りを強くする大事な手筋で、
大体はこの盤面みたいに金の下に打つことが多いね。\n
\n
底歩を打つと歩の上にいる駒はただで取れなくなって
その駒を取るために新に攻め駒を用意する必要が出てくるので、
相手の攻めを遅らせることができるよ。
\x
]])
      player:setPosition("9/9/9/5p3/9/2P6/1PSP5/1K3G1r1/PN7 b Ps 1")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【底歩を打たなかった場合】\_q\w9\n
]])
      player:appendMove("9i9h")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
先手が好きな手を指して、
]])
      player:appendMove("2h4h+")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
後手が金を取るとこの局面。\w9\w9\n
先手は好きな手を1手指せていて、後手は持ち駒に金と銀。
\x
]])
      player:setPosition("9/9/9/5p3/9/2P6/1PSP5/1K3G1r1/PN7 b Ps 1")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【底歩を打った場合】\_q\w9\n
]])
      player:appendMove("P*4i")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
先手は底歩を打って、
]])
      player:appendMove("S*4g")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
後手は銀を打つ。\n
]])
      player:appendMove("9i9h")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
先手は好きな手を指して、
]])
      player:appendMove("4g4h+")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
後手は金を取って、\n
]])
      player:appendMove("9h9g")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
先手は好きな手を指して、
]])
      player:appendMove("4h4i")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
後手は歩を取ってこの局面。\w9\w9\n
先手は好きな手を2手指していて、後手の持ち駒は金と歩。\n
底歩を打たないときと比べて、好きな手を1手追加で指せていて、
相手の持ち駒が{金、銀}から{金、歩}に変わっているよ。
\x
\0
歩一枚で、自分の攻めるターンを増やしつつ、相手の攻め駒も減らすことが出来る、
ローリスクハイリターンな手筋だよ。\n
\n
\![*]\q[戻る,将棋用語_手筋] \![*]\q[閉じる,閉じる]\n
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "合わせの歩",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln3ksnl/1r1sg1gb1/p2pppppp/2p6/7S1/9/PPPPPPP1P/1BG4R1/LNS1KG1NL b Pp 1")
      player:appendMove("P*2d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【合わせの歩】\_q\w9\n
相手の歩の利きに持ち駒の歩を打つこと。\n
攻め駒を前進させたり、飛車で横歩を取ったり、
十字飛車を狙ったりするときに使われることが多いよ。
\n
\![*]\q[戻る,将棋用語_手筋] \![*]\q[閉じる,閉じる]\n
]])
    return str
    end,
  },
  {
    anchor  = true,
    id      = "パンツを脱ぐ",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/2P6/PP7/LS7/KNG6 b - 1")
      player:appendMove("8i7g")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【パンツを脱ぐ】\_q\w9\n
パンツを脱ぐとは穴熊囲いの桂馬を跳ねることだよ。\n
主に相穴熊で見られる手筋で、囲いの上部の攻め合いに強くなるね。
ただ、横からの攻めには弱くなってしまうので注意。\n
\w9\n
\s[きょとん]名前の由来？@\n
えっと……大事なところが露出して、\n
下の方がスースー…\s[照れ]……。\n
んん゛っ…穴熊の桂馬はぱんつみたいに大事だからかなっ。\n
\n
\![*]\q[戻る,将棋用語_手筋] \![*]\q[閉じる,閉じる]\n
]])
      return str:tostring()
    end,
  },
}
