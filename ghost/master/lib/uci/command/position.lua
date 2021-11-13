local StringBuffer  = require("string_buffer")
local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "position")
  data.command = Command.POSITION
  data.moves  = {}
  index = 2
  if list[index] == "startpos" then
    data.fen  = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    index = index + 1
  else
    local pos       = list[index]
    local color     = list[index + 1]
    local castling  = list[index + 2]
    local enpassant = list[index + 3]
    local halfmoves = list[index + 4]
    local moves     = list[index + 5]
    data.fen  = table.concat({pos, color, castling, enpassant, halfmoves, moves}, " ")
    index = index + 6
  end
  if list[index] == "moves" then
    index = index + 1
    for i = index, #list do
      table.insert(data.moves, list[i])
    end
  end
  return data
end

function M.tostring(data)
  assert(data.command == Command.POSITION)
  local str = StringBuffer("position"):append(" ")
  if data.startpos then
    str:append("startpos")
  elseif data.sfen then
    str:append("fen"):append(" "):append(table.concat(data.sfen, " "))
  end
  if type(data.moves) == "table" and #data.moves > 0 then
    str:append(" "):append("moves")
    for i = 1, #data.moves do
      str:append(" "):append(data.moves[i])
    end
  end
  return str:tostring()
end

return M
