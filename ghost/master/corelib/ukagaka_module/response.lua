local Class     = require("class")
local Headers   = require("ukagaka_module.headers")

local M   = Class(Headers)
M.__index = M

local CRLF  = string.char(0x0d, 0x0a)

function M:_init(code, message, protocol, headers)
  self:code(code)
  self:message(message)
  self:protocol(protocol)
  self:super()._init(self, headers)
end

function M:code(code)
  local old = self._code
  if code then
    self._code  = code
  end
  return old
end

function M:message(message)
  local old = self._message
  if message then
    self._message = message
  end
  return old
end

function M:protocol(protocol)
  local old = self._protocol
  if protocol then
    self._protocol  = protocol
  end
  return old
end

function M:request(request)
  local old = self._request
  if request then
    self._request = request
  end
  return old
end

function M.parse(obj)
  local res = {}
  if type(obj) == "string" then
    local line  = string.gmatch(obj, "[^" .. CRLF .."]+" .. CRLF)()
    res.protocol, res.code, res.message = string.gmatch(line, "(%w+/%d%.%d) (%d+) (.+)" .. CRLF)()
    local _, pos  = string.find(obj, CRLF .. CRLF)
    --assert(string.len(obj) == pos) --  今のところはCRLFCRLF以降にメッセージは無い...はず
    res = M(res.code, res.message, res.protocol,
        Headers.parse(string.sub(obj, string.len(line) + 1, pos)):headers())
    return res
  end
  return nil
end

function M:tostring()
  local str = ""
  local req = self:request()
  if req then
    if self:protocol() == nil then
      self:protocol(req:protocol())
    end
  end
  if self:protocol() then
    str = str .. self:protocol()
  end
  if self:code() then
    str = str .. " " .. self:code()
  end
  if self:message() then
    str = str .. " " .. self:message()
  end
  str = str .. CRLF .. self:super().tostring(self) .. CRLF
  return str
end

return M
