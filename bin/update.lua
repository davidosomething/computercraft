---
-- Update scripts by computer label
-- bin/update v4.0.1
--
-- pastebin Q54ecuNa
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

shell.setDir('/')

term.setTextColor(colors.lightGray)
shell.run('script', 'get', { pastebinId = 'QwW6Xg6M'; dest = 'bin/gh'; })
shell.run('script', 'get', { pastebinId = 'LeGJ4Wkb'; dest = 'lib/console'; })
shell.run('script', 'get', { pastebinId = 'LeGJ4Wkb'; dest = 'lib/meter'; })

term.setTextColor(colors.lightGray)
-- reactor
if os.getComputerLabel() == 'reactor' then
  shell.run('script', 'get', { pastebinId = '710inmxN'; dest = 'reactor/main'; })
end

-- remote
if os.getComputerLabel() == 'remote' then
  shell.run('script', 'get', { pastebinId = 'Y4UsBfP7'; dest = 'lib/reactorRemote'; })
  shell.run('script', 'get', { pastebinId = 'SHyMGSSK'; dest = 'remote/main'; })
end
term.setTextColor(colors.white)
