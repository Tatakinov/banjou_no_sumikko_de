local lc  = require("luachild")

local M = {}
local SEP = string.sub(package.config, 1, 1)

function M.join(...)
  local t = {...}
  return table.concat(t, SEP)
end

function M.basename(path)
  local match = string.match(path, [[.+[/\](.-)$]])
  return match or path
end

function M.normalize(path)
  -- TODO stub
  return path
end

function M.relative(base, path)
  -- TODO stub
  base  = M.normalize(base)
  path  = M.normalize(path)
  return string.sub(path, #base + 1)
end

function M.dirWalk(path, func)
  for entry in lc.dir(path) do
    if entry.type == "directory" then
      M.dirWalk(path .. SEP .. entry.name, func)
    elseif entry.type == "file" then
      func(path .. SEP .. entry.name)
    end
  end
end

return M
