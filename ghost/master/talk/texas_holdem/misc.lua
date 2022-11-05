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
        local bet, call, fold, sum = 0, 0, 0, 0
        for _, v in ipairs(v.action) do
          for _, v in ipairs(v.preflop) do
            if v == "bet" or v == "raise" or v == "allin" then
              bet = bet + 1
            elseif v == "call" then
              call  = call + 1
            elseif v == "fold" then
              fold  = fold + 1
            end
            if v ~= "check" then
              sum = sum + 1
            end
          end
        end
        if sum > 0 then
          str:append(string.format([[    %3.1f%% %3.1f%% %3.1f%%\n]], 100 * bet / sum, 100 * call / sum, 100 * fold / sum))
        else
          str:append([[    0     0     0\n]])
        end
        str:append([[  ポストフロップ\n]])
        local bet, call, fold, sum = 0, 0, 0, 0
        for _, v in ipairs(v.action) do
          for _, v in ipairs(v.postflop) do
            if v == "bet" or v == "raise" or v == "allin" then
              bet = bet + 1
            elseif v == "call" then
              call  = call + 1
            elseif v == "fold" then
              fold  = fold + 1
            end
            if v ~= "check" then
              sum = sum + 1
            end
          end
        end
        if sum > 0 then
          str:append(string.format([[    %3.1f%% %3.1f%% %3.1f%%\n]], 100 * bet / sum, 100 * call / sum, 100 * fold / sum))
        else
          str:append([[    0     0     0\n]])
        end
        str:append([[\n]])
      end
      return str
    end,
  },
}
