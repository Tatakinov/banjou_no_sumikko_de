local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Color = KifuPlayer.Color
local CSA   = KifuPlayer.CSA
local IP    = KifuPlayer.InitialPreset
local Misc  = require("shiori.misc")

--[[
--  minimal:  盤,持ち駒,手番
--  header:   対局者,指し手,時間
--  control1: 一手進める,一手戻る,初手,最終手[,分岐]
--  control2: 中断,待った,投了[,入玉宣言]
--  control3: control1 + 検討,本筋,エンジン
--
--  ShogiPlay
--    -- minimal + header + control1
--  ShogiGame
--    -- minimal + header + control2
--  ShogiConsider
--    -- minimal + header + control3
--]]

local preset  = {
  IP.HIRATE,
  IP.KY,
  IP.KA,
  IP.HI,
  IP["2"],
  IP["4"],
  IP["6"],
  IP["8"],
  IP["10"],
}

return {
  {
    id  = "OnShogiGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str         = StringBuffer()
      local selected    = __("SelectedEngine")
      local game_option = __("GameOption") or {
        player_color  = KifuPlayer.Color.BLACK,
        preset        = IP.HIRATE,
        control_guide = true,
      }
      __("GameOption", game_option)

      if ref[0] == "teban" then
        if game_option.player_color == KifuPlayer.Color.BLACK then
          game_option.player_color  = KifuPlayer.Color.WHITE
        elseif game_option.player_color == KifuPlayer.Color.WHITE then
          game_option.player_color  = "furigoma"
        elseif game_option.player_color == "furigoma" then
          game_option.player_color  = KifuPlayer.Color.BLACK
        end
      elseif ref[0] == "preset" then
        local n
        for i, v in ipairs(preset) do
          if game_option.preset == v then
            n = i
            break
          end
        end
        assert(n > 0)
        game_option.preset  = preset[n % #preset + 1]
      elseif ref[0] == "control_guide" then
        game_option.control_guide = not(game_option.control_guide)
      end

      local player  = KifuPlayer.getInstance()
      player:setPosition(game_option.preset)
      str:append(shiori:talk("OnShogiViewMinimal", ref))
      str:append(SS():_q(true):p(0):s("座り_素"):c())

      str:append("メニュー\\n")
      local preset_str  = IP.toKanji(game_option.preset)
      str:append(SS():_l(20)):append("手合:")
          :append(SS():_l(120))
          :append(preset_str)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnShogiGameMenu", "preset"))
          :append("】")
          :append("\\n")
      local color
      if game_option.player_color == "furigoma" then
        color = "振り駒"
      else
        color = KifuPlayer.Color.k(game_option.player_color)
      end
      if game_option.preset == IP.HIRATE then
        str:append(SS():_l(20)):append("ユーザーの手番:")
            :append(SS():_l(120))
            :append(color)
            :append(SS():_l(200)):append("【")
            :append(SS():q("変更", "OnShogiGameMenu", "teban"))
            :append("】")
            :append("\\n")
      else
        str:append(SS():_l(20)):append("ユーザーの手番:")
            :append(SS():_l(120))
            :append("下手")
            :append("\\n")
      end
      str:append(SS():_l(20)):append("思考エンジン:")
      if selected then
        str:append(SS():_l(120)):append(selected)
      else
        str:append(SS():_l(120)):append("未指定")
      end
      str:append(SS():_l(200)):append("【")
          :append(SS():q("管理", "OnManageShogiEngine"))
          :append("】")
          :append("\\n")
      str:append(SS():_l(120)):append("【")
          :append(SS():q("思考エンジンの設定", "OnShogiEngineOption"))
          :append("】")
          :append("\\n")
      str:append(SS():_l(20)):append("駒のガイド:")
          :append(SS():_l(120))
      if game_option.control_guide then
        str:append("表示")
      else
        str:append("非表示")
      end
      str:append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnShogiGameMenu", "control_guide"))
          :append("】")
          :append("\\n")
      if __("Supplement_Engine_Version") == nil then
        str:append("\\![*]"):append(SS():q("思考エンジンをインストールする(15MB/52MB)", "OnInstallShogiEngine"):n())
      elseif __("Supplement_Engine_Version") < "1.0.0" then
        str:append("\\![*]"):append(SS():q("思考エンジンをアップデートする(15MB/52MB)", "OnInstallShogiEngine"):n())
      elseif selected then
        local score_list  = __("成績")
        local score = score_list[selected]
        if score == nil then
          score_list[selected]  = {win = 0, lose = 0}
          score = score_list[selected]
        end
        str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
        str:append(score.win):append("勝"):append(score.lose):append("敗")
        str:append("\\n")
      end
      str:append("\\![*]"):append(SS():q("対局開始", "OnStartShogiEngine"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("説明", "OnExplainShogiGame"):n())
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnInstallShogiEngine",
    content = function(shiori, ref)
      -- TODO ライセンスのconfirmを入れた方が良いかも？
      return [[
\![execute,install,url,https://raw.githubusercontent.com/Tatakinov/banjou_no_sumikko_de_supplement/master/supplement.nar,nar]
]]
    end,
  },
  {
    id  = "OnInitializeShogiEngine",
    content = function(shiori, ref)
      local __            = shiori.var
      local shogi686_path = shiori:property("path") .. "engine\\shogi686\\shogi686.exe"
      local sunfish4_path = shiori:property("path") .. "engine\\sunfish4\\sunfish_usi.exe"
      local engine_list = {
        ["ほどほど"]={
          ["option"]={
            ["TimeMargin"]={
              ["default"]=100,
              ["max"]=3000,
              ["name"]="TimeMargin",
              ["min"]=0,
              ["command"]="option",
              ["type"]="spin",
            },
            ["Eval"]={
              ["default"]="Default",
              ["name"]="Eval",
              ["var"]={
                [1]="Default",
                [2]="Random(NoSearch)",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["Mate"]={
              ["default"]="Default",
              ["name"]="Mate",
              ["var"]={
                [1]="Default",
                [2]="Learn",
                [3]="Average",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["Ordering"]={
              ["default"]="Default",
              ["name"]="Ordering",
              ["var"]={
                [1]="Default",
                [2]="Random",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["SaveTime"]={
              ["name"]="SaveTime",
              ["default"]=true,
              ["command"]="option",
              ["type"]="check",
            },
            ["RandomMove"]={
              ["command"]="option",
              ["type"]="check",
              ["value"]=false,
              ["name"]="RandomMove",
              ["default"]=false,
            },
          },
          ["author"]="merom686",
          ["command"]=shogi686_path,
          ["name"]="ほどほど",
        },
        ["つよい"]={
          ["author"]="Kubo Ryosuke",
          ["command"]=sunfish4_path,
          ["option"]={
            ["UseBook"]={
              ["type"]="check",
              ["command"]="option",
              ["default"]=true,
              ["name"]="UseBook",
            },
            ["Snappy"]={
              ["type"]="check",
              ["command"]="option",
              ["default"]=true,
              ["name"]="Snappy",
            },
            ["MultiPV"]={
              ["default"]=1,
              ["name"]="MultiPV",
              ["max"]=10,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
            ["MarginMs"]={
              ["default"]=500,
              ["name"]="MarginMs",
              ["max"]=2000,
              ["command"]="option",
              ["min"]=0,
              ["type"]="spin",
            },
            ["Threads"]={
              ["default"]=1,
              ["name"]="Threads",
              ["max"]=32,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
            ["MaxDepth"]={
              ["default"]=64,
              ["name"]="MaxDepth",
              ["max"]=64,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
          },
          ["name"]="つよい",
        },
      }
      __("EngineList", engine_list)
      __("SelectedEngine", "ほどほど")
      local score_list  = {
        ["ほどほど"]  = {
          win   = 0,
          lose  = 0,
        },
        ["つよい"]  = {
          win   = 0,
          lose  = 0,
        },
      }
      __("成績", score_list)
      local filename  = shiori:property("path") .. [[engine\version]]
      --print("filename: " .. filename)
      local fh  = io.open(filename, "r")
      if fh then
        __("Supplement_Engine_Version", fh:read("*l"))
        fh:close()
      end
      return shiori:talk("OnShogiGameMenu")
    end,
  },
  {
    passthrough = true,
    id  = "OnExplainShogiGame",
    content = [[
\p[0]\s[座り_素]
\_q
\![*]駒の動かし方\n
動かしたい駒を左クリックして、移動させたい場所を左クリックしてね。\n
間違えて別の駒をクリックしてしまったときは、
右側の駒台を右クリックすればキャンセル出来るよ。\n
\x
\![*]手合\n
二枚落ちや四枚落ちなどの駒落ちの対局を選べるよ。\n
\n
\![*]手番\n
先手か後手、好きな方を選んでね。\n
振り駒にすると${User}の振り歩先で振り駒して先後を決めるよ。\n
\x
\![*]思考エンジンの選択\n
【管理】ボタンをクリックすると思考エンジンを切り替えることができるよ。\n
USIプロトコルに対応したエンジンなら登録できるよ。\n
\n
\![*]思考エンジン設定\n
選択中の思考エンジンの設定だよ。よくわからなければ弄らなくて大丈夫。\n
\n
\x
\![*]思考エンジンをインストールする\n
思考エンジンが同梱されたサプリメントをインストールするよ。\n
同梱されているエンジンの強さはこんな感じ。\n
\n
\![*] ほどほど: 勝てれば脱初心者。\n
\![*] つよい: けっこう強い。\n
\n
\![*]\q[戻る,OnShogiGameMenu]
\_q
]],
  },
}
