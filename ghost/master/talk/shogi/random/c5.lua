local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")
local Utils = require("talk.shogi._utils")

return {
  {
    id  = "将棋トーク_C5",
    content = function(shiori, ref)
      return shiori:talk("将棋トーク")
    end,
  },
  {
    id  = "将棋トーク_C5",
    content = [[
\0
定跡本で定跡を丸覚えしても、
相手が本に載ってる通りに指してこないことがよくあるので、
「どの駒を使って」「どこを攻めるのか」を覚えておくと応用が効くかも。\n
例えば棒銀なら「飛車と銀で」「２三(2筋)を攻める」といった感じにね。
]]
  },
  {
    id  = "将棋トーク_C5",
    content = function(shiori, ref)
      local str = StringBuffer()
      local player  = KifuPlayer.getInstance()
      player:setPosition()
      NOP(player + "2g2f" + "3c3d" + "2f2e" + "2b3c" + "2h2f")
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append([[
\0
たまに見かけるこの5手目２五飛。\n
\s[きょとん]▲３六飛〜▲３四飛として３四の歩を取る狙いだよ。\n
\s[素]対策としてオススメなのは△２二飛からの2筋の逆襲。\n
一直線に進めると、この局面から
]])
      str:append(Utils.M2SS(shiori, {
        wait  = 1000,
                "8b2b",
        "2f3f", "2c2d",
        "3f3d", "2d2e",
      }))
      str:append([[
\0
。\n
こう進めばこちらも歩を入手できて、さらに2筋に飛車がいるおかげで
先手の飛車が2筋に戻れなくて使い辛くなるので後手が指しやすいかな。
\s[ドヤッ]このあとは金銀で先手の飛車を取れば大体勝ち。\n
\s[素]飛車を手に入れたら1筋の歩を突き捨てて
△１八歩〜△１九飛のような手が有効だよ。
]])
      return str
    end,
  },
  {
    id  = "将棋トーク_C5",
    content = [[
\0
対局後は1人でもいいので感想戦をすると上達が早くなるよ。
負けた対局を振り返るのが辛いなら、勝った対局だけでも。
慣れないうちは、コンピューターに棋譜解析してもらうのがいいと思う。
]]
  },
}
