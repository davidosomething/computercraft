---
-- startup.lua - Run on all computers; shows system meta data, updates system
-- scripts, loads APIs, autoruns local system scripts
--
-- @release 5.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--
-- luacheck: globals dko

devices = {}

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- My namespace
local startup = {}


--- Load global APIs
--
startup.initApis = function ()
  local APIS = { 'display', 'json', 'meter', 'config' }

  for i, file in ipairs(APIS) do
    os.unloadAPI('/lib/' .. file)
    os.loadAPI('/lib/' .. file)
    print('  Loaded ' .. file)
  end
end


--- Set up peripheral APIs in global
--
startup.initPeripherals = function ()
  local API_MAP = {
    ['BigReactors-Reactor']   = 'reactor',
    ['BigReactors-Reactor_0'] = 'reactor',
    ['BigReactors-Reactor_4'] = 'reactor',
    ['BigReactors-Reactor_6'] = 'reactor',
  }

  local peripherals = peripheral.getNames()
  for i = 1, #peripherals do
    local pType     = peripheral.getType(peripherals[i])
    local pLocation = peripherals[i]
    print('  Found ' .. pType ..  ' at "' .. pLocation .. '"')

    local pDevice = pType
    if API_MAP[pType] ~= nil then pDevice = API_MAP[pType] end

    -- make globally accessible
    devices[pDevice] = peripheral.wrap(pLocation)

    -- load library
    local pApiFile = '/lib/' .. pDevice
    if fs.exists(pApiFile) then
      print('  Initializing API for ' .. pDevice)
      os.unloadAPI(pApiFile)
      os.loadAPI(pApiFile)
    end
  end
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  if not fs.exists('/bin/dko') then
    print('error: Missing /bin/dko')
    return
  end
  os.unloadAPI('/bin/dko')
  os.loadAPI('/bin/dko')

  term.redirect(term.native())

  -- output message of the day
  dko.resetColors()
  dko.rule()
  print()
  write(' Welcome to ' .. os.version())
  -- luacheck: globals _HOST
  if _HOST ~= nil then write(' (' .. _HOST .. ')\n') end
  print(' Day ' .. os.day() .. ' ' .. textutils.formatTime(os.time(), false))
  dko.rule()
  print()

  term.setTextColor(colors.lightGray)

  dko.message('Initializing global APIs')
  startup.initApis()
  print()

  dko.message('Initializing peripheral APIs')
  startup.initPeripherals()
  print()
end)()

