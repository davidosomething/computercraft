---
-- Remotely controls a reactor via Advanced Wireless Pocket Computer
-- remote/reactor v3.2.5
--
-- pastebin SHyMGSSK
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals meter
os.loadAPI('lib/console')
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

local statusY = 4 -- below usage
local energyY = statusY + 2
local energyMeterY = energyY + 1
local energyTickY = energyMeterY + 1
local fuelMeterY = energyTickY + 2
local fuelConsumedY = fuelMeterY + 1


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- find remote reactor
local reactorId
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
-- output --------------
-- status     autotoggle
-- rf buffer
-- rf meter
-- rf/t
--
-- fuel meter
-- fuel mb/t
--
--
--
-- @tparam table data from requestStatus()
local function showStatus(data)
  local x = 6

  term.setCursorPos(1, statusY) -- below usage
  term.clearLine()
  if data['active'] then
    term.setTextColor(colors.red)
    write('ON ')
  else
    term.setTextColor(colors.lightGray)
    write('off')
  end

  term.setCursorPos(12, statusY) -- below usage
  if data['is_autotoggle'] then
    term.setTextColor(colors.red)
    write('AUTO')
  else
    term.setTextColor(colors.lightGray)
    write('auto')
  end

  term.setTextColor(colors.lightGray)
  term.setCursorPos(x, energyY)
  term.clearLine()
  write(data['energyStored'].. '/10m')

  meter.horizontal(x, energyMeterY, termW - 1, energyMeterY,
                   data['energyStored'], REACTOR_ENERGY_MAX,
                   colors.red)

  term.setCursorPos(x, energyTickY)
  term.clearLine()
  write(data['energyProducedLastTick'] .. ' RF/t')

  meter.horizontal(x, fuelMeterY, termW - 1, fuelMeterY,
                   data['fuelAmount'], data['fuelAmountMax'],
                   colors.yellow)

  term.setCursorPos(x, fuelConsumedY)
  term.clearLine()
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
  print("Reactor ID " .. reactorId)
  print("[q]uit [t]oggle [a]utotogg")
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

  term.setCursorPos(1, energyY)
  write('RF   ')    -- energy meter

  term.setCursorPos(1, fuelMeterY)
  write('Fuel ')    -- fuel meter
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()

  reactorId = findReactor()
  if reactorId == nil then
    log.error('No reactors in range.')
    return
  end

  usage()

  if reactorId == nil then
    reactorId = rednet.lookup(REACTOR_PROTOCOL, REACTOR_HOSTNAME)
    reactorId = findReactor()
    rednet.broadcast('find', PROTOCOL)
    print("ERROR: No reactor @ " .. REACTOR_PROTOCOL .. "." .. REACTOR_HOSTNAME)
    print("Falling back to ID 1")
    read()
    reactorId = 1
  end

  showStatusLabels()


  requestStatus()

  while not is_exit do
    local statusTimer = os.startTimer(1)
    parallel.waitForAny(getKey, getTimeout)
    os.cancelTimer(statusTimer)
  end

  print()
end)()
