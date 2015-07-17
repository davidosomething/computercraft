-- NyY5gUJA

redstone.setOutput('right', false)

while true do
  local c = peripheral.wrap('left')
  if math.floor(c.getEnergyStored() / c.getMaxEnergyStored() * 100) < 90 then
    redstone.setOutput('right', true)
  else
    redstone.setOutput('right', false)
  end

  sleep(1)
end
