-- 麻雀1ミリくらいしか知らない人が書いたAIなので
-- 間違っても参考にしないように。
--
-- AIの概要
--  一般手のみ狙う。
--  有効牌が多くなるように捨て牌を選ぶ。
--  テンパイ即リー。
--  鳴かない。
--  清一色みたいに同じ種類の牌が多いとタイムアウトすることも…

local Clone = require("clone")
local Utils = require("talk.mahjong._utils")

local M = {}

local TIMEOUT = 2

local hai_list        = {}

local function getRemain()
  local remain_hai_list = {}
  for i = 1, 9 do
    table.insert(hai_list, i .. "m")
    remain_hai_list[i .. "m"]  = 4
  end
  for i = 1, 9 do
    table.insert(hai_list, i .. "p")
    remain_hai_list[i .. "p"]  = 4
  end
  for i = 1, 9 do
    table.insert(hai_list, i .. "s")
    remain_hai_list[i .. "s"]  = 4
  end
  for i = 1, 7 do
    table.insert(hai_list, i .. "z")
    remain_hai_list[i .. "z"]  = 4
  end
  return remain_hai_list
end

local function split(str, delim)
  local t = {}
  for s in string.gmatch(str, "[^" .. delim .. "]*") do
    table.insert(t, s)
  end
  return t
end

local function sortHai(hai)
  table.sort(hai, function(a, b)
    return string.reverse(a) < string.reverse(b)
  end)
  return hai
end

local indicator2dora  = {
  ["1m"]  = "2m", ["2m"]  = "3m", ["3m"]  = "4m",
  ["4m"]  = "5m", ["5m"]  = "6m", ["6m"]  = "7m",
  ["7m"]  = "8m", ["8m"]  = "9m", ["9m"]  = "1m",
  ["1p"]  = "2p", ["2p"]  = "3p", ["3p"]  = "4p",
  ["4p"]  = "5p", ["5p"]  = "6p", ["6p"]  = "7p",
  ["7p"]  = "8p", ["8p"]  = "9p", ["9p"]  = "1p",
  ["1s"]  = "2s", ["2s"]  = "3s", ["3s"]  = "4s",
  ["4s"]  = "5s", ["5s"]  = "6s", ["6s"]  = "7s",
  ["7s"]  = "8s", ["8s"]  = "9s", ["9s"]  = "1s",
  ["1z"]  = "2z", ["2z"]  = "3z", ["3z"]  = "4z", ["4z"]  = "1z",
  ["5z"]  = "6z", ["6z"]  = "7z", ["7z"]  = "5z",
}

local yaku2ascii  = {
  ["七対子"]        = "chiitoi",
  ["国士無双"]      = "kokushi",
  ["門前清自摸和"]  = "menzen",
  ["役牌"]          = "yakuhai",
  ["断ヤオ九"]      = "tannyao",
  ["対々和"]        = "toitoi",
  ["混一色"]        = "honnitsu",
}

local function toHandString(tehai, furo)
  local s = table.concat(tehai, "")
  for _, v in ipairs(furo) do
    print("toHandString")
    for k, v in ipairs(v) do
      print(k, v)
    end
    if v.sute then
      s = s .. "<" .. table.concat(v.block, "") .. ">"
    else
      s = s .. "(" .. table.concat(v.block, "") .. ")"
    end
  end
  return s
end

