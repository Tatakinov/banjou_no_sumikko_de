
return {
  {
    id  = "通常起動",
    content = function(shiori, ref)
      local _T  = shiori.i18n
      return _T("hello1")
    end,
  },
  {
    id  = "通常終了",
    content = function(shiori, ref)
      local _T  = shiori.i18n
      return _T("bye1")
    end,
  },
}
