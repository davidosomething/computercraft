--
-- update
-- v1.0.3
-- pastebin Q54ecuNa
-- by @davidosomething
--

-- getScript
-- string pastebin_id
-- string script_name
function getScript(pastebin_id, script_name)
  local tmpfile = 'tmp/' .. os.getComputerLabel() .. '-' .. script_name
  local scriptfile = os.getComputerLabel() .. '/' .. script_name

  if fs.exists(tmpfile) then
    fs.delete(tmpfile)
  end
  shell.run('pastebin', 'get', pastebin_id, tmpfile)

  if fs.exists(tmpfile) then
    fs.makeDir(os.getComputerLabel())
    if fs.exists(scriptfile) then
      fs.delete(scriptfile)
    end
    fs.move(tmpfile, scriptfile)
  end
end

shell.setDir('/')

-- reactor
if os.getComputerLabel() == 'reactor' then
  getScript('710inmxN', 'main')
end

-- remote
if os.getComputerLabel() == 'remote' then
  getScript('SHyMGSSK', 'main')
end

