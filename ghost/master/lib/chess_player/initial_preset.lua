local M = {}

M.HIRATE  = "HIRATE"
M.OTHER   = "OTHER"

local sfen = {
  HIRATE  = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
}

--- presetに対応するsfenを返す@nil
function M.toSfen(preset)
  assert(preset)
  return sfen[preset]
end

local kanji = {
  [M.HIRATE]  = "平手",
  [M.OTHER]   = "その他",
}

function M.toKanji(preset)
  assert(preset)
  local err = "Invalid Initial Preset: "
  return (assert(kanji[preset], err))
end

return M
