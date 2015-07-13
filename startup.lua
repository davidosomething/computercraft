--
-- startup
-- v2.0.7
-- pastebin uVtX8Yx6
-- by @davidosomething
--

print('CC v' .. os.version())
print('ID ' .. os.getComputerID())

if os.getComputerLabel() == nil then
  print('Computer has no label! Please set one.')
else
  print('Label ' .. os.getComputerLabel())
end

shell.setDir('/')

-- system paths
shell.run('mkdir', 'bin')
shell.run('mkdir', 'tmp')
shell.setPath(shell.path()..':/bin')

-- set aliases
shell.setAlias('ll', 'list')
shell.setAlias('e', 'edit')

-- systemUpdate
-- updates the updater
function systemUpdate()
  local tmpfile = 'tmp/update'
  local scriptfile = 'update'

  if fs.exists(tmpfile) then
    fs.delete(tmpfile)
  end
  shell.run('pastebin', 'get', 'Q54ecuNa', tmpfile)

  if fs.exists(tmpfile) then
    if fs.exists('update') then
      fs.delete('update')
    end
    fs.move(tmpfile, 'update')
  end
end

systemUpdate()

shell.run('update')

local envfile = os.getComputerLabel() .. '-env'
if fs.exists(envfile) then
  shell.run(envfile)
end

local mainfile = os.getComputerLabel() .. '/main'
if fs.exists(mainfile) then
  shell.run(mainfile)
end

