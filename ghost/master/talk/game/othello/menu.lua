local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Othello)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnOthelloGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnOthelloGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local othello     = shiori:saori("othello")
      local str         = StringBuffer()
      local game_option = __("OthelloGameOption") or {
        player_color  = 1,
      }
      __("OthelloGameOption", game_option)

      if ref[0] == "teban" then
        if game_option.player_color == 1 then
          game_option.player_color  = 2
        elseif game_option.player_color == 2 then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = 1
        end
      end

      othello("init")
      str:append(shiori:talk("OnOthelloView", ref))
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
          :append(SS():q("変更", "OnOthelloGameMenu", "teban"))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Othello)") or {}
      __("成績(Othello)", score_list)
      local score = score_list["つよい"]
      if score == nil then
        score_list["つよい"]  = {win = 0, lose = 0}
        score = score_list["つよい"]
      end
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append("\\n")
      str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
      str:append(score.win):append("勝"):append(score.lose):append("敗")
      str:append("\\n")
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnOthelloGameStart"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
}
