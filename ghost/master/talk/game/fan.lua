local Judgement = require("talk.game._judgement")

return {
  {
    id  = "OnSetFanID",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_FanID", math.random(3) - 1)
      return nil
    end,
  },
  {
    id  = "OnFan",
    content = function(shiori, ref)
      local __  = shiori.var
      local judge   = __("_CurrentJudgement")
      local fan_id  = __("_FanID") or 0
      local sid = Judgement.sid(judge) -- 正座のsid
      return "\\0\\s[" .. "扇子_" .. sid .. "]\\i[" .. (math.random(2) - 1 + fan_id * 2) ..",wait]\\s[" .. "考慮中_" .. sid .. "]"
    end,
  },
}
