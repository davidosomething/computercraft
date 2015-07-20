---
-- Package manager
-- bin/package v0.0.1-alpha
--
-- pastebin
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals meter

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

local tArgs = { ... }

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local function help()
end

local function list()
end

local function install()
end

local function update()
end

local function remove()
end

(function ()
  if (#tArgs < 1) then
    help()
    return
  end

  local command = tArgs[1]

  if (command == 'help') then return help() end
  if (command == 'list') then return list() end
  if (command == 'install') then return install() end
  if (command == 'update') then return update() end
  if (command == 'remove') then return remove() end

  help()
  return
end)()

