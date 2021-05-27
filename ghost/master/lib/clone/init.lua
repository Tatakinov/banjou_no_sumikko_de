local function M(obj)
  local clone
  local t = type(obj)
  -- TODO
  -- userdata と lightuserdataの考慮
  if t == "table" then
    clone = {}
    for k, v in pairs(obj) do
      clone[k]  = M(v)
    end
    setmetatable(clone, getmetatable(obj))
  else
    clone = obj
  end
  return clone
end

return M
