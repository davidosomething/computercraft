---
-- lib/meter
-- v1.0.0
--
-- Meter exposed as API
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

-- horizontal
--
-- Horizontal meter
--
-- @param int startX term coord
-- @param int startY term coord
-- @param int endX term coord
-- @param int endY term coord
-- @param int value
-- @param int max
function horizontal(startX, startY, endX, endY, value, max)
  local oldBgColor = term.getBackgroundColor()

  local barWidth = endX - startX
  local filledRatio = value / max
  local filledWidth = math.floor(filledRatio * barWidth)
  local filledEndX = startX + filledWidth

  paintutils.drawFilledBox(startX, startY, endX, endY, EMPTY_COLOR)
  paintutils.drawFilledBox(startX, startY, filledEndX, endY, FILLED_COLOR)
  term.setBackgroundColor(oldBgColor)
end

