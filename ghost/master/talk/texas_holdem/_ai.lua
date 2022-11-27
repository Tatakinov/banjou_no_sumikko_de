local Const       = require("talk.texas_holdem._const")

local M = {}

local Table = require("talk.texas_holdem._table")

local HAND  = {
  NONE            = 0,
  HIGH_CARDS      = 1,
  ONE_PAIR        = 2,
  TWO_PAIR        = 3,
  THREE_OF_A_KIND = 4,
  STRAIGHT        = 5,
  FLUSH           = 6,
  FULL_HOUSE      = 7,
  FOUR_OF_A_KIND  = 8,
  STRAIGHT_FLUSH  = 9,
}

local function find(array, elem)
  for i, v in ipairs(array) do
    if elem == v then
      return i
    end
  end
  return nil
end

local function maxNumber(array)
  local max = 0
  for _, v in ipairs(array) do
    local suit, num = string.match(v, "(%w)(%d+)")
    num = tonumber(num)
    if num > max then
      max = num
    end
  end
  return max
end

local function minNumber(array)
  local min = 14
  for _, v in ipairs(array) do
    local suit, num = string.match(v, "(%w)(%d+)")
    num = tonumber(num)
    if num < min then
      min = num
    end
  end
  return min
end

local function shouldRaise(i, style, pos, nplayer, is_raised)
  if is_raised then
    if i <= 34 - nplayer * 3 + pos then
      return true
    end
  else
    if i <= 44 - nplayer * 4 + pos then
      return true
    end
  end
  return false
end

local function shouldCall(i, style, pos, nplayer, is_raised, should_allin)
  -- Button, SB, BB は+nplayerして後ろへ回す
  if pos <= 3 then
    pos = pos + nplayer
  end
  if is_raised then
    if i <= 44 - nplayer * 4 + pos then
      return true
    end
  -- SBの位置なら出来るだけcallしたい
  elseif pos == nplayer + 2 and not(should_allin) then
    if i <= 84 - nplayer * 6 + pos then
      return true
    end
  else
    if i <= 54 - nplayer * 5 + pos then
      return true
    end
  end
  return false
end

function M.initialize(shiori)
end

