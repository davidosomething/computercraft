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

-- do_action
--
local function do_action(action)
  if action == 'autotoggle' then
    rednet.send(reactorPort, 'autotoggle', 'reactor')
  elseif action == 'toggle' then
    rednet.send(reactorPort, 'toggle', 'reactor')
  end
end

-- get_status
--
-- Request status messages from reactors over rednet and display
--
local function get_status()
  rednet.send(reactorPort, 'status', 'reactor')
  local senderId, message, protocol = rednet.receive('remote')
  print(message)
end


-- get_key
--
local function get_key()
  local event, code = os.pullEvent('key')
  if code == keys.a then
    do_action('autotoggle')
  elseif code == keys.t then
    do_action('toggle')
  elseif code == keys.q then
    exit = true
  end
end


-- get_timeout
--
local function get_timeout()
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
  get_status()

  parallel.waitForAny(get_key, get_timeout)
  os.cancelTimer(myTimer)
end

