local M = nil

if string.sub(package.config, 1, 1) == "\\" then
  M = require("conv.windows")
else
  M = require("conv.iconv")
end

return M
