local BGPlayer      = require("backgammon_player")
local Judgement     = require("talk.game._judgement")
local Rand          = require("rand")
local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")

local function genRand(generator, n)
  local r = generator() / (2 ^ 32)
  return math.floor(r * n) + 1
end

local talk  = {
  {
    id  = "OnBackgammonGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      local game_option = __("BackgammonGameOption")
      local player = BGPlayer()
      player:initializeMatch(game_option.point)
      __("_BGPlayer", player)
      __("_BG_White", "player")
      __("_BG_WhiteScore", 0)
      __("_BG_Black", "小宮由希")
      __("_BG_BlackScore", 0)
      __("_Quiet", "Backgammon")
      __("_InGame", true)
      __("_Random", Rand(os.time()))
      __("_BG_Score", {})
      __("_CurrentJudgement", Judgement.equality)
      shiori:saori("backgammon")("init")
      shiori:talk("OnSetFanID")
      return [[
\0\s[座り_素]よろしくお願いします。
]] .. shiori:talk("OnBackgammonPeriodStart")
    end,
  },
  {
    id  = "OnBackgammonGameEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local winner  = tonumber(ref[0])
      local score_list  = __("成績(Backgammon)")
      local score = score_list["ふつう"]
      __("_InGame", false)
      __("_PostGame", true)
      -- 終局後の右クリック対策
      __("_BG_PlayerState", 1)
      if winner == 1 then
        score.win = score.win + 1
        return [[
\0\s[ヮ]${User}の勝ちだよ。
]]
      elseif winner == 2 then
        score.lose  = score.lose + 1
        return [[
\0\s[ドヤッ]わたしの勝ちだね！
]]
      end
    end,
  },
  {
    id  = "OnBackgammonPeriodStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_BGPlayer"):initializeGame(__("_Crawford"))
      return shiori:talk("OnBackgammonRender") .. [[
\![timerraise,1000,1,OnBackgammonFirstDiceRoll]
]]
    end,
  },
  {
    id  = "OnBackgammonPeriodEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local winner  = tonumber(ref[0])
      local w_score = __("_BG_WhiteScore")
      local b_score = __("_BG_BlackScore")
      local option  = __("BackgammonGameOption")
      local score   = __("_BG_Score")
      local win = player:gameOver() * player:getDoubleRate()
      if player:isPassed() then
        win = win / 2
      end
      local str = StringBuffer()
      player:confirmGameOver()
      if winner == 1 then
        w_score = w_score + win
        __("_BG_WhiteScore", w_score)
        if w_score == option.point - 1 then
          __("_Crawford", true)
        else
          __("_Crawford", false)
        end
        table.insert(score, {w = win, b = 0})
        str:append(string.format([=[
\0
\_q
\f[align,center]${User} 由希\n
]=]))
        local w = 0
        local b = 0
        for _, v in ipairs(score) do
          w = w + v.w
          b = b + v.b
          str:append(string.format([=[\f[align,center]%d - %d\n]=], w, b))
        end
        str:append(string.format([[\_q\n]]))
        str:append([=[\0\s[座り_むぅ]むぅ…残念。\n\n]=])
      else
        b_score = b_score + win
        __("_BG_BlackScore", b_score)
        if b_score == option.point - 1 then
          __("_Crawford", true)
        else
          __("_Crawford", false)
        end
        table.insert(score, {w = 0, b = win})
        str:append(string.format([=[
\0
\_q
\f[align,center]${User} 由希\n
]=]))
        local w = 0
        local b = 0
        for _, v in ipairs(score) do
          w = w + v.w
          b = b + v.b
          str:append(string.format([=[\f[align,center]%d - %d\n]=], w, b))
        end
        str:append(string.format([[\_q\n]]))
        str:append([=[\0\s[座り_ドヤッ]やったね！@\n\n]=])
      end
      if w_score >= option.point then
        str:append(SS():timerraise({
          time  = 1000,
          loop  = false,
          ID  = "OnBackgammonGameEnd",
          1,
        }))
      elseif b_score >= option.point then
        str:append(SS():timerraise({
          time  = 1000,
          loop  = false,
          ID  = "OnBackgammonGameEnd",
          2,
        }))
      else
        str:append([[\s[座り_素]それじゃあ次の対局に行くよ。]])
        str:append(SS():timerraise({
          time  = 1000,
          loop  = false,
          ID  = "OnBackgammonPeriodStart"
        }))
      end
      return str
    end,
  },
  {
    id  = "OnBackgammonFirstDiceRoll",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local w_dice  = 0
      local b_dice  = 0
      repeat
        w_dice  = genRand(__("_Random"), 6)
        b_dice  = genRand(__("_Random"), 6)
      until w_dice ~= b_dice
      --print("w", w_dice)
      --print("b", b_dice)
      __("_BG_Dice1", {
        color = "W",
        value = w_dice,
      })
      __("_BG_Dice2", {
        color = "B",
        value = b_dice,
      })
      __("_BG_Dice", {
        w_dice, b_dice, -- ゾロ目にはならないので2つで確定
      })
      if w_dice > b_dice then
        __("_BGPlayer"):initColor(1)
        __("_BG_PlayerState", 1)
        str:append(SS():raise("OnBackgammonPlayer"))
      else
        __("_BGPlayer"):initColor(2)
        str:append(SS():timerraise({
          time  = 1000,
          loop  = false,
          ID  = "OnBackgammonAI"
        }))
      end
      return shiori:talk("OnBackgammonRender") .. str:tostring()
    end,
  },
  {
    id  = "OnBackgammonDiceRoll",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local color_str = {"W", "B"}
      local dice1 = 0
      local dice2 = 0
      local player  = __("_BGPlayer")
      dice1 = genRand(__("_Random"), 6)
      dice2 = genRand(__("_Random"), 6)
      local p = player:getPosition()
      for _, i in ipairs({1, 2}) do
        local win = true
        for _, v in ipairs(p[i]) do
          if v > 0 then
            win = false
            break
          end
        end
        if win then
          return SS():raise("OnBackgammonPeriodEnd", i)
        end
      end
      --print("1", dice1)
      --print("2", dice2)
      __("_BG_Dice1", {
        color = color_str[player:getColor()],
        value = dice1,
      })
      __("_BG_Dice2", {
        color = color_str[player:getColor()],
        value = dice2,
      })
      if dice1 == dice2 then
        __("_BG_Dice", {
          dice1, dice1, dice1, dice1,
        })
      else
        __("_BG_Dice", {
          dice1, dice2,
        })
      end
      if player:getColor() == 1 then
        __("_BG_FixDice", false)
        local d1, d2 = dice1, dice2
        if d1 ~= d2 then
          if d1 < d2 then
            d1, d2 = d2, d1
          end
          local moves1 = player:generateMoves(d1)
          local moves2 = player:generateMoves(d2)
          if #moves1 == 0 or #moves2 == 0 then
            if #moves1 > 0 then
              __("_BG_FixDice", true)
              __("_BG_Dice1", {
                color = color_str[player:getColor()],
                value = d1,
              })
              __("_BG_Dice2", {
                color = color_str[player:getColor()],
                value = d2,
              })
              __("_BG_Dice", {
                d1, d2,
              })
            else
              __("_BG_FixDice", true)
              __("_BG_Dice1", {
                color = color_str[player:getColor()],
                value = d2,
              })
              __("_BG_Dice2", {
                color = color_str[player:getColor()],
                value = d1,
              })
              __("_BG_Dice", {
                d2, d1,
              })
            end
          end
        end
        __("_BG_PlayerState", 1)
        str:append(shiori:talk("OnBackgammonRender", "true"))
        str:append(SS():raise("OnBackgammonPlayer"))
      elseif player:getColor() == 2 then
        str:append(shiori:talk("OnBackgammonRender", "false", "false"))
        str:append(SS():timerraise({
          time  = 1000,
          loop  = false,
          ID  = "OnBackgammonAI",
        }))
      end
      return str
    end,
  },
  {
    id  = "OnBackgammonPlayer",
    content = function(shiori, ref)
      --[==[
      if true then
        return [=[\![raise,OnBackgammonAI]]=]
      end
      --]==]
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local state = __("_BG_PlayerState")
      local dice  = __("_BG_Dice")
      local moves = {}
      if state <= #dice then
        moves = player:generateMoves(dice[state], dice[state + 1])
        if #moves == 0 then
          moves = player:generateMoves(dice[state])
        end
      end
      --print("generate", #moves)
      __("_BG_Movable", moves)
      return shiori:talk("OnBackgammonRender", "true")
    end,
  },
  {
    id  = "OnBackgammonPlayerTakeOrPass",
    content = function(shiori, ref)
      return [[
\0\_q
\q[テイク,OnBackgammonPlayerTake]\n
\q[パス,OnBackgammonPlayerPass]\n
\_q
]]
    end,
  },
  {
    id  = "OnBackgammonPlayerTake",
    content = function(shiori, ref)
      local __        = shiori.var
      local player    = __("_BGPlayer")
      player:take()
      return [=[\![raise,OnBackgammonDiceRoll]]=]
    end,
  },
  {
    id  = "OnBackgammonPlayerPass",
    content = function(shiori, ref)
      local __        = shiori.var
      local player    = __("_BGPlayer")
      player:pass()
      return [=[\![raise,OnBackgammonPeriodEnd,2]]=]
    end,
  },
  {
    id  = "OnBackgammonAI",
    content = function(shiori, ref)
      local __        = shiori.var
      local dice      = __("_BG_Dice")
      local player    = __("_BGPlayer")
      local position  = player:getPosition()
      return SS():raise("OnBackgammonAIThink", table.concat(position[1], "/"), table.concat(position[2], "/"), player:getColor(), table.concat(dice, "/"))
    end,
  },
  {
    id  = "OnBackgammonAIResult",
    content = function(shiori, ref)
      local dice1   = tonumber(ref[0])
      local point1  = tonumber(ref[1])
      local __      = shiori.var
      local player  = __("_BGPlayer")
      if dice1 and dice1 > 0 and point1 and point1 > 0 then
        player:move({from = point1, to = point1 - dice1}, dice1)
        local r = __("_BG_Result")
        if not(r) then
          __("_BG_Result", {})
          r = __("_BG_Result")
        end
        table.insert(r, point1)
        table.insert(r, dice1)
        return SS():raise("OnBackgammonRender", false, false)
                  :timerraise({
                    time  = 1000,
                    loop  = false,
                    ID    = "OnBackgammonAIResult",
                    ref[2], ref[3], ref[4], ref[5], ref[6], ref[7],
                  })
      elseif dice1 then
        player:move({dance = dice1}, dice1)
        return SS():raise("OnBackgammonRender", false, false)
                  :timerraise({
                    time  = 100,
                    loop  = false,
                    ID    = "OnBackgammonAIResult",
                    ref[2], ref[3], ref[4], ref[5], ref[6], ref[7],
                  })
      else
        local r = __("_BG_Result") or {}
        local bg  = shiori:saori("backgammon")
        bg("move", r[1] or 0, r[2] or 0, r[3] or 0, r[4] or 0, r[5] or 0, r[6] or 0, r[7] or 0, r[8] or 0)
        __("_BG_Result", nil)
        player:confirm()
        if player:canDouble() then
          __("_BG_PlayerState", "double?")
          return SS():raise("OnBackgammonRender", "true", "false")
        else
          __("_BG_Dice1", nil)
          __("_BG_Dice2", nil)
          return SS():raise("OnBackgammonRender", "false", "false")
                    :timerraise({
                      time  = 1000,
                      loop  = false,
                      ID    = "OnBackgammonDiceRoll",
                    })
        end
      end
    end,
  },
  {
    id  = "3Right",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local state   = __("_BG_PlayerState")
      if type(state) ~= "number" then
        return nil
      end
      if player:getColor() == 1 and state > 1 then
        __("_BG_PlayerState", state - 1)
        player:unmove()
        local r = __("_BG_Result")
        table.remove(r)
        table.remove(r)
        return SS():raise("OnBackgammonPlayer")
      end
    end,
  },
  {
    id  = "3DICE1Right",
    content = function(shiori, ref)
      local __  = shiori.var
      local state = __("_BG_PlayerState")
      local player  = __("_BGPlayer")
      if state == "double?" and player:canDouble() then
        player:double()
        __("_BG_PlayerState", 1)
        return [=[\![raise,OnBackgammonAITakeOrPass]]=]
      end
    end,
  },
  {
    id  = "3DICE2Right",
    content = function(shiori, ref)
      local __  = shiori.var
      local state = __("_BG_PlayerState")
      local player  = __("_BGPlayer")
      if state == "double?" and player:canDouble() then
        __("_BG_PlayerState", 1)
        player:double()
        return [=[\![raise,OnBackgammonAITakeOrPass]]=]
      end
    end,
  },
  {
    id  = "3DICE1Left",
    content = function(shiori, ref)
      local __    = shiori.var
      local player  = __("_BGPlayer")
      local state = __("_BG_PlayerState")
      local dice  = __("_BG_Dice")
      local movable = __("_BG_Movable")
      print("CLICK", "DICE", 1)
      if type(state) == "string" and state == "double?" then
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonDiceRoll]]=]
      end
      if state > #dice or #movable == 0 then
        for i = state, #dice do
          player:move({dance = true}, dice[state])
        end
        local r = __("_BG_Result") or {}
        shiori:saori("backgammon")("move", r[1] or 0, r[2] or 0, r[3] or 0, r[4] or 0, r[5] or 0, r[6] or 0, r[7] or 0, r[8] or 0)
        __("_BG_Result", nil)
        player:confirm()
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        if player:canDouble() then
          return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonAIDouble?]]=]
        else
          return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonDiceRoll]]=]
        end
      end
      if state == 1 and not(__("_BG_FixDice")) then
        -- Swap
        local tmp = dice[1]
        dice[1] = dice[2]
        dice[2] = tmp
        -- Swap
        local dice1 = __("_BG_Dice1")
        local dice2 = __("_BG_Dice2")
        __("_BG_Dice1", dice2)
        __("_BG_Dice2", dice1)
        return SS():raise("OnBackgammonPlayer")
      end
    end,
  },
  {
    id  = "3DICE2Left",
    content = function(shiori, ref)
      local __    = shiori.var
      local player  = __("_BGPlayer")
      local state   = __("_BG_PlayerState")
      local dice    = __("_BG_Dice")
      local movable = __("_BG_Movable")
      if type(state) == "string" and state == "double?" then
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonDiceRoll]]=]
      end
      if state > #dice or #movable == 0 then
        for i = state, #dice do
          player:move({dance = true}, dice[state])
        end
        local r = __("_BG_Result") or {}
        shiori:saori("backgammon")("move", r[1] or 0, r[2] or 0, r[3] or 0, r[4] or 0, r[5] or 0, r[6] or 0, r[7] or 0, r[8] or 0)
        __("_BG_Result", nil)
        player:confirm()
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        if player:canDouble() then
          return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonAIDouble?]]=]
        else
          return shiori:talk("OnBackgammonRender", "false", "false") .. [=[\![timerraise,1000,1,OnBackgammonDiceRoll]]=]
        end
      end
    end,
  },
}

for i = 1, 25 do
  table.insert(talk, {
    id  = "3" .. "POINT" .. i .. "Left",
    content = function(shiori, ref)
      local __      = shiori.var
      local state   = __("_BG_PlayerState")
      local dice    = __("_BG_Dice")
      local player  = __("_BGPlayer")
      local from    = i
      player:move({from = from, to = from - dice[state]}, dice[state])
      local r = __("_BG_Result")
      if not(r) then
        __("_BG_Result", {})
        r = __("_BG_Result")
      end
      table.insert(r, from)
      table.insert(r, dice[state])
      __("_BG_PlayerState", state + 1)
      --print("CLICK", i)
      return SS():raise("OnBackgammonPlayer")
    end,
  })
end

return talk
