local KifuPlayer  = require("kifu_player")
local Misc  = require("talk.shogi._misc")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋トーク_C2",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/2S3S2/9/9/9/4S4/9/9 b - 1")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append(Misc.highlightArray(shiori, {
        {x = 2, y = 2},
        {x = 2, y = 4},
        {x = 4, y = 2},
        {x = 4, y = 4},
      }, 3, 1))
      str:append(Misc.highlightArray(shiori, {
        {x = 6, y = 2},
        {x = 7, y = 2},
        {x = 8, y = 2},
      }, nil, 1))
      str:append(Misc.highlightArray(shiori, {
        {x = 4, y = 6},
        {x = 4, y = 8},
        {x = 5, y = 6},
        {x = 6, y = 6},
        {x = 6, y = 8},
      }, 2, 1))
      str:append([[
\0
銀将は動きが覚えにくいから、\n
\f[underline,true]前方3マス\f[underline,false]と
\f[underline,true]斜めに1マス\f[underline,false]を\n
足したものと覚えると良いかも。
]])
      return str
    end,
  },
  {
    id  = "将棋トーク",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/2G3G2/9/9/9/4G4/9/9 b - 1")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append(Misc.highlightArray(shiori, {
        {x = 2, y = 3},
        {x = 3, y = 2},
        {x = 3, y = 4},
        {x = 4, y = 3},
      }, 3, 1))
      str:append(Misc.highlightArray(shiori, {
        {x = 6, y = 2},
        {x = 7, y = 2},
        {x = 8, y = 2},
      }, nil, 1))
      str:append(Misc.highlightArray(shiori, {
        {x = 4, y = 6},
        {x = 4, y = 7},
        {x = 5, y = 6},
        {x = 5, y = 8},
        {x = 6, y = 6},
        {x = 6, y = 7},
      }, 2, 1))
      str:append([[
\0
金将は銀将とよく間違えられるけど、\n
\f[underline,true]前方3マス\f[underline,false]と
\f[underline,true]十字に1マス\f[underline,false]を\n
足した6マス、と覚えると良いかも。
]])
      return str
    end,
  },
}
