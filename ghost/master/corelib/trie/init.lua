local Class         = require("class")
local StringBuffer  = require("string_buffer")
local utf8          = require("lua-utf8")

local M = Class()

M.__index = M

function M:_init()
  self.tree = {}
  self.word_list  = {}
  self.changed  = false
end

function M:add(str)
  self.changed  = true
  table.insert(self.word_list, str)
end

function M:mktree()
  --table.sort(self.word_list)
  if self.changed == false then
    return
  end
  self.changed  = false

  self.tree = {}
  for i = 1, #self.word_list do
    local current = self.tree
    for pos, code in utf8.next, self.word_list[i] do
      if current[code] == nil then
        current[code] = {}
      end
      current = current[code]
      if utf8.next(self.word_list[i], pos) == nil then
        current.id  = i
      end
    end
  end
end

function M:remove(str)
  for i = 1, #self.word_list do
    if self.word_list[i] == str then
      table.remove(self.word_list, i)
      self.changed  = true
      break
    end
  end
end

function M:gsub(str, replace)
  self:mktree()
  local buffer  = StringBuffer()
  local tmp     = StringBuffer()
  local current = self.tree
  local last_id = nil
  local last_index  = nil
  local index = 1
  local list  = {}
  for _, code in utf8.next, str do
    table.insert(list, code)
  end

  while index <= #list do
    if current[list[index]] then
      tmp:append(utf8.char(list[index]))
      current = current[list[index]]
      if current.id then
        last_id = current.id
        last_index  = index
      end
    else
      current = self.tree
      if last_id then
        if type(replace) == "function" then
          buffer:append(replace(self.word_list[last_id]))
        else
          buffer:append(self.word_list[last_id])
        end
        last_id = nil
        index = last_index
        tmp:clear()
      else
        if tmp:strlen() > 0 then
          buffer:append(tmp:tostring())
          tmp:clear()
          index = index - 1
        else
          buffer:append(utf8.char(list[index]))
        end
      end
    end
    index = index + 1
  end
  if last_id then
    if type(replace) == "function" then
      buffer:append(replace(self.word_list[last_id]))
    else
      buffer:append(self.word_list[last_id])
    end
    last_id = nil
    index = last_index
    tmp:clear()
  elseif tmp:strlen() > 0 then
    buffer:append(tmp)
  end
  return buffer:tostring()
end

return M
