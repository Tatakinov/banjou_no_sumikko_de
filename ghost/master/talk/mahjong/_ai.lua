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

local function getIsolatedTiles(hai)
  local isolated_tiles  = {}
  local reverse = setmetatable({}, {__index = function() return 0 end}) -- 任意の配列の初期値を0にするおまじない
  for _, v in ipairs(hai) do
    reverse[v]  = reverse[v] + 1
  end
  for _, v in ipairs(hai) do
    if reverse[v] == 1 then
      local num   = tonumber(string.sub(v, 1, 1))
      local kind  = string.sub(v, 2, 2)
      if kind == "z" then
        table.insert(isolated_tiles, v)
      elseif kind == "m" or kind == "s" or kind == "p" then
        if  reverse[(num - 2) .. kind] == 0 and
            reverse[(num - 1) .. kind] == 0 and
            reverse[(num + 1) .. kind] == 0 and
            reverse[(num + 2) .. kind] == 0 then
          table.insert(isolated_tiles, v)
        end
      end
    end
  end
  return isolated_tiles
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

function M.getBestSutehai(saori, hai, kawa, round, seat, dora_indicator, furo, safe, riichi_others)
  local dora  = {}
  --[[
  for _, v in ipairs(Utils.strToArray(dora_indicator)) do
    table.insert(dora, indicator2dora(v))
  end
  --]]

  local visible = hai .. table.concat(kawa, "")
  print("Visible", visible)

  local ret = saori("shanten", hai, visible, 0)
  print("saori", ret())
  local shanten, _, sute = string.match(ret(), "(-?[0-9]+),(%w*),(%w*)")
  shanten = tonumber(shanten) or 14
  if shanten == 14 then
    print("SAORI ERROR")
    local h = Utils.strToArray(hai)
    return h[math.random(#h)]
  end
  -- 自摸ってたらすぐに返す。
  if shanten == -1 then
    return nil, nil, true
  -- 一向聴未満で他家がリーチをしてたら降りる
  elseif shanten > 1 then
    local jumme = {}
    for _, v in pairs(riichi_others) do
      table.insert(jumme, v)
    end
    table.sort(jumme)
    if #jumme > 0 then
      print("Ori?")
      local sutehai = getFoldSutehai(hai, safe, kawa, jumme)
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
    local h = Utils.strToArray(hai)
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
    table.insert(valid_list, { hai = v, score = score })
  end
  table.sort(valid_list, function(a, b) return a.score > b.score end)
  for _, v in ipairs(valid_list) do
    print("sute:", v.hai, "score:", v.score)
  end
  -- 一番スコアの良い捨て牌のリストにする
  local result = {}
  local threshold = valid_list[1].score
  for _, v in ipairs(valid_list) do
    if threshold > v.score then
      break
    end
    table.insert(result, v)
  end
  return result[math.random(#result)].hai, shanten == 0
end

return M
