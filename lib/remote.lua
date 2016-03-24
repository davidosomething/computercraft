---
-- lib/remote.lua -- Main remote control program
--
-- @release 2.1.1
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console reactorRemote

-- ---------------------------------------------------------------------------
-- Meta
-- ---------------------------------------------------------------------------

local reactorId
local isExitReactorContext = false
local MODEM_SIDE = 'back'

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  term.clear()

  rednet.open(MODEM_SIDE)

  -- @TODO main menu to select context
  reactorContext()
end)()
