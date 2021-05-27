local Class = require("class")
local Clone = require("clone")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")

local M = Class()
M.__index = M

function M:_init()
  self._data  = {}
  self._mode  = 1
  self:update()
end

function M:mode(mode)
  local m = self._mode
  if mode then
    self._mode  = mode
  end
  return m
end

function M:update()
  if self._mode == 1 then
    self._prev  = Clone(self._data)
  elseif self._mode == 2 then
    self._prev  = {}
  end
end

function M:set(category, parts, visible)
  assert(category)
  if self._data[category] == nil then
    --print("create category: " .. category)
    self._data[category]  = {
    }
  end
  if parts then
    -- 現在表示しているパーツでなければ
    -- 今表示しているパーツは非表示にする。
    if visible then
      for k, v in pairs(self._data[category]) do
        if v then
          self._data[category][k] = 0
        end
      end
    end
    if self._data[category][parts] == nil then
      self._data[category][parts] = 0
    end
    if visible == nil then
      self._data[category][parts] = 1 - self._data[category][parts]
    else
      self._data[category][parts] = visible
    end
  else
    for k, v in pairs(self._data[category]) do
      if visible == nil then
        self._data[category][k] = 1 - v
      else
        self._data[category][k] = visible
      end
    end
  end
end

function M:toSS()
  local str = StringBuffer()
  for category, v in pairs(self._data) do
    if self._prev[category] == nil then
      if next(v) == nil then
        str:append(SS():bind(category, nil, 0))
      end
      for parts, v in pairs(v) do
        str:append(SS():bind(category, parts, v))
      end
    else
      for parts, v in pairs(v) do
        if self._prev[category][parts] ~= v then
          str:append(SS():bind(category, parts, v))
        end
      end
    end
  end
  self:update()
  return str:tostring()
end

return M
