---
-- Remotely controls a reactor via Advanced Wireless Pocket Computer
-- remote/reactor v3.1.1
--
-- pastebin SHyMGSSK
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals meter
os.loadAPI('lib/meter')

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
local PROTOCOL = 'reactor_remote'
local MODEM_SIDE = 'back'
local REACTOR_PROTOCOL = 'reactor'
local REACTOR_HOSTNAME = 'main'
local REACTOR_ENERGY_MAX = 10000000

local is_exit = false
local termW, termH = term.getSize()
local statusY = 4             -- below usage
local energyMeterY = statusY + 1
local fuelMeterY = energyMeterY + 3


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- find remote reactor
local reactorId = rednet.lookup(REACTOR_PROTOCOL, REACTOR_HOSTNAME)
if reactorId == nil then
  print("ERROR: No reactor @ " .. REACTOR_PROTOCOL .. "." .. REACTOR_HOSTNAME)
  print("Falling back to ID 1")
  read()
  reactorId = 1
end

rednet.open(MODEM_SIDE)

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Request one of the reactor tasks
--
-- @tparam {string} action
local function requestAction(action)
  if action == 'autotoggle' then
    rednet.send(reactorId, 'autotoggle', REACTOR_PROTOCOL)
  elseif action == 'toggle' then
    rednet.send(reactorId, 'toggle', REACTOR_PROTOCOL)
  end
end


--- Display formatted reactor status
--
-- @tparam table data from requestStatus()
local function showStatus(data)
  -- line 1
  term.setCursorPos(1, statusY) -- below usage
  if data['active'] then term.blit('ON ', '555', 'fff')
  else                   term.blit('OFF', '777', 'fff')
  end

  term.setCursorPos(6, statusY) -- below usage
  if data['is_autotoggle'] then term.blit('auto', '5555', 'ffff')
  else                          term.blit('auto', '7777', 'ffff')
  end

  -- line 2
  meter.horizontal(7, energyMeterY, termW, energyMeterY,
             data['energyStored'], REACTOR_ENERGY_MAX)

  -- line 3
  term.setCursorPos(6, energyMeterY + 1)
  write(data['energyStored'].. ' / 10m RF (' .. data['energyPercentage'] .. '%)')

  -- line 4
  term.setCursorPos(6, energyMeterY + 2)
  write(data['energyProducedLastTick'] .. ' RF/t')

  -- line 5
  meter.horizontal(7, fuelMeterY, termW, fuelMeterY,
             data['fuelAmount'], data['fuelAmountMax'])

  -- line 6
  term.setCursorPos(6, fuelMeterY + 1)
  write(data['fuelConsumedLastTick'] .. ' mb/t')
end


--- Request status messages from reactors over rednet and display
--
local function requestStatus()
  rednet.send(reactorId, 'status', REACTOR_PROTOCOL)
  -- luacheck: ignore protocol
  local senderId, data, protocol = rednet.receive(PROTOCOL, 1)
  if senderId ~= nil and data ~= nil then showStatus(data) end
end


--- Read keyboard single character input
local function getKey()
  local event, code = os.pullEvent('key') -- luacheck: ignore event
  if      code == keys.a then requestAction('autotoggle')
  elseif  code == keys.t then requestAction('toggle')
  elseif  code == keys.q then is_exit = true
  end
end


--- Wait for system timer to go off
local function getTimeout()
  -- luacheck: ignore event timerHandler
  local event, timerHandler = os.pullEvent('timer')
  requestStatus()
end


--- Display script usage
local function usage()
  term.setCursorPos(1,1)
  print("Reactor remote control")
  print("[q]uit  [t]oggle  [a]utotoggle")
end


--- Display field labels for reactor status
--
local function showStatusLabels()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)

  for lineNumber = statusY, termH do
    term.setCursorPos(1, lineNumber)
    term.clearLine()
  end

  term.setCursorPos(1, energyMeterY)
  print('RF   ')    -- energy meter

  term.setCursorPos(1, fuelMeterY)
  print('Fuel ')    -- fuel meter
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()
  if is_exit then return end

  usage()
  showStatusLabels()

  while not is_exit do
    local statusTimer = os.startTimer(1)
    parallel.waitForAny(getKey, getTimeout)
    os.cancelTimer(statusTimer)
  end
end)()
