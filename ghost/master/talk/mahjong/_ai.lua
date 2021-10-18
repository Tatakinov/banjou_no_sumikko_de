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

-- TODO 高速化
local function getNecessaryHaiMap(saori, hai)
  local map = {}
  local array_hai = Utils.strToArray(hai)
  for i = 1, #array_hai do
    local hai = Clone(array_hai)
    local sutehai = table.remove(hai, i)
    local ret = saori("shanten_normal", table.concat(hai))
    local shanten = tonumber(ret())
    local list  = {}
    if map[sutehai] == nil then
      map[sutehai]  = {
        shanten = shanten,
        list    = list,
      }
      for i = 1, #remain_hai_list do
        if remain_hai_list[i] ~= sutehai then
          local hai = Clone(hai)
          table.insert(hai, remain_hai_list[i])
          sortHai(hai)
          local ret = saori("shanten_normal", table.concat(hai))
          if (tonumber(ret() or 14)) < shanten then
            table.insert(list, remain_hai_list[i])
          end
        end
      end
    end
  end
  return map
end

-- TODO 高速化
local function getNecessaryHaiMapMin(saori, hai, kawa, furo, dora_indicator, current_shanten)
  local shanten_table = {}
  local map = {}
  local array_hai = Utils.strToArray(hai)
  local current_hai_list  = Clone(remain_hai_list)
  local start = os.clock()
  -- 手牌、捨て牌、他家が副露した牌は有効牌候補から削る
  for _, v in ipairs(array_hai) do
    current_hai_list[v] = current_hai_list[v] - 1
  end
  for _, v in ipairs(dora_indicator) do
    current_hai_list[v] = current_hai_list[v] - 1
  end
  for _, v in pairs(kawa) do
    if type(v) == "table" then
      for _, v in ipairs(v) do
        current_hai_list[v] = current_hai_list[v] - 1
      end
    end
  end

  -- 副露している牌を除く
  for _, v in pairs(furo) do
    for _, v in ipairs(v) do
      current_hai_list[v] = current_hai_list[v] - 1
    end
  end

  for i = 1, #array_hai do
    local hai = Clone(array_hai)
    local sutehai = table.remove(hai, i)
    -- 既に算出済みの捨て牌はスルー
    local shanten = shanten_table[table.concat(hai)]
    if shanten == nil then
      local isolated_tiles_base = getIsolatedTiles(hai)
      local ret = saori("shanten_normal", table.concat(hai))
      shanten = tonumber(ret())
      shanten_table[table.concat(hai)]  = shanten
      -- 向聴数が戻る場合は無視
      if shanten == current_shanten then
        local list  = {}
        if map[sutehai] == nil then
          map[sutehai]  = {
            shanten = shanten,
            list    = list,
          }
          for k, v in pairs(current_hai_list) do
            if k ~= sutehai and v > 0 then
              local hai = Clone(hai)
              table.insert(hai, k)
              sortHai(hai)
              local isolated_tiles  = getIsolatedTiles(hai)
              -- 孤立牌を足して向聴数が進むことは無いものとする
              if #isolated_tiles <= #isolated_tiles_base then
                local hai_str = table.concat(hai)
                local current_shanten = shanten_table[hai_str]
                if current_shanten == nil then
                  local ret = saori("shanten_normal", hai_str)
                  -- 計算に時間が掛かりすぎていたらタイムアウトする
                  if os.clock() - start > TIMEOUT then
                    return nil
                  end
                  current_shanten = tonumber(ret()) or 14
                  shanten_table[hai_str]  = current_shanten
                else
                  --print("hit!")
                end
                if current_shanten < shanten then
                  table.insert(list, k)
                end
              end
            end
          end
        end
      end
    else
      --print("hit!")
    end
  end
  return map
end

