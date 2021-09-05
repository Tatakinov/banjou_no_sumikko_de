return {
  {
    id  = "盤面モードのメニュー",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") == "Shogi" then
        return shiori:talk("盤面モードのメニュー(将棋)")
      elseif __("_Quiet") == "Mahjong" then
        return shiori:talk("盤面モードのメニュー(麻雀)")
      end
    end,
  },
  {
    id  = "他のゲームしたい",
    content = [[
\p[3]\s[-1]
\p[2]\s[-1]
\0\s[きょとん]
\_q
\n
\n
\![*]\q[バックギャモン,バックギャモンで遊ぶ]\n
\n
\n
\n
\n
\n
\![*]\q[戻る,メニュー] \![*]\q[閉じる,閉じる]
\_q
\_l[0,0]
今うちの部室で出来るのはこれだけだけど…@。\n
]],
    content_English = [[
\p[3]\s[-1]
\p[2]\s[-1]
\0\s[きょとん]
\_q
\n
\n
\![*]\q[Backgammon,バックギャモンで遊ぶ]\n
\n
\n
\n
\n
\n
\![*]\q[Return,メニュー] \![*]\q[Close,閉じる]
\_q
\_l[0,0]
This is the only game we can play in our club room now.\n
]],
  },
  {
    id  = "麻雀で遊ぶ",
    ---[=[
    content = [[
\0\s[ほっこり]
…。\n
じゃあ、雀卓と他の参加者集めてきてね…@。
]],
--]=]
  },
  {
    id  = "バックギャモンで遊ぶ",
    content = [[
\0
それじゃ用意するね。
\![raise,対局メニュー(BG)]
]],
  },
}
