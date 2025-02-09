local CSA           = require("kifu_player.csa")
local Color         = require("kifu_player.color")
local InitialPreset = require("kifu_player.initial_preset")
local Misc          = require("kifu_player.misc")
local Relative      = require("kifu_player.relative")
local StringBuffer  = require("string_buffer")

-- @module usi

--- usi パーサー

local M = {}

--- TODO comment
-- @tparam string c
-- @treturn color,string
local function getPieceInfo(c)
  local lc  = string.lower(c)
  if lc == c then
    return Color.WHITE, Misc.sfen2csa(lc)
  end
  return Color.BLACK, Misc.sfen2csa(lc)
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
    color = Color.BLACK,
    board = {},
    hands = {},
  }
  for i = 1, 9 do
    data.board[i] = {}
    for j = 1, 9 do
      data.board[i][j]  = {}
    end
  end
  for _, color in ipairs({Color.BLACK, Color.WHITE}) do
    data.hands[color] = {}
    for _, v in ipairs(CSA.HAND) do
      data.hands[color][v] = 0
    end
  end

  local x = 9
  local promote = false
  local y = 1
  local state = 0
  local num = 0
  for c in string.gmatch(str, ".") do
    if c == " " then
      state = state + 1
    elseif state == 0 then  -- 盤面
      local num = tonumber(c)
      if num then
        assert(promote == false, err)
        x = x - num
      else
        if c == "+" then
          assert(promote == false, err)
          promote = true
        elseif c == "/" then
          assert(promote == false, err)
          y = y + 1
          x = 9
        else
          local color, kind = getPieceInfo(c)
          if promote then
            promote = false
            kind  = Misc.promote(kind)
          end
          data.board[x][y].color  = color
          data.board[x][y].kind   = kind
          x = x - 1
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
    elseif state == 2 then  -- 持ち駒
      if c == "-" then
        -- nop
      else
        if tonumber(c) then
          num = num * 10 + tonumber(c)
        else
          local color, kind = getPieceInfo(c)
          if num > 0 then
            data.hands[color][kind] = num
            num = 0
          else
            data.hands[color][kind] = 1
          end
        end
      end
    elseif state == 3 then  -- 手数(無視)
    end -- if state
  end

  return data
end

--- TODO comment
function M.parseMove(str)
  local move  = {}
  local special = Misc.special2csa(str)
  if special then
    return special
  end
  for i = 1, #str do
    local c = string.sub(str, i, i)
    if i == 1 then
      local num = tonumber(c)
      if num == nil then
        move.piece  = Misc.sfen2csa(string.lower(c))
      else
        move.from = {
          x = num,
        }
      end
    elseif i == 2 then
      if c == "*" then
        assert(move.piece)
        move.relative = Relative.H
      else
        assert(move.from)
        move.from.y = Misc.sfen2n(c)
      end
    elseif i == 3 then
      local num = assert(tonumber(c))
      move.to = {
        x = num,
      }
    elseif i == 4 then
      assert(move.to)
      move.to.y = Misc.sfen2n(c)
    elseif i == 5 then
      if c == "+" then
        move.promote  = true
      end
    end
  end
  return move
end

function M.toUSI(jkf)
  assert(type(jkf) == "table")
  local str = StringBuffer()
  local t   = {}
  -- 初期局面
  local init, sep  = M.toUSIinit(jkf.initial)
  str:append(table.concat(init, sep))
  t.init  = init
  t.sep   = sep
  t.moves = {}
  if jkf.moves and #jkf.moves > 0 then
    for i = 1, #jkf.moves do
      local move  = M.toUSImove(jkf.moves[i], i)
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

function M.toUSIinit(initial)
  local sep = " "
  local t   = {}
  if initial == nil or initial.preset == InitialPreset.HIRATE then
    t[1]  = "startpos"
  elseif initial.preset == "OTHER" and initial.data then
    local position  = StringBuffer()
    local hands = StringBuffer()
    local turn  = StringBuffer()
    local array = {}
    for y = 1, 9 do
      local cnt = 0
      for x = 9, 1, -1 do
        local x, y  = x, y
        local piece = initial.data.board[x][y]
        if piece.kind and piece.color then
          if cnt > 0 then
            position:append(cnt)
            cnt = 0
          end
          local p = Misc.csa2sfen(piece.kind)
          local color = piece.color
          if color == Color.BLACK then
            p = string.upper(p)
          end
          position:append(p)
        else
          cnt = cnt + 1
        end
      end
      if cnt > 0 then
        position:append(cnt)
        cnt = 0
      end
      if y < 9 then
        position:append("/")
      end
    end

    t[1] = position:tostring()

    if initial.data.color == Color.BLACK then
      turn:append("b")
    elseif initial.data.color == Color.WHITE then
      turn:append("w")
    else
      -- TODO error
    end

    t[2] = turn:tostring()

    for _, color in ipairs(Color.LIST) do
      for k, v in pairs(initial.data.hands[color]) do
        if k ~= CSA.OU then
          local num = v
          if num > 0 then
            local p = Misc.csa2sfen(k)
            if color == Color.BLACK then
              p = string.upper(p)
            end
            if num > 1 then
              hands:append(num)
            end
            hands:append(p)
          end
        end
      end
    end

    if hands:strlen() == 0 then
      hands:append("-")
    end
    t[3] = hands:tostring()
    t[4] = "1"
  else
    t[1]  = InitialPreset.toSfen(initial.preset)
  end
  return t, sep
end

function M.toUSImove(move_format)
  assert(move_format)
  local str   = StringBuffer()
  local move  = move_format.move
  if move then
    if move.from then
      str:append(tostring(move.from.x))
          :append(Misc.n2sfen(move.from.y))
          :append(tostring(move.to.x))
          :append(Misc.n2sfen(move.to.y))
      if move.promote then
        str:append("+")
      end
    else
      str:append(string.upper(Misc.csa2sfen(move.piece)))
          :append("*")
          :append(tostring(move.to.x))
          :append(Misc.n2sfen(move.to.y))
    end
  end
  return str:tostring()
end

return M
