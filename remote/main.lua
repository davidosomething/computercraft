---
-- Main remote control program
-- remote/main v2.1.0
--
-- pastebin
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console reactorRemote

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')


-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local reactorId

local isExitReactorContext = false
local MODEM_SIDE = 'back'


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

rednet.open(MODEM_SIDE)


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Read keyboard single character input
--
local function reactorGetKey()
  local event, code = os.pullEvent('key') -- luacheck: ignore event
  if      code == keys.a then reactorRemote.requestAction(reactorId, 'autotoggle')
  elseif  code == keys.t then reactorRemote.requestAction(reactorId, 'toggle')
  elseif  code == keys.q then isExitReactorContext = true
  end
end


--- Wait for system timer to go off
--
local function reactorGetTimeout()
  -- luacheck: ignore event timerHandler
  local event, timerHandler = os.pullEvent('timer')
  reactorRemote.requestStatus(reactorId)
end


--- Context for remotely controlling a reactor
-- Reactor remote control event loop
--
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
    local statusTimer = os.startTimer(0.5)
    parallel.waitForAny(reactorGetKey, reactorGetTimeout)
    os.cancelTimer(statusTimer)
  end

  print()
end

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()

  -- @TODO main menu to select context
  reactorContext()

end)()
