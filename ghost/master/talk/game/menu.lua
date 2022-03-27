local SS  = require("sakura_script")

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
      return SS():p(2):s(-1):p(3):s(-1):p(4):s(-1):p(5):s(-1):p(6):s(-1):p(7):s(-1):p(8):s(-1):p(0):s("素")
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
      elseif __("_Quiet") == "Othello" then
        return shiori:talk("盤面モードのメニュー(Othello)")
      elseif __("_Quiet") == "Quoridor" then
        return shiori:talk("盤面モードのメニュー(Quoridor)")
      elseif __("_Quiet") == "Gomoku" then
        return shiori:talk("盤面モードのメニュー(Gomoku)")
      elseif __("_Quiet") == "Connect6" then
        return shiori:talk("盤面モードのメニュー(Connect6)")
      elseif __("_Quiet") == "WordChain" then
        return shiori:talk("盤面モードのメニュー(WordChain)")
      end
    end,
  },
  {
    id  = "他のゲームしたい",
    content = [[
\p[2]\s[-1]
\p[3]\s[-1]
\p[4]\s[-1]
\p[5]\s[-1]
\p[6]\s[-1]
\p[7]\s[-1]
\p[8]\s[-1]
\0\s[きょとん]
\_q
\n
\n
\![*]\q[バックギャモン,バックギャモンで遊ぶ]  \![*]\q[チェス,チェスで遊ぶ]\n
\![*]\q[オセロ,オセロで遊ぶ]          \![*]\q[コリドール,コリドールで遊ぶ]\n
\![*]\q[五目並べ,五目並べで遊ぶ]        \![*]\q[コネクト6,コネクト6で遊ぶ]\n
\![*]\q[しりとり,しりとりで遊ぶ]        \![*]\q[麻雀,麻雀で遊ぶ]\n
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
  {
    id  = "オセロで遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,OnOthelloGameMenu]
]],
  },
  {
    id  = "コリドールで遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,OnQuoridorGameMenu]
]],
  },
  {
    id  = "五目並べで遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,OnGomokuGameMenu]
]],
  },
  {
    id  = "コネクト6で遊ぶ",
    content = [[
\0\s[素]
それじゃ用意するね。
\![raise,OnConnect6GameMenu]
]],
  },
  {
    id  = "しりとりで遊ぶ",
    content = [[
\0\s[素]
\![raise,OnWordChainGameMenu]
]],
  },
}
