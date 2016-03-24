---
-- lib/reactor.lua -- Big Reactor API
--
-- @release 1.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals config display meter
-- luacheck: globals devices
-- luacheck: globals dko

local DEVICE     = 'reactor'
local ENERGY_MAX = 10000000
local TEMP_MAX   = 900
local REACTOR    = devices[DEVICE]

local state

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Get the energy stored in the reactor's buffer as a percentage
--
-- @return int buffer percent full
function getEnergyPercentage() -- luacheck: ignore
  return meter.percent(REACTOR.getEnergyStored(), ENERGY_MAX)
end


--- Display reactor status on in a window
--
function updateStatus() -- luacheck: ignore
  display.use(DEVICE)
  local termW, termH = term.getSize()

  -- line 1
  dko.label('reactor: ')
  if REACTOR.getActive() then
    term.setTextColor(colors.lime)
    write('ON')
  else
    term.setTextColor(colors.red)
    write('off')
  end

  term.setCursorPos(19,1)
  dko.label('optimize: ')
  if state.isOptimizing then
    term.setTextColor(colors.lime)
    write('ON')
  else
    term.setTextColor(colors.gray)
    write('off')
  end
  print()

  -- line 2
  print()

  -- line 3
  dko.label('energy: ')
  term.setTextColor(colors.lightGray)
  write(REACTOR.getEnergyStored() .. '/10000000 RF')
  print()

  -- line 4
  meter.horizontal(2, 4, termW - 1, 4,
    REACTOR.getEnergyStored(), ENERGY_MAX,
    colors.red)

  -- line 5
  print()

  -- line 6
  dko.label('output: ')
  term.setTextColor(colors.lightGray)
  write(REACTOR.getEnergyProducedLastTick() .. ' RF/t')
  print()

  -- line 7
  dko.label('fuel:   ')
  term.setTextColor(colors.yellow)
  write(REACTOR.getFuelAmount())
  term.setTextColor(colors.lightGray)
  write('/')
  term.setTextColor(colors.lightBlue)
  write(REACTOR.getWasteAmount())
  term.setTextColor(colors.lightGray)
  write('/' .. REACTOR.getFuelAmountMax() .. 'mb')
  print()

  -- line 8
  meter.horizontal(2, 8, termW - 1, 8,
    REACTOR.getFuelAmount(), REACTOR.getFuelAmountMax(),
    colors.yellow)

  -- line 9
  print()

  dko.label('usage:  ')
  term.setTextColor(colors.lightGray)
  write(REACTOR.getFuelConsumedLastTick() .. 'mb/t')
  print()

  dko.label('core:   ')
  term.setTextColor(colors.lightGray)
  write(REACTOR.getFuelTemperature() .. 'C')
  print()

  dko.label('case:   ')
  term.setTextColor(colors.lightGray)
  write(REACTOR.getCasingTemperature() .. 'C')
  print()
end


--- Switch optimize on/off state, persist to configFile
--
function toggleOptimize() -- luacheck: ignore
  state.isOptimizing = not state.isOptimizing
  config.set('reactor', state)
  config.save()
end


--- Switch reactor on/off, persist to configFile
--
-- @tparam {nil,boolean} state - toggle if nil, on if true, off if false
function toggleReactor() -- luacheck: ignore
  state.isActive = not REACTOR.getActive()
  REACTOR.setActive(state.isActive)
  config.set('reactor', state)
  config.save()
end


--- Is the reactor running hot?
--
-- @return boolean
function isHot()
  return REACTOR.getFuelTemperature() > TEMP_MAX
end


--- Lower temperature below optimal max
--
function optimizeTemp()
  display.use(DEVICE)

  local insertionLevel = REACTOR.getControlRodLevel(0)

  while true do
    print('Optimizing control rod insertion... (any key to cancel)')
    print('      level: ' .. REACTOR.getControlRodLevel(0))
    print('  fuel temp: ' .. REACTOR.getFuelTemperature() .. 'C')

    if isHot() then
      insertionLevel = insertionLevel + 2
    else
      print('Reactor optimized!')
      break
    end
    REACTOR.setAllControlRodLevels(insertionLevel)

    -- let optimize for 2 seconds, or user does something
    local timer = os.startTimer(2) -- luacheck: ignore
    local event = { os.pullEvent() }
    if (event[1] ~= "timer") then
      print('User cancelled optimizing (' .. event[1] .. ')')
      break
    end
  end
end


--- Optimize rod level based on energy buffer, then level off by temperature
--
function optimize() -- luacheck: ignore
  display.use(DEVICE)

  if not REACTOR.getActive() then
    print('Reactor is not active')
    return
  end

  -- Initialize all rods to the buffer level so reactor is essentially off
  -- when buffer is full
  REACTOR.setAllControlRodLevels(getEnergyPercentage())

  -- Optimize temp if hot
  print('Optimizing control rod insertion... (any key to cancel)')
  print('      level: ' .. REACTOR.getControlRodLevel(0))
  os.sleep(2)
  if isHot() then optimizeTemp() end
end


--- Called by initPeripherals
--
function init() -- luacheck: ignore
  state = {
    isActive     = REACTOR.getActive(),
    isOptimizing = config['reactor'].isOptimizing,
  }
end


--- Run in background tab!
--
function bg() -- luacheck: ignore
  while true do
    updateStatus() -- luacheck: ignore
    os.sleep(2)
  end
end

