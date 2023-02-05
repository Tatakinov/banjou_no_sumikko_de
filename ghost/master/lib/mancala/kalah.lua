local M = {}

local function isEmpty(t)
  local sum = 0
  for _, v in ipairs(t) do
    sum = sum + v
  end
  return sum == 0
end

function M.init(mancala)
  for i = 1, 2 do
    mancala:resetStore(i)
    for j = 1, 6 do
      mancala:set(i, j, 4)
    end
  end
end

function M.lap(mancala, index)
  local ret = true
  local player  = mancala:teban()
  local num = mancala:get(player, index)
  mancala:set(player, index, 0)
  local i = index + 1
  while num > 0 do
    while num > 0 and i <= 6 do
      mancala:add(player, i)
      i = i + 1
      num = num - 1
    end
    if num > 0 and player == mancala:teban() then
      mancala:addStore(player)
      num = num - 1
      if num == 0 then
        -- もう1回自分のターン
        ret = false
        goto do_last_process
      end
    end
    if num > 0 then
      player  = mancala:reverse(player)
      i = 1
    end
  end

  -- 特殊な石取り
  do
    i = i - 1
    local n1  = mancala:get(player, i)
    local n2  = mancala:get(mancala:reverse(player), 7 - i)
    if player == mancala:teban() and n1 == 1 and n2 > 0 then
      mancala:set(player, i, 0)
      mancala:set(mancala:reverse(player), 7 - i, 0)
      mancala:addStore(player, n1 + n2)
    end
  end

  ::do_last_process::

  local sum = 0
  for i = 1, 6 do
    sum = sum + mancala:get(1, i)
  end
  if sum == 0 then
    for i = 1, 6 do
      sum = sum + mancala:get(2, i)
      mancala:set(2, i, 0)
    end
    mancala:addStore(2, sum)
  end
  sum = 0
  for i = 1, 6 do
    sum = sum + mancala:get(2, i)
  end
  if sum == 0 then
    for i = 1, 6 do
      sum = sum + mancala:get(1, i)
      mancala:set(1, i, 0)
    end
    mancala:addStore(1, sum)
  end
  return ret
end

return M
