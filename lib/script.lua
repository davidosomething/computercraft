---
-- Get a script from GitHub if available, otherwise pastebin. Exposed as script
-- api.
-- lib/script v1.0.1
--
-- pastebin 0khvYUyX
--
-- @author David O'Trakoun <me@davidosomething.com>
-- @usage
-- os.loadAPI('/lib/script')
-- script.get({ pastebinId = '710inmxN'; dest = 'reactor/main'; })
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
-- @tparam table scriptData
function get(scriptData)
  local tmpfile = 'tmp/' .. scriptData['pastebinId']

  print('Updating ' .. scriptData['dest'] .. ' from ' .. fromSource .. '... ')

  shell.setDir('/')
  fs.delete(tmpfile)
  if http then
    shell.run('gh', 'get', scriptData['dest'] .. '.lua', tmpfile)
  else
    shell.run('pastebin', 'get', scriptData['pastebinId'], tmpfile)
  end

  if fs.exists(tmpfile) then
    fs.delete(scriptData['dest'])
    fs.move(tmpfile, scriptData['dest'])
  end
end

