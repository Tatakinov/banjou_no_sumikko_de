local CSA           = require("kifu_player.csa")
local Color         = require("kifu_player.color")
local InitialPreset = require("kifu_player.initial_preset")
local KifuPlayer    = require("kifu_player.kifu_player")
local Misc          = require("kifu_player.misc")

local M = {}

local player  = KifuPlayer()

M.CSA           = CSA
M.Color         = Color
M.InitialPreset = InitialPreset
M.KifuPlayer    = {
  getInstance = function()
    return player
  end
}
M.Misc          = Misc
M.getInstance = function()
  return player
end

return M
