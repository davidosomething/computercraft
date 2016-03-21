---
-- Get a script from GitHub if available, otherwise pastebin.
-- bin/script
--
-- pastebin 0khvYUyX
--
-- @release 4.1.0
-- @author David O'Trakoun <me@davidosomething.com>
-- @script script
--

local tArgs = { ... }

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Get a valid protocol
--
-- @tparam string protocol
-- @treturn string protocol
local function validateProtocol(protocol)
  -- default protocol
  if protocol == nil then
    protocol = 'pastebin'
    if http ~= nil then return 'gh' end
  end

  -- invalid protocol, use default
  if protocol ~= 'pastebin' and protocol ~= 'gh' then
    protocol = validateProtocol()
  end

  return protocol
end


--- Replace a script with a new version from pastebin
--
-- @tparam string pastebinId
-- @tparam string dest
-- @tparam string protocol force using github or pastebin
-- @tparam string ref if using gh protocol then can specify a branch or tag
local function get(pastebinId, dest, protocol, ref)
  protocol = validateProtocol(protocol)
  if ref == nil then ref = 'master' end

  local tmpfile = 'tmp/' .. pastebinId

  print('Updating ' .. dest .. ' from ' .. protocol .. '... ')

  shell.setDir('/')
  fs.delete(tmpfile)
  if protocol == 'gh' then
    shell.run('gh', 'get', dest .. '.lua', tmpfile, ref)
  else
    shell.run('pastebin', 'get', pastebinId, tmpfile)
  end

  if fs.exists(tmpfile) then
    fs.delete(dest)
    fs.move(tmpfile, dest)
  end
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  local fn = tArgs[1]
  if fn == 'get' then get(tArgs[2], tArgs[3], tArgs[4]) end
end)()

