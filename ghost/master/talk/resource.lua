local Misc  = require("shiori.misc")

local num_tsume = 2

local function getTsumeNumber()
  local time  = math.floor(os.time() / 100)
  time  = time % num_tsume + 1
  return time
end

return {
  -- ここからSHIORIの情報なので弄らない
  {
    passthrough = true,
    id  = "version",
    content = "1.0.3",
  },
  {
    passthrough = true,
    id  = "craftman",
    content = "Tatakinov",
  },
  {
    passthrough = true,
    id  = "craftmanw",
    content = "タタキノフ",
  },
  {
    passthrough = true,
    id  = "name",
    content = "Kagari_Kotori",
  },
  -- ここまで
  {
    passthrough = true,
    id  = "username",
    content = function(shiori, ref)
      local __  = shiori.var
      return __("User") -- 直接content=__("User")だと動的にならない。
    end,
  },
  {
    passthrough = true,
    id  = "sakura.recommendsites",
    content = Misc.createURLList(
    {
      {"将棋連盟", "https://www.shogi.or.jp/"},
      {"-", "-", "-"},
      {"将棋倶楽部24", "https://www.shogidojo.net/"},
      {"81Dojo", "https://81dojo.com/"},
      {"将棋ウォーズ", "https://shogiwars.heroz.jp/"},
      {"将棋クエスト", "http://wars.fm/ja"},
      --{"SDIN 将棋", "https://sdin.jp/browser/board/shogi/"},
      --{"lishogi", "https://lishogi.org/"},
      {"-", "-", "-"},
      {"ぴよ将棋", "https://www.studiok-i.net/"},
      {"将皇", "http://www14.big.or.jp/~ken1/application/shogi.html"},
      {"将棋 Flash", "https://www.gamedesign.jp/flash/shogi/shogi.html"},
      {"きのあ将棋", "https://syougi.qinoa.com/ja/"},
      {"こまお", "http://usapyon.game.coocan.jp/komao/"},
      {"-", "-", "-"},
      {"クラウド将棋局面図ジェネレーター", "http://sfenreader.appspot.com/index.html"},
      {"将棋ったーβ", "https://shogitter.com/"},
      {"-", "-", "-"},
      {"なんとなく将棋の勉強になる替え歌シリーズ/山田定跡の人", "https://www.nicovideo.jp/mylist/55038179"},
      {"将棋講座/ButaneGorilla", "https://www.nicovideo.jp/mylist/50368976"},
      {"盤上のシンデレラ/四駒関係（ＫＫＰＰ）", "https://www.nicovideo.jp/mylist/53808293"},
      {"-", "-", "-"},
      {"詰将棋の答え", "script:\\![raise,OnAnswerTsumeShogi]", "-"},
    }),
  },
  {
    passthrough = true,
    id  = "OnAnswerTsumeShogi",
    content = function(shiori, ref)
      local answer  = {
        "▲３三金△４一玉▲４三香△５二金▲３一飛成△同玉▲２二金△４一玉▲４二金上までの9手詰",
        "▲１三角△同玉▲２三金△１四玉▲２六桂までの5手詰",
      }
      local num = getTsumeNumber()
      return "\\p[0]" .. answer[num] .. "だよ。"
    end,
  },
  {
    passthrough = true,
    id  = "vanishbuttoncaption",
    content = [[部活動を…諦めます！]]
  },
  {
    passthrough = true,
    id  = "menu.background.bitmap.filename",
    content = function(shiori, ref)
      local num = getTsumeNumber()
      return string.format("menu/background%03d.png", num)
    end,
  },
  {
    passthrough = true,
    id  = "menu.background.alignment",
    content = "centertop",
  },
  {
    passthrough = true,
    id  = "menu.foreground.bitmap.filename",
    content = function(shiori, ref)
      local num = getTsumeNumber()
      return string.format("menu/foreground%03d.png", num)
    end,
  },
  {
    passthrough = true,
    id  = "menu.background.alignment",
    content = "centertop",
  },
  {
    passthrough = true,
    id  = "balloon_tooltip",
    content = function(shiori, ref)
      if ref[1] then
        --print(ref[1])
        return shiori:talk(ref[1] .. "_tooltip")
      end
      return nil
    end,
  },
}
