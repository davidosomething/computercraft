---
-- github repo client
-- bin/gh
--
-- based on https://raw.githubusercontent.com/seriallos/computercraft/master/gist.lua
--
-- pastebin QwW6Xg6M
--
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
    print("USAGE: gh get FILEPATH DEST")
    return
  end

  local action = tArgs[1]
  if "get" ~= action then
    errorMessage("Only 'get' is supported right now")
    return
  end

  local filepath = tArgs[2]

  local program = tArgs[3]
  if fs.exists(program) then
    errorMessage("File " .. program .. " exists. No action taken.")
    return
  end

  local ref
  if #tArgs > 3 then ref = tArgs[4] end
  if ref == nil then ref = "master" end

  local urlparts = { GH_URL, USERNAME, REPO, ref, filepath }
  local url = table.concat(urlparts, '/')
  local request = http.get(url)
  if request then
    local response = request.readAll()
    request.close()

    local file = fs.open( program, "w" )
    file.write( response )
    file.close()
  else
    errorMessage('Error retrieving ' .. filepath .. ' from ' .. program)
    errorMessage(url)
    pause()
  end

end)()
