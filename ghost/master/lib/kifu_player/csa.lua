-- @module CSA

--- CSA表記

local M = {}

--- 歩兵
-- @field FU
M.FU = "FU"

--- と金
-- @field TO
M.TO = "TO"

--- 香車
-- @field KY
M.KY = "KY"

--- 成香
-- @field NY
M.NY = "NY"

--- 桂馬
-- @field KE
M.KE = "KE"

--- 成桂
-- @field NK
M.NK = "NK"

--- 銀将
-- @field GI
M.GI = "GI"

--- 成銀
-- @field NG
M.NG = "NG"

--- 金将
-- @field KI
M.KI = "KI"

--- 角行
-- @field KA
M.KA = "KA"

--- 龍馬
-- @field UM
M.UM = "UM"

--- 飛車
-- @field HI
M.HI = "HI"

--- 龍王
-- @field RY
M.RY = "RY"

--- 王将
-- @field OU
M.OU = "OU"

M.HAND  = {
  M.FU, M.KY, M.KE, M.GI, M.KI, M.KA, M.HI, M.OU,
}

M.ALL   = {
  M.FU, M.KY, M.KE, M.GI, M.KI, M.KA, M.HI, M.OU,
  M.TO, M.NY, M.NK, M.NG,       M.UM, M.RY,
}

return M
