local Class = require("class")
local Conv  = require("conv")
local Native    = require("saori_universal.native")
local Module    = require("ukagaka_module.saori")
--[[
local Protocol  = require("saori_caller.protocol")
local Request   = require("saori_caller.request")
local Response  = require("saori_caller.response")
--]]
local Protocol  = Module.Protocol
local Request   = Module.Request
local Response  = Module.Response

local M   = Class()
M.__index = M

function M:_init(path, sender)
  self.path   = path
  self.sender = sender
  self.native = Native(path)
end

function M:load()
  local sep = string.sub(package.config, 1, 1)
  local pos = string.find(self.path, sep .. "[^" .. sep .. "]*$")
  local dir = string.sub(self.path, 1, pos)
  local ret = self.native:load(dir)
  --print("ret = " .. tostring(ret))
  return ret
end

function M:request(...)
  local req = Request("EXECUTE", nil, Protocol.v10)
  local t = type(select(1, ...) or nil)
  if t == "table" then
    local tbl = select(1, ...)
    if tbl.method then
      --print("change method")
      req:method(tbl.method)
    end
    if tbl.command then
      req:command(tbl.command)
    end
    if tbl.headers then
      for k, v in pairs(tbl.headers) do
        req:header(k, v)
      end
    end
  else
    local size  = select("#", ...)
    for i = 1, size do
      local v = select(i, ...)
      if v ~= nil then
        req:header("Argument" .. (i - 1), tostring(select(i, ...)))
      end
    end
  end
  req:header("Sender", self.sender)
  req:header("Charset", "Shift_JIS")
  req:header("SecurityLevel", "Local")
  --print("Request:")
  --print(req:tostring())
  local str = req:tostring()
  str = Conv.conv(str, "cp932", "UTF-8") or str
  local ret = self.native:request(str)
  ret = Conv.conv(ret, "UTF-8", "cp932") or ret
  local res = Response.parse(ret)
  res:request(req)
  return res
end

function M:unload()
  local ret = self.native:unload()
  return ret
end

return M
