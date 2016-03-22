---
-- lib/reactor.lua - Big Reactor API
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals config devices monitor json meter label

local ENERGY_MAX = 10000000
local TEMP_MAX   = 900

local state = {}

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Get the energy stored in the reactor's buffer as a percentage
-- @return int buffer percent full
local function getEnergyPercentage() -- luacheck: ignore
  return meter.percent(devices['reactor'].getEnergyStored(), ENERGY_MAX)
end


--- Display reactor status on monitor
--
local function status() -- luacheck: ignore
  devices['monitor'].clear()
  devices['monitor'].setTextScale(0.5)
  devices['monitor'].setCursorPos(1,1)

  -- line 1
  label('reactor: ')
  if devices['reactor'].getActive() then
    devices['monitor'].setTextColor(colors.lime)
    write('ON')
  else
    devices['monitor'].setTextColor(colors.red)
    write('off')
  end

  devices['monitor'].setCursorPos(19,1)
  label('auto: ')
  if state.isAutotoggle then
    devices['monitor'].setTextColor(colors.lime)
    write('ON')
  else
    devices['monitor'].setTextColor(colors.gray)
    write('off')
  end
  print()

  -- line 2
  print()

  -- line 3
  label('energy: ')
  devices['monitor'].setTextColor(colors.lightGray)
  write(devices['reactor'].getEnergyStored() .. '/10000000 RF')
  print()

  -- line 4
  meter.horizontal(2, 4, monitor.termW - 1, 4,
    devices['reactor'].getEnergyStored(), ENERGY_MAX,
    colors.red)

  -- line 5
  print()

  -- line 6
  label('output: ')
  devices['monitor'].setTextColor(colors.lightGray)
  write(devices['reactor'].getEnergyProducedLastTick() .. ' RF/t')
  print()

  -- line 7
  label('fuel:   ')
  devices['monitor'].setTextColor(colors.yellow)
  write(devices['reactor'].getFuelAmount())
  devices['monitor'].setTextColor(colors.lightGray)
  write('/')
  devices['monitor'].setTextColor(colors.lightBlue)
  write(devices['reactor'].getWasteAmount())
  devices['monitor'].setTextColor(colors.lightGray)
  write('/' .. devices['reactor'].getFuelAmountMax() .. 'mb')
  print()

  -- line 8
  meter.horizontal(2, 8, monitor.termW - 1, 8,
    devices['reactor'].getFuelAmount(), devices['reactor'].getFuelAmountMax(),
    colors.yellow)

  -- line 9
  print()

  label('usage:  ')
  devices['monitor'].setTextColor(colors.lightGray)
  write(devices['reactor'].getFuelConsumedLastTick() .. 'mb/t')
  print()

  label('core:   ')
  devices['monitor'].setTextColor(colors.lightGray)
  write(devices['reactor'].getFuelTemperature() .. 'C')
  print()

  label('case:   ')
  devices['monitor'].setTextColor(colors.lightGray)
  write(devices['reactor'].getCasingTemperature() .. 'C')
  print()
end


--- Switch autotoggle on/off state, persist to configFile
--
local function toggleAutotoggle() -- luacheck: ignore
  -- toggle
  state.isAutotoggle = not state.isAutotoggle
  config.reactor = state

  -- save
  local configFile = fs.open('/config.json', 'w')
  configFile.write(textutils.serializeJSON(config))
  configFile.close()
end


--- Switch reactor on/off
--
-- @tparam {nil,boolean} state - toggle if nil, on if true, off if false
local function toggleReactor() -- luacheck: ignore
  -- toggle
  state.isActive = not devices['reactor'].getActive()
  devices['reactor'].setActive(state.isActive)

  -- save
  config.reactor = state
  local configFile = fs.open('/config.json', 'w')
  configFile.write(textutils.serializeJSON(config))
  configFile.close()
end


--- Lower temperature below optimal max
--
local function optimizeTemp()
  local insertionLevel = devices['reactor'].getControlRodLevel(0)
  while true do
    print('Optimizing control rod insertion... (any key to cancel)')
    print('      level: ' .. devices['reactor'].getControlRodLevel(0))
    print('  fuel temp: ' .. devices['reactor'].getFuelTemperature() .. 'C')

    local isHot = devices['reactor'].getFuelTemperature() > TEMP_MAX
    if isHot then insertionLevel = insertionLevel + 2 else break end
    devices['reactor'].setAllControlRodLevels(insertionLevel)

    -- let optimize for 2 seconds, or user does something
    local timer = os.startTimer(2)
    local event = {os.pullEvent()}
    if (event[1] ~= "timer" or event[2] ~= timer) then
      print('User cancelled optimizing (' .. event[1] .. ')')
      break
    end
  end
end


--- Optimize rod level based on energy buffer, then level off by temperature
--
local function optimize() -- luacheck: ignore
  if not state.isActive then
    print('Reactor is not active')
    return
  end

  -- Initialize all rods to the buffer level so reactor is essentially off
  -- when buffer is full
  devices['reactor'].setAllControlRodLevels(getEnergyPercentage())

  -- Check if that does the trick
  print('Optimizing control rod insertion... (any key to cancel)')
  print('      level: ' .. devices['reactor'].getControlRodLevel(0))
  os.sleep(2)
  local isOptimal = devices['reactor'].getFuelTemperature() < TEMP_MAX
  if isOptimal then return else optimizeTemp() end
end


--- Called by setupPeripherals
--
local function init() -- luacheck: ignore
  state.isActive     = config['reactor'].isActive
  state.isAutotoggle = config['reactor'].isAutotoggle
end

