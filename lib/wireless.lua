---
-- wireless communication library exposed as API (WIP)
-- uses rednet and falls back to cloud
-- lib/wireless v0.0.2-alpha
--
-- pastebin rTCUgtUz
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- luacheck: globals console cloud

os.unloadAPI('/lib/console')
os.loadAPI('/lib/console')

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

-- feature flag
local IS_CLOUD_ENABLED = false

if IS_CLOUD_ENABLED then
  os.unloadAPI('/lib/cloud')
  os.loadAPI('/lib/cloud')
end


-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

--- adapter for rednet.lookup falling back to cloud.lookup
--
-- @tparam {string} protocol
-- @tparam {string} hostname
-- @return {nil,int} computer ID for use on rednet comms
function lookup(protocol, hostname)
  local lookupId = rednet.lookup(protocol, hostname)
  if lookupId then return lookupId end
  console.warn('No hosts on ' .. protocol .. "." .. hostname)

  if IS_CLOUD_ENABLED then
    console.log('Trying cloud lookup...')
    lookupId = cloud.lookup(protocol, hostname)
    if lookupId then return lookupId end
    console.warn('No reactors in cloud')
  end

  return nil
end

