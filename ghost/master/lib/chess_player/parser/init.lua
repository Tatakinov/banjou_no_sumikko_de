-- @module Parser

--- KIF,KI2,CSA,JKF形式とのやりとりを行う

local UCI = require("chess_player.parser.uci")

local class_table = {
  UCI = UCI,
}

local M = {}

for k, v in pairs(class_table) do
  M[k]  = v
end

--- UTF-8な棋譜をパースする
-- @tparam string str
-- @treturn ChessData
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
