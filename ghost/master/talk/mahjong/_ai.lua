-- 麻雀1ミリくらいしか知らない人が書いたAIなので
-- 間違っても参考にしないように。

local Clone = require("clone")

local M = {}

local function split(str, delim)
  local t = {}
  for s in string.gmatch(str, "[^" .. delim .. "]*") do
    table.insert(t, s)
  end
  return t
end

local function strToArray(tiles)
  local t = {}
  for tile in string.gmatch(tiles, "%w%w") do
    table.insert(t, tile)
  end
  return t
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

function M.getBestSutehai(shiori, hai, kawa, round, seat, dora_indicator)
  local dahai_choice  = {}
  local best_point  = -1  -- 必ず更新させるため-1スタート
  local dora  = {}
  --[[
  for _, v in ipairs(strToArray(dora_indicator)) do
    table.insert(dora, indicator2dora(v))
  end
  --]]

  -- 孤立牌は優先的に切る
  local isolated_tiles = getIsolatedTiles(strToArray(hai))
  print("-- isolated --")
  for i, v in ipairs(isolated_tiles) do
    print(i, v)
  end
  if #isolated_tiles > 0 then
    return isolated_tiles[math.random(#isolated_tiles)]
  end

  local mahjong = shiori:saori("mahjong")
  local list  = mahjong("shanten_normal", hai)
  local min_shanten = tonumber(list())
  print("Shanten", min_shanten)

  --不要牌？の抽出
  local unnecessary_hai_list = {}
  local array_hai = strToArray(hai)
  for i = 1, #array_hai do
    local hai = Clone(array_hai)
    local unnecessary_hai = table.remove(hai, i)
    local ret = mahjong("shanten_normal", table.concat(hai))
    if tonumber(ret()) == min_shanten then
      table.insert(unnecessary_hai_list, unnecessary_hai)
      unnecessary_hai_list[unnecessary_hai] = 1
    end
  end
  print("-- unnecessary --")
  for k, v in pairs(unnecessary_hai_list) do
    print(k, v)
  end

  -- 仲間外れ率が高めの牌を抽出
  local freq_map  = setmetatable({}, {__index = function() return 0 end,})
  for i = 0, #list do
    print("Ref" .. i, list[i])
    local list  = split(list[i], ",")
    for _, v in ipairs(list) do
      if type(v) == "string" and #v == 2 then
        freq_map[v] = freq_map[v] + 1
      end
    end
  end
  local freq_list = {}
  local freq  = 0
  for k, v in pairs(freq_map) do
    if v > 1 then
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
  if #priority_sutehai > 0 then
    return priority_sutehai[math.random(#priority_sutehai)]
  end
  --return unnecessary_hai_list[math.random(#unnecessary_hai_list)]
  -- なんかserverがもっといい打牌をしてくれることに期待する
  return nil
end

return M
