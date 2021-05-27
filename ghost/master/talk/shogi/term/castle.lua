return {
  {
    id  = "将棋用語_囲い",
    content = [[
\0
\_q
【相居飛車】\n
矢倉囲い\n
中住まい 中原囲い アヒル囲い\n
【対抗型(居飛車)】\n
舟囲い 天守閣美濃 端玉銀冠 elmo囲い\n
居飛車穴熊 銀冠穴熊\n
【対抗型(振り飛車)】\n
美濃囲い 片美濃 銀美濃 木村美濃 高美濃 銀冠 振り飛車穴熊\n
【相振り飛車】\n
金無双 美濃囲い 右矢倉 穴熊(相振り)\n
【その他】\n
居玉 無敵囲い\n
\n
\![*]\q[戻る,将棋用語] \![*]\q[閉じる,閉じる]\n\_q
]]
  },
  {
    anchor  = true,
    id      = "__",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【】\_q\w9\n
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "矢倉囲い",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/2PP5/PPSG5/1KG6/LN7 b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【矢倉囲い】\_q\w9\n
主に相矢倉や矢倉対居角左美濃で見られる囲い。\n
6〜8筋からの攻めには強い一方、横から攻められるとすぐに寄せられてしまうよ。
なので、この囲いにするなら余程のことがない限りは飛車を切らないように注意。\n
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "中住まい",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/2P6/PP1PPPP1P/2GSKSG2/LN5NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【中住まい】\_q\w9\n
相掛かりや横歩取りで見られる囲い。\n
金や銀の位置はまちまちで、とりあえず玉が５八にいたら中住まいって呼ぶ気がする。
この例はよくある形で、左右の金の位置が良く、
大駒交換しても自陣に大駒を打たれる隙が無いよ。
大駒交換をして、こちらが一方的に敵陣に大駒を打てる展開を目指そう。\n
ただ、桂馬や香車が動いたり、金が横に動くと大駒を打たれる隙が出来るので、
特に△９八歩や△８八歩のような手には注意。\n
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "中原囲い",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/2P6/PP1PPP3/1BG2S3/LNSKG4 b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【中原囲い】\_q\w9\n
相掛かりや横歩取りで見られる囲い。\n
この囲いにするなら攻めは飛車角桂で攻めていくことが多いよ。
うまく大駒交換をして、囲いの堅さで勝負する感じかな。
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "アヒル囲い",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/P8/1PPPPPP1P/3SKS3/LNG3GNL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【アヒル囲い】\_q\w9\n
中住まいでは桂馬を跳ねると大駒を打ち込む隙が出来ていたので
金を一段引くことで隙が出来ないようにした囲い。
大抵の場合、浮き飛車+▲９七角として大駒交換を狙っていくことが多いよ。\n
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "舟囲い",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("9/9/9/9/9/2P6/PP1P5/1BK1GS3/LNSG5 b 2rb2g2s3n3l14p 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【舟囲い】\_q\w9\n
対振りでよく使われる囲い。\n
急戦ならこの囲いのまま戦い、
持久戦なら天守閣美濃や銀冠、穴熊などに進展させることが多いよ。\n
急戦で戦う場合はどちらかの銀を
右側へ動かして行って2〜3筋を攻める感じになるよ。
囲いの弱点は、６九の金が玉の紐しかないことと、
玉の横を守るのが５八の金なことかな。
\n
\_q\![*]\q[戻る,将棋用語_囲い] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
}
