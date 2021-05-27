local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋トーク_C9",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
}
