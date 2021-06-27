local lc  = require("luachild")

local M = {}

function M.tostring(obj, ...)
  local obj_type  = type(obj)
  if     obj_type == "string" then
    return obj
  elseif obj_type == "table" then
    if #obj > 0 then
      return M.tostring(obj[math.random(#obj)], ...)
    elseif obj.__tostring then
      return tostring(obj)
    -- X-SSTP-Return-*への暫定的な対応
    elseif next(obj) then
      return obj
    end
  elseif obj_type == "function" then
    return M.tostring({obj(...)}, ...) -- 関数が複数の値を返してくる場合に対応
  elseif obj_type == "thread" then
    local t = {coroutine.resume(obj, ...)}
    if table.remove(t, 1) then
      return M.tostring(t, ...)
    else
      return nil, t[1] or debug.traceback(obj, t[1])
    end
  end
  return nil
end

function M.serialize(obj, indent)
  indent  = indent or ""
  local obj_type  = type(obj)
  if obj_type == "boolean" or obj_type == "number" then
    return tostring(obj)
  elseif obj_type == "string" then
    -- Note:
    -- luaのqでは制御文字をエスケープする処理が行われるが
    -- 制御文字の範囲が0x00-0x1f,0x7fに加えて
    -- 0x80-0x9fも含まれており、これがUTF-8のマルチバイト文字の
    -- 2byte目以降(0x80-0xbf)に重なっているため、
    -- 不必要なエスケープ処理が行われてしまう。
    -- これを元に戻す処理を行っているが、( \128 -> [0x80] )
    -- エスケープの後にこれらの文字が来た場合を想定していないため、
    -- ( \\128 -> \[0x80] )
    -- のようになってしまうことに注意。
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
    for k, v in pairs(obj) do
      str = str .. indent .. "  " .. "[" .. M.serialize(k, indent .. "  ") .. "]=" .. M.serialize(v, indent .. "  ") .. ",\n"
    end
    str = str .. indent .. "}"
    return str
  end
  return tostring(nil)
end

local b1  = string.char(0x01)
local b2  = string.char(0x02)
function M.createURLList(tbl)
  local list  = {}
  for _, v in ipairs(tbl) do
    if type(v) ~= "table" or #v == 0 then
      break
    end
    v[1]  = v[1] or ""
    v[2]  = v[2] or ""
    v[3]  = v[3] or ""
    v[4]  = v[4] or ""
    table.insert(list, table.concat(v, b1))
  end
  local str = table.concat(list, b2)
  if str and #str > 0 then
    return str
  end
  return nil
end

function M.toArgs(...)
  local list  = {}
  local size  = select("#", ...)
  for i = 1, size do
    list["Reference" .. (i - 1)]  = select(i, ...)
  end
  return list
end

function M.toArray(tbl)
  local t = {}
  for k, v in pairs(tbl) do
    if string.match(k, "^Reference%d+$") then
      local num = tonumber(string.sub(k, 10))
      t[num]  = v
    end
  end
  local mt  = {
    __call  = function(self, name)
      assert(name)
      return tbl[name]
    end,
  }
  return setmetatable(t, mt)
end

return M