local function getUnnecessaryHaiList(saori, hai)
  local ret = saori("shanten_normal", hai)
  local min_shanten = ret()
  local array_hai = Utils.strToArray(hai)
  local unnecessary_hai_list  = {}
  for i = 1, #array_hai do
    local hai = Clone(array_hai)
    local unnecessary_hai = table.remove(hai, i)
    local ret = saori("shanten_normal", table.concat(hai))
    if tonumber(ret()) == min_shanten then
      table.insert(unnecessary_hai_list, unnecessary_hai)
      unnecessary_hai_list[unnecessary_hai] = 1
    end
  end
  return unnecessary_hai_list
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

  local list  = saori("shanten_normal", hai)
  local min_shanten = tonumber(list())
  -- 自摸ってたらすぐに返す。
  if min_shanten == -1 then
    return nil, nil, true
  -- 一向聴未満で他家がリーチをしてたら降りる
  elseif min_shanten > 1 then
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
  print("Shanten", min_shanten)

  -- 孤立牌は優先的に切る
  local isolated_tiles = getIsolatedTiles(Utils.strToArray(hai))
  print("-- isolated --")
  for i, v in ipairs(isolated_tiles) do
    print(i, v)
  end
  if #isolated_tiles > 0 then
    -- 孤立した字牌は特に優先的に切る
    local isolated_honours  = {}
    for _, v in ipairs(isolated_tiles) do
      if string.match(v, "%dz") then
        table.insert(isolated_honours, v)
      end
    end
    -- 国士無双みたいな孤立牌がある手が成立しなくなるが
    -- このAIでは一般手しか狙わないので問題ない。
    if #isolated_honours > 0 then
      return isolated_honours[math.random(#isolated_honours)], min_shanten == 0
    else
      return isolated_tiles[math.random(#isolated_tiles)], min_shanten == 0
    end
  end

  -- 有効牌？の抽出
  local necessary_hai_map = getNecessaryHaiMapMin(saori, hai, kawa, furo, dora_indicator, min_shanten)
  -- タイムアウトしていた場合はnilを返す
  if necessary_hai_map == nil then
    return nil
  end
  print("-- necessary --")
  for k, v in pairs(necessary_hai_map) do
    --print(k, "Shanten", v.shanten)
    print(k, "=>", table.concat(v.list, ", "))
  end

  local necessary_hai_list = {}
  for k, v in pairs(necessary_hai_map) do
    table.insert(necessary_hai_list, {
      hai     = k,
      shanten = v.shanten,
      list    = v.list,
    })
  end
  local min_shanten_list
  local shanten = 14
  for _, v in ipairs(necessary_hai_list) do
    if shanten > v.shanten then
      shanten = v.shanten
      min_shanten_list = {
        v,
      }
    elseif shanten == v.shanten then
      table.insert(min_shanten_list, v)
    end
  end
  local best_sutehai_list = {}
  local list_size = 0
  for _, v in ipairs(min_shanten_list) do
    if list_size < #v.list then
      list_size = #v.list
      best_sutehai_list = {
        v
      }
    elseif list_size == #v.list then
      table.insert(best_sutehai_list, v)
    end
  end
  print("-- best_sutehai --")
  for i, v in ipairs(best_sutehai_list) do
    print(i, v.hai, table.concat(v.list, ", "))
  end
  local yao9_list = {}
  for _, v in ipairs(best_sutehai_list) do
    if string.match(v.hai, "%dz") or string.match(v.hai, "[19][mps]") then
      table.insert(yao9_list, v)
    end
  end
  print("-- yao9 --")
  for i, v in ipairs(yao9_list) do
    print(i, v.hai, table.concat(v.list, ", "))
  end
  if #yao9_list > 0 then
    return yao9_list[math.random(#yao9_list)].hai, yao9_list[1].shanten == 0
  else
    return best_sutehai_list[math.random(#best_sutehai_list)].hai, best_sutehai_list[1].shanten == 0
  end

--[[
  -- 不要牌？の抽出
  local unnecessary_hai_list = getUnnecessaryHaiList(saori, hai)
  print("-- unnecessary --")
  for k, v in pairs(unnecessary_hai_list) do
    print(k, v)
  end

  -- 仲間外れ率が高めの牌を抽出
  local freq_map  = setmetatable({}, {__index = function() return 0 end,})
  if list[0] then
    for i = 0, #list do
      print("Ref" .. i, list[i])
      local list  = split(list[i], ",")
      for _, v in ipairs(list) do
        if type(v) == "string" and #v == 2 then
          freq_map[v] = freq_map[v] + 1
        end
      end
    end
  end
  local freq_list = {}
  local freq  = 0
  for k, v in pairs(freq_map) do
    if v > 0 then
      if freq < v then
        freq  = v
        freq_list = {k}
      elseif freq == v then
        table.insert(freq_list, k)
      end
    end
  end
  print("-- freq --")
  for i, v in ipairs(freq_list) do
    print(i, v)
  end
  local priority_sutehai  = {}
  for _, v in ipairs(freq_list) do
    if unnecessary_hai_list[v] then
      table.insert(priority_sutehai, v)
    end
  end
  --[[
  if #freq_list > 0 then
    return freq_list[math.random(#freq_list)]
  end
  --]]
--[[
  if #priority_sutehai > 0 then
    return priority_sutehai[math.random(#priority_sutehai)]
  end
  --return unnecessary_hai_list[math.random(#unnecessary_hai_list)]
  -- なんかserverがもっといい打牌をしてくれることに期待する
  return nil
--]]
end

return M
