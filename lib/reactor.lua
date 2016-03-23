---
-- lib/reactor.lua - Big Reactor API
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals config display meter
-- luacheck: globals devices
-- luacheck: globals label

local DEVICE     = 'reactor'
local ENERGY_MAX = 10000000
local TEMP_MAX   = 900

local Reactor = devices[DEVICE]
local state = {}

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Get the energy stored in the reactor's buffer as a percentage
-- @return int buffer percent full
function getEnergyPercentage() -- luacheck: ignore
  return meter.percent(Reactor.getEnergyStored(), ENERGY_MAX)
end


--- Display reactor status on in a window
--
function updateStatus() -- luacheck: ignore
  display.use(DEVICE)
  local termW, termH = term.getSize()

  -- line 1
  label('reactor: ')
  if Reactor.getActive() then
    term.setTextColor(colors.lime)
    write('ON')
  else
    term.setTextColor(colors.red)
    write('off')
  end

  term.setCursorPos(19,1)
  label('optimize: ')
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
  label('energy: ')
  term.setTextColor(colors.lightGray)
  write(Reactor.getEnergyStored() .. '/10000000 RF')
  print()

  -- line 4
  meter.horizontal(2, 4, termW - 1, 4,
    Reactor.getEnergyStored(), ENERGY_MAX,
    colors.red)

  -- line 5
  print()

  -- line 6
  label('output: ')
  term.setTextColor(colors.lightGray)
  write(Reactor.getEnergyProducedLastTick() .. ' RF/t')
  print()

  -- line 7
  label('fuel:   ')
  term.setTextColor(colors.yellow)
  write(Reactor.getFuelAmount())
  term.setTextColor(colors.lightGray)
  write('/')
  term.setTextColor(colors.lightBlue)
  write(Reactor.getWasteAmount())
  term.setTextColor(colors.lightGray)
  write('/' .. Reactor.getFuelAmountMax() .. 'mb')
  print()

  -- line 8
  meter.horizontal(2, 8, termW - 1, 8,
    Reactor.getFuelAmount(), Reactor.getFuelAmountMax(),
    colors.yellow)

  -- line 9
  print()

  label('usage:  ')
  term.setTextColor(colors.lightGray)
  write(Reactor.getFuelConsumedLastTick() .. 'mb/t')
  print()

  label('core:   ')
  term.setTextColor(colors.lightGray)
  write(Reactor.getFuelTemperature() .. 'C')
  print()

  label('case:   ')
  term.setTextColor(colors.lightGray)
  write(Reactor.getCasingTemperature() .. 'C')
  print()
end


--- Switch optimize on/off state, persist to configFile
--
function toggleOptimize() -- luacheck: ignore
  state.isOptimizing = not state.isOptimizing
  config.set('reactor', state)
  config.save()
end


--- Switch reactor on/off
--
-- @tparam {nil,boolean} state - toggle if nil, on if true, off if false
function toggleReactor() -- luacheck: ignore
  state.isActive = not Reactor.getActive()
  Reactor.setActive(state.isActive)
  config.set('reactor', state)
  config.save()
end


--- Lower temperature below optimal max
--
function optimizeTemp()
  local insertionLevel = Reactor.getControlRodLevel(0)
  while true do
    print('Optimizing control rod insertion... (any key to cancel)')
    print('      level: ' .. Reactor.getControlRodLevel(0))
    print('  fuel temp: ' .. Reactor.getFuelTemperature() .. 'C')

    local isHot = Reactor.getFuelTemperature() > TEMP_MAX
    if isHot then insertionLevel = insertionLevel + 2 else break end
    Reactor.setAllControlRodLevels(insertionLevel)

    -- let optimize for 2 seconds, or user does something
    local timer = os.startTimer(2)
    local event = { os.pullEvent() }
    if (event[1] ~= "timer" or event[2] ~= timer) then
      print('User cancelled optimizing (' .. event[1] .. ')')
      break
    end
  end
end


--- Optimize rod level based on energy buffer, then level off by temperature
--
function optimize() -- luacheck: ignore
  if not state.isActive then
    print('Reactor is not active')
    return
  end

  -- Initialize all rods to the buffer level so reactor is essentially off
  -- when buffer is full
  Reactor.setAllControlRodLevels(getEnergyPercentage())

  -- Check if that does the trick
  print('Optimizing control rod insertion... (any key to cancel)')
  print('      level: ' .. Reactor.getControlRodLevel(0))
  os.sleep(2)
  local isOptimal = Reactor.getFuelTemperature() < TEMP_MAX
  if isOptimal then return else optimizeTemp() end
end


--- Called by initPeripherals
--
function init() -- luacheck: ignore
  state.isActive     = Reactor.getActive()
  state.isOptimizing = config['reactor'].isOptimizing
end


--- Run in background tab!
--
function bg() -- luacheck: ignore
  while true do
    updateStatus() -- luacheck: ignore
    os.sleep(2)
  end
end

