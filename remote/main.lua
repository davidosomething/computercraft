---
-- Main remote control program
-- remote/main v2.0.0
--
-- @author David O'Trakoun <me@davidosomething.com>
--

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

--- Context for remotely controlling a reactor
local is_exit = false

local function reactorContext()
  local is_exit

  os.unloadAPI('/lib/reactorRemote')
  os.loadAPI('/lib/reactorRemote')
  reactorId = reactorRemote.findReactor()
  if reactorId ~= nil then
    reactorRemote.usage()
    reactorRemote.showStatusLabels()
    reactorRemote.requestStatus()
  else
    console.error('Reactor not found.')
    is_exit = true
  end

  while not is_exit do
    local statusTimer = os.startTimer(1)
    parallel.waitForAny(reactorGetKey, reactorRemote.getTimeout)
    os.cancelTimer(statusTimer)
  end

  print()
end

--- Read keyboard single character input
local function reactorGetKey()
  local event, code = os.pullEvent('key') -- luacheck: ignore event
  if      code == keys.a then reactorRemote.requestAction('autotoggle')
  elseif  code == keys.t then reactorRemote.requestAction('toggle')
  elseif  code == keys.q then is_exit = true
  end
end



-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()

  -- @TODO main menu to select context
  reactorContext()

end)()
