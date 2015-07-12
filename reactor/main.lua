--
-- reactor/main
-- v2.1.5
-- pastebin 710inmxN
-- by @davidosomething
--

-- monitor
local m = peripheral.find('monitor')
if m then
  term.redirect(m)
end

-- reactor
local r = peripheral.wrap('back')

-- modem
local modemSide = 'left'
local w = peripheral.wrap(modemSide)
rednet.open(modemSide)

autotoggle = true
exit = false

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
  print('fuel:   ' .. r.getFuelAmount() .. '/' .. r.getFuelAmountMax() .. ' mb')
  print('usage:  ' .. r.getFuelConsumedLastTick() .. ' mb/t')
  print('waste:  ' .. r.getWasteAmount() .. ' mb')
  print('core:   ' .. r.getFuelTemperature() .. ' C')
  print('case:   ' .. r.getCasingTemperature() .. ' C')

  if autotoggle then
    print('autotoggle: ON' )
  else
    print('autotoggle: OFF' )
  end
end

-- toggle_reactor
--
-- Switch reactor on/off
--
local function toggle_reactor()
  if r.getActive() then
    r.setActive(false)
  else
    r.setActive(true)
  end
end

local function get_monitor_touch()
  local event, side, x, y = os.pullEvent('monitor_touch')
  toggle_reactor()
end

local function get_timeout()
  local event, timerHandler = os.pullEvent('timer')
  autotoggle()
end

local function get_modem_message()
  local senderId, message, protocol = rednet.receive('reactor')
  if message == 'toggle' then
    toggle_reactor()
  end

  local message = ''

  if r.getActive() then
    message = message .. 'ON'
  else
    message = message .. 'OFF'
  end

  message = message .. '\nrf: ' .. r.getEnergyStored()
  message = message .. '\nfuel: ' .. r.getFuelAmount() .. '/' .. r.getFuelAmountMax()
  rednet.send(senderId, message, 'remote')
end

local function get_key()
  local event, code = os.pullEvent('key_up')
  if code == key.q then
    exit = true
  end
end

while not exit do
  local myTimer = os.startTimer(1)
  m.clear()
  m.setTextScale(0.5)
  m.setCursorPos(1,1)
  status()

  parallel.waitForAny(get_key, get_monitor_touch, get_modem_message, get_timeout)
  os.cancelTimer(myTimer)
end


