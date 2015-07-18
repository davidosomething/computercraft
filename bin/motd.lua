---
-- Message of the day
-- motd v1.0.1
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

rule()
resetColors()

print('Welcome to ' .. os.version())
print(' You are ' .. os.getComputerLabel() .. ':' .. os.getComputerID())

rule()
resetColors()
