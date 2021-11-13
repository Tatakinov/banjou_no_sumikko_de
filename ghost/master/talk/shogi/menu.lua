local StringBuffer  = require("string_buffer")
local SS  = require("sakura_script")

return {
  {
    id  = "将棋メニュー",
    content = [[
\_q
\0
\![*]\q[用語集,将棋用語]\n
\![*]\q[次の一手/手筋問題集,OnShogiNextMove]\n
\![*]\q[由希の研究メモ,将棋の戦法と手筋]\n
\![*]\q[ネット将棋をしてみたい,ネット将棋をしてみたい]\n
\![*]\q[四方山話,将棋四方山話一覧]\n
\n
\![*]\q[戻る,メニュー] \![*]\q[閉じる,閉じる]
\_q
]],
--\![*]\q[講座,将棋講座一覧]\n
  },
  {
    id  = "盤面モードのメニュー(将棋)",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer([[\0]])
      if __("_InGame") then
        str:append("\\![*]")
        str:append(SS():q("投了する", "OnShogiGameResign"):n())
      else
        str:append("\\![*]")
        str:append(SS():q("盤面モードを終了する", "盤面モード終了"):n())
        if __("_PostGame") then
          str:append("\\![*]")
          str:append(SS():q("この一局の評価", "OnTalkAnalysisResult"):n())
          str:append("\\![*]")
          str:append(SS():q("棋譜をクリップボードにコピー", "OnCopyKifuToClipboard"):n())
          str:append("\\![*]")
          str:append(SS():q("棋譜を保存", "OnSaveKifu"):n():n())
        elseif __("_次の一手問題ID") then
          str:append("\\![*]"):append(SS():q("次の一手の答えを見る", "将棋_次の一手_答え"):n():n())
        elseif __("_実戦詰将棋問題ID") then
          str:append("\\![*]"):append(SS():q("実戦詰将棋の答えを見る", "将棋_実戦詰将棋_答え"):n():n())
        end
      end
      str:append("\\![*]"):append(SS():q("閉じる", "閉じる"):n())
      return str
    end,
  },
}
