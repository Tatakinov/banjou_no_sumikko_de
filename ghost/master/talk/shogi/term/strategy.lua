local KifuPlayer           = require("kifu_player")
local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Utils = require("talk.shogi._utils")

return {
  {
    id      = "将棋用語_戦法",
    content = [[
\0\s[素]\b[2]
\_q
【相居飛車】\n
\![*]相掛かり\n
5手爆弾\n
\![*]角換わり\n
角換わり棒銀 角換わり早繰り銀 角換わり腰掛け銀 角換わり腰掛け銀４八金２九飛 一手損角換わり\n
\![*]横歩取り\n
青野流 横歩取り４五角 相横歩\n
\![*]矢倉\n
\![*]部分的な戦法\n
棒銀 早繰り銀 腰掛け銀\n
\n
【対抗型】\n
対振り急戦 対振り持久戦 相穴熊\n
\n
【振り飛車】
\![*]中飛車\n
原始中飛車 ゴキゲン中飛車\n
\![*]四間飛車\n
角交換四間飛車 レグスペ 藤井システム\n
\![*]三間飛車\n
石田流 早石田 トマホーク 鬼殺し\n
\![*]向かい飛車\n
ダイレクト向かい飛車 阪田流向かい飛車\n
\n
【相振り飛車】\n
向かい飛車vs三間飛車 中飛車vs三間飛車\n
\n
\![*]\q[戻る,将棋用語一覧] \![*]\q[閉じる,閉じる]\n
\_q
]],
  },
  {
    anchor  = true,
    id      = "相掛かり",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lnsgk1snl/1r4gb1/p1ppppppp/9/1p5P1/9/PPPPPPP1P/1BG4R1/LNS1KGSNL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【相掛かり】\_q\w9\n
序盤に角道を開けずに飛車先を突いていくのが特徴の戦型。
短い手数で一気に終盤戦になることもあるので序盤から慎重な差し回しが求められるよ。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    passthrough = true,
    id  = "相掛かり_tooltip",
    content = [[
序盤に角道を開けずに飛車先の歩交換を行う相居飛車の戦型。
]],
  },
  {
    anchor  = true,
    id  = "角換わり",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lnsgk2nl/1r4g2/p1ppppspp/6p2/1p5P1/2P6/PPSPPPP1P/2G4R1/LN2KGSNL b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【角換わり】\_q\w9\n
名前のとおり、序盤からお互いに角を持ち合うことになる戦型だよ。\n
角打ちの隙がないか考えながら駒組みしないとなので、
将棋始めたての頃は少し大変かも。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "角換わり棒銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1gk2nl/1r4g2/p1spppspp/2p3p2/1p5P1/2P4S1/PPSPPPP1P/2G4R1/LN2KG1NL b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【角換わり棒銀】\_q\w9\n
角交換後に棒銀を目指す戦法。\n
後手が素直に銀交換に応じてくれるといいんだけど、
△５四角とする手があって、受け方を知らないと
何も出来なくなっちゃうのでちょっと危険。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "角換わり早繰り銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1gk2nl/1r4g2/p1p1p1spp/3pspp2/1p5P1/2P2SP2/PPSPPP2P/2GK3R1/LN3G1NL b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【角換わり早繰り銀】\_q\w9\n
角交換後に早繰り銀を目指す戦法。\n
私が知らないだけなんだけど、早繰り銀にはこの形で対抗する！@
みたいな形がないので、結構有力だと思う。\n
銀交換出来たら、▲５六角から２三の地点を狙うのが1つの狙いだよ。
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "角換わり腰掛け銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("l5knl/1r2g1g2/2n1p1sp1/p1ppspp1p/1p5P1/P1PPSPP1P/1PS1P1N2/2G1G2R1/LNK5L b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【角換わり腰掛け銀】\_q\w9\n
元々、角換わり腰掛け銀と言えばこれのことだったんだけど、
最近は角換わり腰掛け銀４八金２九飛の流行で
両者共この形に組むことはほとんどなくなったみたい。\n
42173という魔法の数字はこの戦型のもの。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "角換わり腰掛け銀４八金２九飛",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lr5nl/3g1kg2/2n1ppsp1/p1pps1p1p/1p5P1/P1P1SPP1P/1PSPP1N2/2GK1G3/LN5RL b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
\_q【角換わり腰掛け銀４八金２九飛】\_q\w9\n
この戦法は、2015年頃からプロ間で指されはじめた戦法で、
元々はコンピューター同士の対局で現れたものだよ。\n
今までの角換わり腰掛け銀と比べると、玉の位置と
自陣に角を打ち込む隙が無くなっているのが特徴。\n
\n
\_q\![*]\q[続き,角換わり腰掛け銀４八金２九飛_続き1]\n
\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "角換わり腰掛け銀４八金２九飛_続き1",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      --TODO 最初の説明
      str:append([[
\0
\_q【角換わり腰掛け銀４八金２九飛】\_q\w9\n
\n
この戦法は元々後手番で指された戦法で、
従来の腰掛け銀に対して先攻出来る利点があるよ。
先手が従来の腰掛け銀、後手が４八金２九飛(６二金８一飛)型に組むと、
]])
      player:setPosition("lr5nl/3g1kg2/2n1ppsp1/p1pps1p1p/1p5P1/P1P1SPP1P/1PSPP1N2/2G1G2R1/LNK5L b Bb 1")
      player:appendMove("6g6f")
      str:append(shiori:talk("OnShogiViewMinimal"))
str:append([[
\0
こんな形になって手番は後手。\n
\x[noclear]
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
                "6d6e",
        "6f6e", "7c6e",
      }))
str:append([[
\0
と仕掛ける手があって、
先手は後手に先攻されるのは嫌なので強く
]])
      str:append(Utils.M2SS(shiori, {
        "5f6e",
      }))
str:append([[
\0
として６筋を逆襲。\x[noclear]
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
                  "5d6e",
        "P*6c",   "6b7b",
        "N*6d",   "7b7c",
        "6c6b+",  "7c6d",
      }))
str:append([[
\0
として
玉の近くにと金を作ることに成功するよ。\n
\x[noclear]
ここから指してみると先手は攻め駒が少なく、攻めの継続が難しい。\n
一方後手は先手から駒をたくさん貰っているので、手番が回ってくれば
色々攻める手がありそう。\n
となるとこの後は後手が主導権を握る戦いになってしまい、先手としては不満。
\x[noclear]
なので局面を戻して、
]])
      player:setPosition("lr5nl/3g1kg2/2n1ppsp1/p1p1s1p1p/1p1P3P1/P1P1SPP1P/1PS1P1N2/2G1G2R1/LNK5L w BPb 1")
      player:appendMove("7c6e")
      str:append(shiori:talk("OnShogiViewMinimal"))
str:append([[
\0
この局面、\w9\w9先手は
]])
      str:append(Utils.M2SS(shiori, {
        "7g6f",
      }))
str:append([[
\0
とするしかなく、結局後手に先攻を許してしまうよ。\n
\x[noclear]\n
せっかく先手で相手より1手多く指せるはずなのに
後手に先に攻められてしまうのは悔しい。
なので、どうにか先攻出来るようにしようとした結果、
先手も後手と同じ４八金２九飛型に組むようになったよ。\n
そんな経緯があって、今では腰掛け銀はこっちが指されることが多いかな。\n
\n
\_q\![*]\q[戻る,将棋四方山話一覧] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "横歩取り",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lnsgk1snl/6g2/p1ppppb1p/6R2/9/1rP6/P2PPPP1P/1BG6/LNS1KGSNL b 3P2p 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【横歩取り】\_q\w9\n
２四の飛車が３四にいた歩を取ることから横歩取りと名付けられたよ。\n
急戦形だと飛車角が入り乱れる激しい戦いになるので見てる分には楽しい。\n
\n
横歩取り４五角や相横歩のせいでアマチュア間ではあんまり指されないかも。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "横歩取り４五角",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lnsgk1snl/6g2/p1pppp2p/6R2/5b3/1rP6/P2PPPP1P/1SG4S1/LN2KG1NL b B4Pp 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【横歩取り４五角】\_q\w9\n
アマチュア間で横歩取りが指されない理由その1。\n
後手番の戦法で、ハメ手としてかなり有名。
正しく指せば先手が良くなるものの、正しく指すのが何せ難しい。
その分、格上に一発入ったりするので覚えて損は無いかも？\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "相横歩",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("lnsgk1snl/6g2/p1pppp2p/6R2/9/2r6/P2PPPP1P/1SG6/LN2KGSNL b B3Pb3p 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【相横歩】\_q\w9\n
アマチュア間で横歩取りが指されない理由その2。\n
横歩取り４五角と比べると、後手がそこまで変な手を指してこないので
定跡を知らなくても意外と良い勝負が出来るかも？
一応、穏やかにするチャンスが何回かあるので
それで勝負するのもアリ。
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str:tostring()
    end,
  },
  {
    anchor  = true,
    id  = "棒銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("7nl/6g2/6spp/6p2/7P1/7S1/5PP1P/7R1/7NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【棒銀】\_q\w9\n
▲２七銀〜▲２六銀と銀を進めていって、2筋突破を目指す戦法。\n
シンプルだけど、破壊力は抜群。\n
実際の進行はこんな感じだよ。\n
\n
\_qクリックしてね！\_q
\x
]])
      player:setPosition("7nl/6g2/7pp/6p2/7P1/7S1/5PP1P/7R1/7NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【棒銀がきれいに決まる場合】\_q\n
\_w[1000]
相手の守りが金だけだと棒銀が決まるよ。\n
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
        "2f1e", "pass",
        "2e2d", "2c2d",
        "1e2d", "P*2c",
        "2d2c+","3b2c",
        "2h2c+",
      }))
      str:append([[
\0
。\n
こうなれば先手が大体勝ちだね。\n
こうなることは少ないけど、攻めの基本パターンとして覚えておきたいところ。\n
\n
\_qクリックしてね！\_q
\x
]])
      player:setPosition("7nl/6g2/6spp/6p2/7P1/7S1/5PP1P/7R1/7NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【端の突き合いがない場合】\_q\n
\_w[1000]
▲１六歩△１四歩の交換がない時は、銀交換に持ち込めるよ。\n
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
        "2f1e", "pass",
        "2e2d", "2c2d",
        "1e2d", "3c2d",
        "2h2d", "P*2c",
        "2d2h",
      }))
      str:append([[
\0
。\n
「相手の守り駒を一枚減らした」\n
「銀を持ち駒にした(=好きなところに銀を打てる)」\n
と2つの利点があって交換出来るのは攻めた方の得。\n
……とされていたんだけど、
最近は「手数掛けた割に銀交換だけじゃあまり得したとは言えないんじゃないか」
という考えに変わってきてるみたい。\n
まあ、プロレベルの話であって、アマチュア間ではほぼ間違いなく得だと思うけどね。\n
\n
\_qクリックしてね！\_q
\x
]])
      player:setPosition("7nl/6g2/6sp1/6p1p/7P1/7SP/5PP2/7R1/7NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【端を突き合った場合】\_q\n
\_w[1000]
▲１六歩△１四歩の交換が入っている場合は、1筋から攻めるのが定跡。\n
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
        "1f1e", "1d1e",
        "2f1e", "1a1e",
        "1i1e",
      }))
      str:append([[
\0
。\n
瞬間的には銀香交換で駒損だけど、端を破る形になるのでトントンかな。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "早繰り銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("7nl/6g2/6spp/6p2/7P1/5SP2/5P2P/7R1/7NL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
▲３七銀〜▲４六銀と銀を進めていって、2、3筋で戦いを起こす戦法。\n
▲５六角と打って２三の地点を攻めるのが狙いとしてある……かな。\n
銀がいなくなると、△６四角とかで２八にいる飛車を狙われやすいので注意。\n
\n
\_qクリックしてね！\_q
\x
]])
      player:setPosition("7nl/6g2/6sp1/6p1p/7P1/5SP1P/5P3/7R1/7NL b Bb 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
\_q【進行1例】\_q\n
\_w[1000]
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
        "3f3e", "3d3e",
        "4f3e", "pass",
        "2e2d", "2c2d",
        "3e2d", "3c2d",
        "2h2d", "P*2c",
        "2d2h",
      }))
      str:append([[
\0
。\n
3筋の歩と銀が交換できて棒銀よりお得感があるね。\n
この後の進行としては、
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
                "pass",
        "B*5f", "S*2b",
        "1f1e", "1d1e",
        "P*1b", "1a1b",
        "P*2d",
      }))
      str:append([[
\0
なんてのが考えられるかな。\n
この歩を取ると▲１二角成と出来るので、一本取った！って感じだね。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "腰掛け銀",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("7nl/9/6spp/6p2/7P1/4SPP2/4P1N1P/7R1/8L b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append([[
\0
▲４七銀〜▲５六銀と銀を進めていって、2、3、4筋を攻めていく戦法。
２九にいる桂馬を▲３七桂〜▲４五桂と活用しやすく、飛車銀桂の3つの駒で
攻めていくので、攻めが繋がりやすいよ。\n
相手の持ち駒に歩があると、△３五歩▲同歩△３六歩のような攻めが生じるので、
銀は４七で待機して、攻める直前で５六に上がるのが良さそう。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "四間飛車",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1gkgsnl/1r1s3b1/p1pppp1pp/6p2/1p7/2PP5/PPB1PPPPP/3R5/LNSGKGSNL b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【四間飛車】\_q\w9\n
飛車を左から4つめの筋に振る振り飛車。\n
飛車先を突破するというよりは相手の攻めに乗じて
左側の駒をうまく駒台にのせていくのが狙い。\n
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "４五歩早仕掛け",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln1g3nl/1ks1gr3/1ppp1sbpp/p3ppp2/7P1/P1P1PPP2/1P1PS3P/1BK1GS1R1/LN1G3NL b - 1")
      player:appendMove("4f4e")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【４五歩早仕掛け】\_q\w9\n
四間飛車急戦の一種。\n
▲３三角成△同桂▲２四歩△同歩▲同飛の2筋突破が先手の基本的な狙い。
△５四歩を突いてくれないと成立しにくい。
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
  {
    anchor  = true,
    id  = "相穴熊",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition("ln4gnk/1r4gsl/p1ppspbpp/4p1p2/1p7/2PP5/PPBSPPPPP/3R2GSL/LN4GNK b - 1")
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():p(0)):append([[
\_q【相穴熊】\_q\w9\n
相穴熊は対抗型の一種で両対局者が穴熊囲いに組んだ戦型。\n
基本的に金銀はすべて囲いに使われるため、いかにして細い攻めを繋げるかが勝負の鍵になるよ。\n
\n
一応相居飛車や相振り飛車でも相穴熊になる可能性はあるんだけど、
対局者のどちらかが穴熊にせずに攻め始めることが多いから、
実際に見たことはまだないんだよね…。
\n
\_q\![*]\q[戻る,将棋用語_戦法] \![*]\q[閉じる,閉じる]\n\_q
]])
      return str
    end,
  },
}
