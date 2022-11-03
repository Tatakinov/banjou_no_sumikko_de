local M = {}

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
end

function M.flop(shiori, action)
  local __  = shiori.var
  local ret
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
    ret = {"raise", math.floor(__("_Pot") / 10) * 5}
  elseif hand_strength == HAND.HIGH_CARDS and community_strength == HAND.HIGH_CARDS and strength >= HAND.ONE_PAIR then
    ret = {"raise", math.floor(__("_Pot") / 10) * 5}
  elseif hand_strength == HAND.HIGH_CARDS and community_strength == HAND.ONE_PAIR and strength >= HAND.TWO_PAIR then
    ret = {"raise", math.floor(__("_Pot") / 10) * 5}
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

function M.turn(shiori, action)
  local __        = shiori.var
  local ret
  local saori     = shiori:saori("TexasHoldem")
  local hand      = __("_Hand")
  local community = __("_Community")
  local rate      = tonumber(saori("estimate", #community, community[1], community[2], community[3], community[4], #__("_Playable"), hand[1], hand[2])())
  local strength  = tonumber(saori("hand", hand[1], hand[2], community[1], community[2], community[3], community[4])())
  local rate  = -1
  if __("_CurrentBet") > 0 then
    local list  = {}
    for _, v in ipairs(community) do
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
  if strength > __("_Strength") then
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
  local strength  = tonumber(saori("hand", hand[1], hand[2], community[1], community[2], community[3], community[4], community[5])())
  local rate  = -1
  if __("_CurrentBet") > 0 then
    local list  = {}
    for _, v in ipairs(community) do
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
  if strength > __("_Strength") then
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

return M
