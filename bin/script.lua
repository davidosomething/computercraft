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

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local fromSource = 'pastebin'
if http then fromSource = 'github' end

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Replace a script with a new version from pastebin
--
-- @tparam string pastebinId
-- @tparam string dest
-- @tparam string protocol force using github or pastebin
local function get(pastebinId, dest, protocol)
  if protocol == nil and http ~= nil then protocol = 'gh' end

  local tmpfile = 'tmp/' .. pastebinId

  print('Updating ' .. dest .. ' from ' .. fromSource .. '... ')

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

local args = {...}
fn = args[1]
if fn == 'get' then get(args[2], args[3], args[4]) end

