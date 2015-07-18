---
-- Get a script from GitHub if available, otherwise pastebin. Exposed as script
-- bin.
-- bin/script v3.0.0
--
-- pastebin 0khvYUyX
--
-- @author David O'Trakoun <me@davidosomething.com>
-- @usage
-- shell.run('script', 'get', stringpastebinId; stringdest; })
-- shell.run('script', 'get', '710inmxN', 'reactor/main'; })
--

local tArgs = { ... }

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Replace a script with a new version from pastebin
--
-- @tparam string pastebinId
-- @tparam string dest
-- @tparam string protocol force using github or pastebin
local function get(pastebinId, dest, protocol)
  if protocol == nil then
    protocol = 'pastebin'
    if http ~= nil then protocol = 'gh' end
  end

  local tmpfile = 'tmp/' .. pastebinId

  print('Updating ' .. dest .. ' from ' .. protocol .. '... ')

  shell.setDir('/')
  fs.delete(tmpfile)
  if protocol == 'gh' then
    shell.run('gh', 'get', dest .. '.lua', tmpfile)
  else
    shell.run('pastebin', 'get', pastebinId, tmpfile)
  end

  if fs.exists(tmpfile) then
    fs.delete(dest)
    fs.move(tmpfile, dest)
  end
end

local fn = tArgs[1]
if fn == 'get' then get(tArgs[2], tArgs[3], tArgs[4]) end

