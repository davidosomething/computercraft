---
-- Message of the day
-- bin/motd
--
-- pastebin zs7pMz89
--
-- @release 2.0.0
-- @author David O'Trakoun <me@davidosomething.com>
-- @script motd
--

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

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
  term.clearLine()
  print()
  resetColors()
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  resetColors()
  print()
  rule() -- --------------------------------------------------------------------
  print()
  print(' Welcome to ' .. os.version())
  print(' You are on ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
  print(' ' .. os.day() .. ' ' .. textutils.formatTime(os.time(), false))
  print()
  rule() -- --------------------------------------------------------------------
  print()
end)()
