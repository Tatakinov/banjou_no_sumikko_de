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
      __("_BGPlayer", BGPlayer())
      __("_BG_PointMatch", 1)
      __("_BG_White", "player")
      __("_BG_WhiteScore", 0)
      __("_BG_Black", "小宮由希")
      __("_BG_BlackScore", 0)
      __("_Quiet", "Backgammon")
      __("_InGame", true)
      __("_Random", Rand(os.time()))
      __("_CurrentJudgement", Judgement.equality)
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
      __("_Quiet", false)
      __("_InGame", false)
      -- 終局後の右クリック対策
      __("_BG_PlayerState", 1)
      if winner == 1 then
        return [[
\0\s[ヮ]${User}の勝ちだよ。
]]
      elseif winner == 2 then
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
      __("_BGPlayer"):initialize()
      return shiori:talk("OnBackgammonRender") .. [[
\![timerraise,1000,1,OnBackgammonFirstDiceRoll]
]]
    end,
  },
  {
    id  = "OnBackgammonPeriodEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local winner  = tonumber(ref[0])
      local w_score = __("_BG_WhiteScore")
      local b_score = __("_BG_BlackScore")
      __("_BGPlayer"):initialize()
      if winner == 1 then
        w_score = w_score + 1
        __("_BG_WhiteScore", w_score)
        if w_score >= __("_BG_PointMatch") then
          return SS():raise("OnBackgammonGameEnd", 1)
        end
      else
        b_score = b_score + 1
        __("_BG_BlackScore", b_score)
        if b_score >= __("_BG_PointMatch") then
          return SS():raise("OnBackgammonGameEnd", 2)
        end
      end
      return shiori:talk("OnBackgammon_PeriodStart")
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
      print("w", w_dice)
      print("b", b_dice)
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
      print("1", dice1)
      print("2", dice2)
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
        __("_BG_PlayerState", 1)
        str:append(shiori:talk("OnBackgammonRender", "true", "true"))
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
      local __  = shiori.var
      local state = __("_BG_PlayerState")
      local dice  = __("_BG_Dice")
      if #dice >= state then
        local moves = __("_BGPlayer"):generateMoves(dice[state])
        --print("generate", #moves)
        __("_BG_Movable", moves)
      end
      if state == 1 then
        return shiori:talk("OnBackgammonRender", "true", "true")
      elseif #dice >= state then
        return shiori:talk("OnBackgammonRender", "true", "true")
      else
        return shiori:talk("OnBackgammonRender", "true", "false")
      end
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
      if dice1 and point1 then
        player:move(point1, dice1)
        return SS():raise("OnBackgammonRender", false, false)
                  :timerraise({
                    time  = 1000,
                    loop  = false,
                    ID    = "OnBackgammonAIResult",
                    ref[2], ref[3], ref[4], ref[5], ref[6], ref[7],
                  })
      else
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        player:confirm()
        return SS():raise("OnBackgammonRender", false, false)
                  :timerraise({
                    time  = 1000,
                    loop  = false,
                    ID    = "OnBackgammonDiceRoll",
                  })
      end
    end,
  },
  {
    id  = "3Right",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local state   = __("_BG_PlayerState")
      if player:getColor() == 1 and state > 1 then
        player:unmove()
        __("_BG_PlayerState", state - 1)
        return SS():raise("OnBackgammonPlayer")
      end
    end,
  },
  {
    id  = "3DICE1Left",
    content = function(shiori, ref)
      local __    = shiori.var
      local state = __("_BG_PlayerState")
      local dice  = __("_BG_Dice")
      print("CLICK", "DICE", 1)
      if state == 1 then
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
      elseif state > #dice then
        local player  = __("_BGPlayer"):confirm()
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        return shiori:talk("OnBackgammonRender", "false", "false") .. [[
\![timerraise,1000,1,OnBackgammonDiceRoll]
]]
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
      if #movable == 0 and state <= #dice then
        print("CLICK", "DANCE")
        player:move("dance", dice[state])
        __("_BG_PlayerState", state + 1)
        return SS():raise("OnBackgammonPlayer")
      end
      if state > #dice then
        local player  = __("_BGPlayer"):confirm()
        __("_BG_Dice1", nil)
        __("_BG_Dice2", nil)
        return shiori:talk("OnBackgammonRender", "false", "false") .. [[
\![timerraise,1000,1,OnBackgammonDiceRoll]
]]
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
      player:move(from, dice[state])
      __("_BG_PlayerState", state + 1)
      --print("CLICK", i)
      return SS():raise("OnBackgammonPlayer")
    end,
  })
end

return talk
