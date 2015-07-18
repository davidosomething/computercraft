---
-- Message of the day
-- motd v1.0.2
--
-- pastebin zs7pMz89
--
-- @author David O'Trakoun <me@davidosomething.com>
--

local function rule()
  term.setBackgroundColor(colors.lightGray)
  term.clearLine()
  print()
end

local function resetColors()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end

resetColors()
print()
rule()
resetColors()

print()
print(' Welcome to ' .. os.version())
print(' You are on ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
print()

rule()
resetColors()
print()
