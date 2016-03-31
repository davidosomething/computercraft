---
-- lib/capacitor Capacitor status
--
-- @release 1.0.0-alpha
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals config meter
-- luacheck: globals devices
-- luacheck: globals dko

local DEVICE  = 'capacitor'
local REACTOR = devices[DEVICE]

local state

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Get capacitor energy percent
--
-- @treturn int
function getEnergyPercent()
  return meter.percent(c.getEnergyStored(), c.getMaxEnergyStored())
end


--- Detect if the capacitor is low on energy
--
-- @treturn boolean true if low
function isLow()
  return getEnergyPercent() < 50
end


--- Called by initPeripherals
--
function init() -- luacheck: ignore
  state = {
    isActive     = REACTOR.getActive(),
    isOptimizing = config['reactor'].isOptimizing,
  }
end
