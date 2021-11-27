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
      local _T  = shiori.i18n
      local strength  = __("Strength")
      local interval  = __("TalkInterval") or 60
      local str       = StringBuffer()

      local strength_str  = {
        ["無"]      = _T("無"),
        ["入門"]    = _T("入門"),
        ["初級"]    = _T("初級"),
        ["中級"]    = _T("中級"),
        ["上級"]    = _T("上級"),
        ["有段"]    = _T("有段"),
        ["高段"]    = _T("高段"),
        ["観る将"]  = _T("観る将"),
        ["不明"]    = _T("不明"),
      }

      str:append([[
\0
\_q
\n
\n
\n
]])
      str:append(_T("option_render_mode"))
      if __("描画モード") == 1 then
        str:append(SS():q(_T("fast(unstable)"), "OnPreference", "描画モード"))
      else
        str:append(SS():q(_T("slow(stable)"), "OnPreference", "描画モード"))
      end
      str:append(SS():n())

      str:append([=[\![*]]=])
      str:append(SS():q(_T("option_clear_render_info"), "OnPreference", "描画情報のクリア"))
      str:append(SS():n())

      str:append(_T("option_your_strength"))
      str:append(SS():q(strength_str[strength], "OnPreference", "棋力"))
      str:append(SS():n())

      str:append(_T("option_talk_interval"))
      str:append(SS():q(interval .. _T("second"), "OnPreference", "喋る間隔"))
      str:append(SS():n())

      str:append(_T("option_footer"))
      return str
    end,
  },
}
