---
-- Message of the day
-- bin/motd
--
-- pastebin zs7pMz89
--
-- @release 2.0.1
-- @author David O'Trakoun <me@davidosomething.com>
-- @script motd
--

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Reset to default terminal colors
--
local function resetColors()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end


--- Draw full length line
--
local function rule()
  term.setBackgroundColor(colors.lightGray)
  print()
  resetColors()
  print()
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  resetColors()
  rule()
  print()
  write(' Welcome to ' .. os.version())

  -- luacheck: globals _HOST
  if _HOST ~= nil then write(' (' .. _HOST .. ')\n') end

  print(' You are on ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
  print(' Day ' .. os.day() .. ' ' .. textutils.formatTime(os.time(), false))
  rule()
  print()
end)()
