---
-- Meter exposed as API
-- lib/meter v1.0.0
--
--
-- pastebin LeGJ4Wkb
--
-- @author David O'Trakoun <me@davidosomething.com>
--

-- -----------------------------------------------------------------------------
-- Meta ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

local FILLED_COLOR = colors.red
local EMPTY_COLOR = colors.gray

-- -----------------------------------------------------------------------------
-- Functions -------------------------------------------------------------------
-- -----------------------------------------------------------------------------

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
function horizontal(startX, startY, endX, endY, value, max)
  local oldBgColor = colors.black
  if term.getBackgroundColor ~= nil then -- compatibility with CC <1.7.4
    oldBgColor = term.getBackgroundColor()
  end

  local barWidth = endX - startX
  local filledRatio = value / max
  local filledWidth = math.floor(filledRatio * barWidth)
  local filledEndX = startX + filledWidth

  paintutils.drawFilledBox(startX, startY, endX, endY, EMPTY_COLOR)
  paintutils.drawFilledBox(startX, startY, filledEndX, endY, FILLED_COLOR)
  term.setBackgroundColor(oldBgColor)
end

