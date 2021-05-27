
return {
  {
    id  = "OnInitialize",
    content = function(shiori, ref)
      local __  = shiori.var
      __("描画モード", __("描画モード") or 1)
    end,
  },
}
