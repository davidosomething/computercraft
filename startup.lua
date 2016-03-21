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

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------


--- Wait for keypress
--
local function pause()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
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


--- Update scripts specific to a computer with label
--
local function localUpdate()
  if os.getComputerLabel() == nil then return end

  -- machine path
  fs.makeDir(os.getComputerLabel())

  -- capacitor
  if os.getComputerLabel() == 'capacitor' then
    shell.run('script', 'get', 'SQsnn6aE', 'capacitor/main')
  end

  -- reactor
  if os.getComputerLabel() == 'reactor' then
    shell.run('script', 'get', '710inmxN', 'reactor/main')
  end

  -- remote
  if os.getComputerLabel() == 'remote' then
    shell.run('script', 'get', 'Y4UsBfP7', 'lib/reactorRemote')
    shell.run('script', 'get', 'SHyMGSSK', 'remote/main')
  end
end


--- Do full update only
--
local function doUpdate()
  systemUpdate()
  update()
  localUpdate()
end


--- Run this computer's autostart program in a background tab
local function doAutostart()
  if os.getComputerLabel() == nil then return end
  local mainfile = os.getComputerLabel() .. '/main'
  if fs.exists(mainfile) then
    message("Starting " .. mainfile .. " in bg...")
    print()
    shell.openTab(mainfile)
  end
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  if os.getComputerLabel() == nil then
    return errorMessage('Computer has no label! Please set one and reboot.')
  end

  local fn = tArgs[1]
  if fn == 'update' then
    message('Updating...')
    return doUpdate()
  end

  message('Bootstrapping...')
  bootstrap()
  print()

  message('System update...')
  doUpdate()
  print()

  doAutostart()

  -- output message of the day
  if fs.exists('bin/motd') then shell.run('bin/motd') end
end)()

