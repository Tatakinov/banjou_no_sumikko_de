local Class = require("class")

local M = Class()
M.__index = M

M.none  = "none"
M.komi  = "komi"
M.kata_set_rules  = "kata-set-rules"
M.boardsize = "boardsize"
M.time_settings = "time_settings"
M.play  = "play"
M.genmove = "genmove"
M.final_score = "final_score"
M.quit  = "quit"
M.showboard = "showboard"

function M.n2pos(x, y)
  local t = {"A", "B", "C", "D", "E", "F", "G", "H", "J"}
  return t[x] .. tostring(y)
end

function M:_init()
  self._n = 0
  self._command = M.none
end

function M:tostring(id, ...)
  local t = {...}
  self._n = self._n + 1
  self._command = id
  if #t > 0 then
    return self._n .. " " .. id .. " " .. table.concat(t, " ")
  end
  return self._n .. " " .. id
end

function M:parse(str)
  local t = {
    kind  = M.none
  }
  if string.match(str, "^[=?]" .. self._n) then
    t.kind  = self._command
    local data  = string.match(str, "^[=?]" .. self._n .. " (.*)")
    if data then
      t.data  = data
    end
  end
  return t
end

return M
