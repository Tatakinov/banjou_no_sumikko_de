local StringBuffer  = require("string_buffer")

local function c2i(bool)
  if bool then
    return 1
  else
    return 2
  end
end

return {
  {
    id  = "OnMancalaView",
    content = function(shiori, ref)
      local __  = shiori.var
      local mancala = __("_Mancala")
      local color = __("_MancalaColor") or 1
      local str = StringBuffer()
      for i = 1, 2 do
        for j = 1, 6 do
          local num = mancala:get(i, j)
          str:append(string.format("\\![bind,MANCALA%02d%02d,,0]", c2i(color == i), j))
          str:append(string.format("\\![bind,MANCALA_NUM%02d%02d,,0]", c2i(color == i), j))
          str:append(string.format("\\![bind,MANCALA_NUM10%02d%02d,,0]", c2i(color == i), j))
          str:append(string.format("\\![bind,DUMMY_MANCALA%02d%02d,DUMMY,0]", c2i(color == i), j))
          if num <= 6 then
            str:append(string.format("\\![bind,MANCALA%02d%02d,%d,1]", c2i(color == i), j, num))
          else
            local n1  = num % 10
            local n10 = math.floor(num / 10)
            str:append(string.format("\\![bind,MANCALA_NUM%02d%02d,%d,1]", c2i(color == i), j, n1))
            str:append(string.format("\\![bind,MANCALA_NUM10%02d%02d,%d,1]", c2i(color == i), j, n10))
          end
          if ref[0] == "playable" and color == i and num > 0 then
            str:append(string.format("\\![bind,DUMMY_MANCALA%02d%02d,DUMMY,1]", c2i(color == i), j))
          end
        end
        local num = mancala:getStore(i)
        local n1  = num % 10
        local n10 = math.floor(num / 10)
        str:append(string.format("\\![bind,MANCALA_STORE%02d,%d,1]", c2i(color == i), n1))
        str:append(string.format("\\![bind,MANCALA_STORE10%02d,%d,1]", c2i(color == i), n10))
      end
      return [=[\p[9]\s[21000]]=] .. str:tostring()
    end,
  },
}
