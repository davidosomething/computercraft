--
-- remote/main
-- v2.1.8
-- pastebin SHyMGSSK
-- by @davidosomething
--

-- remote reactor
local reactorPort = 1

-- modem
local modemSide = 'back'
local w = peripheral.wrap(modemSide)
rednet.open(modemSide)

local function do_action(action)
  if action == 'toggle' then
    rednet.send(reactorPort, 'toggle', 'reactor')
  else
    rednet.send(reactorPort, 'status', 'reactor')
  end

  local senderId, message, protocol = rednet.receive('remote')
  print(message)
  print()
  print()
end

local function get_timeout()
  local event, timerHandler = os.pullEvent('timer')
end

local function usage()
  print("q)uit  t)oggle  s)tatus")
  print()
end

exit = false
while not exit do
  usage()

  local event, code = os.pullEvent('key')
  if code == keys.t then
    do_action('toggle')
  elseif code == keys.s then
    do_action('status')
  elseif code == keys.q then
    exit = true
  end
end

