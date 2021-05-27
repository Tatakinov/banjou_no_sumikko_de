local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

return {
  {
    id      = "ネット将棋をしてみたい",
    content = [[
\_q
\0\b[2]
【対人】\n
将棋倶楽部24 81道場\n
将棋ウォーズ 将棋クエスト\n
\n
【対CPU】\n
将棋ウォーズ 将皇 きのあ将棋\n
ぴよ将棋 ハム将棋 こまお\n
\n
【時間設定に関する雑感】\n
持ち時間とか秒読みとか考慮時間とか
\n
2分切れ負け 3分切れ負け\n
5分切れ負け 10分切れ負け\n
10秒将棋 5分+フィッシャー5秒 30秒+1分\n
1分30秒 5分30秒 10分30秒 15分60秒 30分60秒\n
\n
\q[【戻る】,将棋メニュー] \q[【閉じる】,閉じる]\n
\_q
]],
  },
  {
    anchor  = true,
    id      = "将棋倶楽部24",
    content = [[
\0
\_q【将棋倶楽部24】\_q\w9\n
ネット対局の中では一番ユーザー数が多いと言われているのがここ、将棋倶楽部24だよ。\n
\n
対局相手がたくさんいるのはいいことなんだけど、
一番レートの低い15級でも15級とは思えない強さなので、
将棋を始めたばかりの人はあんまりここを使わない方がいいかも。\n
URLは\q[ここ,OnJumpURL,https://www.shogidojo.net/]。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "81道場",
    content = [[
\0
\_q【81道場(エイティーワンどうじょう)】\_q\w9\n
数ある対局サイトの中でも対局後の感想戦での機能が非常に優れてるよ。\n
他のサイトでは符号でやり取りするところを実際に盤面を動かせるので
初心者でも感想戦がやりやすいかな。\n
実際、他のサイトより対局後に感想戦が行われることが多い気がする。\n
URLは\q[ここ,OnJumpURL,https://81dojo.com/]。
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "将棋ウォーズ",
    content = [[
\0
\_q【将棋ウォーズ】\_q\w9\n
スマホの将棋アプリの中では一番有名なアプリ。\n
\n
対局回数に制限があって一日3局まで。\n
自分の手をコンピュータが代わりに指してくれる"棋神"というシステムがあったり、
局後に棋譜の解析をしたり、次の一手問題を答えることが出来たりするよ。\n
また、対局中に表示されるエフェクトと呼ばれるものがあって、
特定の囲いや戦法などを使用することで集めることが出来るよ。\n
……"パンツを脱ぐ"のエフェクトは男子に人気があって、
それ目当てで将棋ウォーズで遊ぶ人がいるとかいないとか……。\n
URLは\q[ここ,OnJumpURL,https://shogiwars.heroz.jp/]。
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "将棋クエスト",
    content = [[
\0
\_q【将棋クエスト】\_q\w9\n
スマホアプリの中では将棋ウォーズに次いでユーザー数が多いかな。\n
将棋ウォーズと違って対局回数に制限が無いので遊びすぎには注意が必要かな？\n
対局後のヒント機能でコンピュータが考える最善手と評価値を見られるのが特徴。\n
他にも、マイページから戦法毎の勝敗やレーティングなどを確認出来るので、
自分の得意戦法を調べるのに役立ってくれるかも。
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "きのあ将棋",
    content = [[
\0
\_q【きのあ将棋】\_q\w9
色んなタイプのCPUと対局できるよ。\n
あひる囲いを多用するCPUがいるので、対あひる囲いの勉強をするなら
ここのCPUと対局するのがいいかも。
URLは\q[ここ,OnJumpURL,https://syougi.qinoa.com/ja/game/]。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "ぴよ将棋",
    content = [[
\0
\_q【ぴよ将棋】\_q\w9\n
Lv1〜Lv40までの細かいCPUレベルがあって、自分にあった強さのCPUと戦えるよ。\n
また、将棋ウォーズや将棋クエストの棋譜を取り込んだりすることが
出来るので棋譜再生アプリとしても優秀だね。\n
URLは\q[ここ,OnJumpURL,https://www.studiok-i.net/ps/]。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "将皇",
    content = [[
\0
\_q【将皇】\_q\w9\n
毎日更新される実践詰将棋と勝ちきれ将棋で中終盤力を鍛えられるのが魅力的。\n
URLは\q[ここ,OnJumpURL,https://ken1shogi.sakura.ne.jp/shogiwebgl/]。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "ハム将棋",
    content = [[
\0
\_q【ハム将棋】\_q\w9\n
初心者では勝つのが大変だけど、ある程度将棋が指せる人なら簡単に勝てる
程よい強さのCPUとして非常に有名。
……だったんだけどサイト閉鎖＆Flash終了で遊ぶのは難しくなっちゃったよ。
\n
棋力は将棋ウォーズで１〜５級くらいかな？@\n
"待った"は出来ないので一手一手慎重に指そう。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]]
  },
  {
    anchor  = true,
    id      = "こまお",
    content = [[
\0
\_q【こまお】\_q\w9\n
駒の動き方を覚えたくらいの人の対局相手としてちょうどいい強さ。\n
URLは\q[ここ,OnJumpURL,http://usapyon.game.coocan.jp/komao/]。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "持ち時間とか秒読みとか考慮時間とか",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append([[
\0
\_q【持ち時間とか秒読みとか考慮時間とか】\_q\w9\n
持ち時間10秒、秒読み10秒、考慮時間10秒。\n
]])
      local player  = KifuPlayer.getInstance()
      player:setPosition()
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
   10/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    9/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    8/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    7/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    6/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    5/10  10/10    10/10\n
\_q
]])
      NOP(player + "7g7f")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q\c
【手番:後手】\n
持ち時間 秒読み 考慮時間\n
    5/10  10/10    10/10\n
\_q
\_w[2000]
]])
      NOP(player + "3c3d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    5/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    4/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    3/10  10/10    10/10\n
\_q
\_w[1000]
]])
      NOP(player + "2g2f")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q\c
【手番:後手】\n
持ち時間 秒読み 考慮時間\n
    3/10  10/10    10/10\n
\_q
\_w[2000]
]])
      NOP(player + "8c8d")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    3/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    2/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    1/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    0/10  10/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    0/10   9/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    0/10   8/10    10/10\n
\_q
\_w[1000]
\_q\c
【手番:先手】\n
持ち時間 秒読み 考慮時間\n
    0/10   7/10    10/10\n
\_q
]])
      str:append([[
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id      = "2分切れ負け",
    content = [[
\0
\_q【2分切れ負け】\_q\w9\n
エクストリーム早指しバトル。\n
\![*]出来るだけいい手を指して相手を詰ます。\n
\![*]指し手の対応に悩む手を連発して時間切れを狙う。\n
のどちらかを目標に戦った方がいい…かも。\n
将棋を始めてすぐにこの時間設定で対局すると、
考えずに指す癖がついちゃうかもしれないので、
ある程度強くなってから手を出す方がいいと思う。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "3分切れ負け",
    content = [[
\0
\_q【3分切れ負け】\_q\w9\n
エクストリーム早指しバトル。\n
とはいえ、2分切れ負けよりは時間があるので、
1回くらいは考える時間があるかも。
2分切れ負けと同じく、相手の時間を切らすか、
相手を詰ますかのどっちかを狙うのがいいと思う。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "5分切れ負け",
    content = [[
\0
\_q【5分切れ負け】\_q\w9\n
このくらいの時間があると大体の対局は詰みまで指せることが多いよ。\n
奇襲戦法の類もこの時間くらいまでが多く見られる…かも？\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "10分切れ負け",
    content = [[
\0
\_q【10分切れ負け】\_q\w9\n
ほとんどの対局は終局まで指せる時間設定かな。\n
長考も何回か出来るので、じっくり考えたい人向け。\n
また、時間を掛けて考えた方が棋力の向上に繋がる……と思うので、
切れ負けなら一番長いこの時間で戦うのがおすすめだよ。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "10秒将棋",
    content = [[
\0
\_q【10秒将棋】\_q\w9\n
秒読み10秒(一手毎に10秒以内に指さないと時間切れになる)のルール。\n
切れ負けと違って、常に10秒は時間があるので
時間切れを狙うのは向いてないと思う。
「この局面ならこの手しかないでしょ！」という局面でも
しっかり10秒使って先の局面のことを考えると勝率が上がるかも。
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "5分+フィッシャー5秒",
    content = [[
\0
\_q【5分+フィッシャー5秒】\_q\w9\n
最初の持ち時間が5分で、
自分が1手指す毎に持ち時間が5秒足される、将棋ではけっこう珍しい時間設定。\n
難しい局面でたくさん時間を使えるように、
すぐに指せる局面ではすぐに指すのがコツ。\n
この辺り10秒将棋とは逆になってるね。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "30秒+1分",
    content = [[
\0
\_q【30秒+1分】\_q\w9\n
秒読み30秒+考慮時間1分の将棋。\n
基本的には30秒使って指して、どうしてもそれ以上考えたいときに
考慮時間を削って考える感じかな。\n
対局全体に時間は使いたくないけど、考える時間は欲しい時なんかは
この時間設定で戦うことになるかも。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "1分30秒",
    content = [[
\0
\_q【1分30秒】\_q\w9\n
持ち時間1分+秒読み30秒の将棋。\n
持ち時間1分はわりとすぐになくなるので、
この1分をどれだけうまく残せるかが大事かな。
中盤戦の入り口で持ち時間が残せていると、その後を有利に戦える…かも？\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "5分30秒",
    content = [[
\0
\_q【5分30秒】\_q\w9\n
持ち時間5分+秒読み30秒。\n
持ち時間5分だとあんまり長考は出来ないので、
時間切れ負けはしたくない！という人や、
短時間で対局したいって人向けかな。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "10分30秒",
    content = [[
\0
\_q【10分30秒】\_q\w9\n
持ち時間10分+秒読み30秒。\n
中終盤をじっくり考えて最終盤で秒読みくらいの時間かな。
長考もしたいけど対局時間は長くなくていい人向け。
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
  {
    anchor  = true,
    id      = "15分60秒",
    content = [[
\0
\_q【15分60秒】\_q\w9\n
持ち時間15分+秒読み60秒。\n
ネット将棋では長めの時間設定だね。\n
中盤でじっくり時間を使えて、持ち時間がなくなっても1手毎に60秒あるので、
そこまで時間を気にせず戦えるかな。\n
\n
\_q\q[【戻る】,将棋を指してみたい] \q[【閉じる】,閉じる]\n\_q
]],
  },
}
