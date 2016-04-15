---
-- bin/dko.lua - DKO system manager. Can be loaded as an API.
--
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--

local CLI_ARGS = { ... }

-- ---------------------------------------------------------------------------
-- Private
-- ---------------------------------------------------------------------------

local function usage() -- luacheck: ignore
  print('USAGE:')
  print()
  print('  bootstrap      -- Create system directories')
  print('  pause          -- Press any key to continue prompt')
  print('  resetColors    -- Reset terminal fg and bg colors')
  print('  rule           -- Draw a light gray horizontal line')
  print('  update         -- Update scripts ')
end


-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

local dko = {}


--- Split a string into a table
--
-- @see http://stackoverflow.com/a/7615129/230473
-- @tparam string inputstr
-- @tparam string sep separating character
dko.strsplit = function (inputstr, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  local i = 1
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end


--- Reset to default terminal colors
--
dko.resetColors = function ()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
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


--- Wait for keypress
--
dko.pause = function ()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
end


--- Get the github downloader script
--
dko.getGh = function ()
  if fs.exists('/bin/gh') then return end

  local GH_URL   = 'https://raw.githubusercontent.com'
  local USERNAME = 'davidosomething'
  local REPO     = 'computercraft'
  local REF      = 'master'
  local FILENAME = 'bin/gh.lua'
  local urlparts = { GH_URL, USERNAME, REPO, REF, FILENAME }
  local url = table.concat(urlparts, '/')

  local request = http.get(url)
  if not request then
    dko.errorMessage('Could not download /bin/gh')
    return
  end

  local response = request.readAll()
  request.close()

  local file = fs.open('/bin/gh', "w")
  file.write(response)
  file.close()
  dko.message('Updated /bin/gh')
end


--- Create system dirs and set aliases
--
dko.bootstrap = function ()
  dko.message('Bootstrapping')
  shell.setDir('/')

  -- system paths
  shell.run('mkdir', 'bin')
  shell.run('mkdir', 'lib')
  shell.run('mkdir', 'tmp')
  shell.run('mkdir', 'var')

  -- set path
  shell.setPath(shell.path() .. ':/bin')

  -- set aliases
  shell.setAlias('l', 'list')
  shell.setAlias('ll', 'list')
  shell.setAlias('e', 'edit')
  shell.setAlias('up', 'startup update')
  shell.setAlias('update', 'startup update')

  -- get scripts
  dko.getGh()
  dko.update()
end


--- Update manifest and scripts listed in it in the format:
-- bin/someprogram
-- lib/anapi
--
dko.update = function ()
  shell.setDir('/')

  shell.run('gh', 'get', 'var/manifest', '/var/manifest')
  dko.message('Updated /var/manifest')

  local manifest = fs.open('/var/manifest', 'r')
  while true do
    local dest = manifest.readLine()
    dko.message('Updating ' .. dest)
    if dest == nil then break end

    if fs.exists(dest) then fs.delete(dest) end
    shell.run('gh', 'get', dest .. '.lua', dest)
    dko.message('Updated ' .. dest)
  end
  manifest.close()
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()

  -- When run as program
  if #CLI_ARGS == 0 then return end

  local command = CLI_ARGS[1]
  if dko[command] == nil then
    dko.errorMessage("Command not found '" .. command "'")
    return
  end

  dko[command]()

end)()

