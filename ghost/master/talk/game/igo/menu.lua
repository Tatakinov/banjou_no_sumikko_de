local IgoPlayer = require("igo_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Igo)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("パスする", "OnIgoGamePass"):n())
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnIgoGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnIgoGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str         = StringBuffer()
      local game_option = __("IgoGameOption") or {
        player_color  = 1,
        rule  = "japanese",
        komi  = 7,
      }
      __("_Igo", IgoPlayer.Player())

      __("IgoGameOption", game_option)

      if ref[0] == "teban" then
        if game_option.player_color == 1 then
          game_option.player_color  = 2
        elseif game_option.player_color == 2 then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = 1
        end
      end

      if ref[0] == "rule" then
        if game_option.rule == "japanese" then
          game_option.rule  = "chinese"
        elseif game_option.rule == "chinese" then
          game_option.rule  = "tromp-taylor"
        elseif game_option.rule == "tromp-taylor" then
          game_option.rule  = "japanese"
        end
      end

      if ref[0] == "komi" then
        game_option.komi  = ref[0]
      end

      str:append(shiori:talk("OnIgoView", ref))
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
          :append(SS():q("変更", "OnIgoGameMenu", "teban"))
          :append("】")
          :append("\\n")

      local rule
      if game_option.rule == "japanese" then
        rule  = "日本"
      elseif game_option.rule == "chinese" then
        rule  = "中国"
      elseif game_option.rule == "tromp-taylor" then
        rule  = "TrompTaylor"
      end
      str:append(SS():_l(20)):append("ルール:")
          :append(SS():_l(120))
          :append(rule)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnIgoGameMenu", "rule"))
          :append("】")
          :append("\\n")

      str:append(SS():_l(20)):append("コミ:")
          :append(SS():_l(120))
          :append(game_option.komi)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnIgoGameConfig", "komi"))
          :append("】")
          :append("\\n")

      local score_list  = __("成績(Igo)") or {
        ["つよい"]  = {
          win   = 0,
          lose  = 0,
        },
      }
      __("成績(Igo)", score_list)
      local score = score_list["つよい"]
      str:append("\\n")
      if __("Supplement_Engine_Version") == nil then
        str:append("\\![*]"):append(SS():q("思考エンジンをインストールする(36MB/94MB)", "OnInstallEngine"):n())
      elseif __("Supplement_Engine_Version") < "1.3.0" then
        str:append("\\![*]"):append(SS():q("思考エンジンをアップデートする(36MB/94MB)", "OnInstallEngine"):n())
      else
        str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
        str:append(score.win):append("勝"):append(score.lose):append("敗")
        str:append("\\n")
      end
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnIgoGameEngineInitialize"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnIgoGameConfig",
    content = function(shiori, ref)
      return string.format([=[\![inputbox,OnIgoGameConfig_%s,0]]=], ref[0])
    end,
  },
  {
    id  = "OnIgoGameConfig_komi",
    content = function(shiori, ref)
      local komi  = tonumber(ref[0])
      if komi then
        return string.format([=[\![raise,OnIgoGameMenu,komi,%s]]=], ref[0])
      end
    end,
  },
}
