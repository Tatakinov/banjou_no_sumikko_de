local SS      = require("sakura_script")

local AI        = 2
local INFINITE  = 2^30

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
      local d1      = dice[1]
      local d2      = dice[2]
      local bg      = shiori:saori("backgammon")
      print(player:dump())
      bg("position", player:dump())
      print("search")
      local result  = bg("search", d1, d2)
      local t = {}
      for n in string.gmatch(result(), "[^/]+") do
        table.insert(t, tonumber(n))
      end
      print("win-rate:", t[1], t[2], t[3], t[4], t[5])
      print(result[0])
      print(result[1])
      print(result[2])
      print(result[3])
      local from1, dice1 = string.match(result[0] or "", "(%d*),(%d*)")
      local from2, dice2 = string.match(result[1] or "", "(%d*),(%d*)")
      local from3, dice3 = string.match(result[2] or "", "(%d*),(%d*)")
      local from4, dice4 = string.match(result[3] or "", "(%d*),(%d*)")
      if dice1 == dice2 then
        for i = 0, 3 do
          if not(result[i]) then
            player:move({dance = true}, d1)
          end
        end
      else
        if not(result[0]) then
          player:move({dance = true}, d1)
          player:move({dance = true}, d2)
        elseif not(result[1]) then
          local d = tonumber(dice1)
          if d == d1 then
            player:move({dance = true}, d2)
          else
            player:move({dance = true}, d1)
          end
        end
      end
      return SS():raise("OnBackgammonAIResult", dice1, from1, dice2, from2, dice3, from3, dice4, from4)
    end,
  },
  {
    id  = "OnBackgammonAITakeOrPass",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local bg  = shiori:saori("backgammon")
      local option  = __("BackgammonGameOption")
      local w_score = __("_BG_WhiteScore")
      bg("position", player:dump())
      print("TakeOrPass")
      local result  = bg("evaluate")()
      local t = {}
      for n in string.gmatch(result, "[^/]+") do
        table.insert(t, tonumber(n))
      end
      print("win-rate:", t[1], t[2], t[3], t[4], t[5])
      local rate  = (t[1] - t[2]) * 1 + (t[2] - t[3]) * 2 + t[3] * 3
                  - (1 - t[1] - t[4]) * 1 - (t[4] - t[5]) * 2 - t[5] * 3
      print("rate:", rate)
      if w_score + player:getDoubleRate() >= option.point or
          2 * rate > -1 then
        player:take()
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        return [[\0テイクするよ。]] ..
          SS():raise("OnBackgammonRender", "false", "false")
                :timerraise({
                  time  = 1000,
                  loop  = false,
                  ID    = "OnBackgammonDiceRoll",
                }):tostring()
      end
      player:pass()
      return [=[\0パスするよ。\![raise,OnBackgammonPeriodEnd,1]]=]
    end,
  },
  {
    id  = "OnBackgammonAIDouble?",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local bg  = shiori:saori("backgammon")
      local w_score = __("_BG_WhiteScore")
      local b_score = __("_BG_BlackScore")
      local option  = __("BackgammonGameOption")
      bg("position", player:dump())
      print("Double?")
      print(player:dump())
      local result  = bg("evaluate")()
      print("result", result)
      local t = {}
      for n in string.gmatch(result, "[^/]+") do
        table.insert(t, tonumber(n))
      end
      print("win-rate:", t[1], t[2], t[3], t[4], t[5])
      local rate  = (t[1] - t[2]) * 1 + (t[2] - t[3]) * 2 + t[3] * 3
                  - (1 - t[1] - t[4]) * 1 - (t[4] - t[5]) * 2 - t[5] * 3
      print("rate:", rate)
      if player:canDouble() then
        if (w_score + player:getDoubleRate() >= option.point and
            b_score + player:getDoubleRate() < option.point) or
            (2 * rate > 1 and t[4] < 0.3) then
          player:double()
          return [[\0ダブルするよ。]] ..
            shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![raise,OnBackgammonPlayerTakeOrPass]]=]
        end
      end
      return [=[\![raise,OnBackgammonDiceRoll]]=]
    end,
  },
}
