---
-- bin/gh -- github repo client
-- based on https://raw.githubusercontent.com/seriallos/computercraft/master/gist.lua
-- @release 2.0.2
-- @author David O'Trakoun <me@davidosomething.com>
-- @script gh
--

local tArgs = { ... }

local GH_URL   = "https://raw.githubusercontent.com"
local USERNAME = "davidosomething"
local REPO     = "computercraft"


-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

--- Wait for keypress
--
local function pause()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.lightGray)
  print('Press any key to continue')
  os.pullEvent("key")
end


--- Output fancy error message
--
-- @tparam {string} text
local function errorMessage(text)
  -- square
  term.setBackgroundColor(colors.red)
  write(' ')

  -- text
  term.setBackgroundColor(colors.pink)
  term.setTextColor(colors.red)
  write(' ' .. text .. '\n')
end


-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

(function ()
  if not http then
    errorMessage("GitHub requires HTTP API")
    return
  end

  if (#tArgs < 3) then
    print("USAGE: gh get SRC DEST")
    return
  end

  local action = tArgs[1]
  if "get" ~= action then
    errorMessage("Only 'get' is supported right now")
    return
  end

  local srcRelativePath = tArgs[2]
  local destPath = tArgs[3]

  local ref
  if #tArgs > 3 then ref = tArgs[4] end
  if ref == nil then ref = "master" end

  local urlparts = { GH_URL, USERNAME, REPO, ref, srcRelativePath }
  local url = table.concat(urlparts, '/')
  local request = http.get(url)
  if request then
    local response = request.readAll()
    request.close()

    local file = fs.open(destPath, "w")
    file.write(response)
    file.close()
  else
    errorMessage('Error retrieving ' .. srcRelativePath)
    errorMessage('from ' .. url)
    pause()
  end

end)()
