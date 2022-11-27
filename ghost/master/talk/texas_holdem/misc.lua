local StringBuffer  = require("string_buffer")

return {
  {
    id  = "p_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      str:append([=[\_q\0\b[2]]=])
      if not(__("_PlayerInfo")) then
        return nil
      end
      for k, v in pairs(__("_PlayerInfo")) do
        str:append(k):append([[さんの情報だよ\n]])
        str:append([[  プリフロップ\n]])
        str:append([[    bet  call chck limp fold\n]])
        local bet, check, call, limp, fold, sum = 0, 0, 0, 0, 0, 0
        for _, v in ipairs(v.action) do
          for _, v in ipairs(v.preflop) do
            if v == "bet" or v == "raise" or v == "allin" then
              bet = bet + 1
            elseif v == "call" then
              call  = call + 1
            elseif v == "limp" then
              limp  = limp + 1
            elseif v == "fold" then
              fold  = fold + 1
            elseif v == "check" then
              check = check + 1
            end
            sum = sum + 1
          end
        end
        if limp + fold > 0 then
          str:append(string.format([[    %3.1f%% %3.1f%% %3.1f%% %3.1f%% %3.1f%%\n]], 100 * bet / sum, 100 * call / sum, 100 * check / sum, 100 * limp / sum, 100 * fold / sum))
          print("Player:", k)
          print("----")
          print("bet", 100 * bet / (bet + limp + fold))
          print("limp / fold", 100 * limp / (limp + fold), 100 * fold / (limp + fold))
        else
          str:append([[なし\n]])
        end
        str:append([[  ポストフロップ\n]])
        local bet, raise, call, check, fold, sum = 0, 0, 0, 0, 0, 0
        for _, v in ipairs(v.action) do
          for _, v in ipairs(v.postflop) do
            if v == "bet" or v == "raise" or v == "allin" then
              if v == "bet" then
                bet = bet + 1
              elseif v == "raise" then
                raise = raise + 1
              else
                bet = bet + 1
                raise = raise + 1
              end
            elseif v == "call" then
              call  = call + 1
            elseif v == "check" then
              check = check + 1
            elseif v == "fold" then
              fold  = fold + 1
            end
            sum = sum + 1
          end
        end
        if sum > 0 then
          str:append(string.format([[    %3.1f%% %3.1f%% %3.1f%% %3.1f%%\n]], 100 * bet / sum, 100 * call / sum, 100 * check / sum, 100 * fold / sum))
          print("fold:", fold / sum)
          if bet + call + check > 0 then
            print("bet / call / fold", 100 * bet / (bet + call + fold), 100 * call / (bet + call + fold), 100 * fold / (bet + call + fold))
          end
          print("----")
        else
          str:append([[なし\n]])
        end
        str:append([[\n]])
      end
      return str
    end,
  },
}
