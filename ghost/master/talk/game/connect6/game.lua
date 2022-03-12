local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnConnect6GameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Connect6")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      local game_option = __("Connect6GameOption")
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
          SS():raise("OnConnect6GameTurnBegin")
    end,
  },
  {
    id  = "OnConnect6GameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local connect6 = shiori:saori("connect6")
      local teban = connect6("teban")()
      local player_color  = __("_PlayerColor")
      local array = {
        Black = 1,
        White = 2,
      }
      if connect6("isGameOver")() == "True" then
        __("_LatestPut", nil)
        str:append("\\0\\s[座り_素]")
        local ret = connect6("isGameOver")
        __("_InGame", false)
        local s = {
          ["Black"] = 1,
          ["White"] = 2,
          ["Draw"]  = 3,
        }
        local option  = __("Connect6GameOption")
        local score = __("成績(Connect6)")[option.cpu_level]
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
        str:append(SS():raise("OnConnect6GamePlayerTurnBegin"))
      else
        str:append(SS():raise("OnConnect6GameCpuTurnBegin"))
      end
      return str
    end,
  },
  {
    id  = "OnConnect6GamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      local connect6 = shiori:saori("connect6")
      local hits  = connect6("genHits")

      __("_Connect6_State", "begin")

      str:append(shiori:talk("OnConnect6View"))

      if tonumber(hits()) == 0 then
        return SS():raise("OnConnect6GamePlayerTurnEnd")
      end

      for i = 0, tonumber(hits()) - 1 do
        local x, y  = string.match(hits[i], "(%d+),(%d+)")
        if not(tonumber(x)) or not(tonumber(y)) then
          break
        end
        shiori:talk("OnConnect6ViewCollision", x, y)
      end
      str:append(shiori:talk("OnConnect6ViewCommit"))

      return str
    end,
  },
  {
    id  = "OnConnect6GamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local connect6 = shiori:saori("connect6")
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      print("put: ", connect6("put", x, y)())
      __("_LatestPut", {x = x, y = y})
      str:append(shiori:talk("OnConnect6View"))
      str:append(SS():raise("OnConnect6GameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnConnect6GameCpuTurnBegin",
    content = function(shiori, ref)
      local __      = shiori.var
      local option  = __("Connect6GameOption")
      local connect6 = shiori:saori("connect6")
      local hit  = connect6("search", 10000 * option.cpu_level)
      print("hit: ", hit[0], "score", hit[1])
      local x, y  = string.match(hit[0], "(%d+),(%d+)")
      return SS():raise("OnConnect6GameCpuTurnEnd", x, y)
    end,
  },
  {
    id  = "OnConnect6GameCpuTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local connect6 = shiori:saori("connect6")
      local str = StringBuffer()
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      if not(x) or not(y) then
        assert(false, "invalid ref")
      else
        print("Put: " , connect6("put", x, y)())
        __("_LatestPut", {x = x, y = y})
      end
      str:append(shiori:talk("OnConnect6View"))
          :append(SS():raise("OnConnect6GameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnConnect6GameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("Connect6GameOption")
      __("_InGame", false)
      local str = StringBuffer()
      str:append(shiori:talk("OnConnect6View"))
      str:append("\\0\\s[座り_素]ありがとうございました。")
      local score = __("成績(Connect6)")[option.cpu_level]
      score.lose  = score.lose + 1
      return str
    end,
  },
}
