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

print([[* Kagari/Kotori Logger v1.0.0

]])

local Socket  = require("socket")
local server  = assert(Socket.bind("localhost", 49801))
local ip, port  = server:getsockname()

print("Listen to", ip, port)

while true do
  local client  = server:accept()
  while true do
    local line, err = client:receive("*l")
    if err then
      break
    else
      print(client, line)
    end
  end
end
