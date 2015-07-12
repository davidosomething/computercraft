--
-- update
-- v1.0.2
-- pastebin Q54ecuNa
-- by @davidosomething
--

-- get_script
-- string pastebin_id
-- string script_name
function get_script(pastebin_id, script_name)
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
  get_script('710inmxN', 'main')
end

-- remote
if os.getComputerLabel() == 'remote' then
  get_script('SHyMGSSK', 'main')
end

