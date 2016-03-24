---
-- startup.lua - Run on all computers; shows system meta data, updates system
-- scripts, loads APIs, autoruns local system scripts
--
-- @release 5.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

devices = {}

os.unloadAPI('/bin/dko')
os.loadAPI('/bin/dko')

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- My namespace
local startup = {}

--- Create system dirs and set aliases
--
startup.bootstrap = function ()
  shell.setDir('/')

  -- system paths
  shell.run('mkdir', 'bin')
  shell.run('mkdir', 'lib')
  shell.run('mkdir', 'tmp')

  -- set path
  shell.setPath(shell.path()..':/bin')

  -- set aliases
  shell.setAlias('l', 'list')
  shell.setAlias('ll', 'list')
  shell.setAlias('e', 'edit')
  shell.setAlias('up', 'startup update')
  shell.setAlias('update', 'startup update')
end


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

  -- actual startup
  dko.message('Bootstrapping')
  startup.bootstrap()
  print()

  dko.message('Initializing global APIs')
  startup.initApis()
  print()

  dko.message('Initializing peripheral APIs')
  startup.initPeripherals()
  print()
end)()

