---
-- Capacitor autostart
-- capacitor/main
--
-- pastebin SQsnn6aE
--
-- @release 0.0.4-alpha
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console json meter wireless

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

os.unloadAPI('/lib/json')
os.loadAPI('/lib/json')

os.unloadAPI('/lib/meter')
os.loadAPI('/lib/meter')

local is_exit = false
local config = json.decodeFromFile('/capacitor/config.json')


-- ---------------------------------------------------------------------------
-- Peripheral config
-- ---------------------------------------------------------------------------

local c = peripheral.wrap(config['capacitor_side'])

redstone.setOutput(config['redstone_side'], false)


-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Get capacitor energy percent
--
-- @treturn int
local function getEnergyPercent()
  return meter.percent(c.getEnergyStored(), c.getMaxEnergyStored())
end


--- Detect if the capacitor is low on energy
--
-- @treturn boolean true if low
local function isLowEnergy()
  return getEnergyPercent() < config['redstone_toggle_threshold']
end


--- Send status as a table over rednet
--
-- @tparam int remoteId computerId to send rednet message to
local function sendStatus(remoteId)
  local message = {}

  message['energyStored'] = c.getEnergyStored()
  message['maxEnergyStored'] = c.getMaxEnergyStored()
  message['energyPercent'] = getEnergyPercent()

  rednet.send(remoteId, message, config['remote_protocol'])
end


--- toggle redstone signal on timeout
local function toggleRedstoneSignal()
  if isLowEnergy() then
    redstone.setOutput(config['redstone_side'], true)
  else
    redstone.setOutput(config['redstone_side'], false)
  end
end


--- Do some action if receiving redstone message from modem
--
local function getModemMessage()
  -- luacheck: ignore protocol
  local senderId, message, protocol = rednet.receive('reactor')
  sendStatus(senderId)
end


--- Wait for system timer to trigger
--
local function getTimeout()
  -- luacheck: ignore event timerHandler
  local event, timerHandler = os.pullEvent('timer')
  toggleRedstoneSignal()
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  if is_exit then return end

  while not is_exit do
    local statusTimer = os.startTimer(0.5)
    parallel.waitForAny(getModemMessage, getTimeout)
    os.cancelTimer(statusTimer)
  end
end)()

