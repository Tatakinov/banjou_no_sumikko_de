local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Connect6)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnConnect6GameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnConnect6GameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local connect6     = shiori:saori("connect6")
      local str         = StringBuffer()
      local game_option = __("Connect6GameOption") or {
        player_color  = 1,
        cpu_level     = 1,
      }

      __("Connect6GameOption", game_option)

      if ref[0] == "teban" then
        if game_option.player_color == 1 then
          game_option.player_color  = 2
        elseif game_option.player_color == 2 then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = 1
        end
      end

      if ref[0] == "cpu_level" then
        local level = tonumber(ref[1]) or 0
        if level >= 1 then
          game_option.cpu_level = level
        end
      end

      connect6("init")
      str:append(shiori:talk("OnConnect6View", ref))
      str:append(SS():_q(true):p(0):s("座り_素"):c())

      --str:append("メニュー\\n")
      local color
      if game_option.player_color == "random" then
        color = "ランダム"
      elseif game_option.player_color == 1 then
        color = "先手"
      elseif game_option.player_color == 2 then
        color = "後手"
      end
      str:append(SS():_l(20)):append("ユーザーの手番:")
          :append(SS():_l(120))
          :append(color)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnConnect6GameMenu", "teban"))
          :append("】")
          :append("\\n")

      str:append(SS():_l(20)):append("CPUレベル:")
          :append(SS():_l(120))
          :append(game_option.cpu_level)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnConnect6ChangeOption", "cpu_level", game_option.cpu_level))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Connect6)") or {}
      __("成績(Connect6)", score_list)
      local score = score_list[game_option.cpu_level]
      if score == nil then
        score_list[game_option.cpu_level]  = {win = 0, lose = 0}
        score = score_list[game_option.cpu_level]
      end
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
      str:append(score.win):append("勝"):append(score.lose):append("敗")
      str:append("\\n")
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnConnect6GameStart"))
      str:append("  \\![*]"):append(SS():q("ルール説明", "OnConnect6GameExplanation"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnConnect6ChangeOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local name      = ref[0]
      local value     = ref[1]
      assert(name and value)
      str:append(SS():C():inputbox("OnConnect6ChangedOption", 0, value))
      return str:tostring()
    end,
  },
  {
    id  = "OnConnect6ChangedOption",
    content = function(shiori, ref)
      return SS():raise("OnConnect6GameMenu", "cpu_level", ref[0])
    end,
  },
  {
    id  = "OnConnect6GameExplanation",
    content = [[
\0
コネクト6は五目並べみたいなゲームだよ。\n
1手目は黒番が石を一個打って、2手目以降はそれぞれが2個ずつ打って
自分の石を6個連続で並べれば勝ちになるよ。\n
\n
\![*]\q[戻る,OnConnect6GameMenu]
]],
  },
}
