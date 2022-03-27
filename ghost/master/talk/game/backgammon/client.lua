return {
  {
    id  = "OnBackgammonAIThink",
    content = function(shiori, ref)
      --return shiori:talk("OnBackgammonAIThinkNormal", ref)
      return shiori:talk("OnBackgammonAIThinkNative", ref)
    end,
  },
}
