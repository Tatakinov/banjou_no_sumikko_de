local M = {
  plus_mate   = 1,
  won         = 2,
  winning     = 3,
  plus        = 4,
  plus_equal  = 5,
  equality    = 6,
  minus_equal = 7,
  minus       = 8,
  losing      = 9,
  lost        = 10,
  minus_mate  = 11,
  equalize    = 100,
  unclear     = 101,
  critical    = 102,
}

local Judge_SID = {
  [M.plus_mate]   = "勝ち", -- TODO 表情差分の追加
  [M.won]         = "勝ち",
  [M.winning]     = "勝勢",
  [M.plus]        = "優勢",
  [M.plus_equal]  = "有利",
  [M.equality]    = "互角",
  [M.minus_equal] = "不利",
  [M.minus]       = "劣勢",
  [M.losing]      = "敗勢",
  [M.lost]        = "負け",
  [M.minus_mate]  = "負け", -- TODO 表情差分の追加
  [M.equalize]    = 0,
  [M.unclear]     = 0,
  [M.critical]    = 0,
}

function M.sid(judge)
  return Judge_SID[judge]
end

return M