local function getFoldSutehai(hai, safe, kawa, jumme)
  local hai = Utils.strToArray(hai)
  local tmp = {}
  for _, v in ipairs(hai) do
    tmp[v]  = true
  end
  local hai = {}
  for k, _ in pairs(tmp) do
    table.insert(hai, k)
  end
  local list  = setmetatable({}, {__index = function() return 0 end})
  --print("jumme", jumme)
  --print("#kawa", #kawa)
  local size  = 0
  for _, v in pairs(safe) do
    size  = size  + 1
    for _, v in ipairs(v) do
      list[v] = list[v] + 1
    end
  end
  --[[
  for i = size, 2 do
    for _, v in ipairs(hai_list) do
      list[v] = list[v] + 1
    end
  end
  --]]
  --[=[
  for i = jumme, #kawa do
    --print("kawa[i]", kawa[i])
    list[kawa[i]] = 3
  end
  --]=]
  if #jumme == 1 then
    for i = jumme[1], #kawa do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 1 then
        list[kawa[i]] = 1
      end
    end
  elseif #jumme == 2 then
    for i = jumme[1], jumme[2] - 1 do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 1 then
        list[kawa[i]] = 1
      end
    end
    for i = jumme[2], #kawa do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 2 then
        list[kawa[i]] = 2
      end
    end
  elseif #jumme == 3 then
    for i = jumme[1], jumme[2] - 1 do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 1 then
        list[kawa[i]] = 1
      end
    end
    for i = jumme[2], jumme[3] - 1 do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 2 then
        list[kawa[i]] = 2
      end
    end
    for i = jumme[3], #kawa do
      --print("kawa[i]", kawa[i])
      if list[kawa[i]] < 3 then
        list[kawa[i]] = 3
      end
    end
  end
  local safe_hai_list = {}
  for tile, safe_value in pairs(list) do
    for _, v in ipairs(hai) do
      if tile == v then
        table.insert(safe_hai_list, {
          tile  = tile,
          safe  = safe_value,
        })
      end
    end
  end
  local safe_value  = 0
  local best_safe_hai_list  = {}
  for _, v in ipairs(safe_hai_list) do
    if safe_value < v.safe then
      safe_value  = v.safe
      best_safe_hai_list  = {
        v.tile,
      }
    elseif safe_value == v.safe then
      table.insert(best_safe_hai_list, v.tile)
    end
  end
  --
  print("-- best fold hai --")
  print("safe_value", safe_value)
  for i, v in ipairs(best_safe_hai_list) do
    print(i, v)
  end
  if #best_safe_hai_list > 0 then
    return best_safe_hai_list[math.random(#best_safe_hai_list)]
  end
end

function M.getBestSutehai(saori, hai, kawa, round, seat, dora_indicator, furo, furo_others, safe, riichi_others)
  -- 自摸った牌も含まれているので除外する
  local tmp = {}
  for _, v in ipairs(hai) do
    table.insert(tmp, v)
  end
  local tsumo = table.remove(tmp)
  hai = table.concat(tmp, "")

  local dora  = {}
  for _, v in ipairs(dora_indicator) do
    table.insert(dora, indicator2dora[v])
  end

  local visible = hai .. tsumo .. table.concat(kawa, "") .. table.concat(dora_indicator, "")
  for _, v in ipairs(furo) do
    local t = Utils.decode(v.block)
    if v.sute then
      for k, v in pairs(Utils.decode(v.sute)) do
        t[k] = t[k] - v
      end
    end
    visible = visible .. table.concat(Utils.encode(t), "")
  end
  print("Visible", visible)

  local hand = toHandString(Utils.strToArray(hai), furo) .. tsumo

  local ret = saori("shanten", hand, visible, 0)
  print("saori", ret())
  local shanten, _, sute = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
  shanten = tonumber(shanten) or 14
  if shanten == 14 then
    print("SAORI ERROR")
    local h = Utils.strToArray(hai .. tsumo)
    return h[math.random(#h)]
  end
  -- 自摸ってたらすぐに返す。
  if shanten == -1 then
    return nil, nil, true
  end
  do
    local map = Utils.decode(Utils.strToArray(hai))
    local t
    for k, v in pairs(Utils.decode({tsumo})) do
      if v > 0 then
        t = k
      end
    end
    -- 暗槓
    if map[t] == 3 then
      map[t] = map[t] - 3
      table.insert(furo, {
        block = Utils.encode({[t] = 4}),
        sute  = nil,
      })
      local hand = Utils.encode(map)
      hand = toHandString(hand, furo) .. tsumo
      local ret = saori("shanten", hand, visible, 0)
      print("ankan", ret())
      table.remove(furo)
      local s, _, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
      s = tonumber(s)
      if s <= shanten then
        -- 他家がリーチしてなければ暗槓する
        local t = {}
        for _, v in ipairs(riichi_others) do
          table.insert(t, v)
        end
        if #t == 0 then
          return nil, false, false, true
        end
      end
    end
    -- 加槓
    local can = false
    for _, v in ipairs(furo) do
      can = true
      for _, v in ipairs(v.block) do
        if tsumo ~= v then
          can = false
          break
        end
      end
      if can then
        break
      end
    end
    if can then
      -- 他家がリーチしてなければ加槓する
      local t = {}
      for _, v in ipairs(riichi_others) do
        table.insert(t, v)
      end
      if #t == 0 then
        return nil, false, false, false, true
      end
    end
  end
  -- 一向聴未満で他家がリーチをしてたら降りる
  if shanten > 1 then
    local jumme = {}
    for _, v in pairs(riichi_others) do
      table.insert(jumme, v)
    end
    table.sort(jumme)
    if #jumme > 0 then
      print("Ori?")
      local sutehai = getFoldSutehai(hai .. tsumo, safe, kawa, jumme)
      if sutehai then
        print("Ori")
        return sutehai
      end
    end
  end
  print("Shanten", shanten)

  sute = Utils.strToArray(sute)
  local valid_list = {}
  for _, v in ipairs(sute) do
    local h = Utils.strToArray(hai .. tsumo)
    local s
    for i = 1, #h do
      if h[i] == v then
        s = table.remove(h, i)
        break
      end
    end
    local ret = saori("shanten", table.concat(h, ""), visible .. s, 0)
    local _, valid, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
    valid = Utils.strToArray(valid)
    -- 牌毎の枚数でスコアを弄った方が良いかもしれない
    local remain = getRemain()
    for _, v in ipairs(Utils.strToArray(visible .. s)) do
      remain[v] = remain[v] - 1
    end
    local score = 0
    for _, v in ipairs(valid) do
      score = score + remain[v]
    end
    valid_list[v] = score
    table.insert(valid_list, { hai = v, score = score })
  end
  table.sort(valid_list, function(a, b) return a.score > b.score end)
  for _, v in ipairs(valid_list) do
    print("sute:", v.hai, "score:", v.score)
  end
  --
  print("yaku", hai, tsumo, visible, table.concat(dora, ""), round, seat)
  local ret = saori("yaku", hai, tsumo, visible, table.concat(dora, ""), round, seat)
  local han, sute = string.match(ret(), "([0-9]+),(%w*)")
  print("yaku", ret())
  if ret() == "Error" then
    print("Error:", ret[0])
  end
  print("han", han)
  sute = Utils.strToArray(sute)
  for _, v in ipairs(sute) do
    sute[v] = true
  end
  -- 一番スコアの良い捨て牌のリストにする
  local result = {}
  local result_p_high = {}
  local result_p_high_upper = {}
  local threshold = valid_list[1].score
  for _, v in ipairs(valid_list) do
    if threshold == v.score then
      if sute[v.hai] then
        table.insert(result_p_high, v)
      end
      table.insert(result, v)
    elseif sute[v.hai] and (v.score / threshold) >= 0.8 then
      table.insert(result_p_high_upper, v)
      table.insert(result, v)
    end
  end
  if #result_p_high > 0 then
    print("p-high")
    local e = result_p_high[math.random(#result_p_high)]
    return e.hai, shanten == 0
  end
  if #result_p_high_upper > 0 then
    print("upper!")
    local e = result_p_high_upper[math.random(#result_p_high_upper)]
    return e.hai, shanten == 0
  end
  return result[math.random(#result)].hai, shanten == 0
end

function M.doChi(saori, tehai, furo, sute, visible, round, seat, dora_indicator)
  local ret = saori("shanten", toHandString(tehai, furo), table.concat(visible, ""))
  local shanten, _, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
  shanten = tonumber(shanten)
  local dora  = {}
  for _, v in ipairs(dora_indicator) do
    table.insert(dora, indicator2dora[v])
  end

  local t = Utils.decode(tehai)
  local su
  for k, v in pairs(Utils.decode({sute})) do
    print(k, v)
    if v > 0 then
      su = k
    end
  end

  local result = {}
  for _, v in ipairs({
    { d1 = -1, d2 = -2, },
    { d1 = 1, d2 = -1, },
    { d1 = 2, d2 = 1, },
  }) do
    print("CHI")
    print(su, v)
    print(v.d1, v.d2)
    print(t[su + v.d1], t[su + v.d2])
    if t[su + v.d1] > 0 and t[su + v.d2] > 0 then
      t[su + v.d1] = t[su + v.d1] - 1
      t[su + v.d2] = t[su + v.d2] - 1
      table.insert(furo, {
        block = Utils.encode({
          [su] = 1,
          [su + v.d1] = 1,
          [su + v.d2] = 1,
        }),
        sute = sute,
      })
      local tehai = Utils.encode(t)

      print("shanten", toHandString(tehai, furo), table.concat(visible, ""))
      local ret = saori("shanten", toHandString(tehai, furo), table.concat(visible, ""))
      local s, _, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
      s = tonumber(s)
      if s < shanten then
        local h = Utils.encode(t)
        local t = table.remove(h)
        print("yaku", toHandString(h, furo), t, table.concat(visible, ""), table.concat(dora, ""), round, seat)
        local ret = saori("yaku", toHandString(h, furo), t, table.concat(visible, ""), table.concat(dora, ""), round, seat)
        local han, sute, yaku = string.match(ret(), "([0-9]+),(%w*),(%w*)")
        han = tonumber(han)
        print("han", han, sute, yaku)
        table.insert(result, {
          block = Utils.encode({[su + v.d1] = 1, [su + v.d2] = 1}),
          han = han,
          yaku = yaku,
        })
      end

      t[su + v.d1] = t[su + v.d1] + 1
      t[su + v.d2] = t[su + v.d2] + 1
      table.remove(furo)
    end
  end
  table.sort(result, function(a, b)
    return a.han > b.han
  end)
  if #result > 0 then
    if #furo > 0 or result[1].han > 0 and result[1].yaku ~= "Dora" then
      return true, result[1].block[1], result[1].block[2]
    end
  end
  return false
end

function M.doPonKan(saori, tehai, furo, sute, visible, round, seat, dora_indicator, num)
  local ret = saori("shanten", toHandString(tehai, furo), table.concat(visible, ""))
  local shanten, _, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
  shanten = tonumber(shanten)
  local dora  = {}
  for _, v in ipairs(dora_indicator) do
    table.insert(dora, indicator2dora[v])
  end

  local t = Utils.decode(tehai)
  local su
  for k, v in pairs(Utils.decode({sute})) do
    if v > 0 then
      su = k
    end
  end

  local result = {}
  if t[su] >= (num - 1) then
    t[su] = t[su] - (num - 1)
    local block = {}
    for i = 1, num do
      table.insert(block, sute)
    end
    table.insert(furo, {
      block = block,
      sute = sute,
    })

    local tehai = Utils.encode(t)
    print("shanten", toHandString(tehai, furo), table.concat(visible, ""))
    local ret = saori("shanten", toHandString(tehai, furo), table.concat(visible, ""))
    local s, _, _ = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
    s = tonumber(s)
    if s < shanten then
      local h = Utils.encode(t)
      local t = table.remove(h)
      print("yaku", toHandString(h, furo), t, table.concat(visible, ""), table.concat(dora, ""), round, seat)
      local ret = saori("yaku", toHandString(h, furo), t, table.concat(visible, ""), table.concat(dora, ""), round, seat)
      local han, sute, yaku = string.match(ret(), "([0-9]+),(%w*),(%w*)")
      han = tonumber(han)
      print("han", han, sute, yaku)
      table.insert(result, {
        han = han,
        yaku = yaku,
      })
    end

    t[su] = t[su] + (num - 1)
    table.remove(furo)
  end
  table.sort(result, function(a, b)
    return a.han > b.han
  end)
  if #result > 0 then
    if #furo > 0 or result[1].han > 0 and result[1].yaku ~= "Dora" then
      return true
    end
  end
  return false
end

function M.doKan(saori, tehai, furo, sute, visible, round, seat, dora_indicator)
  return M.doPonKan(saori, tehai, furo, sute, visible, round, seat, dora_indicator, 4)
end

function M.doPon(saori, tehai, furo, sute, visible, round, seat, dora_indicator)
  return M.doPonKan(saori, tehai, furo, sute, visible, round, seat, dora_indicator, 3)
end

function M.doAnkan(saori, tehai, furo, tsumo, visible, round, seat, dora_indicator)
end

return M
