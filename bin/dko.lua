---
-- bin/dko.lua - DKO system manager. Can be loaded as an API.
--
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--

local CLI_ARGS = { ... }


-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

local dko = {}


dko.usage = function (...)
  print('USAGE:')
  print()
  print('  bootstrap      -- Create system directories')
  print('  pause          -- Press any key to continue prompt')
  print('  resetColors    -- Reset terminal fg and bg colors')
  print('  rule           -- Draw a light gray horizontal line')
  print('  update         -- Update scripts ')
  print()
end


--- Split a string into a table
--
-- @see http://stackoverflow.com/a/7615129/230473
-- @tparam string inputstr
-- @tparam string sep separating character
dko.strsplit = function (...)
  shell     = arg[0]
  inputstr  = arg[1]
  sep       = arg[2] or "%s"

  local t = {}
  local i = 1
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end


dko.rest = function (...)
  shell = arg[0]
  array = arg[1]
  index = arg[2] or 2

  if not array then return {} end

  local rest = {}
  for i=index,#array do
    rest[#rest+1] = array[i]
  end
  return rest
end


--- Reset to default terminal colors
--
dko.resetColors = function (...)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end


--- Output fancy system message (magenta bullet and text)
--
-- @tparam string text
dko.message = function (arg)
  shell = arg[0]
  text = arg[1]

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
dko.errorMessage = function (...)
  shell = arg[0]
  text = arg[1]

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
dko.rule = function (...)
  term.setBackgroundColor(colors.lightGray)
  print()
  dko.resetColors()
  print()
end


--- Output white text (e.g. for reactor labels)
--
-- @tparam string text
dko.label = function (...)
  shell = arg[0]
  text = arg[1]

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  write(text)
end


--- Wait for keypress
--
dko.pause = function (...)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
end


--- Get the github downloader script
--
dko.getGh = function (...)
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
dko.bootstrap = function (...)
  shell = arg[0]

  dko.message('Bootstrapping')
  shell.setDir('/')

  -- system paths
  shell.run('mkdir', 'bin')
  shell.run('mkdir', 'lib')
  shell.run('mkdir', 'tmp')
  shell.run('mkdir', 'var')

  -- set aliases
  shell.setAlias('l', 'list')
  shell.setAlias('ll', 'list')
  shell.setAlias('e', 'edit')
  shell.setAlias('up', 'startup update')
  shell.setAlias('update', 'startup update')

  -- get scripts
  dko.getGh()
  dko.update(shell)
end


--- Update manifest and scripts listed in it in the format:
-- bin/someprogram
-- lib/anapi
--
dko.update = function (...)
  shell = arg[0]

  shell.setDir('/')

  shell.run('gh', 'get', 'var/manifest', '/var/manifest')
  dko.message('Updated /var/manifest')

  local manifest = fs.open('/var/manifest', 'r')
  while true do
    local dest = manifest.readLine()
    if dest == nil then break end

    dko.message('Updating ' .. dest)
    shell.run('gh', 'get', dest .. '.lua', dest)
  end
  manifest.close()
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()

  -- When used as API
  if not shell then return end

  -- When run as program
  -- Always set path
  if not string.find(shell.path(), ':/bin') then
    shell.setPath(shell.path() .. ':/bin')
  end

  -- Usage if no command in args
  if #CLI_ARGS == 0 then
    dko.usage()
    return
  end

  -- Pass command
  local command = CLI_ARGS[1]
  if not dko[command] then
    dko.errorMessage("Command not found '" .. command "'")
    return
  end

  -- just in case for lua 5.2, not sure what CC includes
  dko[command](shell, dko.rest(CLI_ARGS))

end)()

