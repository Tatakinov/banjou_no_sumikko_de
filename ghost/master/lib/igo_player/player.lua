local Class = require("class")

local M = Class()
M.__index = M

local BLACK = 1
local WHITE = 2

local function reverse(color)
  return 3 - color
end

local function generateMap(n, init)
  local map = {}
  for y = 1, n do
    map[y]  = {}
    for x = 1, n do
      map[y][x] = init
    end
  end
  return map
end

function M:_init()
  self._komi  = 7
  self._teban = BLACK
  self._agehama = {0, 0}
  self._prev_agehama  = {}
  self._pass  = 0
  self:setBoardSize(9)
end

function M:setBoardSize(n)
  self._board_size  = n
  self._board = generateMap(n, 0)
end

function M:getBoardSize()
  return self._board_size
end

function M:getTeban()
  return self._teban
end

function M:get(x, y)
  if x < 1 or x > self._board_size or y < 1 or y > self._board_size then
    return nil
  end
  return self._board[y][x]
end

function M:isGameOver()
  return self._pass >= 2
end

function M:nextTurn()
  self._teban = reverse(self._teban)
end

function M:pass()
  self._pass  = self._pass + 1
  self:nextTurn()
end


function M:put(x, y)
  if not(self:_put(x, y, true)) then
    return false
  end
  self._pass  = 0
  self:nextTurn()
  return true
end

function M:canPut(x, y)
  return self:_put(x, y, false)
end

function M:_put(x, y, force)
  if x < 1 or x > self._board_size or y < 1 or y > self._board_size then
    return false
  end
  if self._board[y][x] ~= 0 then
    return false
  end

  if #self._prev_agehama == 1 and
      self._prev_agehama[1].x == x and self._prev_agehama[1].y == y then
    assert(not(force))
    return false
  end

  if force then
    self._prev_agehama  = {}
  end

  -- 仮置き
  self._board[y][x] = self:getTeban()

  for _, v in ipairs({
    {dx = 0, dy = 1},
    {dx = 0, dy = -1},
    {dx = 1, dy = 0},
    {dx = -1, dy = 0},
  })
  do
    local queue = {}
    local visited = generateMap(self._board_size, false)
    local capture = nil
    table.insert(queue, {x = x + v.dx, y = y + v.dy})
    while #queue > 0 do
      local e = table.remove(queue, 1)
      if e.x < 1 or e.x > self._board_size or
          e.y < 1 or e.y > self._board_size then
        -- nop
      elseif not(visited[e.y][e.x]) then
        local c = self:get(e.x, e.y)
        if c == 0 then
          capture = false
          break
        end
        if c == reverse(self:getTeban()) then
          capture = true
          visited[e.y][e.x] = true
          for _, v in ipairs({
            {dx = 0, dy = 1},
            {dx = 0, dy = -1},
            {dx = 1, dy = 0},
            {dx = -1, dy = 0},
          })
          do
            table.insert(queue, {x = e.x + v.dx, y = e.y + v.dy})
          end
        end
      end
    end
    if capture then
      if force then
        for y = 1, self._board_size do
          for x = 1, self._board_size do
            if visited[y][x] then
              table.insert(self._prev_agehama, {x = x, y = y})
              self._board[y][x] = 0
            end
          end
        end
      else
        if not(force) then
          self._board[y][x] = 0
        end
        return true
      end
    end
  end
  local queue = {}
  local visited = generateMap(self._board_size, false)
  local capture = true
  table.insert(queue, {x = x, y = y})
  while #queue > 0 do
    local e = table.remove(queue, 1)
    if e.x < 1 or e.x > self._board_size or
        e.y < 1 or e.y > self._board_size then
      -- nop
    elseif not(visited[e.y][e.x]) then
      local c = self:get(e.x, e.y)
      if c == 0 then
        capture = false
        break
      end
      if c == self:getTeban() then
        visited[e.y][e.x] = true
        for _, v in ipairs({
          {dx = 0, dy = 1},
          {dx = 0, dy = -1},
          {dx = 1, dy = 0},
          {dx = -1, dy = 0},
        })
        do
          table.insert(queue, {x = e.x + v.dx, y = e.y + v.dy})
        end
      end
    end
  end
  if capture then
    assert(not(force))
    self._board[y][x] = 0
    return false
  elseif not(force) then
    self._board[y][x] = 0
  end
  return true
end

function M:generateMoves()
  local list  = {}
  for y = 1, self._board_size do
    for x = 1, self._board_size do
      if self:canPut(x, y) then
        table.insert(list, {x = x, y = y})
      end
    end
  end
  return list
end

function M:dump()
  for y = 1, self._board_size do
    local s = ""
    for x = 1, self._board_size do
      s = s .. tostring(self:get(x, y))
    end
    print(s)
  end
end

return M
