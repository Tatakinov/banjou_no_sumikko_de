local Class = require("class")
local Misc  = require("shiori.misc")

local FILE_NAME = "kagari_save.lua"
local file_path = nil

local M = Class()
M.__index = M
M.__call  = function(self, key, ...)
  local ret = self._data[key]
  if select("#", ...) > 0 then
    self._data[key] = select(1, ...)
  end
  return ret
end

local function recursive(dst, src)
  if type(src) == "table" then
    for k, v in pairs(src) do
      dst[k]  = recursive(dst[k], v)
    end
  else
    if dst == nil then
      dst = src
    end
  end
  return dst
end

function M:init(key, default)
  local tmp = default
  local v = self(key)
  if v then
    assert(type(v) == type(default))
    tmp = recursive(tmp, v)
  else
    self(key, default)
  end
  return self(key)
end

function M:load(path)
  --print("load")
  file_path  = path .. FILE_NAME
  local chunk = loadfile(file_path, "t")
  if chunk then
    local data  = chunk()
    if type(data) == "table" then
      self._data  = data
    else
      self._data  = {}
      return false
    end
  else
    -- TODO error message
    --  file_path  = nil
    self._data  = {}
    return false
  end
  return true
end

function M:save()
  --print("save")

  local tmp = {}
  -- 先頭に_がついている変数は一時変数なので無視
  for k, v in pairs(self._data) do
    if string.sub(k, 1, 1) ~= "_" then
      tmp[k]  = v
    end
  end

  if file_path and next(self._data) then
    local fh  = io.open(file_path, "w")
    if fh then
      fh:write("return " .. Misc.serialize(tmp))
    else
      -- TODO error message
      return false
    end
    return true
  end
  return false
end

return M
