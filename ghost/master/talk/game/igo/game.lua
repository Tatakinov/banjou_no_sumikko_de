local GTP = require("gtp")
local IgoPlayer = require("igo_player")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnIgoGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Igo")
      __("_InGame", true)
      __("_CurrentJudgement", 6) -- Judgement.equality
      __("_SeizaCount", os.time())
      local game_option = __("IgoGameOption")
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
          SS():raise("OnIgoGameTurnBegin")
    end,
  },
  {
    id  = "OnIgoGameTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      local player  = __("_Igo")
      local str = StringBuffer()
      local teban = player:getTeban()
      local player_color  = __("_PlayerColor")
      process("send", id, gtp:tostring(GTP.showboard))
      if player:isGameOver() then
        str:append(SS():raise("OnIgoView"))
        str:append(SS():raise("OnIgoGameCalcScore"))
      elseif teban == player_color then
        str:append(SS():raise("OnIgoView"))
        str:append(SS():raise("OnIgoGamePlayerTurnBegin"))
      else
        str:append(SS():raise("OnIgoView"))
        str:append(SS():raise("OnIgoGameCpuTurnBegin"))
      end
      return str
    end,
  },
  {
    id  = "OnIgoGamePlayerTurnBegin",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer();
      str:append(SS():raise("OnIgoView", "playable"))
      return str
    end,
  },
  {
    id  = "OnIgoGamePlayerTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      local player  = __("_Igo")
      local teban = player:getTeban()
      local x = tonumber(ref[0])
      local y = tonumber(ref[1])
      player:put(x, y)
      __("_LastPut", {x = x, y = y})
      local color = {"black", "white"}
      process("send", id, gtp:tostring(GTP.play, color[teban] .. " " .. GTP.n2pos(x, y)))
      return nil
    end,
  },
  {
    id  = "OnIgoGameCpuTurnBegin",
    content = function(shiori, ref)
      local __      = shiori.var
      local option  = __("IgoGameOption")
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      local player  = __("_Igo")
      local color = {"black", "white"}
      process("send", id, gtp:tostring(GTP.genmove, color[player:getTeban()]))
    end,
  },
  {
    id  = "OnIgoGameCpuTurnEnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = __("_Igo")
      local str = StringBuffer()
      local x = tonumber(ref[0]) or "pass"
      local y = tonumber(ref[1])
      if x == "pass" then
        player:pass()
        str:append([[\0\s[座り_きょとん]パスするよ。]])
      else
        if not(x) or not(y) then
          assert(false, "invalid ref")
        else
          player:put(x, y)
          __("_LastPut", {x = x, y = y})
        end
      end
      str:append(SS():raise("OnIgoGameTurnBegin"))
      return str
    end,
  },
  {
    id  = "OnIgoGamePass",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("IgoGameOption")
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      local player  = __("_Igo")
      local teban = player:getTeban()
      __("_LastPut", nil)
      local color = {"black", "white"}
      player:pass()
      process("send", id, gtp:tostring(GTP.play, color[teban] .. " pass"))
      print("PASS")
    end,
  },
  {
    id  = "OnIgoGameResign",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("IgoGameOption")
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      __("_InGame", false)
      __("_LastPut", nil)
      process("send", id, gtp:tostring(GTP.quit))
      process("despawn", id)
      local str = StringBuffer()
      str:append(shiori:talk("OnIgoView"))
      str:append("\\0\\s[座り_素]ありがとうございました。")
      local score = __("成績(Igo)")["つよい"]
      score.lose  = score.lose + 1
      return str
    end,
  },
  {
    id  = "OnIgoGameCalcScore",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("IgoGameOption")
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      process("send", id, gtp:tostring(GTP.final_score))
      return [[\0\s[座り_素]地の計算をするね。\n時間がかかるから、のんびり待っててね。]]
    end,
  },
  {
    id  = "OnIgoGameOver",
    content = function(shiori, ref)
      local __  = shiori.var
      local option  = __("IgoGameOption")
      local process = shiori:saori("process")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      __("_InGame", false)
      __("_LastPut", nil)
      process("send", id, gtp:tostring(GTP.quit))
      process("despawn", id)
      local str = StringBuffer()
      str:append("\\0\\s[座り_素]")
      __("_InGame", false)
      local result  = string.sub(ref[0], 1, 1)
      local color = {
        B = 1,
        W = 2,
      }
      local option  = __("IgoGameOption")
      local score = __("成績(Igo)")["つよい"]
      print("Result:", color[result])
      if result == "0" then
        print("Draw")
        str:append("引き分けだよ。")
      elseif color[result] == __("_PlayerColor") then
        score.win = score.win + 1
        local diff  = string.sub(ref[0], 3)
        str:append(string.format("${User}の%s目勝ちだよ。", diff))
      else
        score.lose  = score.lose + 1
        local diff  = string.sub(ref[0], 3)
        str:append(string.format("わたしの%s目勝ちだね。", diff))
      end
      return str
    end,
  },
}
