local Class = require("class")
local SaoriBasic      = require("saori_basic")
local SaoriUniversal  = require("saori_universal")
local Module    = require("ukagaka_module.saori")
local Protocol  = Module.Protocol

local M = Class()
M.__index = M

function M:load(base, sender, list)
  self.base   = base
  self.sender = sender
  self.lib    = {}
  for k, v in pairs(list) do
    local tag, path = k, v
    if tag and path then
      self:_add(tag, path)
    else
      -- TODO error
    end
  end
end

function M:_add(tag, path)
  --print("tag:  " .. tag .. #tag)
  --print("path: " .. path .. #path)
  if string.sub(path, -4) == ".dll" then
    self.lib[tag] = SaoriUniversal(path, self.sender)
  elseif string.sub(path, -4) == ".exe" then
    self.lib[tag] = SaoriBasic(path, self.sender)
  end
end

function M:_remove(tag)
  self.lib[tag] = nil
end

function M:loadall()
  for k, v in pairs(self.lib) do
    --print("load(): " .. k)
    local ret = v:load()
    if ret ~= true then
      -- TODO error
      print("SAORI error(load):", k)
      self:_remove(k)
    else
      -- GET Version
      local res = v:request({
        method = "GET",
        command = "Version",
      })
      if res:protocol() ~= Protocol.v10 then
        print("SAORI error(request):", k)
        self:_remove(k)
      else
        print("SAORI ok:", k)
        --print(res:tostring())
      end
    end
  end
end

function M:unloadall()
  for k, v in pairs(self.lib) do
    local ret = v:unload()
    if ret ~= true then
      -- TODO error
    end
    self:_remove(k)
  end
end

function M:get(tag)
  return self.lib[tag]
end

return M
