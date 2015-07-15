---
-- Run on all computers; shows system meta data, updates system scripts, loads
-- APIs, autoruns local system scripts
-- startup v3.0.0
--
-- pastebin uVtX8Yx6
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local scripts = {}
scripts['bin/update']   = 'Q54ecuNa'
scripts['bin/gh']       = 'QwW6Xg6M'
scripts['lib/meter']    = 'LeGJ4Wkb'


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Create system dirs and set aliases
--
local function bootstrap()
  shell.setDir('/')

  -- booted from disk or pocket pc in disk drive -- copy to local so we can
  -- boot without disk next time
  if shell.getRunningProgram() == 'disk/startup' then
    fs.delete('/startup')
    fs.copy('disk/startup', 'startup')
  end

  -- system paths
  shell.run('mkdir', 'bin')
  shell.run('mkdir', 'lib')
  shell.run('mkdir', 'tmp')

  -- machine path
  if os.getComputerLabel() ~= nil then fs.makeDir(os.getComputerLabel()) end

  -- set path
  shell.setPath(shell.path()..':/bin')

  -- set aliases
  shell.setAlias('ll', 'list')
  shell.setAlias('e', 'edit')
end


--- Show startup message
--
local function motd()
  print('Welcome!')
  print('CC v' .. os.version())
  print('ID ' .. os.getComputerID())

  if os.getComputerLabel() == nil then
    term.setTextColor(colors.red)
    print('Computer has no label! Please set one.')
    term.setTextColor('white')
  else
    print('Label ' .. os.getComputerLabel())
  end

  print('Booted from ' .. shell.getRunningProgram())
  print('       on ' .. os.clock())
  print()
end


--- Updates the updater
--
-- @tparam {table} systemScripts
local function systemUpdate(systemScripts)
  shell.setDir('/')

  for dest,value in pairs(systemScripts) do
    (function()
      if value == nil then return end

      local tmpfile = 'tmp/' .. value

      print('Updating ' .. dest .. ' from ' .. value .. '... ')

      fs.delete(tmpfile)
      shell.run('pastebin', 'get', value, tmpfile)

      if fs.exists(tmpfile) then
        fs.delete(dest)
        fs.move(tmpfile, dest)
      end
    end)()
  end

  print()
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  print('Bootstrapping...')
  bootstrap()
  print()

  print('System update...')
  term.setTextColor(colors.lightGray)
  systemUpdate(scripts)
  term.setTextColor(colors.white)
  print()

  -- load APIs
  if fs.exists('lib/meter') then os.loadAPI('lib/meter') end

  -- update computer specific scripts
  shell.run('bin/update')

  -- load computer specific APIs
  local envfile = os.getComputerLabel() .. '-env'
  if fs.exists(envfile) then shell.run(envfile) end

  -- run this computer's autostart program in a background tab
  local mainfile = os.getComputerLabel() .. '/main'
  if fs.exists(mainfile) then
    print("Starting " .. mainfile .. " in another tab")
    shell.openTab(mainfile)
  end

  motd()
end)()
