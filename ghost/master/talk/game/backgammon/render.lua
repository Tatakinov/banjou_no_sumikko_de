local Render        = require("talk.game.backgammon._render_shell")
local StringBuffer  = require("string_buffer")

Render.initialize()

return {
  {
    id  = "OnBackgammonRender",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_BGPlayer")
      local render_collision_dice = ref[0] == "true"
      local str = StringBuffer()
      str:append(Render.clear())
      local both_points = __("_BGPlayer"):getPosition()
      for color, points in ipairs(both_points) do
        for i, point in ipairs(points) do
          str:append(Render.renderPiece(i, color, point))
        end
      end
      local dice1 = __("_BG_Dice1")
      local dice2 = __("_BG_Dice2")
      if dice1 and dice2 then
        str:append(Render.renderDice(1, dice1.color, dice1.value))
        str:append(Render.renderDice(2, dice2.color, dice2.value))
      end
      if render_collision_dice then
        --print("DICE DUMMY")
        str:append(Render.renderSwap())
      end
      local movable = __("_BG_Movable")
      if movable then
        --print("POINT DUMMY")
        for _, v in ipairs(movable) do
          str:append(Render.renderMovable(v))
        end
      end
      local color = player:getDoubleColor()
      if color then
        str:append(Render.renderDouble(color, player:getDoubleRate()))
      end
      str:append(Render.update())
      return str
    end,
  },
}
