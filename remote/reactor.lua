--
-- remote/reactor
-- v3.0.0
-- by @davidosomething
-- pastebin SHyMGSSK
--
-- Remotely controls a reactor via Advanced Wireless Pocket Computer
--

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
local fuelMeterY = energyMeter + 3


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- find remote reactor
local reactorId = rednet.lookup(REACTOR_PROTOCOL, REACTOR_HOSTNAME)
if reactorId then rednet.open(MODEM_SIDE) else is_exit = true end


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- doAction
--
-- @param {string} action
local function doAction(action)
  if action == 'autotoggle' then
    rednet.send(reactorId, 'autotoggle', REACTOR_PROTOCOL)
  elseif action == 'toggle' then
    rednet.send(reactorId, 'toggle', REACTOR_PROTOCOL)
  end
end


-- requestStatus
--
-- Request status messages from reactors over rednet and display
--
local function requestStatus()
  rednet.send(reactorId, 'status', REACTOR_PROTOCOL)
  local senderId, data, protocol = rednet.receive(PROTOCOL, 1)
  if senderId ~= nil and message ~= nil then showStatus(data) end
end


-- getKey
--
local function getKey()
  local event, code = os.pullEvent('char')
  if      code == keys.a then doAction('autotoggle')
  elseif  code == keys.t then doAction('toggle')
  elseif  code == keys.q then is_exit = true
  end
end


-- getTimeout
--
local function getTimeout()
  local event, timerHandler = os.pullEvent('timer')
end


-- usage
--
local function usage()
  term.setCursorPos(1,1)
  print("Reactor remote control")
  print("[q]uit  [t]oggle  [a]utotoggle")
end


-- showStatusLabels
--
-- Display field labels for reactor status
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


-- showStatus
--
-- Display formatted reactor status
--
-- @param table data from requestStatus()
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
  meter.draw(7, energyMeterY, termW, energyMeterY,
             data['energyStored'], REACTOR_ENERGY_MAX)

  -- line 3
  term.setCursorPos(6, energyMeterY + 1)
  write(data['energyStored'].. ' / 10m RF (' .. data['energyPercentage'] .. '%)')

  -- line 4
  term.setCursorPos(6, energyMeter + 2)
  write(data['energyProducedLastTick'] .. ' RF/t')

  -- line 5
  meter.draw(7, fuelMeterY, termW, fuelMeterY,
             data['fuelAmount'], data['fuelAmountMax'])

  -- line 6
  term.setCursorPos(6, fuelMeterY + 1)
  write(data['fuelConsumedLastTick'] .. ' mb/t')
end

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  if is_exit then return end

  term.clear()
  usage()
  showStatusLabels()

  while not is_exit do
    local statusTimer = os.startTimer(1)
    requestStatus()

    parallel.waitForAny(getKey, getTimeout)
    os.cancelTimer(statusTimer)
  end
end)()