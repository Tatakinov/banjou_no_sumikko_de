local Color         = require("chess_player.color")
local InitialPreset = require("chess_player.initial_preset")
local Misc          = require("chess_player.misc")
local Relative      = require("chess_player.relative")
local StringBuffer  = require("string_buffer")

-- @module uci

--- uci パーサー

local M = {}

--- TODO comment
-- @tparam string c
-- @treturn color,string
local function getPieceInfo(c)
  local uc  = string.upper(c)
  if uc == c then
    return Color.WHITE, uc
  end
  return Color.BLACK, uc
end

function M.parse(kp, str)
end

--- 任意の初期局面をパースする
function M.parseInit(str)
  local err = "Invalid initial position"
  assert(str, err)
  -- TODO InitialPreset
  -- OTHER
  local data  = {
    color = Color.WHITE,
    board = {},
    hands = {},
  }
  for i = 1, 8 do
    data.board[i] = {}
    for j = 1, 8 do
      data.board[i][j]  = {}
    end
  end
  for _, color in ipairs({Color.BLACK, Color.WHITE}) do
    data.hands[color] = {}
    for _, v in ipairs(Misc.HAND) do
      data.hands[color][v] = 0
    end
  end

  local x = 1
  local promote = false
  local y = 8
  local state = 0
  local num = 0
  for c in string.gmatch(str, ".") do
    if c == " " then
      state = state + 1
    elseif state == 0 then  -- 盤面
      local num = tonumber(c)
      if num then
        assert(promote == false, err)
        x = x + num
      else
        if c == "+" then
          assert(promote == false, err)
          promote = true
        elseif c == "/" then
          assert(promote == false, err)
          y = y - 1
          x = 1
        else
          local color, kind = getPieceInfo(c)
          if promote then
            promote = false
            kind  = Misc.promote(kind)
          end
          data.board[x][y].color  = color
          data.board[x][y].kind   = kind
          x = x + 1
        end
      end --  if num
    elseif state == 1 then  -- 初期局面での手番
      if c == "b" then
        data.color  = Color.BLACK
      elseif c == "w" then
        data.color  = Color.WHITE
      else
        -- error()
      end
    elseif state == 2 then  -- castling available
      if c == "-" then
        -- nop
      end
    elseif state == 3 then  -- en passant
    elseif state == 4 then -- half 50 moves
    elseif state == 5 then -- tesuu
    end -- if state
  end

  return data
end

--- TODO comment
function M.parseMove(str)
  local move  = {}
  if str == "resign" then
    return str
  end
  if str == "0000" then
    return "nullmove"
  end
  for i = 1, #str do
    local c = string.sub(str, i, i)
    if i == 1 then
      move.from = {
        x = Misc.fen2n(c),
      }
    elseif i == 2 then
      assert(move.from)
      local num = tonumber(c)
      move.from.y = num
    elseif i == 3 then
      move.to = {
        x = Misc.fen2n(c),
      }
    elseif i == 4 then
      assert(move.to)
      local num = assert(tonumber(c))
      move.to.y = num
    elseif i == 5 then
      move.promote  = string.upper(c)
    end
  end
  return move
end

function M.toUCI(jkf)
  assert(type(jkf) == "table")
  local str = StringBuffer()
  local t   = {}
  -- 初期局面
  local init, sep  = M.toUCIinit(jkf.initial)
  str:append(table.concat(init, sep))
  t.init  = init
  t.sep   = sep
  t.moves = {}
  if jkf.moves and #jkf.moves > 0 then
    for i = 1, #jkf.moves do
      local move  = M.toUCImove(jkf.moves[i], i)
      if move then
        table.insert(t.moves, move)
      else
        --TODO stub
        break
      end
    end
    str:append(" moves"):append(t.sep):append(table.concat(t.moves, sep))
  end
  return str:tostring(), t
end

function M.toUCIinit(initial)
  local sep = " "
  local t   = {}
  if initial == nil or initial.preset == InitialPreset.HIRATE then
    t[1]  = "startpos"
  elseif initial.preset == "OTHER" then
    -- TODO stub
  else
    t[1]  = InitialPreset.toSfen(initial.preset)
  end
  return t, sep
end

function M.toUCImove(move_format)
  assert(move_format)
  local str   = StringBuffer()
  local move  = move_format.move
  if move then
    if move.from then
      if move.from.x == 0 and move.from.y == 0 and
          move.to.x == 0 and move.to.y == 0 then
        str:append("0000")
      else
        str:append(Misc.n2fen(move.from.x))
            :append(tostring(move.from.y))
            :append(Misc.n2fen(move.to.x))
            :append(tostring(move.to.y))
        if move.promote then
          str:append(string.lower(move.promote))
        end
      end
    else
      str:append(string.upper(Misc.csa2sfen(move.piece)))
          :append("*")
          :append(Misc.n2fen(move.to.x))
          :append(tostring(move.to.y))
    end
  end
  return str:tostring()
end

return M
