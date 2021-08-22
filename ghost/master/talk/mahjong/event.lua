-- jong-rinrinのコードを参考にしています。

local AI          = require("talk.mahjong._ai")
local Judgement   = require("talk.game._judgement")
local SS          = require("sakura_script")

local TIMEOUT     = 1.950

local VERSION     = "UKAJONG/0.2"
local RESPONSE_ID = "OnMahjongResponse"
local NAME        = "小宮由希"
local UMP_VERSION = "?"
local ACTION      = {
  sutehai = "sutehai",
  riichi  = "richi",
  yes     = "yes",
  no      = "no",
  ron     = "ron",
  tsumo   = "tsumo",
}

local JIFU  = {
  ["東"]  = "4z",
  ["南"]  = "1z",
  ["西"]  = "2z",
  ["北"]  = "3z",
  ["1z"]  = "2z",
  ["2z"]  = "3z",
  ["3z"]  = "4z",
  ["4z"]  = "1z",
}

return {
  {
    id  = "OnMahjong",
    content = function(shiori, ref)
      return shiori:talk("OnMahjong_" .. ref[1], ref)
    end,
  },
  {
    id  = "OnMahjong_hello",
    content = function(shiori, ref)
      local __  = shiori.var
      return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1],
          "ump=" .. UMP_VERSION, "name=" .. NAME)
    end,
  },
  {
    id  = "OnMahjong_gamestart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Mahjong")
      __("_InGame", true)
      __("_Mahjong_Jifu", JIFU[ref[2]])
      shiori:talk("OnSetFanID")
      return [[
\0\s[座り_素]よろしくお願いします。
]]
    end,
  },
  {
    id  = "OnMahjong_gameend",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", false)
      __("_InGame", false)
      return [[
\0\s[座り_素]対局ありがとうございました。
]]
    end,
  },
  {
    id  = "OnMahjong_kyokustart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Mahjong_Kawa", {})
      __("_Mahjong_Bafu", ref[2])
      local jifu  = __("_Mahjong_Jifu")
      __("_Mahjong_Jifu", JIFU[jifu])
      __("_Mahjong_Kawa", {})
      __("_Mahjong_Riichi", false)
      __("_CurrentJudgement", Judgement.equality)
      return [[
\0\s[考慮中_互角]
]]
    end,
  },
  {
    id  = "OnMahjong_kyokuend",
    content = function(shiori, ref)
      return nil
    end,
  },
  {
    id  = "OnMahjong_point",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[2] ~= NAME then
        return nil
      end
      local score = __("_Mahjong_Score") or 0
      if ref[3] == "=" then
        __("_Mahjong_Score", tonumber(ref[4]))
      elseif ref[3] == "+" then
        local diff  = tonumber(ref[4])
        __("_Mahjong_Score", score + diff)
        return [[
\0\s[形勢_勝勢]
]]
      elseif ref[3] == "-" then
        local diff  = tonumber(ref[4])
        __("_Mahjong_Score", score - diff)
        if diff >= 8000 then
          return [[
\0\s[形勢_負け]
]]
        else
          return [[
\0\s[形勢_敗勢]
]]
        end
      end
    end,
  },
  {
    id  = "OnMahjong_haipai",
    content = function(shiori, ref)
      local __  = shiori.var
      local t   = {}
      for tile in string.gmatch(ref[3], "%w%w") do
        table.insert(t, tile)
      end
      __("_Mahjong_Tehai", t)
      return nil
    end,
  },
  {
    id  = "OnMahjong_dora",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Mahjong_DoraIndicator", ref[2])
      return nil
    end,
  },
  {
    id  = "OnMahjong_open",
    content = function(shiori, ref)
      return nil
    end,
  },
  {
    id  = "OnMahjong_tsumo",
    content = function(shiori, ref)
      local __  = shiori.var
      local tehai = __("_Mahjong_Tehai")
      table.insert(tehai, ref[4])
      print("tsumo", ref[4])
      __("_Mahjong_Tsumo", ref[4])
      return nil
    end,
  },
  {
    id  = "OnMahjong_sutehai",
    content = function(shiori, ref)
      local __  = shiori.var
      local kawa  = __("_Mahjong_Kawa")
      if kawa[ref[2]] == nil then
        kawa[ref[2]]  = {}
      end
      table.insert(kawa[ref[2]], ref[3])
      if ref[2] ~= NAME then
        return nil
      end
      local tehai = __("_Mahjong_Tehai")
      -- 手牌から捨てる
      for i, v in ipairs(tehai) do
        if v == ref[3] then
          table.remove(tehai, i)
          break
        end
      end
      return nil
    end,
  },
  {
    id  = "OnMahjong_sutehai?",
    content = function(shiori, ref)
      local __  = shiori.var
      local tehai = __("_Mahjong_Tehai")
      table.sort(tehai, function(a, b)
        return string.reverse(a) < string.reverse(b)
      end)
      print("Tehai:", table.concat(tehai, ""))
      local start   = os.clock()
      local sutehai, riichi, tsumo = AI.getBestSutehai(shiori:saori("mahjong"), table.concat(tehai, ""), __("_Mahjong_Kawa"), __("_Mahjong_Bafu"), __("_Mahjong_Jifu"), __("_Mahjong_DoraIndicator"))
      local finish  = os.clock()
      -- CPU時間での計算だがシングルスレッドなのでほぼ実時間…？
      if TIMEOUT < finish - start then
        -- サーバー側がタイムアウトと認識してレスポンスを無視するが、
        -- うっかり次の巡目の時に送ってしまったらまずいので
        -- 送るのを抑制する。
        print("Timeout")
        return nil
      end
      if tsumo then
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.tsumo)
      end
      if __("_Mahjong_Riichi") then
        sutehai = __("_Mahjong_Tsumo")
        riichi  = false
      end
      print("sutehai", sutehai)
      if riichi then
        print("riichi!")
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.riichi, sutehai)
      elseif sutehai then
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.sutehai, sutehai)
      else
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1])
      end
    end,
  },
  {
    id  = "OnMahjong_naku?",
    content = function(shiori, ref)
      -- TODO stub
      local has_ron = false
      for i = 2, #ref do
        if ref[i] == "ron" then
          has_ron = true
          break
        end
      end
      if has_ron then
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.ron)
      else
        return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.no)
      end
    end,
  },
  {
    id  = "OnMahjong_tenpai?",
    content = function(shiori, ref)
      return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1], ACTION.yes)
    end,
  },
  {
    id  = "OnMahjong_say",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[2] == NAME then
        if ref[3] == "richi" then
          -- サーバー側のAIでリーチした場合ここで捉えるしかない？
          print("riichi!")
          __("_Mahjong_Riichi", true)
        end
        local str = {
          chi     = [[チー]],
          pon     = [[ポン]],
          kan     = [[カン]],
          ron     = [[ロン！]],
          tsumo   = [[ツモ！]],
          richi   = [[リーチ！]],
          tenpai  = [[テンパイ]],
          noten   = [[ノーテン]],
        }
        return [[\0]] .. str[ref[3]]
      else
        -- TODO stub
        return nil
      end
    end,
  },
  {
    id  = "OnMahjong_agari",
    content = function(shiori, ref)
      return nil
    end,
  },
  {
    id  = "OnMahjong_ryukyoku",
    content = function(shiori, ref)
      return nil
    end,
  },
}
