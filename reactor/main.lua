--
-- reactor/main
-- v2.3.0
-- pastebin 710inmxN
-- by @davidosomething
--

-- -----------------------------------------------------------------------------
-- Constants -------------------------------------------------------------------
-- -----------------------------------------------------------------------------
ENERGY_MAX = 10000000
AUTOTOGGLE_ENERGY_THRESHOLD = 50

-- -----------------------------------------------------------------------------
-- Program state ---------------------------------------------------------------
-- -----------------------------------------------------------------------------
autotoggle = true
exit = false


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- monitor
local m = peripheral.find('monitor')
term.redirect(m)

-- reactor
local reactorSide = 'back'
local r = peripheral.wrap('back')

-- modem
local modemSide = 'left'
local w = peripheral.wrap(modemSide)
rednet.open(modemSide)


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- getEnergyPercentage
--
-- return int
local function getEnergyPercentage()
  return math.floor(r.getEnergyStored() / ENERGY_MAX * 100)
end

-- doAutotoggle
--
local function doAutotoggle()
  -- no fuel, leave off
  if r.getFuelAmount() == 0 then
    r.setActive(false)
    return
  end

  -- turn on if empty buffer
  if getEnergyPercentage() < AUTOTOGGLE_ENERGY_THRESHOLD then
    r.setActive(true)
    return
  end

  -- turn off if not needed
  if r.getEnergyProducedLastTick() == 0 then
    r.setActive(false)
    return
  end
end


-- statusLabel
--
local function statusLabel(text)
  m.setTextColor(colors.white)
  term.write(text)
end


-- status
--
local function status()
  m.clear()
  m.setTextScale(0.5)
  m.setCursorPos(1,1)

  statusLabel('reactor: ')
  if r.getActive() then
    m.setTextColor(colors.lime)
    term.write('ON')
  else
    m.setTextColor(colors.red)
    term.write('OFF')
  end
  print()

  statusLabel('energy: ')
  m.setTextColor(colors.lightGray)
  term.write(r.getEnergyStored() .. '/10000000 RF')
  print()

  statusLabel('output: ')
  m.setTextColor(colors.lightGray)
  term.write(r.getEnergyProducedLastTick() .. ' RF/t')
  print()

  statusLabel('fuel:   ')
  m.setTextColor(colors.yellow)
  term.write(r.getFuelAmount())
  m.setTextColor(colors.lightGray)
  term.write('/')
  m.setTextColor(colors.lightBlue)
  term.write(r.getWasteAmount())
  m.setTextColor(colors.lightGray)
  term.write('/' .. r.getFuelAmountMax() .. 'mb')
  print()

  statusLabel('usage:  ')
  m.setTextColor(colors.lightGray)
  term.write(r.getFuelConsumedLastTick() .. 'mb/t')
  print()

  statusLabel('core:   ')
  m.setTextColor(colors.lightGray)
  term.write(r.getFuelTemperature() .. 'C')
  print()

  statusLabel('case:   ')
  m.setTextColor(colors.lightGray)
  term.write(r.getCasingTemperature() .. 'C')
  print()

  statusLabel('auto:   ')
  if autotoggle then
    m.setTextColor(colors.lime)
    term.write('ON')
  else
    m.setTextColor(colors.gray)
    term.write('OFF')
  end

  m.setTextColor(colors.lightGray)
  print()
  print("q)uit  t)oggle  a)utotoggle")
  print()
end


-- toggleReactor
--
-- Switch reactor on/off
--
-- nil,boolean state - toggle if nil, on if true, off if false
local function toggleReactor(state)
  -- toggle
  if state == nil then
    state = not r.getActive()
  end

  -- set to exact
  r.setActive(state)
end


-- getMonitorTouch
--
local function getMonitorTouch()
  local event, side, x, y = os.pullEvent('monitor_touch')
  toggleReactor()
end


-- getTimeout
--
local function getTimeout()
  local event, timerHandler = os.pullEvent('timer')
  if autotoggle then
    doAutotoggle()
  end
end


-- getModemMessage
--
local function getModemMessage()
  local senderId, message, protocol = rednet.receive('reactor')
  if message == 'autotoggle' then
    autotoggle = not autotoggle
  elseif message == 'toggle' then
    toggleReactor()
  elseif message == 'on' then
    toggleReactor(true)
  elseif message == 'off' then
    toggleReactor(false)
  end

  local message = ''

  if r.getActive() then
    message = message .. 'ON'
  else
    message = message .. 'OFF'
  end

  message = message .. '\nrf: ' .. r.getEnergyStored()
  message = message .. '\nfuel: ' .. r.getFuelAmount() .. '/' .. r.getFuelAmountMax()

  if autotoggle then
    message = message .. '\nauto: ON'
  else
    message = message .. '\nauto: OFF'
  end

  rednet.send(senderId, message, 'remote')
end


-- getKey
--
local function getKey()
  local event, code = os.pullEvent('key')
  if code == keys.a then
    autotoggle = not autotoggle
  elseif code == keys.t then
    toggleReactor()
  elseif code == keys.q then
    exit = true
  end
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

while not exit do
  local myTimer = os.startTimer(1)
  status()

  parallel.waitForAny(getKey, getMonitorTouch, getModemMessage, getTimeout)
  os.cancelTimer(myTimer)
end

