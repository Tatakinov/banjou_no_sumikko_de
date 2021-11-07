local Process = require("process")
local SS      = require("sakura_script")

local AI        = 2
local INFINITE  = 2^30

local function isPassed(p, q)
  local index = 0
  for i = 1, #p do
    if p[i] > 0 then
      index = i
    end
  end
  local is_passed = true
  for i = #q - index + 1, 25 do
    if q[i] > 0 then
      is_passed = false
    end
  end
  return is_passed
end

local function remainPiece(p)
  local sum = 0
  for i, v in ipairs(p) do
    if p[i] > 0 then
      sum = sum + v
    end
  end
  return sum
end

local function evalContinuous(p)
  local continuous  = 0
  local sum = 0
  for i = 1, #p do
    if p[i] <= 1 then
      continuous  = 0
    else
      continuous  = continuous + 1
      if continuous then
        sum = sum + 5 + continuous
      end
    end
  end
  return sum
end

local function pipCount(p)
  local sum = 0
  for i, v in ipairs(p) do
    sum = sum + i * v
  end
  return sum
end

local function evalPoint(p, q)
  local point = {
    20, 20, 20, 20, 20, 19,
    18, 17, 16, 15, 14, 13,
    12, 11, 10,  9,  8,  7,
     6,  5,  4,  3,  2,  1,
     0,
  }
  if isPassed(p, q) then
    point = {
      200, 200, 200, 200, 200, 200,
      180, 170, 160, 150, 140, 130,
      120, 110, 100,  90,  80,  70,
       60,  50,  40,  30,  20,  10,
        0,
    }
  end
  local sum = 0
  for i, v in ipairs(p) do
    sum = sum + point[i] * v
  end
  return sum
end

local function evalBlock(p)
  local sum = 0
  for i, v in ipairs(p) do
    if v == 1 then
      sum = sum - 8 + math.floor(i / 3)
    elseif v == 2 then
      sum = sum + 10
    elseif v == 3 then
      sum = sum + 5
    elseif v == 4 then
      sum = sum + 0
    elseif v >= 5 then
      sum = sum - 7 * (v - 4)
    end
  end
  return sum
end

local function evalBlot(p, q)
  local eval_table  = {
    11, 12, 13, 14, 15, 17,
     6,  6,  5,  3,  2,  1,
  }
  local sum = 0
  for i = 1, 24 do
    if p[i] == 1 then
      for j = 1, 12 do
        local enemy = q[25 - i + j] or 0
        if enemy > 0 then
          -- pip数がそこまで増えない場所では気にしなくてもいいように。
          sum = sum - math.floor(eval_table[j] / math.sqrt(10 + i))
        end
      end
    end
  end
  return sum
end

local function evaluate(p, q)
  local sum = evalBlock(p)            - evalBlock(q)
  sum = sum + evalPoint(p, q)         - evalPoint(q, p)
  sum = sum + evalContinuous(p)       - evalContinuous(p)
  sum = sum + evalBlot(p, q)          - evalBlot(q, p)
  -- pipカウントは相手が多ければ○
  sum = sum - 5 * pipCount(p)             + 5 * pipCount(q)
  if isPassed(p, q) then
    -- 残りの駒数も相手が多い方が良い
    -- evalPointに対抗するため乗数は大きめ
    sum = sum - remainPiece(p) * 1000 + remainPiece(q) * 1000
  else
    -- 残りの駒数も相手が多い方が良い
    sum = sum - remainPiece(p) * 15   + remainPiece(q) * 15
  end
  -- passするべきかの判断用
  if isPassed(p, q) then
    if pipCount(p) <= pipCount(q) then
      sum = sum + 100
    else
      sum = sum - 100
    end
  end
  return sum
end

