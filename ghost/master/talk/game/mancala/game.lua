

return {
  {
    id  = "OnMancalaGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      local game_option = __("MancalaGameOption")
      __("_Quiet", "Mancala")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      if game_option.player_color == "random" then
        local color = math.random(2)
        __("_MancalaColor", color)
        if color == 1 then
          return [=[\0\s[座り_素]${User}が先手だよ。\nよろしくお願いします。\![raise,OnMancalaGameTurnBegin]]=]
        else
          return [=[\0\s[座り_素]わたしが先手だね。\nよろしくお願いします。\![raise,OnMancalaGameTurnBegin]]=]
        end
      else
        __("_MancalaColor", game_option.player_color)
        return [=[\0\s[座り_素]よろしくお願いします。\![raise,OnMancalaGameTurnBegin]]=]
      end
    end,
  },
  {
    id  = "OnMancalaGameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local mancala = __("_Mancala")
      local sum = 0
      for i = 1, 6 do
        sum = sum + mancala:get(mancala:teban(), i)
      end
      if sum == 0 then
        return [=[\![raise,OnMancalaView]\![raise,OnMancalaGameEnd]]=]
      end
      if __("_MancalaColor") == mancala:teban() then
        return [=[\![raise,OnMancalaGamePlayerTurnBegin]]=]
      else
        return [=[\![raise,OnMancalaGameCpuTurnBegin]]=]
      end
    end,
  },
  {
    id  = "OnMancalaGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_MancalaState", "no_select")
      __("_MancalaIndex", 0)
      return [=[\![raise,OnMancalaView,playable]]=]
    end,
  },
  {
    id  = "OnMancalaGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local mancala = __("_Mancala")
      mancala:lap(__("_MancalaIndex"))
      return [=[\![raise,OnMancalaView]\![raise,OnMancalaGameTurnBegin]]=]
    end,
  },
  {
    id  = "OnMancalaGameCpuTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local saori = shiori:saori("mancala")
      local mancala = __("_Mancala")
      local game_option = __("MancalaGameOption")
      saori("position", mancala:dump())
      local ret = saori("search", game_option.cpu_level)
      print(string.format("eval: %s move: %s", ret[0], ret()))
      mancala:lap(tonumber(ret()))
      return [=[\![raise,OnMancalaView]\![raise,OnMancalaGameTurnBegin]]=]
    end,
  },
  {
    id  = "OnMancalaGameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_InGame", false)
      local score_list  = __("成績(Mancala)")
      local score = score_list["Kalah"]
      score.lose  = score.lose + 1
      return [[\0\s[座り_素]対局ありがとうございました。]]
    end,
  },
  {
    id  = "OnMancalaGameEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local mancala = __("_Mancala")
      local c = __("_MancalaColor")
      __("_InGame", false)
      local score_list  = __("成績(Mancala)")
      local score = score_list["Kalah"]
      if mancala:getStore(c) > mancala:getStore(mancala:reverse(c)) then
        -- ユーザ勝ち
        score.win = score.win + 1
        return [[\0\s[座り_素]${User}の勝ちだよ。]]
      elseif mancala:getStore(c) < mancala:getStore(mancala:reverse(c)) then
        score.lose  = score.lose + 1
        -- ユーザ負け
        return [[\0\s[座り_素]対局ありがとうございました。]]
      else
        -- 引き分け
        return [[\0\s[座り_素]引き分けだよ。]]
      end
    end,
  },
}
