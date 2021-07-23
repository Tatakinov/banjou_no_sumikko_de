local Class         = require("class")
local Color         = require("sakura_script.color")
local Shape         = require("sakura_script.shape")
local Render        = require("sakura_script.render")
local StringBuffer  = require("string_buffer")

local M = Class()

M.Color   = Color
M.Shape   = Shape
M.Render  = Render

M.__index = M
M.__tostring  = function(self)
  return self:tostring()
end
M.__call  = function(self, str)
  self.str:append(str)
  return self
end
M.__concat  = function(a, b)
  --[[ -- debug
  local s_a = tostring(a)
  local s_b = tostring(b)
  return s_a .. s_b
  --]]
  -- TODO 雑
  return tostring(a) .. tostring(b)
end

function M:_init()
  self.str  = StringBuffer()
end

function M:__q(t)
  assert(t)
  assert(#t > 0)
  assert(t.str)
  self.str:append("\\__q["):append(t[1])

  for i = 2, #t do
    self.str:append(","):append(t[i])
  end
  self.str:append("]"):append(t.str):append("\\__q")

  return self
end

function M:_a(t)
  assert(t)
  assert(#t > 0)
  assert(t.str)
  self.str:append("\\_a["):append(t[1])

  for i = 2, #t do
    self.str:append(","):append(t[i])
  end
  self.str:append("]"):append(t.str):append("\\_a")

  return self
end


local _b_options  = {
  -- \_b[path, x, y], \_b[path, inline]共通
  {
    "opaque", "use_self_alpha",
  },
  -- \_b[path, x, y] のみ
  {
    "fixed", "background", "foreground",
  },
}

function M:_b(t)
  assert(t)
  assert(#t > 1)
  self.str:append("\\_b["):append(t[1])
  if #t == 2 and t[2] == "inline" then
    self.str:append(",inline")
  elseif #t == 3 and tonumber(t[2]) and tonumber(t[3]) then
    self.str:append(","):append(tonumber(t[2])):append(","):append(tonumber(t[3]))
    for _, v in ipairs(_b_options[2]) do
      if t[v] then
        self.str:append(",--option="):append(v)
      end
    end
  else
    error("Invalid argument")
  end
  for _, v in ipairs(_b_options[1]) do
    if t[v] then
      self.str:append(",--option="):append(v)
    end
  end
  if t.clipping and string.match(t.clipping, "^%d+ %d+ %d+ %d+$") then
    self.str:append(",--clipping="):append(t.clipping)
  end
  self.str:append("]")
  return self
end

function M:_l(x, y)
  self.str:append("\\_l[")
  if x then
    self.str:append(x)
  end
  self.str:append(",")
  if y then
    self.str:append(y)
  end
  self.str:append("]")
  return self
end

function M:_q(enable)
  if enable ~= nil then
    self.str:append("\\![quicksection,"):append(enable):append("]")
  else
    self.str:append("\\_q")
  end
  return self
end

function M:_w(time)
  if tonumber(time) then
    self.str:append("\\_w["):append(tonumber(time)):append("]")
  end
  return self
end

function M:C()
  self.str:append("\\C")
  return self
end

function M:b(n)
  assert(tonumber(n))
  self.str:append("\\b["):append(tonumber(n)):append("]")
  return self
end

function M:bind(category, parts, num)
  assert(category)
  self.str:append("\\![bind,"):append(category):append(",")
  if parts then
    self.str:append(parts)
  end
  self.str:append(",")
  if tonumber(num) then
    self.str:append(num)
  end
  self.str:append("]")
  return self
end

function M:c(t)
  if t and (t.type == "line" or t.type == "char") then
    local n = tonumber(t[1])
    assert(tonumber(n))
    self.str:append("\\c["):append(t.type):append(","):append(n)
    n = tonumber(t[2])
    if n then
      self.str:append(","):append(n)
    end
    self.str:append("]")
  else
    self.str:append("\\c")
  end
  return self
end

local dialog_common_params = {
  "title", "dir", "filter", "ext", "name", "id",
}

local dialog_color_params = {
  "color", "id",
}

function M:dialog(command, param)
  local str = StringBuffer()
  if command == "open" or command == "save" or command == "folder" then
    str:append("\\![open,dialog,"):append(command)
    for i = 1, #dialog_common_params do
      local key = dialog_common_params[i]
      if param[key] then
        str:append(",--"):append(key):append("="):append(param[key])
      end
    end
  elseif command == "color" then
    str:append("\\![open,dialog,color")
    for i = 1, #dialog_color_params do
      local key = dialog_color_params[i]
      if param[key] then
        str:append(",--"):append(key):append("="):append(param[key])
      end
    end
  end
  if str:strlen() == 0 then
    -- TODO error
    return self
  end
  str:append("]")
  self.str:append(str)
  return self
end

function M:embed(ID, ...)
  assert(ID)
  self.str:append("\\![embed,"):append(ID)
  local size  = select("#", ...)
  for i = 1, size do
    self.str:append(","):append(select(i, ...))
  end
  self.str:append("]")
  return self
end

local f_shape = {
  "cursorstyle", "cursornotselectstyle",
  "anchorstyle", "anchornotselectstyle",
  "anchorvisitedstyle",
}

local f_color = {
  "cursorcolor", "cursorbrushcolor", "cursorpencolor", "cursorfontcolor",
  "cursornotselectcolor", "cursornotselectbrushcolor",
  "cursornotselectpencolor", "cursornotselectfontcolor",
  "anchorcolor", "anchorbrushcolor", "anchorpencolor", "anchorfontcolor",
  "anchornotselectcolor", "anchornotselectbrushcolor",
  "anchornotselectpencolor", "anchornotselectfontcolor",
  "anchorvisitedcolor", "anchorvisitedbrushcolor",
  "anchorvisitedpencolor", "anchorvisitedfontcolor",
}

local f_render  = {
  "cursormethod", "cursornotselectedmethod", "anchormethod",
  "anchornotselectmethod", "anchorvisitedmethod",
}

function M:f(t)
  assert(t and next(t))
  local str = StringBuffer()
  for i = 1, #f_shape do
    local key = f_shape[i]
    if t[key] then
      self.str:append("\\f["):append(key):append(","):append(t[key]):append("]")
      return self
    end
  end
  for i = 1, #f_color do
    local key = f_color[i]
    if t[key] then
      self.str:append("\\f["):append(key):append(","):append(t[key]):append("]")
      return self
    end
  end
  for i = 1, #f_render do
    local key = f_render[i]
    if t[key] then
      self.str:append("\\f["):append(key):append(","):append(t[key]):append("]")
      return self
    end
  end
  return self
end

function M:inputbox(ID, time, text, ...)
  assert(ID)
  if tonumber(time) then
    self.str:append("\\![open,inputbox,"):append(ID)
            :append(","):append(tonumber(time))
    if text ~= nil then
      self.str:append(","):append(text)
    end
    -- TODO ...
    self.str:append("]")
  else
    self.str:append("\\![close,inputbox,"):append(ID):append("]")
  end
  return self
end

function M:n(opt)
  self.str:append("\\n")
  if opt == "half" then
    self.str:append("[half]")
  elseif tonumber(opt) then
    self.str:append("[" .. tonumber(opt) .. "]")
  end
  return self
end

function M:p(n)
  assert(tonumber(n))
  self.str:append("\\p["):append(tonumber(n)):append("]")
  return self
end

function M:q(title, ID, ...)
  assert(title)
  assert(ID)
  self.str:append("\\q["):append(title):append(","):append(ID)
  local size  = select("#", ...)
  for i = 1, size do
    self.str:append(","):append(select(i, ...))
  end
  self.str:append("]")
  return self
end

function M:raise(ID, ...)
  assert(ID)
  self.str:append("\\![raise,"):append(ID)
  local size  = select("#", ...)
  for i = 1, size do
    self.str:append(","):append(select(i, ...))
  end
  self.str:append("]")
  return self
end

function M:raiseother(ghost_name, ID, ...)
  assert(ghost_name)
  assert(ID)
  self.str:append("\\![raiseother,"):append(ghost_name):append(","):append(ID)
  local size  = select("#", ...)
  for i = 1, size do
    self.str:append(","):append(select(i, ...))
  end
  self.str:append("]")
  return self
end

function M:s(n)
  --assert(tonumber(n))
  self.str:append("\\s["):append(n):append("]")
  return self
end

function M:timeout(t)
  assert(t)
  if t.balloon then
    assert(tonumber(t.balloon))
    self.str:append("\\![set,balloontimeout,"):append(t.balloon):append("]")
  end
  if t.choice then
    assert(tonumber(t.choice))
    self.str:append("\\![set,choicetimeout,"):append(t.choice):append("]")
  end
  return self
end

function M:timerraise(t)
  assert(t)
  assert(t.time)
  assert(t.ID)
  self.str:append("\\![timerraise,"):append(t.time):append(",")
  if t.loop then
    self.str:append("0")
  else
    self.str:append("1")
  end
  self.str:append(","):append(t.ID)
  for i = 1, #t do
    self.str:append(","):append(t[i])
  end
  self.str:append("]")
  return self
end

function M:x(noclear)
  local noclear = noclear or false
  self.str:append("\\x")
  if noclear then
    self.str:append("[noclear]")
  end
  return self
end

function M:tostring()
  local s = self.str:tostring()
  self:_init()
  return s
end

return M
