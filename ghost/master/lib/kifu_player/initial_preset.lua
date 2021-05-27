local M = {}

M.HIRATE  = "HIRATE"
M.OTHER   = "OTHER"
M.KY      = "KY"
M.KA      = "KA"
M.HI      = "HI"
M["2"]    = "2"
M["4"]    = "4"
M["6"]    = "6"
M["8"]    = "8"
M["10"]    = "10"

local sfen = {
  HIRATE  = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1",
  KY      = "lnsgkgsn1/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  KA      = "lnsgkgsnl/1r7/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  HI      = "lnsgkgsnl/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  ["2"]   = "lnsgkgsnl/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  ["4"]   = "1nsgkgsn1/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  ["6"]   = "2sgkgs2/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  ["8"]   = "3gkg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
  ["10"]  = "4k4/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w - 1",
}

--- presetに対応するsfenを返す@nil
function M.toSfen(preset)
  assert(preset)
  return sfen[preset]
end

local kanji = {
  [M.HIRATE]  = "平手",
  [M.KY]      = "香落ち",
  [M.KA]      = "角落ち",
  [M.HI]      = "飛車落ち",
  [M["2"]]    = "二枚落ち",
  [M["4"]]    = "四枚落ち",
  [M["6"]]    = "六枚落ち",
  [M["8"]]    = "八枚落ち",
  [M["10"]]   = "十枚落ち",
  [M.OTHER]   = "その他",
}

function M.toKanji(preset)
  assert(preset)
  local err = "Invalid Initial Preset: "
  return (assert(kanji[preset], err))
end

return M
