---
-- lib/armor.lua -- Armor repair API
--
-- @release 0.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals config display
-- luacheck: globals devices
-- luacheck: globals dko

local state = {
  inputSide   = nil,
  outputSide  = nil,
}


local function init()
  local peripherals = peripheral.getNames()
  for i = 1, #peripherals do
    local pType     = peripheral.getType(peripherals[i])
    local pLocation = peripherals[i]
    print('  Found ' .. pType ..  ' at "' .. pLocation .. '"')
  end
end