local function generateMoves(player, dice1, dice2, dice3, dice4)
  local moves_list  = {}
  if dice3 == nil then
    local moves = player:generateMoves(dice1, dice2)
    --print("generate1")
    -- TODO if #moves == 0
    if #moves == 0 then
      local tmp = dice1
      dice1 = dice2
      dice2 = tmp
      moves = player:generateMoves(dice1, dice2)
      if #moves == 0 then
        if dice1 < dice2 then
          local tmp = dice1
          dice1 = dice2
          dice2 = tmp
        end
        moves = player:generateMoves(dice1)
        if #moves > 0 then
          --move1 = moves[math.random(#moves)]
        else
          local tmp = dice1
          dice1 = dice2
          dice2 = tmp
          moves = player:generateMoves(dice1)
        end
      end
    end
    for _, move1 in ipairs(moves) do
      player:move(move1)
      local moves = player:generateMoves(dice2)
      player:unmove()
      for _, move2 in ipairs(moves) do
        table.insert(moves_list, {move1, move2})
      end
    end
    if #moves_list == 0 then
      if #moves > 0 then
        for _, move1 in ipairs(moves) do
          table.insert(moves_list, {move1, {dance = dice2}})
        end
      else
        return {{{dance = dice1}, {dance = dice2}}}
      end
    end
    return moves_list
  else
    local moves = player:generateMoves(dice1, dice2, dice3, dice4)
    if #moves > 0 then
      for _, move1 in ipairs(moves) do
        player:move(move1)
        local moves = player:generateMoves(dice1, dice2, dice3)
          for _, move2 in ipairs(moves) do
            player:move(move2)
            local moves = player:generateMoves(dice1, dice2)
              for _, move3 in ipairs(moves) do
                player:move(move3)
                local moves = player:generateMoves(dice1)
                  for _, move4 in ipairs(moves) do
                    table.insert(moves_list, {move1, move2, move3, move4})
                  end
                player:unmove()
              end
            player:unmove()
          end
        player:unmove()
      end
    else
      local moves = player:generateMoves(dice1, dice2, dice3)
      if #moves > 0 then
        for _, move1 in ipairs(moves) do
          player:move(move1)
          local moves = player:generateMoves(dice1, dice2)
            for _, move2 in ipairs(moves) do
              player:move(move2)
              local moves = player:generateMoves(dice1)
                for _, move3 in ipairs(moves) do
                  table.insert(moves_list, {move1, move2, move3, {dance = dice4}})
                end
              player:unmove()
            end
          player:unmove()
        end
      else
        local moves = player:generateMoves(dice1, dice2)
        if #moves > 0 then
          for _, move1 in ipairs(moves) do
            player:move(move1)
            local moves = player:generateMoves(dice1)
              for _, move2 in ipairs(moves) do
                table.insert(moves_list, {move1, move2, {dance = dice3}, {dance = dice4}})
              end
            player:unmove()
          end
        else
          local moves = player:generateMoves(dice1)
          if #moves > 0 then
            for _, move1 in ipairs(moves) do
              table.insert(moves_list, {move1, {dance = dice2}, {dance = dice3}, {dance = dice4}})
            end
          end
        end
      end
    end
    if #moves_list == 0 then
      return {{{dance = dice1}, {dance = dice2}, {dance = dice3}, {dance = dice4}}}
    end
    return moves_list
  end
  assert(false)
end

-- FIXME: 重い上にバグってる?
local function minimax(player, a, b, depth)
  if depth <= 0 then
    local p = player:getPosition()
    return evaluate(p[AI], p[3 - AI])
  else
    depth = depth - 1
  end
  local sum = 0
  for dice1 = 1, 6 do
    for dice2 = 1, 6 do
      local dice3, dice4
      if dice1 == dice2 then
        dice3 = dice1
        dice4 = dice1
      end
      if a == AI then
        -- 適当に小さい数字
        local eval_value  = -INFINITE
        local moves_list  = generateMoves(player, dice1, dice2, dice3, dice4)
        for _, moves in ipairs(moves_list) do
          for _, move in ipairs(moves) do
            player:move(move, nil)
          end
          player:confirm()
          local eval_tmp = minimax(player, b, a, depth)
          if eval_tmp > eval_value then
            eval_value  = eval_tmp
          end
          player:unconfirm()
          for _1, _2 in ipairs(moves) do
            player:unmove()
          end
        end
        sum = sum + eval_value
      else
        -- 適当に小さい数字
        local eval_value  = INFINITE
        local moves_list  = generateMoves(player, dice1, dice2, dice3, dice4)
        for _, moves in ipairs(moves_list) do
          for _, move in ipairs(moves) do
            player:move(move, nil)
          end
          player:confirm()
          local eval_tmp = minimax(player, b, a, depth)
          if eval_tmp < eval_value then
            eval_value  = eval_tmp
          end
          player:unconfirm()
          for _1, _2 in ipairs(moves) do
            player:unmove()
          end
        end
        sum = sum + eval_value
      end
    end
  end
  return sum
end

local function getBestMove2(player, a, dice1, dice2)
  -- 適当に小さい数字
  local eval_value  = -INFINITE
  --print("generate1")
  local moves = player:generateMoves(dice1, dice2)
  --print("generate1")
  -- TODO if #moves == 0
  if #moves == 0 then
    local tmp = dice1
    dice1 = dice2
    dice2 = tmp
    moves = player:generateMoves(dice1, dice2)
    if #moves == 0 then
      if dice1 < dice2 then
        local tmp = dice1
        dice1 = dice2
        dice2 = tmp
      end
      moves = player:generateMoves(dice1)
      if #moves > 0 then
        --move1 = moves[math.random(#moves)]
      else
        local tmp = dice1
        dice1 = dice2
        dice2 = tmp
        moves = player:generateMoves(dice1)
      end
    end
  end
  if #moves == 0 then
    return {
      dice  = {
        dice1, dice2,
      },
      move  = {
        "dance", "dance"
      },
      value = eval_value,
    }
  else
    local p = player:getPosition()
    local t = {}
    for _, v1 in ipairs(moves) do
      player:move(v1, dice1)
      local moves = player:generateMoves(dice2)
      if #moves > 0 then
        for _, v2 in ipairs(moves) do
          player:move(v2, dice2)
          if evaluate(p[a], p[3 - a]) > eval_value then
            eval_value  = evaluate(p[a], p[3 - a])
            t = {
              {v1, v2}
            }
          elseif evaluate(p[a], p[3 - a]) == eval_value then
            table.insert(t, {v1, v2})
          end
          player:unmove()
        end
      else
        if evaluate(p[a], p[3 - a]) > eval_value then
          eval_value  = evaluate(p[a], p[3 - a])
          t = {
            {v1, "dance"}
          }
        elseif evaluate(p[a], p[3 - a]) == eval_value then
          table.insert(t, {v1, "dance"})
        end
      end
      player:unmove()
    end
    local move = t[math.random(#t)]
    return {
      dice  = {
        dice1, dice2,
      },
      move  = move,
      value = eval_value,
    }
  end
end

local function getBestMove4(player, moves, dice, p)
  local t = {}
  local eval_value  = -INFINITE
  for _, v in ipairs(moves) do
    player:move(v, dice)
    if evaluate(p[2], p[1]) > eval_value then
      eval_value  = evaluate(p[2], p[1])
      t = {
        v
      }
    elseif evaluate(p[2], p[1]) == eval_value then
      table.insert(t, v)
    end
    player:unmove()
  end
  return t[math.random(#t)]
end

local function getBestMoves(player, a, moves_list)
  -- 適当に小さい数字
  local eval_value  = -INFINITE
  local p = player:getPosition()
  local t = {}
  for _, moves in ipairs(moves_list) do
    for _, move in ipairs(moves) do
      player:move(move, nil)
    end
    player:confirm()
    --local start = os.clock()
    local eval_tmp = evaluate(p[a], p[3 - a])
    --local eval_tmp = minimax(player, a, 3 - a, 1)
    --print("getBestMoves", os.clock() - start)
    if eval_tmp > eval_value then
      eval_value  = eval_tmp
      t = {moves}
    elseif eval_tmp == eval_value then
      table.insert(t, moves)
    end
    player:unconfirm()
    for i = 1, #moves do
      player:unmove()
    end
  end
  return t
end

return {
  {
    id  = "OnBackgammonAIThinkNormal",
    content = function(shiori, ref)
      local __      = shiori.var
      local player  = __("_BGPlayer")
      local dice    = __("_BG_Dice")
      -- Swap考慮
      local dice1   = dice[1]
      local dice2   = dice[2]
      local dice3   = dice[3]
      local dice4   = dice[4]
      local move1   = "dance"
      local move2   = "dance"
      -- debug
      local moves_list  = generateMoves(player, dice1, dice2, dice3, dice4)
      print("generateMoves", #moves_list)
      -- debug
      if #dice == 2 then
        -- debug
        local t = getBestMoves(player, AI, moves_list)
        print("getBestMoves", #t)
        t = t[math.random(#t)]
        -- debug
        --[[
        local moves1  = getBestMove2(player, AI, dice1, dice2)
        local moves2  = getBestMove2(player, AI, dice2, dice1)
        if moves1.value > moves2.value then
          return SS():raise("OnBackgammonAIResult", moves1.dice[1], moves1.move[1].from, moves1.dice[2], moves1.move[2].from)
        else
          return SS():raise("OnBackgammonAIResult", moves2.dice[1], moves2.move[1].from, moves2.dice[2], moves2.move[2].from)
        end
        --]]
        local dice1 = t[1].dance or t[1].from - t[1].to
        local move1 = t[1].from
        local dice2 = t[2].dance or t[2].from - t[2].to
        local move2 = t[2].from
        return SS():raise("OnBackgammonAIResult", dice1, move1, dice2, move2)
      elseif #dice == 4 then
        --[[
        --print("-- generate 1 --")
        local moves = player:generateMoves(dice1, dice2, dice3, dice4)
        --print("-- generate 1 --")
        local move1 = "dance"
        if #moves > 0 then
          move1 = getBestMove4(player, moves, dice1, __("_BGPlayer"):getPosition())
          print("bestmove1", move1)
        end
        player:move(move1, dice1)
        --print("-- generate 2 --")
        moves = player:generateMoves(dice2)
        --print("-- generate 2 --")
        local move2 = "dance"
        if #moves > 0 then
          move2 = getBestMove4(player, moves, dice2, __("_BGPlayer"):getPosition())
          print("bestmove2", move2)
        end
        player:move(move2, dice2)
        --]]

        --[[
        local moves1_2  = getBestMove2(player, AI, dice1, dice2)
        local move1 = moves1_2.move[1]
        local move2 = moves1_2.move[2]
        player:move(move1, dice1)
        player:move(move2, dice2)
        --]]

        --[[
        --print("-- generate 3 --")
        moves = player:generateMoves(dice3)
        --print("-- generate 3 --")
        local move3 = "dance"
        if #moves > 0 then
          move3 = getBestMove4(player, moves, dice3, __("_BGPlayer"):getPosition())
          print("bestmove3", move3)
        end
        player:move(move3, dice3)
        --print("-- generate 4 --")
        moves = player:generateMoves(dice4)
        --print("-- generate 4 --")
        local move4 = "dance"
        if #moves > 0 then
          move4 = getBestMove4(player, moves, dice4, __("_BGPlayer"):getPosition())
          print("bestmove4", move4)
        end
        --]]

        --[[
        local moves3_4  = getBestMove2(player, AI, dice3, dice4)
        local move3 = moves3_4.move[1]
        local move4 = moves3_4.move[2]
        -- ここでは指し手の生成だけ行い、実際の移動はserver側に行わせる。
        --player:unmove()
        player:unmove()
        player:unmove()
        --]]
        local t = getBestMoves(player, AI, moves_list)
        print("getBestMoves", #t)
        t = t[math.random(#t)]
        local dice1 = t[1].dance or t[1].from - t[1].to
        local move1 = t[1].from
        local dice2 = t[2].dance or t[2].from - t[2].to
        local move2 = t[2].from
        local dice3 = t[3].dance or t[3].from - t[3].to
        local move3 = t[3].from
        local dice4 = t[4].dance or t[4].from - t[4].to
        local move4 = t[4].from
        return SS():raise("OnBackgammonAIResult", dice1, move1, dice2, move2, dice3, move3, dice4, move4)
      end
    end,
  },
  {
    id  = "OnBackgammonAIThinkNative",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local p = player:getPosition()
      local dice    = __("_BG_Dice")
      local dice1   = dice[1]
      local dice2   = dice[2]
      local process = Process({
        command = __("_path") .. "talk\\game\\backgammon\\bgai.exe"
      })
      process:spawn("0/" .. table.concat(p[1], "/"), "0/" .. table.concat(p[2], "/"), "b", dice1, dice2)
      local str = process:readline(true)
      print("BGAI:", str)
      process:despawn()
      local from1, to1, from2, to2, from3, to3, from4, to4  = string.match(str, "(%d*)/(%d*),(%d*)/(%d*),(%d*)/(%d*),(%d*)/(%d*)")
      if from1 then
        --print(from1, to1, from2, to2, from3, to3, from4, to4)
        local dice1 = tonumber(from1) - tonumber(to1)
        local dice2 = tonumber(from2) - tonumber(to2)
        local dice3 = tonumber(from3) - tonumber(to3)
        local dice4 = tonumber(from4) - tonumber(to4)
        if dice1 == 0 then
          from1 = nil
        end
        if dice2 == 0 then
          from2 = nil
        end
        if dice3 == 0 then
          from3 = nil
        end
        if dice4 == 0 then
          from4 = nil
        end
        return SS():raise("OnBackgammonAIResult", dice1, from1, dice2, from2, dice3, from3, dice4, from4)
      else
        local from1, to1, from2, to2  = string.match(str, "(%d*)/(%d*),(%d*)/(%d*)")
        --print(from1, to1, from2, to2)
        local dice1 = tonumber(from1) - tonumber(to1)
        local dice2 = tonumber(from2) - tonumber(to2)
        if dice1 == 0 then
          from1 = nil
        end
        if dice2 == 0 then
          from2 = nil
        end
        return SS():raise("OnBackgammonAIResult", dice1, from1, dice2, from2)
      end
    end,
  }
}
