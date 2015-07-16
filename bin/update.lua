---
-- Update scripts by computer label
-- bin/update v3.0.0
--
-- pastebin Q54ecuNa
--
-- @author David O'Trakoun <me@davidosomething.com>
--

local fromSource = 'pastebin'
if http then fromSource = 'github' end

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Replace a script with a new version from pastebin
--
-- @tparam table scriptData
-- @tparam string pastebinId
function getScript(scriptData)
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

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.setTextColor(colors.lightGray)
  getScript({
    pastebinId = 'QwW6Xg6M';
    dest = 'bin/gh';
  })

  getScript({
    pastebinId = 'LeGJ4Wkb';
    dest = 'lib/meter';
  })

  term.setTextColor(colors.lightGray)
  -- reactor
  if os.getComputerLabel() == 'reactor' then
    getScript({
      pastebinId = '710inmxN';
      dest = 'reactor/main';
    })
  end

  -- remote
  if os.getComputerLabel() == 'remote' then
    getScript({
      pastebinId = 'SHyMGSSK';
      dest = 'remote/reactor';
    })
  end
  term.setTextColor(colors.white)
end)()
