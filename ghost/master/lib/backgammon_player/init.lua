local StringBuffer = require("string_buffer")

local Class = require("class")

local W = 1
local B = 2

local moves = {}
local passed = false

local M = Class()
M.__index = M

M.colors  = {W, B}

function M:_init()
  self._current_color = W
  self._position  = {
    {
      0, 0, 0, 0, 0, 5,
      0, 3, 0, 0, 0, 0,
      5, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 2,
      0,
    },
    {
      0, 0, 0, 0, 0, 5,
      0, 3, 0, 0, 0, 0,
      5, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 2,
      0,
    },
  }
end

function M:initializeMatch(point)
  self._point = point
  self._kifu = {
    game = {},
  }
  self._current_game = 0
  self._crawford  = false
  self._w_point = 0
  self._b_point = 0
end

function M:initializeGame()
  table.insert(self._kifu, {})
  self._position  = {
    {
      0, 0, 0, 0, 0, 5,
      0, 3, 0, 0, 0, 0,
      5, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 2,
      0,
    },
    {
      0, 0, 0, 0, 0, 5,
      0, 3, 0, 0, 0, 0,
      5, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 2,
      0,
    },
  }
  self._position[1][0]  = 0
  self._position[2][0]  = 0
  self._current_rate  = 1
  self._double_color  = nil
  self._current_game = self._current_game + 1
  self._kifu.game[self._current_game] = {}
  passed = false
  moves = {
    move = {},
  }
end

function M:initColor(color)
  self._current_color   = color
end

function M:getColor()
  return self._current_color
end

function M:getPosition()
  return self._position
end

function M:move(move, dice)
  local c     = self._current_color
  local r     = self:reverse(c)
  local p     = self._position
  -- dance
  if move.dance then
    table.insert(moves.move, {
      dice    = dice,
      capture = false,
    })
    return
  end
  local dice  = dice or move.from - move.to
  if move.to <= 0 then
    p[c][move.from]  = p[c][move.from] - 1
    p[c][0] = p[c][0] + 1
    table.insert(moves.move, {
      dice    = dice,
      from    = move.from,
      to      = 0,
      capture = false,
    })
  else
    assert(p[c][move.from] > 0)
    assert(p[r][25 - move.to] < 2)
    p[c][move.from]  = p[c][move.from] - 1
    p[c][move.to]    = p[c][move.to] + 1
    if p[r][25 - move.to] == 1 then
      p[r][25 - move.to] = 0
      p[r][25] = p[r][25] + 1
      table.insert(moves.move, {
        dice    = dice,
        from    = move.from,
        to      = move.to,
        capture = true,
      })
    else
      table.insert(moves.move, {
        dice    = dice,
        from    = move.from,
        to      = move.to,
        capture = false,
      })
    end
  end
end

