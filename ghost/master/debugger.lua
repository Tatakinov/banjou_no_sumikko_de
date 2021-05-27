local path  = arg[1]
local ext   = arg[2]

package.path  = path .. "?.lua;" .. path .. "?/init.lua;" ..
                path .. "corelib/?.lua;" ..
                path .. "corelib/?/init.lua;" ..
                path .. "lib/?.lua;" ..
                path .. "lib/?/init.lua"

package.cpath = path .. "?." .. ext .. ";" ..
                path .. "?/init." .. ext .. ";" ..
                path .. "corelib/?." .. ext .. ";" ..
                path .. "corelib/?/init." .. ext .. ";" ..
                path .. "lib/?." .. ext .. ";" ..
                path .. "lib/?/init." .. ext

local module        = require("index")
local StringBuffer  = require("string_buffer")
local ShioriModule  = require("ukagaka_module.shiori")
local Request       = ShioriModule.Request
local Response      = ShioriModule.Response
local Protocol      = ShioriModule.Protocol

local function call(tbl)
  assert(tbl[1])
  local req = Request("GET", nil, Protocol.v30, {
    Charset = "UTF-8",
    Sender  = "Kagari_Debugger",
    ID      = tbl[1],
  })
  for i = 2, #tbl do
    req:header("Reference" .. tostring(i - 2), tbl[i])
  end
  local res = Response.parse(module.request(req:tostring()))
  print(res:tostring())
end

-- main

module.load(path)

while true do
  local line  = io.read("l")
  if line == nil or line == "exit" then
    module.unload()
    break
  end
  local tbl = {}
  local str = StringBuffer()
  local in_quote  = false
  for i = 1, #line do
    local c = string.sub(line, i, i)
    if c == "\"" then
      in_quote  = not(in_quote)
    elseif c == " " and not(in_quote) then
      table.insert(tbl, str:tostring())
      str = StringBuffer()
    else
      str:append(c)
    end
  end
  table.insert(tbl, str:tostring())
  local command = table.remove(tbl, 1)
  if command == "help" then
    print([[Usage:
    call EventID Argument0 Argument1 ...
    exit]])
  end
  if command == "call" then
    call(tbl)
  end
end

os.exit(0)
