local Misc  = require("shiori.misc")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "起動時イベント",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("User") == nil then
        return shiori:talk("初回起動")
      elseif __("Strength") == nil then
        return shiori:talk("棋力調査")
      end
    end,
  },
  {
    id  = "初回起動",
    content = [[
\p[0]\s[考慮中_互角]…………。\s[座り_きょとん]\w9ん？@\w9\n
\s[素]ボードゲーム部に人とは珍しいね。\n
もしかして…？@\n
\n
\n
\n
\n
\![raise,初回起動_理由]
]],
  },
  {
    id  = "初回起動_理由",
    content = [[
\C
\0
\n
\n
\_q
\![*]\q[将棋指したい！,OnTellPurpose,将棋]\n
\![*]\q[麻雀って楽しいよね！,OnTellPurpose,麻雀]\n
\_q
]],
  },
  {
    id  = "初回起動_麻雀",
    content = [[
\0
\s[ほっ]
ツモ。\n
\s[ドヤッ]
\_q
      ビ ギ ニ ン グ オ ブ ザ コ ス モ ス\n
\f[height,200%]
   天   地   創   世\n
\f[height,default]
\n
ドラ 
\_b["image/mahjong/red.png",inline,--option=use_self_alpha]
\_b["image/mahjong/red.png",inline,--option=use_self_alpha]
\_b["image/mahjong/red.png",inline,--option=use_self_alpha]
\_b["image/mahjong/red.png",inline,--option=use_self_alpha]
\n
\n
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/white.png",inline,--option=use_self_alpha]
\n
\_q
\_w[2000]\n
140符105翻。908溝6519穣5024………\n
\s[きょとん]え、違う？@麻雀じゃない？@\n
それじゃあ何？@\n
\n
\![raise,初回起動_理由]
]],
  },
  {
    id  = "初回起動_麻雀",
    content = [[
\0
\s[ほっ]
ツモ。\n
\s[ドヤッ]
\_q
        ハツ\n
\f[height,200%]
    發    の    み\n
\f[height,default]
\n
\_b["image/mahjong/2s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/3s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/4s.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/2s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/3s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/4s.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/6s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/6s.png",inline,--option=use_self_alpha]
\_b["image/mahjong/6s.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/green.png",inline,--option=use_self_alpha]
\_b["image/mahjong/green.png",inline,--option=use_self_alpha]
\_b["image/mahjong/green.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/8s.png",inline,--option=use_self_alpha]
 
\_b["image/mahjong/8s.png",inline,--option=use_self_alpha]
\n
\_q
\_w[2000]\n
………\s[きょとん]え、実は麻雀じゃない？@\n
それじゃあ何？@\n
\n
\![raise,初回起動_理由]
]],
  },
  {
    id  = "OnTellPurpose",
    content = function(shiori, ref)
      if ref[0] == "将棋" then
        return [[
\p[0]\s[ヮ]
おぉ、ちょうど相手を探していたんだ。\n
どうだろ、一局付き合って………\s[素]っと、自己紹介がまだだったね。\n
わたしは小宮由希(こみやゆき)。\w9\n
キミの名前は？@
\![open,inputbox,UserName]
]]
      elseif ref[0] == "麻雀" then
        return shiori:talk("初回起動_麻雀")
      end
    end,
  },
  {
    id  = "UserNameの入力",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local user_name = ref[0]
      __("UserName", user_name)
      return [[
\p[0]\s[きょとん]${UserName}…くん？\n
\n
\n
\n
\n
\n
\_q
\![*]\q[うん,OnSetNickname,${UserName}]\n
\![*]\q[さん付けで,OnSetNickname,${UserName}さん]\n
\![*]\q[ちゃん付けで,OnSetNickname,${UserName}ちゃん]\n
\![*]\q[呼び捨てでいいよ,OnSetNickname,${UserName}]\n
\_q
]]
    end,
  },
  {
    id  = "OnSetNickname",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local user  = ref[0]
      __("User", user)
      shiori:reserveTalk("棋力調査")
      str:append([[
\p[0]\s[ヮ]ん。それじゃあ${User}、よろしくね。\n
\s[素]早速だけど、一局どう？\n
\n
\n
\n
\n
\n
\_q
\![*]\q[もちろん,OnShogiGameMenu]\n
\![*]\q[今はいいかな,初回終了]\n
\_q
]])
      return str
    end,
  },
  {
    id  = "初回終了",
    content = [[
\p[0]\s[素]そっか。\n
何かあったら呼びかけてね。\n
]],
  },
  {
    id  = "イベントトーク",
    content = function(shiori, ref)
      local __  = shiori.var
      local list  = {
      }
      local phase = __("イベント進行度") or 0
      local talk  = list[phase]
      if talk == nil then
        return shiori:talk("ランダムトーク")
      end
      return shiori:talk(talk)
    end,
  },
  {
    id  = "棋力調査",
    content = [[
\p[0]\s[素]
うちの部では棋力調査を行ってるんだけど、
協力してもらえるかな？@\n
\n
あなたの棋力は……\n
\_q
\n
\![*]\q[将棋よく知らない…,OnTellStrength,無]\n
\![*]\q[駒の動かし方がわかるくらい,OnTellStrength,入門]\n
\![*]\q[初級,OnTellStrength,初級] 
\![*]\q[中級,OnTellStrength,中級] 
\![*]\q[上級,OnTellStrength,上級]\n
\![*]\q[有段,OnTellStrength,有段] 
\![*]\q[高段,OnTellStrength,高段]\n
\![*]\q[観る将棋ファン,OnTellStrength,観る将] 
\_q
]],
  },
  {
    id  = "OnTellStrength",
    content = function(shiori, ref)
      local __  = shiori.var
      local strength  = ref[0]
      __("Strength", strength)
      __("イベント進行度", 1)
      return [[
\0
ん、\s[ヮ]ありがと。\n
\s[素]もし間違えたり、棋力が上がったりしたらメニューから変更してね。
]]
    end,
  },
  {
    id  = "日付イベント",
    content = function(shiori, ref)
      local __  = shiori.var
      local t = os.date("*t")
      local fmt = "%d年%d月%d日"
      local now = fmt:format(t.year, t.month, t.day)
      if __("LastCalled") ~= now then
        __("LastCalled", now)
        return shiori:talk(string.format("%d月%d日", t.month, t.day))
      end
      return nil
    end,
  },
  {
    --将棋型チョコ
    id  = "2月14日",
    content = nil,
  },
  {
    id  = "11月17日",
    content = [[
\p[0]\s[><]11月17日は将棋の日だよ！
]],
  },
}
