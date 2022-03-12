local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnGomokuGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Gomoku")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      local game_option = __("GomokuGameOption")
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
          SS():raise("OnGomokuGameTurnBegin")
    end,
  },
  {
    id  = "OnGomokuGameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local gomoku = shiori:saori("gomoku")
      local teban = gomoku("teban")()
      local player_color  = __("_PlayerColor")
      local array = {
        Black = 1,
        White = 2,
      }
      if gomoku("isGameOver")() == "True" then
        __("_LatestPut", nil)
        str:append("\\0\\s[座り_素]")
        local ret = gomoku("isGameOver")
        __("_InGame", false)
        local s = {
          ["Black"] = 1,
          ["White"] = 2,
          ["Draw"]  = 3,
        }
        local option  = __("GomokuGameOption")
        local score = __("成績(Gomoku)")[option.cpu_level]
        if s[ret[0]] == __("_PlayerColor") then
          score.win = score.win + 1
          str:append("${User}の勝ちだよ。")
        elseif s[ret[0]] == 3 then
          print("Draw")
          str:append("引き分けだよ。")
        else
          score.lose  = score.lose + 1
          str:append("わたしの勝ちだね。")
        end
        return str
      elseif array[teban] == player_color then
        str:append(SS():raise("OnGomokuGamePlayerTurnBegin"))
      else
        str:append(SS():raise("OnGomokuGameCpuTurnBegin"))
      end
      return str
    end,
  },
  {
    id  = "OnGomokuGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      local gomoku = shiori:saori("gomoku")
      local hits  = gomoku("genHits")

      __("_Gomoku_State", "begin")

      str:append(shiori:talk("OnGomokuView"))

      if tonumber(hits()) == 0 then
        return SS():raise("OnGomokuGamePlayerTurnEnd")
      end

      for i = 0, tonumber(hits()) - 1 do
        local x, y  = string.match(hits[i], "(%d+),(%d+)")
        if not(tonumber(x)) or not(tonumber(y)) then
          break
        end
        shiori:talk("OnGomokuViewCollision", x, y)
      end
      str:append(shiori:talk("OnGomokuViewCommit"))

      return str
    end,
  },
  {
    id  = "OnGomokuGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local gomoku = shiori:saori("gomoku")
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      print("put: ", gomoku("put", x, y)())
      __("_LatestPut", {x = x, y = y})
      str:append(shiori:talk("OnGomokuView"))
      str:append(SS():raise("OnGomokuGameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnGomokuGameCpuTurnBegin",
    content = function(shiori, ref)
      local __      = shiori.var
      local option  = __("GomokuGameOption")
      local gomoku = shiori:saori("gomoku")
      local hit  = gomoku("search", 10000 * option.cpu_level)
      print("hit: ", hit[0], "score", hit[1])
      local x, y  = string.match(hit[0], "(%d+),(%d+)")
      return SS():raise("OnGomokuGameCpuTurnEnd", x, y)
    end,
  },
  {
    id  = "OnGomokuGameCpuTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local gomoku = shiori:saori("gomoku")
      local str = StringBuffer()
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      if not(x) or not(y) then
        assert(false, "invalid ref")
      else
        print("Put: " , gomoku("put", x, y)())
        __("_LatestPut", {x = x, y = y})
      end
      str:append(shiori:talk("OnGomokuView"))
          :append(SS():raise("OnGomokuGameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnGomokuGameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("GomokuGameOption")
      __("_InGame", false)
      local str = StringBuffer()
      str:append(shiori:talk("OnGomokuView"))
      str:append("\\0\\s[座り_素]ありがとうございました。")
      local score = __("成績(Gomoku)")[option.cpu_level]
      score.lose  = score.lose + 1
      return str
    end,
  },
}
