return {
  {
    id      = "盤面モード終了",
    content = function(shiori, ref)
      local __  = shiori.var
      --[[
      local process = shiori:saori("process")
      process("despawn", __("_EnginePID"))
      --]]
      __("_Quiet", false)
      __("_PostGame", false)
      __("_BoardReverse", false)
      return SS():p(2):s(-1):p(4):s(-1):p(0):s("素"):tostring()
    end,
  },
  {
    id  = "盤面モードのメニュー",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") == "Shogi" then
        return shiori:talk("盤面モードのメニュー(将棋)")
      elseif __("_Quiet") == "Mahjong" then
        return shiori:talk("盤面モードのメニュー(麻雀)")
      elseif __("_Quiet") == "Backgammon" then
        return shiori:talk("盤面モードのメニュー(BG)")
      elseif __("_Quiet") == "Chess" then
        return shiori:talk("盤面モードのメニュー(Chess)")
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
\![*]\q[チェス,チェスで遊ぶ]\n
\![*]\q[麻雀,麻雀で遊ぶ]\n
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
\![*]\q[Chess,チェスで遊ぶ]\n
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
    content = [[
\0\s[きょとん]
それじゃあ、雀卓と他の参加者を集めてきてね。
]],
  },
  {
    id  = "バックギャモンで遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,対局メニュー(BG)]
]],
  },
  {
    id  = "チェスで遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,OnChessGameMenu]
]],
  },
}
