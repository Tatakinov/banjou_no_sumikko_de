local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnQuoridorGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Quoridor")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      local game_option = __("QuoridorGameOption")
      if game_option.player_color == "random" then
        if math.random(1, 2) == 2 then
          __("_PlayerColor", 1)
        else
          __("_PlayerColor", 2)
        end
      else
        __("_PlayerColor", game_option.player_color)
      end
      if __("_PlayerColor") == 2 then
        __("_BoardReverse", true)
      else
        __("_BoardReverse", false)
      end
      return "\\0\\s[座り_きょとん]よろしくお願いします。\\_w[1000]\\s[座り_素]" ..
          SS():raise("OnQuoridorGameTurnBegin")
    end,
  },
  {
    id  = "OnQuoridorGameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local quoridor  = shiori:saori("quoridor")
      local player_color  = __("_PlayerColor")
      local option  = __("QuoridorGameOption")
      local teban = quoridor("teban")()
      local array = {
        ["Player1"] = 1,
        ["Player2"] = 2,
        ["Player3"] = 3,
        ["Player4"] = 4,
      }

      local ret = quoridor("isGameOver")
      if ret() == "True" then
        __("_InGame", false)
        local score = __("成績(Quoridor)")[option.cpu_level]
        local str = StringBuffer()
        str:append("\\0\\s[座り_素]")
        if array[ret[0]] == player_color then
          str:append("${User}の勝ちだよ。")
          score.win = score.win + 1
        else
          str:append("わたしの勝ちだね。")
          score.lose  = score.lose + 1
        end
        return str
      end

      if array[teban] == player_color then
        return SS():raise("OnQuoridorGamePlayerTurnBegin")
      else
        return SS():raise("OnQuoridorGameCpuTurnBegin")
      end
    end,
  },
  {
    id  = "OnQuoridorGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      local quoridor  = shiori:saori("quoridor")

      __("_Quoridor_State", "begin")

      str:append(shiori:talk("OnQuoridorView"))

      local pos = quoridor("getPlayerPos")
      shiori:talk("OnQuoridorViewCollision", pos[0], pos[1])

      local puttable  = quoridor("puttableHBar")
      for i = 0, tonumber(puttable()) - 1 do
        shiori:talk("OnQuoridorViewCollisionHBar", puttable[i])
      end

      local puttable  = quoridor("puttableVBar")
      for i = 0, tonumber(puttable()) - 1 do
        shiori:talk("OnQuoridorViewCollisionVBar", puttable[i])
      end

      str:append(shiori:talk("OnQuoridorViewCommit"))

      return str
    end,
  },
  {
    id  = "OnQuoridorGamePlayerTurnSelectPiece",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      local quoridor  = shiori:saori("quoridor")

      __("_Quoridor_State", "select")

      str:append(shiori:talk("OnQuoridorView"))

      local moves = quoridor("genMoves")
      for i = 0, tonumber(moves()) - 1 do
        local x, y  = string.match(moves[i], "(%d+),(%d+)")
        shiori:talk("OnQuoridorViewCollision", x, y)
        shiori:talk("OnQuoridorViewHighlight", x, y)
      end

      str:append(shiori:talk("OnQuoridorViewCommit"))

      return str
    end,
  },
  {
    id  = "OnQuoridorGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local quoridor  = shiori:saori("quoridor")
      local str = StringBuffer()
      local action = ref[0]
      local x = tonumber(ref[1])
      local y = tonumber(ref[2])
      local t = ref[3]

      __("_QuoridorState", "end")

      if action == "move" then
        quoridor("move", x, y)
      elseif action == "put" then
        quoridor("put", x, y, t)
      end
      str:append(shiori:talk("OnQuoridorView"))
      str:append(SS():raise("OnQuoridorGameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnQuoridorGameCpuTurnBegin",
    content = function(shiori, ref)
      local __      = shiori.var
      local option  = __("QuoridorGameOption")
      local quoridor  = shiori:saori("quoridor")
      local ret = quoridor("search", option.cpu_level)
      local x, y    = string.match(ret[0], "(%d+),(%d+)")
      if ret() == "put" then
        return SS():raise("OnQuoridorGameCpuTurnEnd", ret(), x, y, ret[1])
      else
        return SS():raise("OnQuoridorGameCpuTurnEnd", ret(), ret[0])
      end
    end,
  },
  {
    id  = "OnQuoridorGameCpuTurnEnd",
    content = function(shiori, ref)
      local quoridor  = shiori:saori("quoridor")
      local action  = ref[0]
      local x       = ref[1]
      local y       = ref[2]
      local t       = ref[3]
      if action == "put" then
        quoridor("put", x, y, t)
      else
        quoridor("move", x, y)
      end
      return shiori:talk("OnQuoridorView") .. SS():raise("OnQuoridorGameTurnBegin")
    end,
  },
  {
    id  = "OnQuoridorGameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_InGame", false)
      local game_option = __("QuoridorGameOption")
      local str = StringBuffer()
      str:append(shiori:talk("OnQuoridorView"))
      str:append("\\0\\s[座り_素]ありがとうございました。")
      local score = __("成績(Quoridor)")[game_option.cpu_level]
      score.lose  = score.lose + 1
      return str
    end,
  },
}
