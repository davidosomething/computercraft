--
-- startup
-- v2.0.4
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
shell.run('mkdir', 'tmp')

-- set aliases
shell.setAlias('ll', 'list')
shell.setAlias('e', 'edit')

-- system_update
-- updates the updater
function system_update()
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

system_update()

shell.run('update')

local envfile = os.getComputerLabel() .. '-env'
if fs.exists(envfile) then
  shell.run(envfile)
end

