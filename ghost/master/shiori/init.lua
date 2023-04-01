local Class         = require("class")
local Config        = require("shiori.config")
local Trie          = require("trie")
local Misc          = require("shiori.misc")
local Module        = require("ukagaka_module.shiori")
local Path          = require("path")
local Protocol      = Module.Protocol
local Request       = Module.Request
local Response      = Module.Response
local SaoriCaller   = require("saori_caller")
local StringBuffer  = require("string_buffer")
local Talk          = require("shiori.talk")
local I18N          = require("shiori.i18n")
local Variable      = require("shiori.variable")

local M = Class()
M.__index = M

function M:_init()
  math.randomseed(os.time())

  self._charset = "UTF-8"
  self._name    = "Kagari/Kotori"

  self._trie          = Trie()
  self._replace       = {}
  self._replace_trie  = Trie()
  for _, v in ipairs({"[", "]", "\\_a", "\\__q"}) do
    self._trie:add(v)
    self._replace_trie:add(v)
  end
  self._saori      = SaoriCaller()
  self._reserve = {}

  self._external_allow_list = {}

  self.var  = Variable()
  self.i18n = I18N()

  self._data   = Talk()

  self._chain = {}
end

function M:load(path)
  self.var:load(path)
  self.var("_path", path)

  local __  = self.var
  __("_DictError", {})

  --トーク読み込み
  Path.dirWalk(path .. "talk", function(file_path)
    local file_name  = Path.basename(file_path)
    if string.sub(file_name, 1, 1) == "_" or string.sub(file_name, -4, -1) ~= ".lua" then
      return
    end
    local t, err  = (function()
      local fh  = io.open(file_path, "r")
      if fh == nil then
        return nil, "file not found"
      end
      local data  = fh:read("*a")
      local chunk, err = load(data, Path.relative(path, file_path))
      if err then
        return chunk, err
      end
      if type(chunk) ~= "function" then
        return nil, "invalid chunk"
      end
      local t = chunk()
      if type(t) ~= "table" then
        return nil, "invalid dictionary"
      end
      return t
    end)()
    if err then
      print("Failed to load dict: " .. err)
      local dict_error  = __("_DictError")
      table.insert(dict_error, err)
    else
      for _, v in ipairs(t) do
        --print("talk: " .. _)
        --print("id:   " .. tostring(v.id))
        if v.i18n then
          self.i18n:add(v)
        else
          self._data:add(v)
          if v.anchor then
            self._trie:add(v.id)
          end
        end
      end
    end
  end)

  self._config  = Config.load(path)

  self._saori:load(path, self:talk("name"), self._config.SAORI)
  self._saori:loadall()

  for _, v in ipairs(self._config.External) do
    self._external_allow_list[v]  = true
  end

  --置換の読み込み
  for _, v in ipairs(self._config.Replace) do
    local before, after = v.before, v.after
    if before and after then
      self._replace[before]  = after
      self._replace_trie:add(before)
    else
      -- TODO error
    end
  end
  self:talk("OnDictionaryLoaded")
end

function M:unload()
  print("unload")
  self.var:save()
  self._saori:unloadall()
end

local function extractHeaders(obj)
  local t = {
    Value             = obj.Value,
    ValueNotify       = obj.ValueNotify,
    ErrorLevel        = obj.ErrorLevel,
    ErrorDescription  = obj.ErrorDescription,
  }
  for k, v in pairs(obj) do
    if string.match(k, "^X%-SSTP%-PassThru%-") then
      t[k]  = v
    end
  end
  return t
end

function M:request(req)
  local res = Response(204, 'No Content', Protocol.v30, {
    Charset = self._charset,
    Sender  = self._name,
  })

  if req == nil then
    return res
  end

  local id  = req:header("ID")
  local security_level  = req:header("SecurityLevel") or ""
  if id == nil then
    -- TODO comment
    -- print("nil ID: " .. tostring(id))
  elseif string.lower(security_level) == "local" or
      self._external_allow_list[id] then
    local value, passthrough = self:_talk(id, req:headers())
    -- X-SSTP-PassThru-*への暫定的な対応
    local tbl = {}
    if type(value) == "table" then
      tbl   = value
      value = value.Value
    end
    if id == "OnTranslate" then
      value = value or req:header("Reference0")
      -- 末尾が\\e => passthroughでない、なら自動置換を実行する
      local passthrough = false
      local id  = req:header("Reference2")
      if id then
        local talk  = self._data:get(id) or {}
        passthrough = talk.passthrough
      end
      -- SHIORI Resource他置換しないトークには置換や末尾\eの追加を行わない
      if value and not(passthrough) then
        value = self:autoReplaceVars(value)
        value = self:autoLink(value)
        value = self:autoReplace(value)
        --  末尾にえんいーを追加する。
        --  えんいーが既にあるかを調べるのは面倒いのでとりあえず付けておく。
        value = value .. "\\e"
      end
    end
    if value then
      --value = string.gsub(value, "\x0d\x0a", "")
      value = string.gsub(value, "\x0d", "")
      value = string.gsub(value, "\x0a", "")
      res:code(200)
      res:message("OK")
      tbl.Value = value
    end
    --[[
    -- X-SSTP-PassThru-*への暫定的な対応
    --]]
    local headers = extractHeaders(tbl)
    for k, v in pairs(headers) do
      res:header(k, v)
    end
  end
  res:header("Charset", self._charset)
  res:header("Sender", self._name)
  res:request(req)
  return res
end

