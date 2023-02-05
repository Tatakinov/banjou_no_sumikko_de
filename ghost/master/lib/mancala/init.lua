local Class = require("class")

local Variant = {
  ["Kalah"]  = require("mancala.kalah"),
}

local M = Class()
M.__index = M

function M:_init(variant_name)
  self._teban = 1
  self._store = {}
  self._hole  = {{}, {}}
  self._variant = Variant[variant_name]
  self._variant.init(self)
end

function M:teban()
  return self._teban
end

function M:get(player, index)
  return self._hole[player][index]
end

function M:set(player, index, num)
  self._hole[player][index] = num
end

function M:add(player, index)
  self:set(player, index, self:get(player, index) + 1)
end

function M:remove(player, index)
  local num = self:get(player, index)
  self:set(player, index, 0)
  return num
end

function M:getStore(player)
  return self._store[player]
end

function M:addStore(player, num)
  num = num or 1
  self._store[player] = self._store[player] + num
end

function M:resetStore(player)
  self._store[player] = 0
end

function M:lap(index)
  local str = self:dump()
  if self._variant.lap(self, index) then
    self._teban = self:reverse(self._teban)
  end
  print(str .. " => " .. self:dump())
end

function M:reverse(color)
  return 3 - color
end

function M:dump()
  return self:teban() .. "/" ..
      table.concat(self._hole[1], "/") .. "/" ..
      self._store[1] .. "/" ..
      table.concat(self._hole[2], "/") .. "/" ..
      self._store[2]
end

return M
