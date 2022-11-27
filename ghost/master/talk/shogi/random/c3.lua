local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋トーク_C3",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク",
    content = [[
\0
歩と歩がぶつかったらほとんどの場合は取る一手だよ。\n
たまに取っちゃいけない歩もあったりするけど、
そういう手はやられて覚えよう。
]]
  },
  {
    id  = "将棋トーク",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition()
      NOP(player + "7g7f" + "3c3d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
最序盤の▲７六歩△３四歩の局面だよ。\n
\s[きょとん]ここでうっかり銀を上がってしまうと……\n
]])
      NOP(player + "7i7h")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\x
]])
      NOP(player + "2b8h+")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\s[ほっ]角をただで取られた上に馬まで作られてゲームセット。\n
\s[素]矢倉や四間飛車を指そうとした時にやりがちなので気をつけてね。\n
]])
      return str
    end,
  },
}
