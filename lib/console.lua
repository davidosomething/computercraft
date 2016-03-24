---
-- lib/console.lua -- logging library exposed as API
-- @release 2.0.1
-- @author David O'Trakoun <me@davidosomething.com>
--

local defaultColors = {
  ['log'] = {
    ['fg'] = colors.white,
    ['bg'] = colors.black,
  },
  ['warn'] = {
    ['fg'] = colors.black,
    ['bg'] = colors.yellow,
  },
  ['error'] = {
    ['fg'] = colors.red,
    ['bg'] = colors.pink,
  },
}

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Output with color options
--
-- @tparam string message
-- @tparam string level
-- @tparam int fg color value
-- @tparam int bg color value
function echo(message, level, fg, bg)
  if level == nil then level = 'log' end
  if fg == nil then fg = defaultColors[level].fg end
  if bg == nil then bg = defaultColors[level].bg end
  term.setTextColor(fg)
  term.setBackgroundColor(bg)
  write(message)
end


-- Log a plain white on black message
--
-- @tparam string message
function log(message) -- luacheck: ignore
  echo(message, 'log')
  print()
end


-- Log a warning message
--
-- @tparam string message
function warn(message) -- luacheck: ignore
  -- show a lightblue # before the msg
  term.setTextColor(colors.lightBlue)
  term.setBackgroundColor(defaultColors['warn']['bg'])
  write('# ')

  echo(message, 'warn')
  print()
end


-- Log an error message
--
-- @tparam string message
function error(message) -- luacheck: ignore
  -- show a white ! on red bg before the msg
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.red)
  write('!')
  write(' ')

  echo(message, 'error')
  print()
end

