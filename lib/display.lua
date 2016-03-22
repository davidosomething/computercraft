---
-- lib/display - Display exposed as API
-- @release 0.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--
-- luacheck: globals devices

local windows = {}

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Create or reuse a window on the current display
--
function use(name) -- luacheck: ignore
  -- Already using the window
  if term.current() == windows[name] then return end

  -- Window doesn't exist, create it in the monitor
  if windows[name] == nil then
    local termW, termH = term.getSize()
    local parentTerm = devices['monitor'] or term.native()
    windows[name] = window.create(parentTerm, 1, 1, termW, termH)
  end

  -- Window exists, use it
  term.redirect(windows[name])
end


--- Back to regular monitor/native term
--
function reset()
  -- Hide any open windows
  for name,win in pairs(windows) do win.setVisible(false) end

  -- Redirect any future output to monitor or native terminal
  local parentTerm = devices['monitor'] or term.native()
  term.redirect(parentTerm)
end

