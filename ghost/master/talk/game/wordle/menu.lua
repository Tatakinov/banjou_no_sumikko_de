local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "盤面モードのメニュー(Wordle)",
    content = nil,
  },
  {
    id  = "OnWordleGameMenu",
    content = function(shiori, ref)
      local __          = shiori.var
      local str = StringBuffer(SS():_q(true))

      shiori:talk("OnWordleGameInitialize")
      print("V:", type(__("_WordleVocabulary")))

      local game_option = __("WordleGameOption") or {
        length  = 5,
      }
      __("WordleGameOption", game_option)

      if ref[0] == "length" then
        local n = tonumber(ref[1])
        if n and n > 0 then
          game_option.length  = n
        end
      end

      str:append("文字数:\\_l[120]")
          :append(game_option.length):append("【")
          :append("\\_l[200,]\\q[変更,OnWordleGameOption]")
          :append("】"):append([[\n]])

      str:append([[\n\n]])

      str:append("\\![*]"):append(SS():q("ゲーム開始", "OnWordleGameStart"))
      str:append("  \\![*]"):append(SS():q("ルール説明", "OnWordleGameExplanation"))
      str:append("\\n")
      str:append("\\![*]"):append(SS():q("戻る", "メニュー"))
      str:append("      ")
      str:append("\\![*]"):append(SS():q("閉じる", "盤面モード終了"))

      str:append(SS():_q(false))

      str:append("\\![set,balloontimeout,0]\\![set,choicetimeout,0]")

      return str:tostring()
    end,
  },
  {
    id  = "OnWordleGameOption",
    content = function(shiori, ref)
      if ref[0] then
        return [[\C\![raise,OnWordleGameMenu,length,]] .. ref[0] .. "]"
      end
      return "\\C\\![open,inputbox,OnWordleGameOption]"
    end,
  },
  {
    id  = "OnWordleGameExplanation",
    content = [[
\0
\_q【ルール説明】\n
\n
\n
\![*]\q[戻る,OnWordleGameMenu]
]],
  },
}
