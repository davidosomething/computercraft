--
-- remote/main
-- v2.2.0
-- pastebin SHyMGSSK
-- by @davidosomething
--


-- -----------------------------------------------------------------------------
-- Program state ---------------------------------------------------------------
-- -----------------------------------------------------------------------------
exit = false


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

-- remote reactor
local reactorPort = 1

-- modem
local modemSide = 'back'
local w = peripheral.wrap(modemSide)
rednet.open(modemSide)


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- doAction
--
local function doAction(action)
  if action == 'autotoggle' then
    rednet.send(reactorPort, 'autotoggle', 'reactor')
  elseif action == 'toggle' then
    rednet.send(reactorPort, 'toggle', 'reactor')
  end
end

-- getStatus
--
-- Request status messages from reactors over rednet and display
--
local function getStatus()
  rednet.send(reactorPort, 'status', 'reactor')
  local senderId, message, protocol = rednet.receive('remote')
  print(message)
end


-- getKey
--
local function getKey()
  local event, code = os.pullEvent('key')
  if code == keys.a then
    doAction('autotoggle')
  elseif code == keys.t then
    doAction('toggle')
  elseif code == keys.q then
    exit = true
  end
end


-- getTimeout
--
local function getTimeout()
  local event, timerHandler = os.pullEvent('timer')
end


-- usage
--
local function usage()
  print("q)uit  t)oggle  a)utotoggle")
  print()
end


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

while not exit do
  local myTimer = os.startTimer(1)
  m.clear()
  m.setCursorPos(1,1)
  usage()
  getStatus()

  parallel.waitForAny(getKey, getTimeout)
  os.cancelTimer(myTimer)
end

