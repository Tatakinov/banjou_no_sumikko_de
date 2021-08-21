local StringBuffer  = require("string_buffer")

return {
  {
    id = "hwnd",
    content = function(shiori, ref)
      local __  = shiori.var
      local sep = string.char(0x01)
      local hwnd  = {
        ghost = {},
        balloon = {},
      }
      for ghost in string.gmatch(ref[0], "[^" .. sep .. "]*") do
        --print("ghost hwnd: " .. ghost)
        table.insert(hwnd.ghost, tonumber(ghost))
      end
      for balloon in string.gmatch(ref[1], "[^" .. sep .. "]*") do
        --print("balloon hwnd: " .. balloon)
        table.insert(hwnd.balloon, tonumber(balloon))
      end
      __("_hwnd", hwnd)
    end,
  },
  {
    id  = "uniqueid",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_uniqueid", ref[0])
    end,
  },
  {
    id  = "otherghostname",
    content = function(shiori, ref)
      local __  = shiori.var
      local otherghostname  = {}
      local cnt = 0
      for _, _ in pairs(ref) do
        local otherghost = ref["Reference" .. cnt]
        if otherghost ~= nil then
          local t = {}
          local sep = "\x01"
          otherghost:gsub("[^" .. sep .. "]*", function(m) table.insert(t, m) end)
          table.insert(otherghostname, {
            name            = t[1],
            sakura_surface  = t[2],
            kero_surface    = t[3],
          })
          cnt = cnt + 1
        else
          break
        end
      end
      __("_otherghostname", otherghostname)
    end,
  },
  {
    id  = "installedghostname",
    content = function(shiori, ref)
      local __  = shiori.var
      local installedghostname  = {}
      local cnt = 0
      for _, _ in pairs(ref) do
        local ghostname = ref[cnt]
        if ghostname ~= nil then
          --print(ghostname)
          table.insert(installedghostname, ghostname)
          cnt = cnt + 1
        else
          break
        end
      end
      __("_installedghostname", installedghostname)
    end,
  },
}
