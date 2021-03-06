---
-- lib/reactorRemote -- Remotely controls a reactor via Advanced Wireless
-- Pocket Computer. Exposed as reactorRemote api.
--
-- @release 1.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console meter wireless

-- ---------------------------------------------------------------------------
-- Meta
-- ---------------------------------------------------------------------------

local PROTOCOL = 'reactor_remote'

-- search for a reactor dynamically, or just use fallback id?
-- feature flag
local IS_FIND_REACTOR = false

local REACTOR_PROTOCOL = 'reactor'
local REACTOR_HOSTNAME = 'main'

-- if no reactor can be found dynamically in rednet range or via craft-a-cloud
-- this will be used. Change this to your known reactor ID
local REACTOR_FALLBACK_ID = 1

local REACTOR_ENERGY_MAX = 10000000

local termW, termH = term.getSize()

local statusY = 4 -- below usage
local energyY = statusY + 2
local energyMeterY = energyY + 1
local energyTickY = energyMeterY + 1
local fuelMeterY = energyTickY + 2
local fuelConsumedY = fuelMeterY + 1

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Find a reactor via rednet.lookup, fall back to cloud.lookup, fall back to
-- REACTOR_FALLBACK_ID
--
-- @return {int} reactorId
function findReactor() -- luacheck: ignore
  if IS_FIND_REACTOR then
    local lookupId = wireless.lookup(REACTOR_PROTOCOL, REACTOR_HOSTNAME)
    if lookupId then return lookupId end
    console.error('No reactors found! Falling back to ID ' .. REACTOR_FALLBACK_ID)
  end

  return REACTOR_FALLBACK_ID
end


--- Request one of the reactor tasks
--
-- @tparam {int} reactorId
-- @tparam {string} action
function requestAction(reactorId, action) -- luacheck: ignore
  if action == 'autotoggle' then
    rednet.send(reactorId, 'autotoggle', REACTOR_PROTOCOL)
  elseif action == 'toggle' then
    rednet.send(reactorId, 'toggle', REACTOR_PROTOCOL)
  end
end


--- Display script usage
function usage() -- luacheck: ignore
  term.setCursorPos(1,1)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  term.clearLine()
  print("[q]uit [t]oggle [a]utotogg")
end


--- Display field labels for reactor status
--
function showStatusLabels(reactorId) -- luacheck: ignore
  term.setCursorPos(1,2)
  print("Reactor ID: " .. reactorId)

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)

  for lineNumber = statusY, termH do
    term.setCursorPos(1, lineNumber)
    term.clearLine()
  end

  term.setCursorPos(1, energyY)
  write('RF   ')    -- energy meter

  term.setCursorPos(1, fuelMeterY)
  write('Fuel ')    -- fuel meter
end


--- Display formatted reactor status
--
-- output --------------
-- status     autotoggle
-- rf buffer
-- rf meter
-- rf/t
--
-- fuel meter
-- fuel mb/t
-- ---------------------
--
-- @tparam table data from requestStatus()
function showStatus(data)
  local x = 6

  term.setCursorPos(1, statusY) -- below usage
  term.clearLine()
  if data['active'] then
    term.setTextColor(colors.red)
    write('ON ')
  else
    term.setTextColor(colors.lightGray)
    write('off')
  end

  term.setCursorPos(12, statusY) -- below usage
  if data['is_autotoggle'] then
    term.setTextColor(colors.red)
    write('AUTO')
  else
    term.setTextColor(colors.lightGray)
    write('auto')
  end

  term.setTextColor(colors.lightGray)
  term.setCursorPos(x, energyY)
  term.clearLine()
  write(data['energyStored'].. '/10m')

  meter.horizontal(x, energyMeterY, termW - 1, energyMeterY,
                   data['energyStored'], REACTOR_ENERGY_MAX,
                   colors.red)

  term.setCursorPos(x, energyTickY)
  term.clearLine()
  write(data['energyProducedLastTick'] .. ' RF/t')

  meter.horizontal(x, fuelMeterY, termW - 1, fuelMeterY,
                   data['fuelAmount'], data['fuelAmountMax'],
                   colors.yellow)

  term.setCursorPos(x, fuelConsumedY)
  term.clearLine()
  write(data['fuelConsumedLastTick'] .. ' mb/t')
end


--- Request status messages from reactors over rednet and display
--
function requestStatus(reactorId) -- luacheck: ignore
  rednet.send(reactorId, 'status', REACTOR_PROTOCOL)
  -- luacheck: ignore protocol
  local senderId, data, protocol = rednet.receive(PROTOCOL, 1)
  if senderId ~= nil and data ~= nil then showStatus(data) end
end

