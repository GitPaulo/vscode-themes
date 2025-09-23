-- Single line comment
--[[
Multi-line
comment
]]
--[==[
Long bracketed comment with custom level
]==]

local PI = 3.14159
local tbl = { key = "value", num = 42 }

-- Global function with string formatting
function greet(name)
  print(("Hello, %s!"):format(name))
end

-- Numeric for loop with conditional
for i = 1, 5 do
  local cond = (i % 2 == 0) and true or false
  if cond then
    greet("Lua")
  else
    -- no-op
  end
end

-- Local recursive function
local function factorial(n)
  if n <= 1 then return 1 end
  return n * factorial(n - 1)
end
print("factorial(5):", factorial(5))

-- Variadic function & closures
local function sum(...)
  local s = 0
  for _, v in ipairs{...} do s = s + v end
  return s
end
print("sum(1,2,3):", sum(1,2,3))

-- Upvalue/closure example
local function make_counter()
  local count = 0
  return function()
    count = count + 1
    return count
  end
end
local counter = make_counter()
print("counter:", counter(), counter())

-- Metatable with __index and __add
local Vector = {}
Vector.__index = Vector
function Vector.new(x,y)
  return setmetatable({x=x,y=y}, Vector)
end
function Vector.__add(a,b)
  return Vector.new(a.x+b.x, a.y+b.y)
end
function Vector:len()
  return math.sqrt(self.x^2 + self.y^2)
end

local v1, v2 = Vector.new(1,2), Vector.new(3,4)
local v3 = v1 + v2
print(("Vector len: %.2f"):format(v3:len()))

-- Custom iterator
local function squares(n)
  local i = 0
  return function()
    i = i + 1
    if i <= n then return i, i*i end
  end
end
for i, sq in squares(5) do
  print(("square(%d)=%d"):format(i, sq))
end

-- Coroutine example
local co = coroutine.create(function()
  for i = 1, 3 do
    coroutine.yield(i * 10)
  end
  return "done"
end)
while true do
  local ok, val = coroutine.resume(co)
  if not ok or val == nil then break end
  print("coroutine yielded:", val)
end

-- Error handling with pcall/xpcall
local function risky(n)
  assert(n > 0, "n must be positive")
  return n * 2
end
local ok, res = pcall(risky, -1)
if not ok then
  print("Caught error:", res)
end

-- Table iteration
for k, v in pairs(tbl) do
  print(("tbl[%s]=%s"):format(k, tostring(v)))
end

-- String patterns
local str = "one two three"
for w in str:gmatch("%w+") do
  print("word:", w)
end

-- Bit operations (if bit32 exists)
if bit32 then
  print("bit32 band:", bit32.band(0xF0, 0x0F))
end

print("Script finished.")
