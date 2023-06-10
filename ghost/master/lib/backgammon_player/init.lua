local Class = require("class")

local W = 1
local B = 2

local M = Class()
M.__index = M

M.colors  = {W, B}

function M:_init()
  self._current_color = W
  self._position  = {
    {
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0,
    },
    {
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0,
      0,
    },
  }
  self._data  = {
    init_color  = W,
    moves       = {},
  }
end

function M:initialize(crawford)
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
  self._crawford  = not(not(crawford))
end

function M:initColor(color)
  self._data.init_color = color
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
    table.insert(self._data.moves, {
      color   = c,
      dice    = move.dance,
    })
    return
  end
  local dice  = dice or move.from - move.to
  if move.to <= 0 then
    p[c][move.from]  = p[c][move.from] - 1
    p[c][0] = p[c][0] + 1
    table.insert(self._data.moves, {
      color   = c,
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
      table.insert(self._data.moves, {
        color   = c,
        dice    = dice,
        from    = move.from,
        to      = move.to,
        capture = true,
      })
    else
      table.insert(self._data.moves, {
        color   = c,
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
  local move  = table.remove(self._data.moves, #self._data.moves)
  local c     = move.color
  local r     = self:reverse(c)
  assert(c == self._current_color)
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

function M:confirm()
  self._current_color = self:reverse(self._current_color)
end

function M:unconfirm()
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
  return true
end

function M:double()
  if self:canDouble() then
    print("double!")
    self._double_color  = self:reverse(self._current_color)
    self._current_rate  = self._current_rate * 2
    return true
  else
    print("dont double")
  end
  return false
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

return M
