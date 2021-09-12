local M = {}

function M.strToArray(tiles)
  local t = {}
  for tile in string.gmatch(tiles, "%w%w") do
    table.insert(t, tile)
  end
  return t
end

return M
