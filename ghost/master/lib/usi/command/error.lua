local Command  = require("usi.command")

local M = {}

function M.parse(reason)
  local data  = {}
  data.command  = Command.ERROR
  data.reason   = reason
  return data
end

function M.tostring(list)
  return nil
end

return M
