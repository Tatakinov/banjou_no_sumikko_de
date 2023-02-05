local talk  = {}

for i = 1, 6 do
  table.insert(talk, {
    id  = string.format("9DUMMY_MANCALA01%02dLeft", i),
    content = function(shiori, ref)
      --print("click")
      local __  = shiori.var
      local state = __("_MancalaState")
      local index = __("_MancalaIndex") or 0
      __("_MancalaState", "select")
      __("_MancalaIndex", i)
      return [=[\![raise,OnMancalaGamePlayerTurnEnd]]=]
      --return nil
    end,
  })
end

return talk
