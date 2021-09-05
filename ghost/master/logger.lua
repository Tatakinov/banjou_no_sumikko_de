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
local server  = assert(Socket.bind("localhost", 39801))
local ip, port  = server:getsockname()

print("* Listen to", ip, port, "\n")

local socs  = {server}

while true do
  local rsocs, wsocs, err = Socket.select(socs, nil, nil)
  if err then
    print("An Error Occured")
    break
  end
  for _, v in ipairs(rsocs) do
    if v == server then
      local client  = server:accept()
      table.insert(socs, client)
    else
      local client  = v
      local line, err = client:receive("*l")
      if err then
        for i, v in ipairs(socs) do
          if v == client then
            table.remove(socs, i)
          end
        end
      else
        print(client, line)
      end
    end
  end
end

for _, v in ipairs(socs) do
  v:close()
end
