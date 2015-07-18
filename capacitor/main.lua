---
-- Capacitor monitoring
-- capacitor/main v0.0.2-alpha
--
-- pastebin SQsnn6aE
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console meter wireless

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

os.unloadAPI('/lib/meter')
os.loadAPI('/lib/meter')

os.unloadAPI('/lib/wireless')
os.loadAPI('/lib/wireless')

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local CAPACITOR_SIDE = 'back'
local REDSTONE_SIDE = 'right'

-- below this percentage, turn on redstone signal
local REDSTONE_TOGGLE_ENERGY_THRESHOLD = 90

local is_exit = false


-- -----------------------------------------------------------------------------
-- Peripheral config -----------------------------------------------------------
-- -----------------------------------------------------------------------------

local c = peripheral.wrap(CAPACITOR_SIDE)

redstone.setOutput(REDSTONE_SIDE, false)


local function isLowEnergy()
  return meter.percent(c.getEnergyStored(), c.getMaxEnergyStored()) < REDSTONE_TOGGLE_ENERGY_THRESHOLD
end

-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  term.clear()

  while not is_exit do
    if isLowEnergy() then
      redstone.setOutput(REDSTONE_SIDE, true)
    else
      redstone.setOutput(REDSTONE_SIDE, false)
    end

    os.sleep(0.5)
  end

end)()

