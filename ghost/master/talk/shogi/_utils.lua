local KifuPlayer  = require("kifu_player")
local NOP = require("nop")
local StringBuffer  = require("string_buffer")

local M = {}

function M.MovesToSakuraScript(shiori, tbl)
  local wait  = tbl.wait
  local sfen  = tbl.sfen
  local player  = KifuPlayer.getInstance()
  local str = StringBuffer()
  assert(type(tbl) == "table")
  if sfen then
    player:setPosition(sfen)
  end
  for _, v in ipairs(tbl) do
    NOP(player + v)
    str:append(shiori:talk("OnShogiViewMinimal"))
    str:append("\\0"):append(player:getSashite():gsub("　", ""))
    if wait then
      str:append("\\_w["):append(wait):append("]")
    end
  end
  return str:tostring()
end

function M.M2SS(shiori, tbl)
  return M.MovesToSakuraScript(shiori, tbl)
end

return M
