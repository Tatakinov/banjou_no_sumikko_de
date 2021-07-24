return {
  {
    id  = "盤面モードのメニュー",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") == "Shogi" then
        return shiori:talk("盤面モードのメニュー(将棋)")
      elseif __("_Quiet") == "Mahjong" then
        return shiori:talk("盤面モードのメニュー(麻雀)")
      end
    end,
  },
}
