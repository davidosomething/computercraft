---
-- Update scripts by computer label
-- bin/update v3.0.0
--
--
-- pastebin Q54ecuNa
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- Replace a script with a new version from pastebin
--
-- @tparam string pastebinId
-- @tparam string scriptName
function getScript(pastebinId, scriptName)
  local tmpfile = 'tmp/' .. pastebinId
  local dest = os.getComputerLabel() .. '/' .. scriptName

  print('Updating ' .. dest .. ' from ' .. pastebinId .. '... ')

  shell.setDir('/')
  fs.delete(tmpfile)
  shell.run('pastebin', 'get', pastebinId, tmpfile)

  if fs.exists(tmpfile) then
    fs.delete(dest)
    fs.move(tmpfile, dest)
  end
end

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  if os.getComputerLabel() == nil then
    term.setTextColor(colors.red)
    print('Computer has no label! Please set one.')
    term.setTextColor(colors.white)
    return
  end

  term.setTextColor(colors.lightGray)
  -- reactor
  if os.getComputerLabel() == 'reactor' then
    getScript('710inmxN', 'main')
  end

  -- remote
  if os.getComputerLabel() == 'remote' then
    getScript('SHyMGSSK', 'main')
  end
  term.setTextColor(colors.white)
end)()
