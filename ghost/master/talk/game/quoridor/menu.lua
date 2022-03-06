local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Quoridor)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnQuoridorGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnQuoridorGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local quoridor    = shiori:saori("quoridor")
      local str         = StringBuffer()
      local game_option = __("QuoridorGameOption") or {
        player_color  = 1,
        cpu_level     = 2,
      }
      -- 互換性
      game_option.cpu_level = game_option.cpu_level or 9

      __("QuoridorGameOption", game_option)

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
        local level = tonumber(ref[1]) or 2
        if level >= 1 and level <= 2 then
          game_option.cpu_level = level
        end
      end

      quoridor("init", 2)
      str:append(shiori:talk("OnQuoridorView", ref))
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
          :append(SS():q("変更", "OnQuoridorGameMenu", "teban"))
          :append("】")
          :append("\\n")

      str:append(SS():_l(20)):append("CPUレベル:")
          :append(SS():_l(120))
          :append(game_option.cpu_level)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnQuoridorChangeOption", "cpu_level", game_option.cpu_level))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Quoridor)") or {}
      __("成績(Quoridor)", score_list)
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
      str:append("\\![*]"):append(SS():q("対局開始", "OnQuoridorGameStart"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnQuoridorChangeOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local name      = ref[0]
      local value     = ref[1]
      assert(name and value)
      str:append(SS():C():inputbox("OnQuoridorChangedOption", 0, value))
      return str:tostring()
    end,
  },
  {
    id  = "OnQuoridorChangedOption",
    content = function(shiori, ref)
      return SS():raise("OnQuoridorGameMenu", "cpu_level", ref[0])
    end,
  },
}
