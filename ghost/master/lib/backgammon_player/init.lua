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

function M:initialize()
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

function M:move(from, dice)
  local c   = self._current_color
  local r   = self:reverse(c)
  local p   = self._position
  -- dance
  if from == "dance" then
    table.insert(self._data.moves, {
      color   = c,
      dice    = dice,
    })
    return
  end
  local to  = from - dice
  if to <= 0 then
    p[c][from]  = p[c][from] - 1
    table.insert(self._data.moves, {
      color   = c,
      dice    = dice,
      from    = from,
      to      = 0,
      capture = false,
    })
  else
    assert(p[c][from] > 0)
    assert(p[r][25 - to] < 2)
    p[c][from]  = p[c][from] - 1
    p[c][to]    = p[c][to] + 1
    if p[r][25 - to] == 1 then
      p[r][25 - to] = 0
      p[r][25] = p[r][25] + 1
      table.insert(self._data.moves, {
        color   = c,
        dice    = dice,
        from    = from,
        to      = to,
        capture = true,
      })
    else
      table.insert(self._data.moves, {
        color   = c,
        dice    = dice,
        from    = from,
        to      = to,
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
        self:move(25, k)
        local t = self:generateMoves(l, m, n)
        self:unmove()
        if #t > 0 then
          table.insert(moves, 25)
        end
      else
        table.insert(moves, 25)
      end
    end
    return moves
  end
  for i, v in ipairs(p[c]) do
    if v > 0 then
      if p[c][i - k] and
        p[self:reverse(c)][24 - i + k + 1] <= 1 then
        if l then
          self:move(i, k)
          local t = self:generateMoves(l, m, n)
          self:unmove()
          if #t > 0 then
            table.insert(moves, i)
          end
        else
          table.insert(moves, i)
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
      table.insert(moves, k)
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
          table.insert(moves, i)
          break
        end
      end
    end
  end
  return moves
end

return M
