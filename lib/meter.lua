--
-- lib/meter
-- v1.0.0
-- by @davidosomething
--
-- Meter exposed as API
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
  local emptyStartX = filledEndX + 1

  paintutils.drawFilledBox(x, startY, endX, endY, EMPTY_COLOR)
  paintutils.drawFilledBox(x, startY, filledEndX, endY, FILLED_COLOR)
  term.setBackgroundColor(oldBgColor)
end

