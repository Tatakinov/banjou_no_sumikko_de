local Class     = require("class")
local Headers   = require("ukagaka_module.headers")

local M   = Class(Headers)
M.__index = M

local CRLF  = string.char(0x0d, 0x0a)

function M:_init(method, command, protocol, headers)
  self:method(method)
  self:command(command)
  self:protocol(protocol)
  self:super()._init(self, headers)
end

function M:method(method)
  local old = self._method
  if method then
    self._method  = method
  end
  return old
end

function M:command(command)
  local old = self._command
  if command then
    self._command = command
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

function M.parse(obj)
  local req = {}
  if type(obj) == "string" then
    local line  = string.gmatch(obj, "[^" .. CRLF .."]+" .. CRLF)()
    req.method, req.version = string.gmatch(line, "(.+) (%w+/%d%.%d)" .. CRLF)()
    local pos, _  = string.find(req.method, " ")
    if pos and pos < string.len(req.method) then
      req.method, req.command = string.gmatch(req.method, "([^%s]+) (.+)")()
    end
    local _, pos  = string.find(obj, CRLF .. CRLF)
    assert(string.len(obj) == pos) --  今のところはCRLFCRLF以降にメッセージは無い...はず
    req = M(req.method, req.command, req.version,
        Headers.parse(string.sub(obj, string.len(line) + 1, pos)):headers())
    return req
  end
  return nil
end

function M:tostring()
  local str = ""
  if self:method() then
    str = str .. self:method()
  end
  if self:command() then
    str = str .. " " .. self:command()
  end
  if self:protocol() then
    str = str .. " " .. self:protocol()
  end
  str = str .. CRLF .. self:super().tostring(self) .. CRLF
  return str
end

return M
