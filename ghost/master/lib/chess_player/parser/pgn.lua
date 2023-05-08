local Color         = require("chess_player.color")
local InitialPreset = require("chess_player.initial_preset")
local Misc          = require("chess_player.misc")
local Relative      = require("chess_player.relative")
local StringBuffer  = require("string_buffer")

-- @module pgn

--- PGN パーサー

local M = {}

function M.parse(kp, str)
  assert(false)
end

--- 任意の初期局面をパースする
function M.parseInit(str)
  -- TODO stub
end

function M.parseMove(str)
  -- TODO stub
end

function M.toPGN(jkf)
  assert(type(jkf) == "table")
  local header  = StringBuffer()
  local str = StringBuffer()
  header:append('[Event "Banjou no Sumikko de"]\n')
  header:append('[Site "PC"]\n')
  -- TODO 日付の取得
  header:append('[Date "2000.01.01"]\n')
  header:append('[Round "1"]\n')
  -- TODO 対戦者の取得
  header:append(string.format('[White "%s"]\n', jkf.header["White"]))
  header:append(string.format('[Black "%s"]\n', jkf.header["Black"]))
  -- 初期局面
  if jkf.moves and #jkf.moves > 0 then
    for i = 1, #jkf.moves do
      if i % 2 == 1 then
        str:append(string.format("%d.", (i + 1) / 2))
      end
      local move  = M.toPGNmove(jkf.moves[i])
      if move then
        str:append(" " .. move)
      else
        local special = jkf.moves[i].special or "draw"
        if special == "lose" then
          if i % 2 == 0 then
            str:append(" 1-0")
            header:append('[Result "1-0"]\n')
          else
            str:append(" 0-1")
            header:append('[Result "0-1"]\n')
          end
        elseif special == "draw" then
          str:append(" 1/2-1/2")
          header:append('[Result "1/2-1/2"]\n')
        else
          header:append('[Result "1/2-1/2"]\n')
        end
      end
      if i % 2 == 0 then
        str:append("\n")
      end
    end
  end
  header:append('\n')
  return header:tostring() .. str:tostring()
end

function M.toPGNinit(initial)
  -- TODO stub
end

function M.toPGNmove(move_format)
  assert(move_format)
  local str   = StringBuffer()
  local move  = move_format.move
  if move then
    if move.from then
      if move.castling == "K" then
        str:append("O-O")
      elseif move.castling == "Q" then
        str:append("O-O-O")
      else
        str:append(string.upper(move.piece))
            :append(Misc.n2fen(move.from.x))
            :append(tostring(move.from.y))
        if move.capture then
          str:append("x")
        end
        str:append(Misc.n2fen(move.to.x))
            :append(tostring(move.to.y))
        if move.promote then
          str:append(string.upper(move.promote))
        end
      end
    end
  end
  if str:strlen() > 0 then
    return str:tostring()
  end
end

return M
