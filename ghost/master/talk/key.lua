local StringBuffer  = require("string_buffer")

return {
  {
    id  = "b_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Sfen", nil)
      return shiori:talk("OnShogiViewMinimal")
    end,
  },
  {
    id  = "c_Key",
    content = [[
\![open,communicatebox]
]],
  },
  {
    id  = "d_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local dict_error  = __("_DictError")
      for _, v in ipairs(dict_error) do
        str:append([[\_?]]):append(v):append([[\_?\n]])
      end
      if str:strlen() > 0 then
        str:prepend([[\0]])
        return str
      end
      return [[\0辞書エラーは起こってないよ！]]
    end,
  },
  {
    id  = "t_Key",
    content = function(shiori, ref)
      return shiori:talkRandom()
    end,
  },
  {
    id  = "m_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") then
        return shiori:talk("盤面モードのメニュー")
      else
        return shiori:talk("メニュー")
      end
    end,
  },
  {
    id  = "r_Key",
    content = [[
\![reload,shiori]
]],
  },
  {
    id  = "a_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_次の一手問題ID") then
        return shiori:talk("将棋_次の一手_答え")
      elseif __("_実戦詰将棋問題ID") then
        return shiori:talk("将棋_実戦詰将棋_答え")
      end
    end,
  },
}
