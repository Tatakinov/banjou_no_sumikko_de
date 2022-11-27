local Misc  = require("shiori.misc")
local Clipboard = require("clipboard")

return {
  {
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") then
        return nil
      end
      return shiori:talk("ランダムトーク")
    end,
  },
  --[[
  {
    id  = "ランダムトーク",
    content = function(shiori, ref)
      return shiori:talk("雑談トーク")
    end,
  },
  --]]
  {
    id  = "ランダムトーク",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "ランダムトーク_",
    content = function(shiori, ref)
      if math.random(1, 10) == 1 then
        return shiori:talk("イベントトーク")
      end
      return shiori:talk("ランダムトーク")
    end,
  },
}
