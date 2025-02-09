local M = {}

function M.strToArray(tiles)
  local t = {}
  for tile in string.gmatch(tiles, "%w%w") do
    table.insert(t, tile)
  end
  return t
end

local decode_table  = {}
for i = 1, 3 do
  local str = {"m", "p", "s"}
  for j = 1, 9 do
    decode_table[tostring(j) .. str[i]] = j + (i - 1) * 11
  end
end
for i = 1, 7 do
  decode_table[tostring(i) .. "z"] = 35 + (i - 1) * 4
end
function M.decode(list)
  local t = setmetatable({}, { __index = function() return 0 end })
  for _, v in ipairs(list) do
    t[decode_table[v]] = t[decode_table[v]] + 1
  end
  return t
end

local encode_table  = {}
for k, v in pairs(decode_table) do
  encode_table[v] = k
end
function M.encode(map)
  local t = {}
  for k, v in pairs(map) do
    for i = 1, v do
      table.insert(t, encode_table[k])
    end
  end
  return t
end


return M