function M.preFlop(shiori, action)
  local __  = shiori.var
  local ret

  local hand  = __("_Hand")
  local suit, num = string.match(hand[1], "(%w)(%d+)")
  local h1  = {
    suit  = suit,
    num   = tonumber(num),
  }
  local suit, num = string.match(hand[2], "(%w)(%d+)")
  local h2  = {
    suit  = suit,
    num   = tonumber(num),
  }
  if h1.num >= 2 then
    if h1.num < h2.num or h2.num == 1 then
      local tmp = h1
      h1  = h2
      h2  = tmp
    end
  end

  local saori = shiori:saori("TexasHoldem")
  local rate  = tonumber(saori("estimate", #__("_Community"), #__("_Playable"), hand[1], hand[2])())

  local nplayer = __("_NPlayer")
  local playable  = __("_Playable")
  local a         = __("_Action")
  local player_info = __("_PlayerInfo")
  local is_raised = __("_CurrentBet") > __("_Blind")
  local remain  = #playable
  print(#playable)
  assert(remain > 0)
  local index = Table.find(remain, hand[1], hand[2])
  local pos = #playable - #a
  print("Position", __("_Position"))
  print("Position", pos)
  local style = "none"
  for _, v in ipairs(playable) do
    -- TODO stub
  end
  local should_allin  = __("_Stack") <= __("_Blind") * 10
  if shouldRaise(index, style, pos, remain, is_raised) then
    if should_allin then
      return {"allin"}
    else
      return {"raise", __("_Blind") * 2}
    end
  end
  local fold_rate  = 1
  local not_reraise_rate  = 1
  local info  = __("_PlayerInfo")
  for _, v in ipairs(__("_Playable")) do
    if v ~= Const.NAME then
      fold_rate = fold_rate * info[v].style.preflop.fold
      not_reraise_rate = not_reraise_rate * (1 - info[v].style.preflop.raise)
    end
  end
  local bet = __("_Blind") * 2
  local fold_e_value  = fold_rate * __("_TotalBet")
  local reraise_e_value = (1 - fold_rate) * (1 - not_reraise_rate) * bet
  local other_e_value = (1 - fold_rate) * not_reraise_rate * (1 - rate / 100) * bet
  print("E-Value:", fold_e_value, reraise_e_value, other_e_value)
  if fold_e_value > reraise_e_value + other_e_value and not(is_raised) then
    print("check/call -> raise")
    return {"raise", bet}
  elseif find(action, "check") then
    return {"check"}
  elseif shouldCall(index, style, pos, remain, is_raised, should_allin) then
    if should_allin then
      return {"allin"}
    else
      return {"call"}
    end
  else
    return {"fold"}
  end
  assert(false)

  --[[
  local vs_allin  = false
  if h1.num == h2.num then
    print("pair")
    if h1.num == 1 and h1.num >= 11 then
      vs_allin  = true
    end
    if __("_Blind") < __("_CurrentBet") then
      ret = {"call"}
    else
      ret = {"raise", __("_Blind") * 2}
    end
  elseif find(action, "check") then
    print("check")
    ret = {"check"}
  elseif h1.num == 1 and h1.suit == h2.suit and h2.num >= 5 then
    print("A-suited")
    vs_allin  = true
    ret = {"call"}
  elseif h1.num == 1 and h2.num >= 8 then
    print("A")
    if h2.num >= 11 then
      vs_allin  = true
    end
    if __("_Blind") == __("_CurrentBet") then
      ret = {"call"}
    end
  elseif h1.num >= 10 and h2.num >= 10 then
    print("ge T")
    if __("_Blind") == __("_CurrentBet") then
      ret = {"raise", __("_Blind") * 2}
    end
  elseif h1.suit == h2.suit and h1.num - 1 == h2.num then
    print("suited-connector")
    if __("_CurrentBet") == __("_Blind") then
      ret = {"call"}
    end
  end
  if not(ret) then
    ret = {"fold"}
  elseif __("_Stack") < __("_Blind") * 10 then
    ret = {"allin"}
  elseif __("_CurrentBet") >= __("_Blind") * 5 and
      not(vs_allin) then
    ret = {"fold"}
  end
  return ret
  --]]
end

function M.flop(shiori, action)
  local __  = shiori.var
  local saori = shiori:saori("TexasHoldem")
  local hand  = __("_Hand")
  local community = __("_Community")
  local hand_strength       = tonumber(saori("hand", hand[1], hand[2])())
  local community_strength  = tonumber(saori("hand", community[1], community[2], community[3])())
  local strength            = tonumber(saori("hand", hand[1], hand[2], community[1], community[2], community[3])())
  __("_Strength", strength)

  print("debug", saori("estimate", #community, community[1], community[2], community[3], #__("_Playable"), hand[1], hand[2])())

  local rate  = -1
  if __("_CurrentBet") > 0 then
    -- 何らかのペアが出来たと仮定してestimateする。
    local list  = {}
    for _, v in ipairs(community) do
      local suit, num = string.match(v, "(%w)(%d+)")
      for _, v in ipairs({"S", "H", "C", "D"}) do
        if not(find(list, v .. num)) and v ~= suit then
          table.insert(list, v .. num)
        end
      end
    end
    for _, v in ipairs({hand[1], hand[2], community[1], community[2], community[3]}) do
      local pos = find(list, v)
      if pos then
        table.remove(list, pos)
      end
    end
    if #list > 0 then
      local sum = 0
      for _, v in ipairs(list) do
        rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], #__("_Playable"), hand[1], hand[2], v, "N0")())
        sum = sum + rate
        print("debug single rate:", rate)
      end
      rate  = sum / #list
      print("raise kouryo", rate)
    end
  end
  if rate < 0 then
    rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], #__("_Playable"), hand[1], hand[2])())
  end

  if community_strength < strength and strength >= HAND.THREE_OF_A_KIND then
    return {"raise", math.floor(__("_Pot") / 10) * 5}
  elseif hand_strength == HAND.HIGH_CARDS and community_strength == HAND.HIGH_CARDS and strength >= HAND.ONE_PAIR then
    return {"raise", math.floor(__("_Pot") / 10) * 5}
  elseif hand_strength == HAND.HIGH_CARDS and community_strength == HAND.ONE_PAIR and strength >= HAND.TWO_PAIR then
    return {"raise", math.floor(__("_Pot") / 10) * 5}
  elseif find(action, "check") then
    local h_num = minNumber(hand)
    local c_num = maxNumber(community)
    local bet_info  = __("_BetInfo")
    local action = __("_Action")
    if h_num > c_num and #action * 2 > #__("_Playable") then
      print("over: check -> raise")
      return {"raise", math.floor(__("_Pot") / 10) * 5}
    end

    local fold_rate  = 1
    local not_reraise_rate  = 1
    local info  = __("_PlayerInfo")
    for _, v in ipairs(__("_Playable")) do
      if v ~= Const.NAME then
        fold_rate = fold_rate * info[v].style.postflop.fold
        not_reraise_rate = not_reraise_rate * (1 - info[v].style.postflop.reraise)
      end
    end
    local bet = math.floor(__("_Pot") / 10) * 5
    local fold_e_value  = fold_rate * __("_Pot")
    local reraise_e_value = (1 - fold_rate) * (1 - not_reraise_rate) * bet
    local other_e_value = (1 - fold_rate) * not_reraise_rate * (1 - rate / 100) * bet
    print("E-Value:", fold_e_value, reraise_e_value, other_e_value)

    local action  = info[Const.NAME].action
    action  = action[#action].preflop
    action  = action[#action]

    if fold_e_value > reraise_e_value + other_e_value then
      print("check -> raise")
      return {"raise", bet}
    else
      return {"check"}
    end
  elseif rate * (__("_Pot") + __("_TotalBet") + __("_CurrentBet")) / __("_CurrentBet") >= 100 then
    return {"call"}
  end
  return {"fold"}
end

function M.turn(shiori, action)
  local __        = shiori.var
  local ret
  local saori     = shiori:saori("TexasHoldem")
  local hand      = __("_Hand")
  local community = __("_Community")
  local rate      = tonumber(saori("estimate", #community, community[1], community[2], community[3], community[4], #__("_Playable"), hand[1], hand[2])())
  local community_strength  = tonumber(saori("hand", community[1], community[2], community[3], community[4])())
  local strength  = tonumber(saori("hand", hand[1], hand[2], community[1], community[2], community[3], community[4])())
  local rate  = -1
  if __("_CurrentBet") > 0 then
    local list  = {}
    for _, v in ipairs({community[4]}) do
      local suit, num = string.match(v, "(%w)(%d+)")
      for _, v in ipairs({"S", "H", "C", "D"}) do
        if not(find(list, v .. num)) and v ~= suit then
          table.insert(list, v .. num)
        end
      end
    end
    for _, v in ipairs({hand[1], hand[2], community[1], community[2], community[3], community[4]}) do
      local pos = find(list, v)
      if pos then
        table.remove(list, pos)
      end
    end
    if #list > 0 then
      local sum = 0
      for _, v in ipairs(list) do
        rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], community[4], #__("_Playable"), hand[1], hand[2], v, "N0")())
        sum = sum + rate
        print("debug single rate:", rate)
      end
      rate  = sum / #list
      print("raise kouryo", rate)
    end
  end
  if rate < 0 then
    rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], #__("_Playable"), hand[1], hand[2])())
  end
  if (strength > __("_Strength") or strength >= HAND.THREE_OF_A_KIND) and strength > community_strength then
    __("_Strength", strength)
    if find(action, "call") then
      ret = {"call"}
    else
      ret = {"raise", math.floor(__("_Pot") / 10) * 5}
    end
  elseif find(action, "check") then
    ret = {"check"}
  elseif rate * (__("_Pot") + __("_TotalBet") + __("_CurrentBet")) / __("_CurrentBet") >= 100 then
    ret = {"call"}
  end
  if not(ret) then
    ret = {"fold"}
  end
  return ret
end

function M.river(shiori, action)
  local __        = shiori.var
  local ret
  local saori     = shiori:saori("TexasHoldem")
  local hand      = __("_Hand")
  local community = __("_Community")
  local rate      = tonumber(saori("estimate", #community, community[1], community[2], community[3], community[4], community[5], #__("_Playable"), hand[1], hand[2])())
  local community_strength  = tonumber(saori("hand", community[1], community[2], community[3], community[4], community[5])())
  local strength  = tonumber(saori("hand", hand[1], hand[2], community[1], community[2], community[3], community[4], community[5])())
  local rate  = -1
  if __("_CurrentBet") > 0 then
    local list  = {}
    for _, v in ipairs({community[5]}) do
      local suit, num = string.match(v, "(%w)(%d+)")
      for _, v in ipairs({"S", "H", "C", "D"}) do
        if not(find(list, v .. num)) and v ~= suit then
          table.insert(list, v .. num)
        end
      end
    end
    for _, v in ipairs({hand[1], hand[2], community[1], community[2], community[3], community[4], community[5]}) do
      local pos = find(list, v)
      if pos then
        table.remove(list, pos)
      end
    end
    if #list > 0 then
      local sum = 0
      for _, v in ipairs(list) do
        rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], community[4], community[5], #__("_Playable"), hand[1], hand[2], v, "N0")())
        sum = sum + rate
        print("debug single rate:", rate)
      end
      rate  = sum / #list
      print("raise kouryo", rate)
    end
  end
  if rate < 0 then
    rate  = tonumber(saori("estimate", #community, community[1], community[2], community[3], #__("_Playable"), hand[1], hand[2])())
  end
  if (strength > __("_Strength") or strength >= HAND.THREE_OF_A_KIND) and strength > community_strength then
    __("_Strength", strength)
    if find(action, "call") then
      ret = {"call"}
    else
      ret = {"raise", math.floor(__("_Pot") / 10) * 5}
    end
  elseif find(action, "check") then
    ret = {"check"}
  elseif rate * (__("_Pot") + __("_TotalBet") + __("_CurrentBet")) / __("_CurrentBet") >= 100 then
    ret = {"call"}
  end
  if not(ret) then
    ret = {"fold"}
  end
  return ret
end

function M.updateAnalysis(info)
  for k, v in pairs(info) do
    --print("Player", k)
    if #v.action < 10 then
      --print("not refreshed")
    else
      local raise, limp, call, fold = 0, 0, 0, 0
      for _, v in ipairs(v.action) do
        for _, v in ipairs(v.preflop) do
          if v == "raise" or v == "allin" then
            raise = raise + 1
          elseif v == "limp" then
            limp  = limp + 1
          elseif v == "call" then
            call  = call + 1
          elseif v == "fold" then
            fold  = fold + 1
          end
        end
      end
      info[k].style.preflop.raise = raise / (raise + limp + call + fold)
      info[k].style.preflop.limp  = limp / (raise + limp + call + fold)
      info[k].style.preflop.call  = call / (raise + limp + call + fold)
      info[k].style.preflop.fold  = fold / (raise + limp + call + fold)
      --[[
      print("infp refreshed")
      print("raise, limp, fold")
      print(info[k].style.preflop.raise)
      print(info[k].style.preflop.limp)
      print(info[k].style.preflop.fold)
      --]]
      local bet, raise, call, fold = 0, 0, 0, 0
      for _, v in ipairs(v.action) do
        for _, v in ipairs(v.postflop) do
          if v == "allin" then
            bet = bet + 1
            raise = raise + 1
          elseif v == "bet" then
            bet = bet + 1
          elseif v == "raise" then
            raise = raise + 1
          elseif v == "call" then
            call = call + 1
          elseif v == "fold" then
            fold  = fold + 1
          end
        end
      end
      if raise + call + fold > 0 then
        info[k].style.postflop.reraise  = raise / (raise + call + fold)
        info[k].style.postflop.call     = call / (raise + call + fold)
        info[k].style.postflop.fold     = fold / (raise + call + fold)
        --[[
        print("infp refreshed")
        print("reraise, call, fold")
        print(info[k].style.postflop.reraise)
        print(info[k].style.postflop.call)
        print(info[k].style.postflop.fold)
        --]]
      end
    end
  end
end

return M
