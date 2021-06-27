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

print([[* Kagari/Kotori Debugger v1.0.0
* type "help" for more information

]])


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

local function serialize(obj, indent)
  indent  = indent or ""
  local obj_type  = type(obj)
  if obj_type == "boolean" or obj_type == "number" then
    return tostring(obj)
  elseif obj_type == "string" then
    local str = string.format("%q", obj)
    str = str:gsub("\\(%d%d%d)", function(num)
      local n = tonumber(num)
      if n >= 0x80 then
        return string.format("%s", string.char(n))
      else
        return string.format("\\%s", num)
      end
    end)
    return str
  elseif obj_type == "table" then
    local str = "{\n"
    local tbl = {}
    for k, v in pairs(obj) do
      table.insert(tbl, indent .. "  " .. "[" .. serialize(k, indent .. "  ") .. "]=" .. serialize(v, indent .. "  ") .. ",\n")
    end
    table.sort(tbl)
    if #tbl > 0 then
      str = str .. table.concat(tbl, "")
    end
    str = str .. indent .. "}"
    return str
  end
  return "[" .. tostring(obj) .. "]"
end

local function dump_var()
  local shiori  = module.debug()
  print(serialize(shiori.var._data))
end

local function dump_talk(id)
  local shiori  = module.debug()
  if id then
    print(serialize(shiori._data._data[id]))
  else
    print(serialize(shiori._data._data))
  end
end

local function dump(tbl)
  if tbl[1] == "var" then
    dump_var()
  elseif tbl[1] == "talk" then
    dump_talk(tbl[2])
  end
end

-- main

module.load(path)

while true do
  io.write("> ")
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
    call EventID [Argument0 Argument1 ...]
    dump var
    dump talk [id]
    exit]])
  end
  if command == "call" then
    call(tbl)
  elseif command == "dump" then
    dump(tbl)
  end
end

os.exit(0)
