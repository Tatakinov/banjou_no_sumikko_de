local ChessPlayer = require("chess_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local IP    = ChessPlayer.InitialPreset
local Misc  = require("shiori.misc")

local preset  = {
  IP.HIRATE,
}

return {
  {
    id  = "盤面モードのメニュー(Chess)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnChessGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
        --[[ 未実装
        if __("_PostGame") then
          str:append("\\![*]")
          str:append(SS():q("この一局の評価", "OnTalkAnalysisResult"):n())
          str:append("\\![*]")
          str:append(SS():q("棋譜をクリップボードにコピー", "OnCopyKifuToClipboard"):n())
          str:append("\\![*]")
          str:append(SS():q("棋譜を保存", "OnSaveKifu"):n():n())
        end
        --]]
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
  {
    id  = "OnChessGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str         = StringBuffer()
      local selected    = __("SelectedChessEngine")
      local game_option = __("ChessGameOption") or {
        player_color  = ChessPlayer.Color.WHITE,
        preset        = IP.HIRATE,
        control_guide = true,
        time_limit    = true,
      }
      __("ChessGameOption", game_option)

      if ref[0] == "teban" then
        print("Change teban")
        if game_option.player_color == ChessPlayer.Color.WHITE then
          game_option.player_color  = ChessPlayer.Color.BLACK
        elseif game_option.player_color == ChessPlayer.Color.BLACK then
          game_option.player_color  = "random"
        elseif game_option.player_color == "random" then
          game_option.player_color  = ChessPlayer.Color.WHITE
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
      elseif ref[0] == "time_limit" then
        game_option.time_limit  = not(game_option.time_limit)
      end

      local player  = ChessPlayer.getInstance()
      player:setPosition(game_option.preset)
      str:append(shiori:talk("OnChessViewMinimal", ref))
      str:append(SS():_q(true):p(0):s("座り_素"):c())

      --str:append("メニュー\\n")
      local preset_str  = IP.toKanji(game_option.preset)
      str:append(SS():_l(20)):append("手合:")
          :append(SS():_l(120))
          :append(preset_str)
          :append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnChessGameMenu", "preset"))
          :append("】")
          :append("\\n")
      local color
      if game_option.player_color == "random" then
        color = "ランダム"
      else
        color = ChessPlayer.Color.k(game_option.player_color)
      end
      if game_option.preset == IP.HIRATE then
        str:append(SS():_l(20)):append("ユーザーの手番:")
            :append(SS():_l(120))
            :append(color)
            :append(SS():_l(200)):append("【")
            :append(SS():q("変更", "OnChessGameMenu", "teban"))
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
          :append(SS():q("管理", "OnManageChessEngine"))
          :append("】")
          :append("\\n")
      str:append(SS():_l(120)):append("【")
          :append(SS():q("思考エンジンの設定", "OnChessEngineOption"))
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
          :append(SS():q("変更", "OnChessGameMenu", "control_guide"))
          :append("】")
          :append("\\n")
      str:append(SS():_l(20)):append("時間設定:")
          :append(SS():_l(120))
      if game_option.time_limit then
        str:append("短め")
      else
        str:append("長め")
      end
      str:append(SS():_l(200)):append("【")
          :append(SS():q("変更", "OnChessGameMenu", "time_limit"))
          :append("】")
          :append("\\n")
      local score = {win = 0, lose = 0}
      if selected then
        local score_list  = __("成績")
        score = score_list[selected]
        if score == nil then
          score_list[selected]  = {win = 0, lose = 0}
          score = score_list[selected]
        end
      end
      if __("Supplement_Engine_Version") == nil then
        str:append("\\![*]"):append(SS():q("思考エンジンをインストールする(36MB/94MB)", "OnInstallChessEngine"):n())
      elseif __("Supplement_Engine_Version") < "1.2.0" then
        str:append("\\![*]"):append(SS():q("思考エンジンをアップデートする(36MB/94MB)", "OnInstallChessEngine"):n())
      elseif selected then
        str:append(SS():_l(20)):append("成績"):append(SS():_l(120))
        str:append(score.win):append("勝"):append(score.lose):append("敗")
        str:append("\\n")
      end
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("対局開始", "OnStartChessEngine"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("説明", "OnExplainChessGame"):n())
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))
      str:append(" ")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnInstallChessEngine",
    content = function(shiori, ref)
      -- TODO ライセンスのconfirmを入れた方が良いかも？
      return [[
\![execute,install,url,https://raw.githubusercontent.com/Tatakinov/banjou_no_sumikko_de_supplement/master/supplement.nar,nar]
]]
    end,
  },
  {
    id  = "OnInitializeChessEngine",
    content = function(shiori, ref)
      local __            = shiori.var
      local shogi686_path = __("_path") .. "engine\\shogi686\\shogi686.exe"
      local sunfish4_path = __("_path") .. "engine\\sunfish4\\sunfish_usi.exe"
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
      __("SelectedChessEngine", "ほどほど")
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
      local filename  = __("_path") .. [[engine\version]]
      --print("filename: " .. filename)
      local fh  = io.open(filename, "r")
      if fh then
        __("Supplement_Engine_Version", fh:read("*l"))
        fh:close()
      end
      return shiori:talk("OnChessGameMenu")
    end,
  },
  {
    passthrough = true,
    id  = "OnExplainChessGame",
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
\![*]\q[戻る,OnChessGameMenu]
\_q
]],
  },
}
