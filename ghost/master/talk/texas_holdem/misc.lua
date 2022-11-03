local StringBuffer  = require("string_buffer")

return {
  {
    id  = "p_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      str:append([=[\_q\0\b[2]]=])
      for k, v in pairs(__("_PlayerInfo")) do
        str:append(k):append([[さんの情報だよ\n]])
        str:append([[  プリフロップ\n]])
        local bet, call, fold = 0, 0, 0
        local action  = v.preflop_action
        for _, v in ipairs(action) do
          if v == "bet" or v == "raise" or v == "allin" then
            bet = bet + 1
          elseif v == "call" or v == "check" then
            call  = call + 1
          else
            assert(v == "fold")
            fold  = fold + 1
          end
        end
        if #action > 0 then
          str:append(string.format([[    %3.1f %3.1f %3.1f\n]], 100 * bet / #action, 100 * call / #action, 100 * fold / #action))
        else
          str:append([[    0     0     0\n]])
        end
        str:append([[  ポストフロップ\n]])
        local bet, call, fold = 0, 0, 0
        local action  = v.postflop_action
        for _, v in ipairs(action) do
          if v == "bet" or v == "raise" or v == "allin" then
            bet = bet + 1
          elseif v == "call" or v == "check" then
            call  = call + 1
          else
            assert(v == "fold")
            fold  = fold + 1
          end
        end
        if #action > 0 then
          str:append(string.format([[    %3.1f %3.1f %3.1f\n]], 100 * bet / #action, 100 * call / #action, 100 * fold / #action))
        else
          str:append([[    0     0     0\n]])
        end
        str:append([[\n]])
      end
      return str
    end,
  },
}
