local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "将棋の戦法と手筋",
    content = [[
\0
\_q
\n
\n
\q[【横歩取り３三角までの急戦】,OnShogiViewFromFile,talk\shogi\opening\yokofu.kif]\n
\q[【片美濃崩し】,OnShogiViewFromFile,talk\shogi\opening\minokuzushi.kif]\n
\q[【穴熊崩し】,OnShogiViewFromFile,talk\shogi\opening\anagumakuzushi.kif]\n
\n
\q[【戻る】,将棋メニュー] \q[【閉じる】,閉じる]\n\_q

\_l[0,0]
将棋の戦法や手筋を詳しく紹介するよ。\n
]],
  },
  {
    id  = "OnShogiViewFromFile",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      local filename  = shiori:property("path") .. ref[0]
      __("_Quiet",true)
      print("file load: " .. filename)
      player:load(filename)
      str:append(SS():p(0):s("素"))
          :append("盤面を閉じたくなったらメニューを呼び出してね。")
          :append(SS():x())
      str:append(SS():raise("OnShogiView"))
      return str
    end,
  },
}
