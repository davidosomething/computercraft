---
-- Run on all computers; shows system meta data, updates system scripts, loads
-- APIs, autoruns local system scripts
-- startup v3.1.0
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
  if os.getComputerLabel() == nil then
    term.setTextColor(colors.red)
    print('Computer has no label! Please enter one now:')
    term.setTextColor('white')
    os.setComputerLabel(read())
  end
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
  print('Welcome to ' .. os.version())
  print(' You are ' .. os.getComputerLabel() .. ':' .. os.getComputerID())
  print(' Booted from ' .. shell.getRunningProgram())
  print()
end


--- Updates the updater
--
-- @tparam {table} systemScripts
local function systemUpdate(systemScripts)
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
