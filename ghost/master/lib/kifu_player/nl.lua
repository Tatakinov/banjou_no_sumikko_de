local M = {}

M.CR    = string.char(0x0d)
M.LF    = string.char(0x0a)
M.CRLF  = string.char(0x0d, 0x0a)

function M.toLF(str)
  str = string.gsub(str, M.CRLF, M.LF)
  str = string.gsub(str, M.CR,   M.LF)
  return str
end

return M
