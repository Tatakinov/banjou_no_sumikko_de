local Path          = require("path")

local M = {}

local config_filename = "kagari.conf.lua"

local DefaultConfig  = {
  SAORI = {
  },
  Replace = {
  },
  External  = {
  },
}

local function recursive(src, opt)
  for k, v in pairs(src) do
    if opt[k] == nil then
      opt[k]  = v
    else
      if type(v) == "table" then
        recursive(v, opt[k])
      end
    end
  end
end

function M.load(path)
  local fh  = io.open(Path.join(path, config_filename), "r")
  if fh == nil then
    return DefaultConfig
  end
  local data  = fh:read("*a")
  local chunk, err = load(data, "Config")
  if not(chunk) then
    return DefaultConfig
  end
  local config  = chunk()
  recursive(DefaultConfig, config)
  return config
end

return M
