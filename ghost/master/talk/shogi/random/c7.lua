local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋トーク_C7",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク_C7",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1gk2nl/1r1s2g2/p2pppspp/2p3p2/1p5P1/2P3P1P/PPSPPP3/5S1R1/LN1GKG1NL b Bb 1")
      NOP(player + "4h3g")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
後手の△７四歩には▲７八金と上がらないと△７五歩〜△６五角とされて
馬を作られてしまってまずい……とよく言われるけど、
\s[きょとん]その後の手が意外と難しいんだね。
先手から7筋を逆襲したり、金銀で馬を捕獲したり出来るみたい。
]])
      return str
    end,
  },
}
