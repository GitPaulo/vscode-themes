-- Single line comment
--[[
Multi-line comment
]]

local PI = 3.14159
local tbl = {key = "value", num = 42}

function greet(name)
  print(("Hello, %s!"):format(name))
end

for i = 1, 5 do
  local cond = (i % 2 == 0) and true or false
  if cond then
    greet("Lua")
  else
    -- no-op
  end
end

local function factorial(n)
  if n <= 1 then return 1 end
  return n * factorial(n - 1)
end

print(factorial(5))
