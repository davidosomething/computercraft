---
-- Run on all computers; shows system meta data, updates system scripts, loads
-- APIs, autoruns local system scripts
-- startup
--
-- pastebin uVtX8Yx6
--
-- @release 5.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

local tArgs = { ... }

local systemScripts = {}
systemScripts['bin/gh']     = 'QwW6Xg6M'
systemScripts['bin/script'] = '0khvYUyX'

devices = {}

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Reset to default terminal colors
--
local function resetColors()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end


--- Draw full length line
--
local function rule()
  term.setBackgroundColor(colors.lightGray)
  print()
  resetColors()
  print()
end


--- Output fancy system message
--
-- @tparam {string} text
local function message(text)
  -- square
  term.setBackgroundColor(colors.magenta)
  write(' ')

  -- text
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.magenta)
  write(' ' .. text .. '\n')
end


--- Output fancy error message
--
-- @tparam {string} text
local function errorMessage(text)
  -- square
  term.setBackgroundColor(colors.red)
  write(' ')

  -- text
  term.setBackgroundColor(colors.pink)
  term.setTextColor(colors.red)
  write(' ' .. text .. '\n')
end


--- Wait for keypress
--
local function pause()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
end


--- Create system dirs and set aliases
--
local function bootstrap()
  term.setTextColor(colors.lightGray)

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


--- Updates the updater
--
-- @tparam {table} systemScripts
local function systemUpdate()
  term.setTextColor(colors.lightGray)

  shell.setDir('/')

  for dest,pastebinId in pairs(systemScripts) do
    (function()
      if pastebinId == nil then return end

      local tmpfile = 'tmp/' .. pastebinId
      fs.delete(tmpfile)

      if http and fs.exists('bin/gh') then
        shell.run('gh', 'get', dest .. '.lua', tmpfile)
      else
        shell.run('pastebin', 'get', pastebinId, tmpfile)
      end

      if fs.exists(tmpfile) then
        fs.delete(dest)
        fs.move(tmpfile, dest)
      end
    end)()
  end
end


--- Update startup and other system scripts
--
local function update()
  if not fs.exists('bin/script') then
    errorMessage('Missing bin/script')
    pause()
    return
  end

  shell.run('script', 'get', 'uVtX8Yx6', 'startup')
  shell.run('script', 'get', 'zs7pMz89', 'bin/motd')
  shell.run('script', 'get', 'aq8ci7Fc', 'lib/console')
  shell.run('script', 'get', '4nRg9CHU', 'lib/json')
  shell.run('script', 'get', 'LeGJ4Wkb', 'lib/meter')
  shell.run('script', 'get', 'rTCUgtUz', 'lib/wireless')
  shell.run('script', 'get', 'grsCHK53', 'lib/cx4', 'pastebin')
end


--- Do full update only
--
local function doUpdate()
  systemUpdate()
  update()
end


--- Set up peripheral APIs in global
local function setupPeripherals()
  local API_MAP = {}
  API_MAP['BigReactors-Reactor']   = 'reactor'
  API_MAP['BigReactors-Reactor_0'] = 'reactor'
  API_MAP['BigReactors-Reactor_4'] = 'reactor'
  API_MAP['BigReactors-Reactor_6'] = 'reactor'

  local peripherals = peripheral.getNames()
  for i = 1, #peripherals do
    local pType     = peripheral.getType(peripherals[i])
    local pLocation = peripherals[i]
    message('  Found ' .. pType ..  ' at "' .. pLocation .. '"')

    local pDevice = pType
    if API_MAP[pType] ~= nil then pDevice = API_MAP[pType] end

    -- make globally accessible
    _G[pDevice] = peripheral.wrap(pLocation)

    -- load library
    local pApiFile = '/lib/' .. pDevice
    if fs.exists(pApiFile) then
      message('  Initializing API for ' .. pDevice)
      os.unloadAPI(pApiFile)
      os.loadAPI(pApiFile)
    end
  end
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  -- cli: update
  local fn = tArgs[1]
  if fn == 'update' then
    message('Updating')
    return doUpdate()
  end

  -- actual startup
  message('Bootstrapping')
  bootstrap()
  print()

  message('Updating system')
  doUpdate()
  print()

  message('Loading libraries')
  os.unloadAPI('/lib/meter')
  os.loadAPI('/lib/meter')
  print('  Loaded meter')
  os.unloadAPI('/lib/json')
  os.loadAPI('/lib/json')
  print('  Loaded json')
  print()

  message('Initializing peripherals')
  setupPeripherals()
  print()

  -- output message of the day
  resetColors()
  rule()
  print()
  write(' Welcome to ' .. os.version())
  -- luacheck: globals _HOST
  if _HOST ~= nil then write(' (' .. _HOST .. ')\n') end
  print(' Day ' .. os.day() .. ' ' .. textutils.formatTime(os.time(), false))
  rule()
  print()
end)()

