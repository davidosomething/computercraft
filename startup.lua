---
-- Run on all computers; shows system meta data, updates system scripts, loads
-- APIs, autoruns local system scripts
-- startup v4.0.0
--
-- pastebin uVtX8Yx6
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local scripts = {}
scripts['lib/console']  = 'aq8ci7Fc'
scripts['bin/script']   = '0khvYUyX'
scripts['bin/motd']     = 'zs7pMz89'
scripts['bin/update']   = 'Q54ecuNa'


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Create system dirs and set aliases
--
local function bootstrap()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.magenta)
  print('Bootstrapping...')

  term.setTextColor(colors.lightGray)

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
    print('Computer has no label! Please set one and reboot.')
    term.setTextColor(colors.lightGray)
  end
  if os.getComputerLabel() ~= nil then fs.makeDir(os.getComputerLabel()) end

  -- set path
  shell.setPath(shell.path()..':/bin')

  -- set aliases
  shell.setAlias('ll', 'list')
  shell.setAlias('e', 'edit')

  term.setTextColor(colors.white)
end


--- Updates the updater
--
-- @tparam {table} systemScripts
local function systemUpdate(systemScripts)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.magenta)
  print('System update...')

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

  term.setTextColor(colors.white)
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  bootstrap()
  print()

  systemUpdate(scripts)
  print()

  -- update computer specific scripts
  if fs.exists('bin/update') then shell.run('bin/update') end

  -- output message of the day
  if fs.exists('bin/motd') then shell.run('bin/motd') end

  -- load computer specific APIs
  local envfile = os.getComputerLabel() .. '-env'
  if fs.exists(envfile) then shell.run(envfile) end

  -- run this computer's autostart program in a background tab
  local mainfile = os.getComputerLabel() .. '/main'
  if fs.exists(mainfile) then
    print("Starting " .. mainfile .. " in another tab")
    shell.openTab(mainfile)
  end
end)()