function M:unmove()
  local p     = self._position
  local move  = table.remove(moves.move, #moves.move)
  --local c     = move.color
  local c = self._current_color
  local r     = self:reverse(c)
  --assert(c == self._current_color)
  --print("unmove")
  --print("from", move.from, "to", move.to)
  if move.from then
    if move.to == 0 then
      p[c][move.to]    = p[c][move.to] - 1
      p[c][move.from]  = p[c][move.from] + 1
    else
      p[c][move.to]    = p[c][move.to] - 1
      p[c][move.from]  = p[c][move.from] + 1
      if move.capture then
        p[r][25] = p[r][25] - 1
        p[r][25 - move.to] = p[r][25 - move.to] + 1
      end
    end
  end
end

local function filter(a, f)
  local t = {}
  for _, v in ipairs(a) do
    if f(v) then
      table.insert(t, v)
    end
  end
  return t
end

function M:confirm()
  local m = {}
  local dice1 = nil
  local dice2 = nil
  if #moves.move > 0 then
    dice1 = moves.move[1].dice
    dice2 = moves.move[2].dice
    if dice1 < dice2 then
      dice1, dice2 = dice2, dice1
    end
    m = filter(moves.move, function(a) return a.from and a.dice end)
    table.sort(m, function(a, b)
      if a.from == b.from then
        if a.dice == b.dice then
          local a = a.capture and 1 or 0
          local b = b.capture and 1 or 0
          return a > b
        end
        return a.dice > b.dice
      end
      return a.from > b.from
    end)
  end
  table.insert(self._kifu.game[self._current_game], {
    win = moves.win,
    double = moves.double,
    take = moves.take,
    color = self._current_color,
    dice1 = dice1,
    dice2 = dice2,
    move = m,
  })
  moves = {
    move = {},
  }
  self._current_color = self:reverse(self._current_color)
end

function M:reverse(color)
  return 3 - color
end

function M:generateMoves(k, l, m, n)
  local moves = {}
  local c = self._current_color
  local p = self._position
  --print("k", k, "l", l, "m", m, "n", n)
  if p[c][25] > 0 then
    if p[c][25 - k] and
      p[self:reverse(c)][24 - 25 + k + 1] <= 1 then
      if l then
        self:move({from = 25, to = 25 - k}, k)
        local t = self:generateMoves(l, m, n)
        self:unmove()
        if #t > 0 then
          table.insert(moves, {from = 25, to = 25 - k})
        end
      else
        table.insert(moves, {from = 25, to = 25 - k})
      end
    end
    return moves
  end
  for i, v in ipairs(p[c]) do
    if v > 0 then
      if p[c][i - k] and i - k > 0 and
        p[self:reverse(c)][24 - i + k + 1] <= 1 then
        if l then
          self:move({from = i, to = i - k}, k)
          local t = self:generateMoves(l, m, n)
          self:unmove()
          if #t > 0 then
            table.insert(moves, {from = i, to = i - k})
          end
        else
          table.insert(moves, {from = i, to = i - k})
        end
      end
    end
  end
  local can_goal  = true
  for i = 7, 25 do
    if p[c][i] > 0 then
      can_goal  = false
      break
    end
  end
  if can_goal then
    if p[c][k] > 0 then
      -- k - kは0だけど他のと表記を揃えた
      table.insert(moves, {from = k, to = k - k})
    end
    local is_over = true
    for i = 6, k, -1 do
      if p[c][i] > 0 then
        is_over = false
        break
      end
    end
    if #moves == 0 and is_over then
      for i = k - 1, 1, -1 do
        if p[c][i] > 0 then
          --table.insert(moves, {from = i, to = i - k})
          table.insert(moves, {from = i, to = i - i})
          break
        end
      end
    end
  end
  return moves
end

function M:dump()
  local s = ""
  if self._current_color == 1 then
    for _, v in ipairs(self._position) do
      for i = 0, 25 do
        s = s .. tostring(v[i]) .. "/"
      end
    end
  else
    for _, v in ipairs({self._position[2], self._position[1]}) do
      for i = 0, 25 do
        s = s .. tostring(v[i]) .. "/"
      end
    end
  end
  return s
end

function M:canDouble()
  if self:isGameOver() then
    return false
  end
  if self._crawford then
    return false
  end
  if self._double_color and self._current_color ~= self._double_color then
    return false
  end
  if self._current_rate == 64 then
    return false
  end
  local min = self._w_point < self._b_point and self._w_point or self._b_point
  if min + self._current_rate > self._point then
    return false
  end
  return true
end

function M:double()
  if self:canDouble() then
    print("double!")
    self._double_color  = self:reverse(self._current_color)
    self._current_rate  = self._current_rate * 2
    moves.double = self._current_rate
    self:confirm()
    return true
  else
    print("dont double")
  end
  return false
end

function M:take()
  moves.take = true
  self:confirm()
end

function M:pass()
  moves.take = false
  passed = true
  self:confirm()
end

function M:confirmGameOver()
  if passed then
    moves.win = self:getDoubleRate() / 2
  else
    moves.win = self:getDoubleRate() * self:gameOver()
  end
  self._current_color = self:reverse(self._current_color)
  if self._current_color == W then
    self._w_point = self._w_point + moves.win
  else
    self._b_point = self._b_point + moves.win
  end
  if self._crawford ~= nil then
    if self._crawford then
      self._crawford = nil
    elseif self._point - 1 == self._w_point or self._point - 1 == self._b_point then
      self._crawford  = true
    end
  end
  self:confirm()
end

function M:getDoubleColor()
  return self._double_color
end

function M:getDoubleRate()
  return self._current_rate
end

function M:isGameOver()
  local p = self._position
  return p[1][0] == 15 or p[2][0] == 15
end

function M:gameOver()
  local p = self._position
  if p[1][0] == 15 then
    if p[2][0] > 0 then
      return 1
    end
    local backgammon  = false
    for i = 19, 25 do
      if p[2][i] > 0 then
        backgammon  = true
        break
      end
    end
    if backgammon then
      return 3
    else
      return 2
    end
  elseif p[2][0] == 15 then
    if p[1][0] > 0 then
      return 1
    end
    local backgammon  = false
    for i = 19, 25 do
      if p[1][i] > 0 then
        backgammon  = true
        break
      end
    end
    if backgammon then
      return 3
    else
      return 2
    end
  end
  return 1
end

local function append(s, n)
  if #s < n then
    return s .. string.rep(" ", n - #s)
  end
  if string.sub(s, #s, #s) ~= " " then
    s = s .. " "
  end
  return s
end

local function f1(v)
  if v.double then
    return string.format(" Doubles => %d", v.double)
  end
  if v.take == true then
    return " Takes"
  end
  if v.take == false then
    return " Drops"
  end
  local str = StringBuffer()
  str:append(v.dice1):append(v.dice2):append(":")
  for _, v in ipairs(v.move) do
    str:append(" "):append(v.from):append("/"):append(v.to)
    if (v.capture) then
      str:append("*")
    end
  end
  return str:tostring()
end

function M:kifu()
  local str = StringBuffer()
  str:append(string.format('; [EventDate "%s"]\n', os.date("%Y.%m.%d")))
  str:append("\n")
  str:append(" "):append(self._point):append(" point match\n")
  str:append("\n")
  local w_point, b_point = 0, 0
  for i = 1, self._current_game do
    str:append(" Game "):append(i):append("\n")
    str:append(string.format(" User :        %d                Yuki_Komiya : %d\n", w_point, b_point))
    local move = 1
    local color
    local prev
    for index, v in ipairs(self._kifu.game[i]) do
      if v.win then
        if v.color == W then
          if prev.take == false then
            str:append(string.format(" Wins %d point", v.win))
          else
            str:append(string.format("\n      Wins %d point", v.win))
          end
        else
          if prev.take == false then
            str:append(string.format(" Wins %d point\n", v.win))
          else
            str:append(append("", 33))
            str:append(string.format(" Wins %d point\n", v.win))
          end
        end
        color = v.color
        if v.color == W then
          w_point = w_point + v.win
        else
          b_point = b_point + v.win
        end
      else
        if index == 1 or v.color == W then
          str:append(string.format("%3d) ", move))
          move = move + 1
        end
        if index == 1 and v.color == B then
          str:append(append("", 28))
        end
        if v.color == W then
          str:append(append(f1(v), 28))
        else
          str:append(f1(v))
          str:append("\n")
        end
      end
      prev = v
    end
    if color == W then
      str:append("\n")
    end
    str:append("\n")
  end
  return str:tostring()
end

function M:isPassed()
  return passed
end

return M
