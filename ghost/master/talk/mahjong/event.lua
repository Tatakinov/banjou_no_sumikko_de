-- jong-rinrinのコードを参考にしています。

local AI          = require("talk.mahjong._ai")
local Judgement   = require("talk.game._judgement")
local SS          = require("sakura_script")
local Utils       = require("talk.mahjong._utils")

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
  chi     = "chi",
  pon     = "pon",
  kan     = "kan",
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

local function isSSTP(header)
  local is_sstp = false
  if header == nil then
    return false
  end
  for w in string.gmatch(header, "[^,]*") do
    if w == "sstp" then
      is_sstp = true
      break
    end
  end
  return is_sstp
end

local function wrapResponse(ref, ...)
  if isSSTP(ref("SenderType")) then
    local response  = {
      ["X-SSTP-PassThru-ID"]  = RESPONSE_ID,
      ["X-SSTP-PassThru-Reference0"]  = VERSION,
      ["X-SSTP-PassThru-Reference1"]  = ref[1],
    }
    local arg = {...}
    for i, v in ipairs(arg) do
      response["X-SSTP-PassThru-Reference" .. (i + 1)]  = v
    end
    return response
  else
    return SS():raiseother(ref("Sender"), RESPONSE_ID, VERSION, ref[1],
      table.concat({...}, ",")):tostring()
  end
end

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
      return wrapResponse(ref, "ump=" .. UMP_VERSION, "name=" .. NAME)
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
      local t = {}
      for i = 2, 5 do
        local name, score = string.match(ref[i], "([^\x01]*)\x01([^\x01]*)")
        print("name", name, "score", score)
        score = tonumber(score)
        table.insert(t, {name = name, score = score})
      end
      table.sort(t, function(a, b) return a.score > b.score end)
      if t[1].name == NAME then
        return [[
\0\s[座り_ドヤッ]どやぁ…。
]], [[
\0\s[座り_ドヤッ]ふふん。
]]
      elseif t[4].name == NAME then
        return [[
\0\s[座り_もー]も”っか”い”！！
]]
      else
        return [[
\0\s[座り_素]対局ありがとうございました。
]]
      end
    end,
  },
  {
    id  = "OnMahjong_kyokustart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Mahjong_Kawa", {})
      __("_Mahjong_Furo", {})
      __("_Mahjong_Riichi_Others", {})
      __("_Mahjong_Safe", {})
      __("_Mahjong_DoraIndicator", {})
      __("_Mahjong_Bafu", ref[2])
      local jifu  = __("_Mahjong_Jifu")
      __("_Mahjong_Jifu", JIFU[jifu])
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
        if diff >= 8000 then
          return [[
\0\s[形勢_勝勢]いぇす！
]], [[
\0\s[形勢_勝勢]日頃の行いの結果かな！
]]
        else
          return [[
\0\s[形勢_優勢]順調順調♪
]], [[
\0\s[形勢_優勢]よしよし。
]]
        end
      elseif ref[3] == "-" then
        local diff  = tonumber(ref[4])
        __("_Mahjong_Score", score - diff)
        if diff >= 8000 then
          return [[
\0\s[形勢_負け]がーん…。
]], [[
\0\s[形勢_負け]貴重な点棒がー…。
]], [[
\0\s[形勢_負け]いやぁぁ…。
]]
        else
          return [[
\0\s[形勢_敗勢]あぅ…。
]], [[
\0\s[形勢_敗勢]ぎゃふん。
]], [[
\0\s[形勢_敗勢]ひえー！
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
      local t = __("_Mahjong_DoraIndicator")
      table.insert(t, ref[2])
      return nil
    end,
  },
  {
    id  = "OnMahjong_open",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[2] == NAME then
      else
        local furo  = __("_Mahjong_Furo")
        if furo[ref[2]] == nil then
          furo[ref[2]]  = {}
        end
        print("Furo", ref[3])
        print("Sutehai", __("_Mahjong_Sutehai"))
        local tiles = Utils.strToArray(ref[3])
        for i, v in ipairs(tiles) do
          if v == __("_Mahjong_Sutehai") then
            table.remove(tiles, i)
            break
          end
        end
        for i, v in ipairs(tiles) do
          print("Furo" .. i, v)
          table.insert(furo[ref[2]], v)
        end
      end
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
      __("_Mahjong_Remain", tonumber(ref[3]))
      return nil
    end,
  },
  {
    id  = "OnMahjong_sutehai",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Mahjong_Sutehai", ref[3])
      local kawa  = __("_Mahjong_Kawa")
      table.insert(kawa, ref[3])
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
      local sutehai, riichi, tsumo = AI.getBestSutehai(
          shiori:saori("mahjong"),
          table.concat(tehai, ""),
          __("_Mahjong_Kawa"),
          __("_Mahjong_Bafu"),
          __("_Mahjong_Jifu"),
          __("_Mahjong_DoraIndicator"),
          __("_Mahjong_Furo"),
          __("_Mahjong_Safe"),
          __("_Mahjong_Riichi_Others")
      )
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
        return wrapResponse(ref, ACTION.tsumo)
      end
      if __("_Mahjong_Riichi") then
        sutehai = __("_Mahjong_Tsumo")
        riichi  = false
      end
      if __("_Mahjong_Remain") <= 4 then
        __("_Mahjong_Riichi", true)
        riichi  = false
      end
      print("sutehai", sutehai)
      if riichi then
        print("riichi!")
        return wrapResponse(ref, ACTION.riichi, sutehai)
      elseif sutehai then
        return wrapResponse(ref, ACTION.sutehai, sutehai)
      else
        return wrapResponse(ref)
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
        return wrapResponse(ref, ACTION.ron)
      else
        return wrapResponse(ref, ACTION.no)
      end
    end,
  },
  {
    id  = "OnMahjong_tenpai?",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Mahjong_Riichi") then
        return wrapResponse(ref, ACTION.yes)
      else
        return wrapResponse(ref, ACTION.no)
      end
    end,
  },
  {
    id  = "OnMahjong_say",
    content = function(shiori, ref)
      local __  = shiori.var
      if ref[2] == NAME then
        if ref[3] == ACTION.riichi then
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
        if ref[3] == ACTION.riichi then
          local riichi    = __("_Mahjong_Riichi_Others")
          local kawa      = __("_Mahjong_Kawa")
          -- リーチの情報は捨て牌の情報よりも先に送られてくるので
          -- +1 しないといけない
          riichi[ref[2]]  = #kawa + 1
          local tmp ={}
          for _, v in ipairs(kawa[ref[2]] or {}) do
            tmp[v]  = 1
          end
          local t = __("_Mahjong_Safe")
          if t[ref[2]] == nil then
            t[ref[2]] = {}
          end
          for k, _ in pairs(tmp) do
            table.insert(t[ref[2]], k)
          end
        end
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
