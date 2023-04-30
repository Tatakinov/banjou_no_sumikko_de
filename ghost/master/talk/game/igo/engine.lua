local GTP = require("gtp")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

return {
  {
    id  = "OnIgoGameEngineInitialize",
    content = function(shiori, ref)
      local __  = shiori.var
      local gtp = GTP()
      __("_GTP", gtp)
      local process = shiori:saori("process")
      process("uniqueid", __("_uniqueid"))
      local ret = process("spawn", "engine/katago/katago.exe", "gtp -config gtp.cfg -model model.bin", true, "OnIgoGameProcess")
      for k, v in pairs(ret) do
        print(k, v)
      end
      local id  = ret()
      __("_ProcessID", id)
      print("ID", id)
      process("send", id, gtp:tostring(GTP.boardsize, 9))
    end,
  },
  {
    id  = "OnIgoGameProcess",
    content = function(shiori, ref)
      print("Process:", ref[0])
      local __  = shiori.var
      local process = shiori:saori("process")
      local option  = __("IgoGameOption")
      local id  = __("_ProcessID")
      local gtp = __("_GTP")
      if not(ref[0]) then
        local reserve = __("_Reserve")
        __("_Reserve", nil)
        return reserve
      end
      local data  = gtp:parse(ref[0])
      if data.kind == GTP.boardsize then
        process("send", id, gtp:tostring(GTP.komi, option.komi))
        __("_Reserve", nil)
      elseif data.kind == GTP.komi then
        process("send", id, gtp:tostring(GTP.time_settings, "0 3 1"))
        __("_Reserve", nil)
      elseif data.kind == GTP.time_settings then
        process("send", id, gtp:tostring(GTP.kata_set_rules, option.rule))
        __("_Reserve", nil)
      elseif data.kind == GTP.kata_set_rules then
        __("_Reserve", SS():raise("OnIgoGameStart"):tostring())
      elseif data.kind == GTP.play then
        __("_Reserve", SS():raise("OnIgoGameTurnBegin"):tostring())
      elseif data.kind == GTP.genmove then
        local data  = data.data
        if data == "pass" then
          __("_Reserve", SS():raise("OnIgoGameCpuTurnEnd", data):tostring())
        else
          local x = string.find("ABCDEFGHJ", string.sub(data, 1, 1))
          local y = string.sub(data, 2, 2)
          __("_Reserve", SS():raise("OnIgoGameCpuTurnEnd", x, y):tostring())
        end
      elseif data.kind == GTP.final_score then
        print("FINAL_SCORE:", data.data)
        __("_Reserve", SS():raise("OnIgoGameOver", data.data):tostring())
      elseif data.kind == GTP.showboard then
        -- nop
        __("_Reserve", nil)
      end
    end,
  },
}
