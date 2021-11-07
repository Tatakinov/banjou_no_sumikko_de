local Color         = require("chess_player.color")
local InitialPreset = require("chess_player.initial_preset")
local ChessPlayer   = require("chess_player.chess_player")
local Misc          = require("chess_player.misc")

local M = {}

local player  = ChessPlayer()

M.Color         = Color
M.InitialPreset = InitialPreset
M.ChessPlayer   = {
  getInstance = function()
    return player
  end
}
M.Misc          = Misc
M.getInstance = function()
  return player
end

return M
