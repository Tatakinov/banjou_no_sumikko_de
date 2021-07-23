local Class = require("class")
local Conv  = require("conv")
local SaoriBasic      = require("saori_basic")
local SaoriUniversal  = require("saori_universal")
local Module    = require("ukagaka_module.saori")
local Protocol  = Module.Protocol

local M = Class()
M.__index = M

local CRLF  = string.char(0x0d, 0x0a)
local CR    = string.char(0x0d)
local LF    = string.char(0x0a)

local conf_file_name  = "saori.conf"

function M:load(base, sender)
  self.base   = base
  self.sender = sender
  self.lib    = {}
  local fh    = io.open(base .. conf_file_name, "r")
  if fh then
    local data  = fh:read("*a")
    fh:close()
    --  文字コードをCP932(Shift_JIS)へ
    data  = Conv.conv(data, "CP932", "UTF-8")
    --  改行文字をLFへ
    data  = string.gsub(data, CRLF, LF)
    data  = string.gsub(data, CR, LF)
    for line in string.gmatch(data, "([^" .. LF .. "]+)") do
      local tag, path = string.match(line, "(.+),(.+)")
      if tag and path then
        self:_add(tag, path)
      else
        -- TODO error
      end
    end
  else
    -- TODO error
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
