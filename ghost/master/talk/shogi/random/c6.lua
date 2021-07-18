local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")
local Utils = require("talk.shogi._utils")

return {
  {
    id  = "将棋トーク_C6",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク_C6",
    content = [[
\0
あひる囲いは大駒交換した後に、
自陣に大駒を打たれる手が生じにくいので、
大駒交換を積極的に狙っていくのがコツだよ。\n
\s[きょとん]逆に、この囲いを相手にするときは金銀を盛り上げていって
大駒を金銀で取りに行くといい感じかな。
]]
  },
  {
    id  = "将棋トーク_C6",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1gk2nl/1r4g2/p2pppspp/9/1ps3SP1/8P/PPSPPP3/2G4R1/LN2KG1NL w B2Pb2p 1")
      NOP(player + "P*3d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
早繰り銀でよく見られるこんな形。
\s[きょとん]△３四歩には▲２四歩から攻めていけることが多いんだけど、\n
\![*]相手玉が4筋に来ていない\n
\![*]相手の持ち駒に歩がある\n
\s[えー]この場合だけは▲２四歩が成立しなくて、
]])
      NOP(player + "2e2d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
▲２四歩に\w9
]])
      NOP(player + "3d3e")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
△３五銀と取る手があって、\w9
以下
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
        "2d2c+", "P*2g",
        "2h2g", "B*4e",
      }))
      str:append([[
\0
と進んだ局面がこれ。\n
\s[ほっ]飛車を逃げるとせっかく成った歩が取られてしまって気分は敗勢。\n
\s[えー]……とならないように、▲２四歩とするときは▲２三歩成としたときに
カウンターが来ないか注意してみてね。
]])
      return str
    end,
  },
  {
    id  = "将棋トーク_C6",
    content = [[
\0
長い詰みより短い必至、とはいうけれど、\n
\s[ドヤッ]「あ、必至かかるじゃん！@必至かけて勝ち！」\n
\s[素]……となる前に詰みがあるか読まなきゃだよね。
特に、王手を掛けていった先の必至の場合は手順を変えると
詰むこともあるからね。
]]
  },
}
