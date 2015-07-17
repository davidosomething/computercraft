---
-- Main remote control program
-- remote/main v2.0.0
--
-- @author David O'Trakoun <me@davidosomething.com>
--

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

--- Context for remotely controlling a reactor
local isExitReactorContext = false

local function reactorContext()
  os.unloadAPI('/lib/reactorRemote')
  os.loadAPI('/lib/reactorRemote')
  reactorId = reactorRemote.findReactor()
  if reactorId ~= nil then
    reactorRemote.usage()
    reactorRemote.showStatusLabels(reactorId)
    reactorRemote.requestStatus(reactorId)
  else
    console.error('Reactor not found.')
    isExitReactorContext = true
  end

  while not isExitReactorContext do
    local statusTimer = os.startTimer(1)
    parallel.waitForAny(reactorGetKey, reactorGetTimeout)
    os.cancelTimer(statusTimer)
  end

  print()
end

--- Read keyboard single character input
local function reactorGetKey()
  local event, code = os.pullEvent('key') -- luacheck: ignore event
  if      code == keys.a then reactorRemote.requestAction(reactorId, 'autotoggle')
  elseif  code == keys.t then reactorRemote.requestAction(reactorId, 'toggle')
  elseif  code == keys.q then isExitReactorContext = true
  end
end

--- Wait for system timer to go off
local function reactorGetTimeout()
  -- luacheck: ignore event timerHandler
  local event, timerHandler = os.pullEvent('timer')
  reactorRemote.requestStatus(reactorId)
end




-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()

  -- @TODO main menu to select context
  reactorContext()

end)()
