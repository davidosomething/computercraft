---
-- lib/monitor.lua - Monitor API
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--
-- luacheck: globals devices

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Start using the monitor
--
function use() -- luacheck: ignore
  term.redirect(devices['monitor']) -- luacheck: ignore
end

--- Called by initPeripherals
--
function init() -- luacheck: ignore
  devices['monitor'].setTextScale(0.5)
end

