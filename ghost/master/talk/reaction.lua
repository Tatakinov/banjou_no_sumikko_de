local StringBuffer  = require("string_buffer")

-- TODO 好感度の実装
return {
  -- 「ねぇねぇ」と肩をたたく感じ。
  {
    id  = "0Poke",
    content = function(shiori, ref)
      return shiori:talk("m_Key", ref)
    end,
  },
  -- 頭をなでなでする感じ。
  {
    id  = "0Headなで",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") then
        return nil
      end
      local favorability  = __("好感度") or 0
      if favorability < 50 then
        return shiori:talk("頭なで好感度低")
      elseif favorability < 100 then
        return shiori:talk("頭なで好感度中")
      end
    end,
  },
  {
    id  = "頭なで好感度低",
    content = function(shiori, ref)
      return
      [[\0\s[><]……っ。]],
      [[\0\s[きょとん]ど、どしたの急に。]]
    end,
  },
  -- おでこを小突く感じ。
  {
    id  = "0HeadPoke",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_Quiet") then
        return nil
      end
      return shiori:talk("頭つつき")
    end,
  },
  {
    id  = "頭つつき",
    content = function(shiori, ref)
      return [[
\p[0]\s[><]あぅっ！
]]
    end,
  },
  -- おっぱいをモミモミする感じ。
  {
    id  = "0BustPoke",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_InGame") then
        return shiori:talk("胸もみ対局中")
      end
      local favorability  = __("好感度") or 0
      if favorability < 50 then
        return shiori:talk("胸もみ好感度低")
      elseif favorability < 100 then
        return shiori:talk("胸もみ好感度中")
      end
      return nil
    end,
  },
  {
    id  = "胸もみ好感度低",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_LightningMomer", os.time())
      return [[
\p[0]\s[えー]…すけべ。
]]
    end,
  },
  {
    id  = "胸もみ好感度低",
    content = function(shiori, ref)
      local __  = shiori.var
      local time = __("_LightningMomer") or 0
      if os.time() - time < 10 then
        __("IsLightningMomer", true)
        return [[
\p[0]\s[呆れ]校内で噂になってるライトニングモマーって……
もしかして${User}のこと？
]]
      else
        return shiori:talk("0BustPoke")
      end
    end,
  },
  -- おっぱいをナデナデする感じ。
  {
    id  = "0Bustなで",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_InGame") then
        return shiori:talk("胸なで対局中")
      end
      local favorability  = __("好感度") or 0
      if favorability < 50 then
        return shiori:talk("胸なで好感度低")
      end
      return nil
    end,
  },
  {
    id  = "胸なで好感度低",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_LightningMomer", os.time())
      return [[
\p[0]\s[呆れ]えっ……わたしにそういうこと求めてるの？@
]]
    end,
  },
}
