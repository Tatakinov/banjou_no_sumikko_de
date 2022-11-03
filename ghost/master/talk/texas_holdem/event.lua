local AI          = require("talk.texas_holdem._ai")
local Judgement   = require("talk.game._judgement")

local VERSION = "POKER/1.0"
local NAME    = "盤上の隅っこで"

return {
  {
    id  = "OnPoker",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[3] == "hello" then
        return string.format([=[\![raiseother,%s,%s,%s,%s]]=], ref[1], ref[2], VERSION, NAME)
      elseif ref[3] == "action" then
        local community = __("_Community")
        local action  = {}
        local index = 4
        while ref[index] do
          table.insert(action, ref[index])
          index = index + 1
        end
        if #community == 0 then
          action  = AI.preFlop(shiori, action)
        elseif #community == 3 then
          action  = AI.flop(shiori, action)
        elseif #community == 4 then
          action  = AI.turn(shiori, action)
        elseif #community == 5 then
          action  = AI.river(shiori, action)
        end

        if #action == 1 then
          return string.format([=[\![raiseother,%s,%s,%s,%s,%s]]=], ref[1], ref[2], VERSION, NAME, action[1])
        else
          return string.format([=[\![raiseother,%s,%s,%s,%s,%s,%s]]=], ref[1], ref[2], VERSION, NAME, action[1], tostring(action[2]))
        end
      end
    end,
  },
  {
    id  = "OnPokerNotify",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[1] == "game_start" then
        local i = 2
        local t = {}
        while ref[i] do
          t[ref[i]] = {
            action    = {},
            preflop_action  = {},
            postflop_action  = {},
            stack     = 0,
          }
          i = i + 1
        end
        __("_PlayerInfo", t)
        if t[NAME] then
          AI.initialize(shiori)
          __("_Quiet", "TexasHoldem")
          __("_InGame", true)
          __("_CurrentJudgement", Judgement.equality)
          shiori:talk("OnSetFanID")
        end
      elseif ref[1] == "round_start" then
        __("_Blind", tonumber(ref[2]))
        __("_Bet", 0)
        local player_info = __("_PlayerInfo")
        local i = 3
        local t = {}
        while ref[i] do
          local name, stack = string.match(ref[i], "(.+)" .. string.char(0x01) .. "(%d+)")
          table.insert(t, name)
          player_info[name].stack = stack
          if name == NAME then
            __("_Stack", tonumber(stack))
          end
          i = i + 1
        end
        __("_Playable", t)
      elseif ref[1] == "hand" then
        __("_Hand", {ref[2], ref[3]})
        print(ref[2], ref[3])
      elseif ref[1] == "flip" then
        __("_Pot", tonumber(ref[2]))
        __("_CurrentBet", 0)
        local i = 3
        local t = {}
        while ref[i] do
          table.insert(t, ref[i])
          i = i + 1
        end
        __("_Community", t)
      elseif ref[1] == "opening_bet" then
        __("_Bet", tonumber(ref[2]))
      elseif ref[1] == "bet" then
        __("_TotalBet", tonumber(ref[2]))
        __("_CurrentBet", tonumber(ref[3]))
        local player  = ref[4]
        local action  = ref[5]
        local community = __("_Community")
        local player_info  = __("_PlayerInfo")
        local info  = player_info[player]
        assert(info)
        if #community == 0 then
          -- blind betはノイズになるので排除
          if action ~= "bet" then
            table.insert(info.preflop_action, action)
          end
        else
          table.insert(info.postflop_action, action)
        end
        --
        local playable  = __("_Playable")
        if action == "fold" then
          for i, v in ipairs(playable) do
            if player == v then
              table.remove(playable, i)
              break
            end
          end
        end
      end
    end,
  },
}
