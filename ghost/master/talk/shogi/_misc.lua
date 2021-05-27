local KifuPlayer = require("kifu_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local M = {}

function M.explainWithBoard(shiori, filename, ret)
  if filename == nil or ret == nil then
    return nil
  end
  local player  = KifuPlayer.getInstance()
  player:load(filename)
  local str = StringBuffer()
  player:tail()
  local tail  = player:getMoveFormat()
  player:head()
  local current = player:getMoveFormat()
  while current ~= tail do
    str:append(shiori:talk("OnShogiViewMinimal"))
    local comments  = player:getComments()
    if comments then
      comments  = table.concat(comments, "\\n")
      str:append(SS():p(0))
      str:append(comments)
      str:append(SS():x())
    else
      str:append(SS():_w(2000))
    end
    player:forward()
    current = player:getMoveFormat()
  end
  str:append(shiori:talk("OnShogiView"))
  return str:tostring()
end

function M.highlight(shiori, x, y, t, visible)
  t = t or ""
  return shiori:talk("OnShogiRenderHighlight", x, y, t)
end

function M.highlightArray(shiori, array, t, visible)
  local str = StringBuffer()
  for _, v in ipairs(array) do
    str:append(M.highlight(shiori, v.x, v.y, t, visible))
  end
  return str:tostring()
end

return M
