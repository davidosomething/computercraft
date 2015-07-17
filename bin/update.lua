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

os.unloadAPI('/lib/script')
os.loadAPI('/lib/script')

shell.setDir('/')

term.setTextColor(colors.lightGray)
script.get({ pastebinId = 'QwW6Xg6M'; dest = 'bin/gh'; })
script.get({ pastebinId = 'LeGJ4Wkb'; dest = 'lib/console'; })
script.get({ pastebinId = 'LeGJ4Wkb'; dest = 'lib/meter'; })

term.setTextColor(colors.lightGray)
-- reactor
if os.getComputerLabel() == 'reactor' then
  script.get({ pastebinId = '710inmxN'; dest = 'reactor/main'; })
end

-- remote
if os.getComputerLabel() == 'remote' then
  script.get({ pastebinId = 'Y4UsBfP7'; dest = 'lib/reactorRemote'; })
  script.get({ pastebinId = 'SHyMGSSK'; dest = 'remote/main'; })
end
term.setTextColor(colors.white)
