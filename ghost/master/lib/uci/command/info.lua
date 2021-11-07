local Command  = require("uci.command")

local M = {}

function M.parse(list)
  local data  = {}
  assert(list[1] == "info")
  data.command = Command.INFO
  local index = 2
  while index <= #list do
    if  list[index] == "depth" or
        list[index] == "seldepth" or
        list[index] == "time" or
        list[index] == "nodes" or
        list[index] == "hashfull" or
        list[index] == "nps" or
        list[index] == "multipv"
        then
      local key = list[index]
      index = index + 1
      data[key] = assert(tonumber(list[index]))
    elseif list[index] == "score" then
      index = index + 1
      if      list[index] == "cp" then
        data.cp   = true
      elseif  list[index] == "mate" then
        data.mate = true
      end
      index = index + 1
      data.score  = tonumber(list[index]) or 0
      -- lowerbound, upperboundは次のループで処理する
    elseif list[index] == "lowerbound" then
      data.lowerbound = true
    elseif list[index] == "upperbound" then
      data.upperbound = true
    elseif list[index] == "string" then
      index = index + 1
      -- info string 7g7f (70%)
      -- のような定跡を利用していることをstringで返すことがあるので
      -- 分割したまま保持する
      data.str  = {}
      for i = index, #list do
        table.insert(data.str, list[i])
      end
      index = #list
    elseif list[index] == "currmove" then
      index = index + 1
      data.currmove = list[index]
    elseif list[index] == "pv" then
      index = index + 1
      data.pv = {}
      for i = index, #list do
        table.insert(data.pv, list[i])
      end
      index = #list
    end
    index = index + 1
  end
  return data
end

return M
