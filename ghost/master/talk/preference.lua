local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnPreference",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()

      if ref[0] == "描画モード" then
        __(ref[0], 3 - __(ref[0]))  -- 1, 2の反転
        shiori:talk("OnShogiRenderChangeMode", __(ref[0]))
      end

      if ref[0] == "描画情報のクリア" then
        __("_Sfen", nil)
      end

      local strength  = __("Strength") or "不明"
      if ref[0] == "棋力" then
        local strength_array  = {
          "無", "入門",
          "初級", "中級", "上級",
          "有段", "高段",
          "観る将", "不明",
        }
        local index
        for i, v in ipairs(strength_array) do
          if strength == v then
            index = i
          end
        end
        assert(index)
        index = index % #strength_array + 1
        strength  = strength_array[index]
        __("Strength", strength)
      end

      local interval  = __("TalkInterval") or 60
      if ref[0] == "喋る間隔" then
        local interval_array  = {
          60, 120, 180,
        }
        local index
        for i, v in ipairs(interval_array) do
          if interval == v then
            index = i
          end
        end
        assert(index)
        index = index % #interval_array + 1
        interval  = interval_array[index]
        __("TalkInterval", interval)
      end

      str:append(shiori:talk("OnPreferenceText"))

      return str
    end,
  },
  {
    id  = "OnPreferenceText",
    content = function(shiori, ref)
      local __  = shiori.var
      local strength  = __("Strength")
      local interval  = __("TalkInterval") or 60
      local str       = StringBuffer()
      str:append([[
\0
\_q
\n
\n
\n
]])
      local mode_str  = {"高速(不安定)", "低速(安定)"}
      str:append([=[\![*]盤面の描画モード\_l[120,]]=])
      str:append(SS():q(mode_str[__("描画モード")], "OnPreference", "描画モード"))
      str:append(SS():n())

      str:append([=[\![*]]=])
      str:append(SS():q("盤面の描画情報のクリア(b)", "OnPreference", "描画情報のクリア"))
      str:append(SS():n())

      str:append([=[\![*]あなたの棋力\_l[120,]]=])
      str:append(SS():q(strength, "OnPreference", "棋力"))
      str:append(SS():n())

      str:append([=[\![*]喋る間隔\_l[120,]]=])
      str:append(SS():q(interval .. "秒", "OnPreference", "喋る間隔"))
      str:append(SS():n())

      str:append([[
\n
\![*]\q[戻る,メニュー] \![*]\q[閉じる,閉じる]
\_q
\_l[0,0]
設定の変更が行えるよ。
]])
      print("Test", tostring(str))
      return str
    end,
    content_English = function(shiori, ref)
      local __  = shiori.var
      local strength  = __("Strength")
      local strength_str  = {
        ["無"]      = "None",
        ["入門"]    = "15 Kyu",
        ["初級"]    = "10 Kyu",
        ["中級"]    = " 5 Kyu",
        ["上級"]    = " 2 Kyu",
        ["有段"]    = " 2 Dan",
        ["高段"]    = " 5 Dan",
        ["観る将"]  = "spectator",
        ["不明"]    = "unknown",
      }
      local interval  = __("TalkInterval") or 60
      local str = StringBuffer()
      str:append([[
\0
\_q
\n
\n
\n
]])
      local mode_str  = {"Fast(unstable)", "Slow(stable)"}
      str:append([=[\![*]Render mode\_l[160,]]=])
      str:append(SS():q(mode_str[__("描画モード")], "OnPreference", "描画モード"))
      str:append(SS():n())

      str:append([=[\![*]]=])
      str:append(SS():q("Clear render info(b)", "OnPreference", "描画情報のクリア"))
      str:append(SS():n())

      str:append([=[\![*]Your shogi strength\_l[160,]]=])
      str:append(SS():q(strength_str[strength], "OnPreference", "棋力"))
      str:append(SS():n())

      str:append([=[\![*]Talk interval\_l[160,]]=])
      str:append(SS():q(interval .. "sec", "OnPreference", "喋る間隔"))
      str:append(SS():n())

      str:append([[
\n
\![*]\q[Return,メニュー] \![*]\q[Close,閉じる]
\_q
\_l[0,0]
You can change preferences.
]])
      return str
    end,
  },
}
