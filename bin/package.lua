---
-- Package manager
-- bin/package
--
-- pastebin
--
-- @release 0.0.4-alpha
-- @author David O'Trakoun <me@davidosomething.com>
-- @script package
--

-- luacheck: globals console json

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

os.unloadAPI('/lib/json')
os.loadAPI('/lib/json')

local tArgs = { ... }

local MANIFEST_FILENAME = 'packages.json'
local manifest = json.decodeFromFile(MANIFEST_FILENAME)

local REMOTE_MANIFEST_FILEPATH = 'tmp/remote-manifest.json'
local remoteManifest = nil

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Display usage
--
local function help()
  console.log('Usage: package <command> [package]')
  print()
  console.log('Commands:')
  console.log('  help    - show this message')
  console.log('  list    - show installed, missing, and outdated packages')
  console.log('  update  - update a program over http')
  print()
end


--- Get latest remote manifest from github only
--
local function getRemoteManifest()
  shell.run('gh', 'get', MANIFEST_FILENAME, REMOTE_MANIFEST_FILEPATH)
  return json.decodeFromFile(REMOTE_MANIFEST_FILEPATH)
end


--- Show a package as installed
--
-- @tparam string filepath
-- @tparam table data
local function printInstalled()
  term.setTextColor(colors.lightBlue)
  write('i')
end


--- Show a package as missing
--
-- @tparam string filepath
-- @tparam table data
local function printMissing()
  term.setTextColor(colors.pink)
  write('m')
end


--- Print version in pink
--
-- @tparam string filepath
local function printOutdated(filepath)
  term.setTextColor(colors.pink)
  write(manifest[filepath]['version'])
end


--- Print version in gray
--
-- @tparam string filepath
local function printLatest(filepath)
  term.setTextColor(colors.lightGray)
  write(manifest[filepath]['version'])
end


--- Colorized version based on up-to-date status
--
-- @tparam string filepath
local function printVersion(filepath)
  if manifest[filepath] == nil then
    return printOutdated(filepath)
  end

  remoteVersion = remoteManifest[filepath]['version']
  if manifest[filepath]['version'] ~= remoteVersion then
    return printOutdated(filepath)
  end

  return printLatest(filepath)
end


--- Check installed programs against the manifest
--
-- example output
-- i 3.0.0 bin/something
-- m 1.2.3 lib/somethingelse
--
local function listPrograms()
  remoteManifest = getRemoteManifest()

  for filepath,data in pairs(remoteManifest) do
    -- i or m
    if fs.exists(filepath) then printInstalled() else printMissing() end

    -- x.x.x
    oldx, oldy = term.getCursorPos()
    term.setCursorPos(3, oldy)
    printVersion(filepath)

    -- truncates '-alpha' etc extra version info
    term.setCursorPos(7, oldy)
    term.setTextColor(colors.lightGray)

    -- filepath
    write(' ' .. filepath)
    print()
  end
end


--- Update a program
--
local function update()
  -- TODO
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
(function ()
  if (#tArgs < 1) then
    return help()
  end

  local command = tArgs[1]
  if (command == 'help') then return help() end
  if (command == 'list') then return listPrograms() end
  if (command == 'update') then return update() end

  return help()
end)()
