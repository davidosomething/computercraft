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
shell.run('script', 'get', 'QwW6Xg6M', 'bin/gh')
shell.run('script', 'get', 'aq8ci7Fc', 'lib/console')
shell.run('script', 'get', 'LeGJ4Wkb', 'lib/meter')
shell.run('script', 'get', 'rTCUgtUz', 'lib/wireless')

term.setTextColor(colors.lightGray)
-- reactor
if os.getComputerLabel() == 'reactor' then
  shell.run('script', 'get', '710inmxN', 'reactor/main')
end

-- remote
if os.getComputerLabel() == 'remote' then
  shell.run('script', 'get', 'Y4UsBfP7', 'lib/reactorRemote')
  shell.run('script', 'get', 'SHyMGSSK', 'remote/main')
end
term.setTextColor(colors.white)
