local KifuPlayer  = require("kifu_player")
local Misc  = require("shiori.misc")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local function getMouseID(ref)
  local p = ref[3]
  local collision = ref[4]
  local button  = tonumber(ref[5]) or -1
  local n2str = {
    [0] = "Left",
    [1] = "Right",
    [2] = "Middle",
  }
  local id  = StringBuffer()
  if p then
    id:append(p)
  end
  if collision then
    id:append(collision)
  end
  if n2str[button] then
    id:append(n2str[button])
  end
  if id:strlen() > 0 then
    return id:tostring()
  end
  return nil
end

return {
  {
    id      = "OnFirstBoot",
    content = function(shiori, ref)
      return shiori:talk("初回起動")
    end,
  },
  {
    id      = "OnBoot",
    content = function(shiori, ref)
      local talk  = shiori:talk("起動時イベント")
      if talk then
        return talk
      end
      local talk  = shiori:talk("日付イベント")
      if talk then
        return talk
      end
      return shiori:talk("通常起動")
    end,
  },
  {
    id      = "OnClose",
    content = function(shiori, ref)
      return shiori:talk("通常終了")
    end,
  },
  {
    id      = "OnGhostChanged",
    content = function(shiori, ref)
      local talk  = shiori:talk(ref[0] .. "から交代", ref)
      if talk then
        return talk
      end
      return nil
    end,
  },
  {
    id      = "OnGhostChanging",
    content = function(shiori, ref)
      local talk  = shiori:talk(ref[0] .. "に交代", ref)
      if talk then
        return talk
      end
      return nil
    end,
  },
  {
    id      = "OnGhostCalled",
    content = function(shiori, ref)
      local talk  = shiori:talk(ref[0] .. "から呼ばれる", ref)
      if talk then
        return talk
      end
      return nil
    end,
  },
  {
    id      = "OnGhostCalling",
    content = function(shiori, ref)
      local talk  = shiori:talk(ref[0] .. "を呼ぶ", ref)
      if talk then
        return talk
      end
      return nil
    end,
  },
  {
    id      = "OnCommunicate",
    content = function(shiori, ref)
      if ref[0] == "user" and ref[1] ~= nil then
        return shiori:talk(ref[1] .. "_communicate")
      end
    end,
  },
  {
    id      = "OnUserInput",
    content = function(shiori, ref)
      return shiori:talk(ref[0] .. "の入力", ref[1])
    end,
  },
  {
    id      = "OnSystemDialogCancel",
    content = function(shiori, ref)
      return SS():raise(ref[1], "cancel", nil, nil, ref[0])
    end,
  },
  {
    id      = "OnSecondChange",
    content = function(shiori, ref)
      local __  = shiori.var
      local prev_count  = __("_PrevNadeCount") or 0
      local count = __("_NadeCount") or 0
      if prev_count == count then
        __("_NadeCount", 0)
      end
      __("_PrevNadeCount", count)

      if tonumber(ref[3]) == 0 then
        __("_RandomTalkCount", 0)
        return nil
      end

      if __("_InGame") then
        local player  = KifuPlayer.getInstance()
        if __("_GameTesuu") ~= player:getTesuu() then
          __("_GameTesuu", player:getTesuu())
          __("_FanCount", math.random(1, 10) + 20)
        end
        local count = __("_FanCount") or 0
        count = count - 1
        __("_FanCount", count)
        if count == 0 then
          __("_FanCount", math.random(1, 10) + 20)
          return shiori:talk("OnFan")
        end
      end
      if __("_Quiet") then
        __("_RandomTalkCount", 0)
      else
        local count = __("_RandomTalkCount") or 0
        count = count + 1
        if count >= (__("TalkInterval") or 180) then
          __("_RandomTalkCount", 0)
          return shiori:talkRandom()
        end
        __("_RandomTalkCount", count)
      end
    end,
  },
  {
    id      = "OnChoiceSelect",
    content = function(shiori, ref)
      return shiori:talk(ref[0], ref)
    end,
  },
  {
    id      = "OnAnchorSelect",
    content = function(shiori, ref)
      return shiori:talk(ref[0], ref)
    end,
  },
  {
    id      = "OnMouseClick",
    content = function(shiori, ref)
      local id  = getMouseID(ref)
      if id then
        return shiori:talk(id, ref)
      end
    end,
  },
  {
    id      = "OnMouseDoubleClick",
    content = function(shiori, ref)
      ref[5]  = nil -- 左クリック以外でダブルクリックする機会はなさそうなので。
      local id  = getMouseID(ref)
      if id then
        return shiori:talk(id .. "Poke", ref)
      end
    end,
  },
  {
    id      = "OnMouseMove",
    content = function(shiori, ref)
      local __  = shiori.var
      local p = ref[3] or ""
      local c = ref[4] or ""
      local prev  = __("_PrevNadeCollision")
      local count = __("_NadeCount") or 0
      local current = p .. c
      __("_PrevNadeCollision", current)
      if prev == current then
        count = count + 1
        __("_NadeCount", count)
      else
        __("_NadeCount", 0)
      end
      if #current > 0 and (count + 1) % 30 == 0 then
        return shiori:talk("OnMouseNade", p, c, count)
      end
    end,
  },
  {
    id  = "OnMouseNade",
    content = function(shiori, ref)
      local p = ref[0] or ""
      local c = ref[1] or ""
      local n = tonumber(ref[2]) or 0
      print(p .. c .. "Nade" .. n)
      return shiori:talk(p .. c .. "なで")
    end,
  },
  {
    id      = "OnMouseEnter",
    content = function(shiori, ref)
      local id  = getMouseID(ref)
      if id then
        return shiori:talk("OnMouseEnter" .. id, ref)
      end
    end,
  },
  {
    id      = "OnMouseLeave",
    content = function(shiori, ref)
      local id  = getMouseID(ref)
      if id then
        return shiori:talk("OnMouseLeave" .. id, ref)
      end
    end,
  },
  {
    id      = "OnInstallBegin",
    content = [[
\0
何かインストールするの？
]],
  },
  {
    id      = "OnInstallComplete",
    content = function(shiori, ref)
      if ref[0] == "supplement" and ref[1] == "「盤上の隅っこで」用思考エンジン" then
        return shiori:talk("OnInitializeGameEngine")
      end
      return [[\0]] .. ref[1] .. [[
のインストールが完了したよ。
]]
    end,
  },
  {
    id      = "OnInstallFailure",
    content = function(shiori, ref)
      return [[\0インストールに失敗したみたい。(]] .. tostring(ref[0]) .. ")"
    end,
  },
  {
    id      = "OnInstallRefuse",
    content = function(shiori, ref)
      return [[\0]] .. ref[0] .. [[さんの物みたい。]]
    end,
  },
  {
    id      = "OnUpdateBegin",
    content = [[
\0
アップデートを開始するよ。]],
  },
  {
    id      = "OnUpdateReady",
    content = [[
\0
更新があったみたい。]],
  },
  {
    id      = "OnUpdateComplete",
    content = function(shiori, ref)
      if ref[0] == "changed" then
        return [=[\![reload,ghost]]=]
      else
        return [[\0更新は無かったみたい。]]
      end
    end,
  },
  {
    id      = "OnUpdateFailure",
    content = function(shiori, ref)
      return [[\0アップデートに失敗したよ。(]] .. tostring(ref[0]) .. ")"
    end,
  },
  {
    id      = "OnKeyPress",
    content = function(shiori, ref)
      return shiori:talk(ref[0] .. "_Key", ref)
    end,
  },
  {
    id      = "OnSurfaceRestore",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_InGame") then
        return nil
      elseif __("_Quiet") then
        return nil
      end
      if __("_KeepBoardVisible") then
        return SS():p(0):s("素")
      else
        return SS():p(0):s("素"):p(2):s(-1):p(3):s(-1)
      end
    end,
  },
  {
    id  = "OnLanguageChange",
    content = function(shiori, ref)
      local __  = shiori.var
      print("lang", ref[0])
      print("lang", ref[1])
      __("_Language", ref[0])
      shiori:setLanguage(ref[0])
    end,
  },
}

