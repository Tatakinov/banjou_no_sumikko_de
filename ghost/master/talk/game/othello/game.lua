local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnOthelloGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Othello")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      local game_option = __("OthelloGameOption")
      if game_option.player_color == "random" then
        if math.random(1, 2) == 2 then
          __("_PlayerColor", 1)
        else
          __("_PlayerColor", 2)
        end
      else
        __("_PlayerColor", game_option.player_color)
      end
      return "\\0\\s[座り_きょとん]よろしくお願いします。\\_w[1000]\\s[座り_素]" ..
          SS():raise("OnOthelloGameTurnBegin")
    end,
  },
  {
    id  = "OnOthelloGameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local othello = shiori:saori("othello")
      local teban = othello("teban")()
      local player_color  = __("_PlayerColor")
      local array = {
        Black = 1,
        White = 2,
      }
      if othello("isPass")() == "True" then
        othello("pass")
        return SS():raise("OnOthelloGameTurnBegin")
      elseif othello("isGameOver")() == "True" then
        local ret = othello("isGameOver")
        __("_InGame", false)
        local black = tonumber(ret[0])
        local white = tonumber(ret[1])
        local str = StringBuffer()
        str:append("\\0\\s[座り_素]" .. black .. "対" .. white .. "で")
        local score = __("成績(Othello)")["つよい"]
        if black > white then
          if __("_PlayerColor") == 1 then
            score.win = score.win + 1
            str:append("${User}の勝ちだよ。")
          else
            score.lose  = score.lose + 1
            str:append("わたしの勝ちだね。")
          end
          print("Black Win")
        elseif black < white then
          if __("_PlayerColor") == 2 then
            score.win = score.win + 1
            str:append("${User}の勝ちだよ。")
          else
            score.lose  = score.lose + 1
            str:append("わたしの勝ちだね。")
          end
          print("white Win")
        else
          print("Draw")
          str:append("引き分けだよ。")
        end
        return str
      elseif array[teban] == player_color then
        return SS():raise("OnOthelloGamePlayerTurnBegin")
      else
        return SS():raise("OnOthelloGameCpuTurnBegin")
      end
    end,
  },
  {
    id  = "OnOthelloGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      local othello = shiori:saori("othello")
      local moves = othello("genMoves")

      __("_Othello_State", "begin")

      str:append(shiori:talk("OnOthelloView"))

      if tonumber(moves()) == 0 then
        return SS():raise("OnOthelloGamePlayerTurnEnd")
      end

      for i = 0, tonumber(moves()) - 1 do
        local x, y  = string.match(moves[i], "(%d+),(%d+)")
        if not(tonumber(x)) or not(tonumber(y)) then
          break
        end
        shiori:talk("OnOthelloViewCollision", x, y)
      end
      str:append(shiori:talk("OnOthelloViewCommit"))

      return str
    end,
  },
  {
    id  = "OnOthelloGamePlayerTurnEnd",
    content = function(shiori, ref)
      local str = StringBuffer()
      local othello = shiori:saori("othello")
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      if not(x) or not(y) then
        -- pass
        print("Pass1", othello("teban")())
        othello("pass")
        print("Pass2", othello("teban")())
      else
        othello("put", x, y)
      end
      str:append(shiori:talk("OnOthelloView"))
      str:append(SS():raise("OnOthelloGameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnOthelloGameCpuTurnBegin",
    content = function(shiori, ref)
      local othello = shiori:saori("othello")
      local move  = othello("move", 9)
      print("move", move[0], "score", move[1])
      local x, y  = string.match(move[0], "(%d+),(%d+)")
      return SS():raise("OnOthelloGameCpuTurnEnd", x, y)
    end,
  },
  {
    id  = "OnOthelloGameCpuTurnEnd",
    content = function(shiori, ref)
      local othello = shiori:saori("othello")
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      if not(x) or not(y) then
        assert(false, "invalid ref")
      else
        othello("put", x, y)
      end
      return shiori:talk("OnOthelloView") .. SS():raise("OnOthelloGameTurnBegin")
    end,
  },
  {
    id  = "OnOthelloGameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_InGame", false)
      local str = StringBuffer()
      str:append(shiori:talk("OnOthelloView"))
      str:append("\\0\\s[座り_素]ありがとうございました。")
      local score = __("成績(Othello)")["つよい"]
      score.lose  = score.lose + 1
      return str
    end,
  },
}
