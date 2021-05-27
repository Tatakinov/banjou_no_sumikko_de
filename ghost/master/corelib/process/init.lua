local Class   = require("class")
local FH      = require("fh")
local LC      = require("luachild")

local M = Class()
M.__index = M

-- TODO OS
local NL  = string.char(0x0a)
if string.sub(package.config, 1, 1) == "\\" then
  NL  = string.char(0x0d, 0x0a)
end

function M:_init(conf)
  self:_init_spawn()
  self.command  = conf.command
  self.chdir    = conf.chdir
  self.NL       = conf.NL or NL
  assert(self.command)
end

function M:_init_spawn()
  self.pipe_r   = nil
  self.pipe_w   = nil
  self.process  = nil
end

function M:spawn(...)
  if self.process and self.process:wait(false) == true then
    return true
  end
  self:_init_spawn()
  local pipe_r, pipe_w
  pipe_r, self.pipe_w  = LC.pipe()
  self.pipe_r, pipe_w  = LC.pipe()
  self.pipe_w:setvbuf("line")
  pipe_w:setvbuf("line")

  local current_dir = LC.currentdir()
  --  TODO relative path
  if self.chdir then
    if string.find(self.command, ":") or string.sub(self.command, 1, 1) == "/" then
      local dir_sep = string.sub(package.config, 1, 1)
      local dir_sep_fallback = "/"
      local reverse = string.reverse(self.command)
      local pos     = string.find(reverse, dir_sep)
      if pos == nil then
        pos     = string.find(reverse, dir_sep_fallback)
      end
      if pos then
        local dirname = string.sub(self.command, 1, -pos)
        --print("dirname: " .. dirname)
        LC.chdir(dirname)
      end
    end
  end
  local args  = {...}
  table.insert(args, 1, self.command)
  args.stdin  = pipe_r
  args.stdout = pipe_w
  self.process = LC.spawn(args)
  if self.chdir then
    LC.chdir(current_dir)
  end

  if self.process == nil then
    self.pipe_r:close()
    self.pipe_w:close()
    pipe_r:close()
    pipe_w:close()
    self:_init_spawn()
    --print("spawn failed: " .. tostring(self.command))
    return false
  end
  --print("spawn succeed")
  pipe_r:close()
  pipe_w:close()
  return true
end

function M:despawn()
  if self.pipe_w then
    --print("close r pipe")
    self.pipe_w:close()
  end
  if self.pipe_r then
    --print("close w pipe")
    self.pipe_r:close()
  end
  if self.process then
    local ret = self.process:wait(false)
    if ret == true then
      --print("terminate")
      self.process:terminate()
      ret = self.process:wait()
      --print("process exited at " .. ret)
    elseif tonumber(ret) then
      --print("process exited at " .. ret)
    end
  end
  self:_init_spawn()
end

function M:readable()
  if self.pipe_r == nil then
    return false
  end
  return FH.readable(self.pipe_r)
end

function M:readline(blocking)
  blocking  = blocking or false
  if self.pipe_r == nil then
    return nil
  end
  if not(blocking) then
    FH.blocking(self.pipe_r, false)
  end
  local line  = self.pipe_r:read("*l")
  if not(blocking) then
    FH.blocking(self.pipe_r, true)
  end
  --print("Process.Read:  " .. tostring(line))
  return line
end

function M:writeline(str)
  if self.pipe_w == nil then
    -- TODO error
    return
  end
  --print("Process.Write: " .. tostring(str))
  self.pipe_w:write(str, self.NL)
  self.pipe_w:flush()
end

return M
