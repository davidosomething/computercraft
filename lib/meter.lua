---
-- Meter exposed as API
-- lib/meter
--
-- pastebin LeGJ4Wkb
--
-- @release 2.2.0
-- @author David O'Trakoun <me@davidosomething.com>
--

local EMPTY_COLOR = colors.gray

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

function percent(value, max)
  if value <= 0 then return 0 end
  if max <= 0 then return 0 end
  return math.floor(value / max * 100)
end

--- Draw a horizontal meter
--
-- @usage meter.horizontal(1, 1, 10, 2, 50, 100)
--
-- @tparam int startX term coord
-- @tparam int startY term coord
-- @tparam int endX term coord
-- @tparam int endY term coord
-- @tparam int value
-- @tparam int max
-- @tparam int fillColor from colors API
function horizontal(startX, startY, endX, endY, value, max, fillColor)
  -- default for args
  if fillColor == nil then fillColor = colors.red end

  local oldBgColor = colors.black
  if term.getBackgroundColor ~= nil then -- compatibility with CC <1.7.4
    oldBgColor = term.getBackgroundColor()
  end


  local barWidth = endX - startX
  local filledRatio = value / max
  local filledWidth = math.floor(filledRatio * barWidth)
  local filledEndX = startX + filledWidth

  paintutils.drawFilledBox(startX, startY, endX, endY, EMPTY_COLOR)
  paintutils.drawFilledBox(startX, startY, filledEndX, endY, fillColor)
  term.setBackgroundColor(oldBgColor)
  print()
end

