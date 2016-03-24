---
-- bin/dko.lua - DKO system manager. Can be loaded as an API.
--
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--

local CLI_ARGS = { ... }

local dko = {}

--- Reset to default terminal colors
--
dko.resetColors = function ()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end


--- Draw full length line
--
dko.rule = function ()
  term.setBackgroundColor(colors.lightGray)
  print()
  dko.resetColors()
  print()
end

--- Output white text (e.g. for reactor labels)
--
-- @tparam string text
dko.label = function (text)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  write(text)
end


--- Output fancy system message (magenta bullet and text)
--
-- @tparam string text
dko.message = function (text)
  -- bullet
  term.setBackgroundColor(colors.magenta)
  write(' ')

  -- text
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.magenta)
  write(' ' .. text .. '\n')
end


--- Output fancy error message
--
-- @tparam string text
dko.errorMessage = function (text)
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
dko.pause = function ()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
end


--- Updates the updater
--
dko.systemUpdate = function ()
  local SYSTEM_BIN = {
    ['bin/gh']     = 'QwW6Xg6M',
    ['bin/script'] = '0khvYUyX',
  }

  shell.setDir('/')
  term.setTextColor(colors.lightGray)

  for dest, pastebinId in pairs(SYSTEM_BIN) do
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
dko.update = function ()
  if not fs.exists('bin/script') then
    dko.errorMessage('Missing bin/script')
    dko.pause()
    return
  end

  shell.run('script', 'get', 'uVtX8Yx6', 'startup')
  shell.run('script', 'get', 'aq8ci7Fc', 'lib/console')
  shell.run('script', 'get', '4nRg9CHU', 'lib/json')
  shell.run('script', 'get', 'LeGJ4Wkb', 'lib/meter')
end


--- Expose dko namespace to global scope so this can be used as an API
--
local function exposeApi()
  _G['dko'] = dko
end


--- Main, parse args and run
--
local function main()
  if #CLI_ARGS == 0 then return end
end


--- Expose namespaced functions to global scope when loaded as an API
--
if shell.getRunningProgram() ~= 'bin/dko' then
  exposeApi()
else
  main()
end

