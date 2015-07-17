---
-- Message of the day
-- motd v1.0.0
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

--- Show startup message
--
(function ()
  rule()

  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  print('Welcome to ' .. os.version())
  print(' You are ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
  print(' Booted from ' .. shell.getRunningProgram())
  print()

  rule()

  term.setBackgroundColor(colors.black)
end)()
