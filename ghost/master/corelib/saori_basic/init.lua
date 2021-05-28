local Class = require("class")
local Conv  = require("conv")
local Native    = require("saori_universal.native")
local Module    = require("ukagaka_module.saori")
local Process   = require("process")

local Protocol  = Module.Protocol
local Response  = Module.Response

local M   = Class()
M.__index = M

function M:_init(path, sender)
  self._path    = path
  self._sender  = sender
end

function M:load()
  return true
end

function M:request(...)
  local process = Process({
    command = self.path,
    chdir   = true,
  })
  local tbl = {...}
  for i, v in ipairs(tbl) do
    tbl[i]  = Conv.conv(v, "cp932", "UTF-8") or v
  end
  process:spawn(table.unpack(tbl))
  local ret = process:readline(true)
  process:despawn()
  if ret and #ret > 0 then
    local res = Response(200, "OK", Protocol.v10, {
      Charset = "UTF-8",
    })
    res:header("Result", Conv.conv(ret, "UTF-8", "cp932") or ret)
    return res
  else
    return Response(204, "No Content", Protocol.v10, {
    })
  end
end

function M:unload()
  return true
end

return M
