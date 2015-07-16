---
-- Reactor autostart
-- reactor/main v3.1.0
--
-- pastebin 710inmxN
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals meter
os.loadAPI('lib/meter')

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
local PROTOCOL = 'reactor'
local REMOTE_PROTOCOL = 'reactor_remote'
local HOSTNAME = 'main'
local MODEM_SIDE = 'left'
local REACTOR_SIDE = 'back'

local ENERGY_MAX = 10000000
local AUTOTOGGLE_ENERGY_THRESHOLD = 50

local is_autotoggle = true
local is_exit = false


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- monitor
local m = peripheral.find('monitor')
local termW, termH -- luacheck: ignore termH
if m == nil then
  is_exit = true
else
  term.redirect(m)
  termW, termH = m.getSize()
end

-- reactor
local r = peripheral.wrap(REACTOR_SIDE)
if r == nil then is_exit = true end

-- modem
rednet.open(MODEM_SIDE)
rednet.host(PROTOCOL, HOSTNAME)


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

---
-- @return int reactor's energy buffer filled as a percentage
local function getEnergyPercentage()
  return math.floor(r.getEnergyStored() / ENERGY_MAX * 100)
end

--- Rules for when to turn the reactor on/off automatically
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


--- Send reactor status as a table over rednet
--
-- @tparam int remoteId computerId to send rednet message to
local function sendStatus(remoteId)
  local message = {}

  message['active']                 = r.getActive()
  message['energyStored']           = r.getEnergyStored()
  message['fuelAmount']             = r.getFuelAmount()
  message['wasteAmount']            = r.getWasteAmount()
  message['fuelAmountMax']          = r.getFuelAmountMax()
  message['energyProducedLastTick'] = r.getEnergyProducedLastTick()
  message['fuelConsumedLastTick']   = r.getFuelConsumedLastTick()
  message['fuelTemperature']        = r.getFuelTemperature()
  message['casingTemperature']      = r.getCasingTemperature()
  message['is_autotoggle']          = is_autotoggle
  message['energyPercentage']       = getEnergyPercentage()

  rednet.send(remoteId, message, REMOTE_PROTOCOL)
end


--- Output white text
--
-- @tparam string text
local function statusLabel(text)
  m.setTextColor(colors.white)
  write(text)
end


--- Display reactor status on monitor
--
local function status()
  m.clear()
  m.setTextScale(0.5)
  m.setCursorPos(1,1)

  statusLabel('reactor: ')
  if r.getActive() then
    m.setTextColor(colors.lime)
    write('ON')
  else
    m.setTextColor(colors.red)
    write('OFF')
  end
  print()

  meter.horizontal(2, 3, termW - 1, 3, r.getEnergyStored(), ENERGY_MAX)
  print()

  statusLabel('energy: ')
  m.setTextColor(colors.lightGray)
  write(r.getEnergyStored() .. '/10000000 RF')
  print()

  statusLabel('output: ')
  m.setTextColor(colors.lightGray)
  write(r.getEnergyProducedLastTick() .. ' RF/t')
  print()

  statusLabel('fuel:   ')
  m.setTextColor(colors.yellow)
  write(r.getFuelAmount())
  m.setTextColor(colors.lightGray)
  write('/')
  m.setTextColor(colors.lightBlue)
  write(r.getWasteAmount())
  m.setTextColor(colors.lightGray)
  write('/' .. r.getFuelAmountMax() .. 'mb')
  print()

  statusLabel('usage:  ')
  m.setTextColor(colors.lightGray)
  write(r.getFuelConsumedLastTick() .. 'mb/t')
  print()

  statusLabel('core:   ')
  m.setTextColor(colors.lightGray)
  write(r.getFuelTemperature() .. 'C')
  print()

  statusLabel('case:   ')
  m.setTextColor(colors.lightGray)
  write(r.getCasingTemperature() .. 'C')
  print()

  statusLabel('auto:   ')
  if is_autotoggle then
    m.setTextColor(colors.lime)
    write('ON')
  else
    m.setTextColor(colors.gray)
    write('OFF')
  end

  m.setTextColor(colors.lightGray)
  print()
  print("[q]uit  [t]oggle  [a]utotoggle")
  print()
end


--- Switch autotoggle on/off state
--
local function toggleAutotoggle()
  is_autotoggle = not is_autotoggle
end


--- Switch reactor on/off
--
-- @tparam {nil,boolean} state - toggle if nil, on if true, off if false
local function toggleReactor(state)
  -- toggle
  if state == nil then state = not r.getActive() end

  -- set to exact
  r.setActive(state)
end


--- Read right clicks on monitor to toggle reactor on/off
--
local function getMonitorTouch()
  -- luacheck: ignore event side x y
  local event, side, x, y = os.pullEvent('monitor_touch')
  toggleReactor()
end


--- Do some action based on user key input from terminal
--
local function getKey()
  -- luacheck: ignore event
  local event, code = os.pullEvent('char')
  if      code == keys.a then toggleAutotoggle()
  elseif  code == keys.t then toggleReactor()
  elseif  code == keys.q then is_exit = true
  end
end


--- Do some action if receiving redstone message from modem
--
local function getModemMessage()
  -- luacheck: ignore protocol
  local senderId, message, protocol = rednet.receive('reactor')
  if     message == 'autotoggle'  then toggleAutotoggle()
  elseif message == 'toggle'      then toggleReactor()
  elseif message == 'on'          then toggleReactor(true)
  elseif message == 'off'         then toggleReactor(false)
  end

  -- always send reactor status back when a request is made
  sendStatus(senderId)
end


--- Wait for system timer to trigger
--
local function getTimeout()
  -- luacheck: ignore event timerHandler
  local event, timerHandler = os.pullEvent('timer')
  if is_autotoggle then doAutotoggle() end
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  if is_exit then return end

  while not is_exit do
    local statusTimer = os.startTimer(1)
    status()

    parallel.waitForAny(getKey, getMonitorTouch, getModemMessage, getTimeout)
    os.cancelTimer(statusTimer)
  end
end)()
