local KifuPlayer = require("kifu_player")
local Misc  = require("shiori.misc")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id      = "閉じる",
    content = function(shiori, ref)
      return SS():p(0):b(-1):c()
    end,
  },
  -- バルーンのURLをクリックした時に呼ぶ用
  {
    id  = "OnJumpURL",
    content = function(shiori, ref)
      return "\\C\\j[" .. ref[0] .. "]"
    end,
  },
}
