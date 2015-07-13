--
-- reactor/main
-- v2.2.0
-- pastebin 710inmxN
-- by @davidosomething
--


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
if m then
  term.redirect(m)
end

-- reactor
local reactorSide = 'back'
if peripheral.isPresent(reactorSide) then
  local r = peripheral.wrap('back')
else
  exit = true
end

-- modem
local modemSide = 'left'
local w = peripheral.wrap(modemSide)
rednet.open(modemSide)


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- autotoggle
--
local function autotoggle()
  -- no fuel, leave off
  if r.getFuelAmount() == 0 then
    r.setActive(false)
    return
  end

  -- turn on if empty buffer
  if r.getEnergyStored() == 0 then
    r.setActive(true)
    return
  end

  -- turn off if not needed
  if r.getEnergyProducedLastTick() == 0 then
    r.setActive(false)
    return
  end
end


-- status_label
--
local function status_label(text)
  m.setTextColor(colors.white)
  term.write(text)
end


-- status
--
local function status()
  if r.getActive() then
    m.setTextColor(colors.lime)
    print('reactor: ON')
  else
    m.setTextColor(colors.red)
    print('reactor: OFF')
  end

  m.setTextColor(colors.white)

  print('energy: ' .. r.getEnergyStored() .. '/10000000 RF')
  print('output: ' .. r.getEnergyProducedLastTick() .. ' RF/t')

  status_label('fuel:   ')
  m.setTextColor(colors.yellow)
  term.write(r.getFuelAmount())
  m.setTextColor(colors.lightGray)
  term.write('/' .. r.getFuelAmountMax() .. 'mb\n')

  status_label('waste:  ')
  m.setTextColor(colors.lightBlue)
  term.write(r.getWasteAmount())
  m.setTextColor(colors.lightGray)
  term.write('mb')

  print('usage:  ' .. r.getFuelConsumedLastTick() .. 'mb/t')
  print('core:   ' .. r.getFuelTemperature() .. 'C')
  print('case:   ' .. r.getCasingTemperature() .. 'C')

  if autotoggle then
    print('autotoggle: ON' )
  else
    print('autotoggle: OFF' )
  end

  print()
  print("q)uit  t)oggle  a)utotoggle")
  print()
end


-- toggle_reactor
--
-- Switch reactor on/off
--
-- nil,boolean state - toggle if nil, on if true, off if false
local function toggle_reactor(state)
  -- toggle
  if state == nil then
    state = not r.getActive()
  end

  -- set to exact
  r.setActive(state)
end


-- get_monitor_touch
--
local function get_monitor_touch()
  local event, side, x, y = os.pullEvent('monitor_touch')
  toggle_reactor()
end


-- get_timeout
--
local function get_timeout()
  local event, timerHandler = os.pullEvent('timer')
  if autotoggle then
    autotoggle()
  end
end


-- get_modem_message
--
local function get_modem_message()
  local senderId, message, protocol = rednet.receive('reactor')
  if message == 'autotoggle' then
    toggle_reactor()
  elseif message == 'toggle' then
    toggle_reactor()
  elseif message == 'on' then
    toggle_reactor(true)
  elseif message == 'off' then
    toggle_reactor(false)
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


-- get_key
--
local function get_key()
  local event, code = os.pullEvent('key')
  if code == key.a then
    autotoggle = not autotoggle
  elseif code == key.t then
    toggle_reactor()
  elseif code == key.q then
    exit = true
  end
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

while not exit do
  local myTimer = os.startTimer(1)
  m.clear()
  m.setTextScale(0.5)
  m.setCursorPos(1,1)
  status()

  parallel.waitForAny(get_key, get_monitor_touch, get_modem_message, get_timeout)
  os.cancelTimer(myTimer)
end

