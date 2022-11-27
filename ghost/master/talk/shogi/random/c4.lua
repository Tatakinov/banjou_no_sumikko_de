return {
  {
    id  = "将棋トーク_C4",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク",
    content = [[
\0
角交換になったりして持ち駒に角がある時は、両取りになる手がないか
一手進む毎に確認するぐらいの気持ちで指した方がいいよ。
\s[ほっ]角筋は本当にうっかりしやすいから……。
]]
  },
}