function M:autoLink(x, id)
  local ret = x
  local _invalid  = 0
  local _inner  = {}
  local replaced  = {}
  if id then
    replaced[id] = true
  end
  local function replace(str)
    -- TODO
    -- SakuraScriptで装飾されている部分はアンカーを付けないための措置だが
    -- 極めて雑。
    if str == "[" then
      _invalid = _invalid + 1
    elseif str == "]" then
      _invalid = _invalid - 1
    elseif str == "\\_a" or str == "\\__q" then
      _inner[str] = not(_inner[str])
      if _inner[str] then
        _invalid  = _invalid  + 1
      else
        _invalid  = _invalid  - 1
      end
    else
      if _invalid == 0 and replaced[str] ~= true then
        replaced[str] = true
        --  \\_a[ID]text\\_a
        --  \\_a[OnID,r0,r1,...]text\\_a
        --  \\_a[ID,r2,r3,...]text\\_a
        return "\\_a[" .. str .. "]" .. str .. "\\_a"
      end
    end
    return str
  end
  if self._trie and ret then
    ret = self._trie:gsub(ret, replace)
  end
  return ret
end

function M:autoReplace(x)
  local ret = x
  local _invalid  = 0
  local _inner  = {}
  local function replace(str)
    -- TODO
    -- SakuraScriptで装飾されている部分はアンカーを付けないための措置だが
    -- 極めて雑。
    if str == "[" then
      _invalid = _invalid + 1
    elseif str == "]" then
      _invalid = _invalid - 1
    elseif str == "\\_a" or str == "\\__q" then
      _inner[str] = not(_inner[str])
      if _inner[str] then
        _invalid  = _invalid  + 1
      else
        _invalid  = _invalid  - 1
      end
    else
      if _invalid == 0 then
        return self._replace[str]
      end
    end
    return str
  end
  if self._replace_trie and ret then
    ret = self._replace_trie:gsub(ret, replace)
  end
  return ret
end

function M:autoReplaceVars(str)
  local str  = str:gsub("(\\?)%${([^}]+)}", function(escape, s)
    if escape == "\\" then
      return string.format("${%s}", s)
    end
    return tostring(self.var(s))
  end)
  return str
end

function M:_talk(id, ...)
  local id  = id or ""
  local tbl
  if select("#", ...) == 1 and type(select(1, ...)) == "table" then
    tbl = select(1, ...)
    if #tbl == 0 and tbl[0] == nil then
      tbl = Misc.toArray(tbl)
    end
  else
    tbl = Misc.toArray(Misc.toArgs(...))
  end
  local language  = self.var("_Language") or ""
  --print("shiori:talk:     " .. tostring(id))
  --print("shiori:talk.tbl: " .. type(tbl))
  local talk = self._chain[id]
  if talk == nil or coroutine.status(talk.content) == "dead" then
    talk  = self._data:get(id) or {}
    local content = talk["content_" .. language] or talk.content
    if type(content) == "function" then
      talk  = {
        content = coroutine.create(content),
        passthrough = talk.passthrough,
      }
    else
      talk  = {
        content = content,
        passthrough = talk.passthrough,
      }
    end
  end
  local value, err = Misc.tostring(
    talk.content,
    self,
    tbl
  )
  if type(talk.content) == "thread" and coroutine.status(talk.content) ~= "dead" then
    self._chain[id] = talk
  end
  if err then
    local str = StringBuffer([[\0\_q]])
    for s in string.gmatch(err, "([^\n]+)") do
      str:append([[\_?]]):append(s):append([[\_?\n]])
    end
    str:append([[\_q]])
    str.Value = str:tostring()
    str.ErrorLevel  = "warning"
    str.ErrorDescription  = string.gsub(err, "\n", " | ")
    return str, true
  end
  return value, talk.passthrough
end

function M:talk(...)
  return (self:_talk(...))
end

function M:talkRandom()
  local reserve_id  = nil
  if #self._reserve > 0 and self._reserve[1].count == 1 then
    reserve_id  = self._reserve[1].id
    table.remove(self._reserve, 1)
  end
  for _, v in ipairs(self._reserve) do
    v.count = v.count - 1
  end
  if reserve_id then
    self.prev_talk  = self:talk(reserve_id)
  else
    self.prev_talk  = self:talk()
  end
  return self.prev_talk
end

function M:talkPrevious()
  return self.prev_talk
end

function M:reserveTalk(id, count)
  count = count or 1
  local duplicated  = false
  if #self._reserve == 0 then
    table.insert(self._reserve, {id = id, count = count})
  else
    for i = 1, #self._reserve do
      if self._reserve[i].count >= count then
        table.insert(self._reserve, i, {id = id, count = count})
        duplicated  = true
        break
      end
    end
  end
  if duplicated then
    local min = 0
    for i = 1, #self._reserve do
      local p = self._reserve[i]
      if p.count <= min then
        p.count = min + 1
      end
      min = p.count
    end
  end
end

function M:isReservedTalk(id)
  for _, v in ipairs(self._reserve) do
    if v.id == id then
      return v.count
    end
  end
end

function M:saori(id)
  return function(...)
    local saori = self._saori:get(id)
    local ret = saori:request(...)
    local t = {}
    for k, v in pairs(ret:headers()) do
      if string.match(k, "^Value%d+$") then
        local num = tonumber(string.sub(k, 6))
        t[num]  = v
      end
    end
    local mt  = {
      __call  = function(self, name)
        name  = name or "Result"
        return ret:header(name)
      end,
    }
    return setmetatable(t, mt)
  end
end

function M:setLanguage(language)
  self.i18n:set(language)
end

local b1  = string.char(0x01)
local b2  = string.char(0x02)
function M:createURLList(tbl)
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

return M
