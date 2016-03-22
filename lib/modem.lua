
  -- modem
  rednet.open(config['modem_side'])
  rednet.host(config['protocol'], config['hostname'])




--- Send reactor status as a table over rednet
--
-- @tparam int remoteId computerId to send rednet message to
local function sendStatus(remoteId)
  local message = {}

  message['active']                 = devices['reactor'].getActive()
  message['energyStored']           = devices['reactor'].getEnergyStored()
  message['fuelAmount']             = devices['reactor'].getFuelAmount()
  message['wasteAmount']            = devices['reactor'].getWasteAmount()
  message['fuelAmountMax']          = devices['reactor'].getFuelAmountMax()
  message['energyProducedLastTick'] = devices['reactor'].getEnergyProducedLastTick()
  message['fuelConsumedLastTick']   = devices['reactor'].getFuelConsumedLastTick()
  message['fuelTemperature']        = devices['reactor'].getFuelTemperature()
  message['casingTemperature']      = devices['reactor'].getCasingTemperature()
  message['energyPercentage']       = devices['reactor'].getEnergyPercentage()
  message['isAutotoggle']           = config.reactor.isAutotoggle

  rednet.send(remoteId, message, config['remote_protocol'])
end
