---
-- lib/config.lua - JSON config API
-- @release 1.0.0
-- @author David O'Trakoun <me@davidosomething.com>
--
-- luacheck: globals json

local CONFIG_FILE = '/config.json'

local Data = {
  reactor = { isActive = false, isOptimizing = false }
}

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

--- Init defaults
--
function init()
  Data = {
    reactor = { isActive = false, isOptimizing = false }
  }
end


--- Save current Data state
--
function save() -- luacheck: ignore
  local writer = fs.open(CONFIG_FILE, 'w')
  writer.write(textutils.serializeJSON(Data))
  writer.close()
end


--- Load from JSON
--
function load()
  if fs.exists('/config.json') then
    Data = json.decodeFromFile(CONFIG_FILE)
  end
end


--- Setter
--
function set(key, value) -- luacheck: ignore
  Data[key] = value
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  init()
  load()
end)()

