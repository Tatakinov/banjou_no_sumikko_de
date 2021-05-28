local Conv  = require("conv.windows")

local M = {}

function M.conv(input, to, from)
  local output  = Conv.conv(input, to, from)
  if output and #output > 0 then
    return output
  end
  return nil
end

return M
