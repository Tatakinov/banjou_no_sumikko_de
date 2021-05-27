local M = {}

local list  = {
  "black", "copypen", "masknotpen", "maskpen", "maskpennot",
  "mergenotpen", "mergepen", "mergepennot",
  "nop", "not", "notcopypen", "notmaskpen", "notmergepen",
  "notxorpen", "white", "xorpen",
}

for i = 1, #list do
  local key = list[i]
  M[key]  = key
end

return M
