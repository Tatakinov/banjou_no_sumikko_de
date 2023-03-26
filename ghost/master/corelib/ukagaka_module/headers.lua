local Class = require("class")

local M   = Class()
M.__index = M

local CRLF  = string.char(0x0d, 0x0a)

function M:_init(table)
  self._headers = {}
  if type(table) == "table" then
    for k, v in pairs(table) do
      self:header(k, v)
    end
  end
end

function M:header(key, value)
  local old = self._headers[key]
  if value then
    self._headers[key]  = value
  end
  return old
end

function M:headers()
  return self._headers
end

function M.parse(obj)
  if type(obj) == "string" then
    local ret = {}
    for line in string.gmatch(obj, "[^" .. CRLF .."]+" .. CRLF) do
      local k, v = string.gmatch(line, "(.-): (.+)" .. CRLF)()
      if k ~= nil then
        ret[k]  = v
      end
    end
    return M(ret)
  end
  return nil
end

function M:tostring()
  local tbl   = {}
  for k, v in pairs(self:headers()) do
    table.insert(tbl, k .. ": " .. v .. CRLF)
  end
  table.sort(tbl)
  return table.concat(tbl, "")
end

return M
