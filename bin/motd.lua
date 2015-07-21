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
  print()
  resetColors()
  print()
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  resetColors()
  print()
  rule() -- --------------------------------------------------------------------
  print()
  write(' Welcome to ' .. os.version())
  if _CC_VERSION ~= nil then write(' (' .. _CC_VERSION .. ')\n') end
  print(' You are on ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
  print(' Day ' .. os.day() .. ' ' .. textutils.formatTime(os.time(), false))
  print()
  rule() -- --------------------------------------------------------------------
  print()
end)()
