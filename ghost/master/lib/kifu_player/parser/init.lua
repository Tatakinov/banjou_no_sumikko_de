-- @module Parser

--- KIF,KI2,CSA,JKF形式とのやりとりを行う

local KIF = require("kifu_player.parser.kif")
local KI2 = require("kifu_player.parser.ki2")
local CSA = require("kifu_player.parser.csa")
local JKF = require("kifu_player.parser.jkf")
local USI = require("kifu_player.parser.usi")

local class_table = {
  KIF = KIF,
  KI2 = KI2,
  CSA = CSA,
  JKF = JKF,
  USI = USI,
}

local M = {}

for k, v in pairs(class_table) do
  M[k]  = v
end

--- UTF-8な棋譜をパースする
-- @tparam string str
-- @treturn KifuData
function M.parse(kp, str)
  for _, class in pairs(class_table) do
    local success, jkf = pcall(class.parse, kp, str)
    if success and jkf then
      return jkf
    else
      --print(tostring(jkf))
    end
  end
end

--- TODO comment
-- @tparam string str
-- @treturn move
function M.parseMove(str)
  for _, class in pairs(class_table) do
    local success, move = pcall(class.parseMove, str)
    if success and move then
      return move
    else
      -- print(tostring(move))
    end
  end
end

return M
