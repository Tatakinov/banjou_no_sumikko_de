local AI          = require("talk.texas_holdem._ai")
local Judgement   = require("talk.game._judgement")

local Const       = require("talk.texas_holdem._const")

return {
  {
    id  = "OnPoker",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[3] == "hello" then
        return string.format([=[\![raiseother,%s,%s,%s,%s]]=], ref[1], ref[2], Const.VERSION, Const.NAME)
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
          return string.format([=[\![raiseother,%s,%s,%s,%s,%s]]=], ref[1], ref[2], Const.VERSION, Const.NAME, action[1])
        else
          return string.format([=[\![raiseother,%s,%s,%s,%s,%s,%s]]=], ref[1], ref[2], Const.VERSION, Const.NAME, action[1], tostring(action[2]))
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
            style = {
              preflop = {
                raise = 0,
                limp  = 0,
                call  = 0,
                fold  = 0,
              },
              postflop  = {
                reraise = 0,
                call  = 0,
                fold  = 0,
              },
            },
            action  = {},
            stack     = 0,
          }
          i = i + 1
        end
        __("_PlayerInfo", t)
        if t[Const.NAME] then
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
        AI.updateAnalysis(player_info)
        for _, v in pairs(player_info) do
          table.insert(v.action, {
            preflop = {},
            postflop  = {},
          })
        end
        local i = 3
        local t = {}
        while ref[i] do
          local name, stack = string.match(ref[i], "(.+)" .. string.char(0x01) .. "(%d+)")
          table.insert(t, name)
          player_info[name].stack = stack
          if name == Const.NAME then
            __("_Stack", tonumber(stack))
            __("_Position", i - 2)
          end
          i = i + 1
        end
        __("_NPlayer", i - 3)
        __("_Playable", t)
        __("_BetInfo", {
          preflop = "none",
          flop  = "none",
          turn  = "none",
          river = "none",
        })
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
        if #t == 0 then
          __("_IsLimp", true)
        end
        __("_Action", {})
      elseif ref[1] == "opening_bet" then
        __("_Bet", tonumber(ref[2]))
      elseif ref[1] == "bet" then
        __("_TotalBet", tonumber(ref[2]))
        __("_CurrentBet", tonumber(ref[3]))
        local player  = ref[4]
        local action  = ref[5]
        local community = __("_Community")

        local bet_info  = __("_BetInfo")
        local a = __("_Action")
        if action == "raise" then
          __("_Action", {player})
          if #community == 0 then
            bet_info.preflop  = "raise"
          elseif #community == 3 then
            bet_info.flop  = "raise"
          elseif #community == 4 then
            bet_info.turn  = "raise"
          elseif #community == 5 then
            bet_info.river  = "raise"
          end
        elseif action == "check" or action == "call" then
          table.insert(a, player)
        end

        local player_info  = __("_PlayerInfo")
        local info  = player_info[player].action[#player_info[player].action]
        assert(info)
        if #community == 0 then
          -- blind betはノイズになるので排除
          if action ~= "bet" then
            if action == "raise" then
              __("_IsLimp", false)
            end
            if action == "call" and __("_IsLimp") then
              action  = "limp"
            end
            table.insert(info.preflop, action)
          end
        else
          table.insert(info.postflop, action)
        end
        --
        local playable  = __("_Playable")
        if action == "fold" then
          for i, v in ipairs(playable) do
            if v == player then
              table.remove(playable, i)
            end
          end
        end
      elseif ref[1] == "show_down" then
        local player_info = __("_PlayerInfo")
        local i = 2
        while ref[i] do
          local name, h1, h2  = string.match(ref[i], "(.+)\x01(.+)\x01(.+)")
          assert(name)
          local info  = player_info[name]
          info.action[#info.action].hand = {h1, h2}
          i = i + 1
        end
      end
    end,
  },
}
