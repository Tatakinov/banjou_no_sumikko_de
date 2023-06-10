local BGPlayer      = require("backgammon_player")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "対局メニュー(BG)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      __("_BGPlayer", BGPlayer())
      __("_BGPlayer"):initialize()
      local game_option = __:init("BackgammonGameOption", {
        point = 5,
      })
      local score_list  = __:init("成績(Backgammon)", {
        ["ふつう"]  = {
          win   = 0,
          lose  = 0,
        }
      })
      local score = score_list["ふつう"]
      str:append(shiori:talk("OnBackgammonRender", "false", "false"))
      str:append(string.format([[
\_q
\0\s[素]
%dポイントマッチ\_l[200,]\q[【変更】,OnBackgammonChangePoint]\n
\n
成績: %d勝%d敗\n
\n
\![*]\q[対局開始,対局開始(BG)]\n
\![*]\q[ルール説明,ルール説明(BG)]\n
\![*]\q[操作説明,操作説明(BG)]\n
\n
\![*]\q[戻る,他のゲームしたい] \![*]\q[閉じる,閉じる]
\_q
]], game_option.point, score.win, score.lose))
      return str
    end,
  },
  {
    id  = "OnBackgammonChangePoint",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[0] then
        local game_option = __("BackgammonGameOption")
        game_option.point = tonumber(ref[0]) or 5
        return [=[\![raise,対局メニュー(BG)]]=]
      else
        local game_option = __("BackgammonGameOption")
        return string.format([=[\![open,sliderinput,OnBackgammonChangePoint,0,%d,1,9]]=], game_option.point)
      end
    end,
  },
  {
    id  = "対局開始(BG)",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append("\\![raise,OnBackgammonGameStart]")
      return str
    end,
  },
  {
    id  = "ルール説明(BG)",
    content = [[
\0\b[2]
バックギャモンは歴史ある双六ゲームだよ。\n
自分の15個の駒すべてを相手の15個の駒より早くゴールさせれば勝ち。\n
\n
盤面は右上、左上、左下、右下の各6マス、計24マスから出来てて、
白番(${User}側)は右上〜右下を反時計回りに、
黒番は右下〜右上を時計回りに駒を進めていくことになるよ。\n
\n
自分の手番になったら、サイコロを2つ振って出た目の数だけ
1つまたは2つの駒を進めることが出来て。
ゾロ目の時は1つ〜4つの駒を進めることが出来るんだ。\n
ただし、次のような決まりがあるよ。\n
\![*]出た目の数は可能な限り全部使う\n
\![*]片方の目しか使えない場合は大きい数を使う\n
\![*]どちらの目も動かせる駒が無い場合はパス\n
\![*]バーに駒があるときはその駒しか動かせない\n
\![*]移動先に相手の駒が2個以上あるところには進めない\n
\![*]移動先に相手の駒が1個ある場合はその駒を振り出しに戻せる\n
\n
-- 続く\n
\x
\b[2]
バックギャモンにはおおまかに2つのフェーズがあるから順番に説明していくね。\n
\n
\![*]第一フェーズ(ベアリングイン)\n
このゲームでは、駒をゴールさせるためには、
すべての駒を1-6ポイント(白番なら右下のエリア)に集める必要があるよ。\n
\n
\![*]第二フェーズ(ベアリングオフ)\n
すべての駒が1-6ポイントに集まったら、駒を上がらせることが出来るよ。
相手より先にすべての駒を上がらせることが出来たら勝ちだよ。\n
\n
次は勝ったときに手に入るポイントについての説明だよ。\n
\n
白が勝ったとして説明するね。\n
1. 黒が少なくとも1個上がっている\n
2. 黒が1個も上がっていない\n
3. 2.かつ白の1-6ポイント、もしくはバーに黒の駒がある\n
1は普通の上がりで1ポイント、2がギャモン勝ちで2ポイント、
3がバックギャモン勝ちで3ポイント手に入るよ。\n
\n
\![*]ダブル\n
自分の方が有利だなと思ったときなんかに、
相手に「このゲームで勝った方は倍のポイントが貰えるようにしませんか」
と打診することが出来るよ。\n
相手は「テイク(受け入れてゲームを続行)」か
「パス(倍にはせずにこのゲームを負け扱いにして次のゲームに進む)」
を選ぶことになるよ。\n
ゲーム開始後最初のダブルはどちらのプレイヤーも出来て、
ダブルをしたら、ダブルをされた方に次のダブルをする権利が与えられるよ。\n
\n
\![*]\q[戻る,対局メニュー(BG)] \![*]\q[閉じる,閉じる]
]]
  },
  {
    id  = "操作説明(BG)",
    content = [[
\0\b[2]
\_q
\![*]駒\n
駒を移動する\n
\n
\![*]自分の左のダイス\n
ダイス目の順番を入れ替える\n
移動した駒の確定を行う\n
\n
\![*]自分の右のダイス\n
動かせる駒が無いときに動かせない回数分押す\n
移動した駒の確定を行う\n
\n
\![*]それ以外の部分を右クリック\n
移動した駒を戻す(undo)\n
\n
\![*]相手のダイスを左クリック\n
自分のサイコロを振る\n
\n
\![*]相手のダイスを右クリック\n
ダブルをしてから自分のサイコロを振る\n
\n
\![*]\q[戻る,対局メニュー(BG)] \![*]\q[閉じる,閉じる]
\_q
]]
  },
}
