---
-- github repo client
-- bin/gh v2.0.0
--
-- based on https://raw.githubusercontent.com/seriallos/computercraft/master/gist.lua
--
-- pastebin QwW6Xg6M
--
-- @author David O'Trakoun <me@davidosomething.com>
--

local tArgs = { ... }

local GH_URL   = "https://raw.githubusercontent.com"
local USERNAME = "davidosomething"
local REPO     = "computercraft"


-- -----------------------------------------------------------------------------
-- Main ------------------------------------------------------------------------
-- -----------------------------------------------------------------------------

(function ()
  if not http then
    print("GitHub requires HTTP API")
    return
  end

  if (#tArgs < 3) then
    print( "USAGE: gh get FILEPATH DEST" )
    return
  end

  local action = tArgs[1]
  if "get" ~= action then
    print( "Only 'get' is supported right now" )
    return
  end

  local filepath = tArgs[2]

  local program = tArgs[3]
  if fs.exists( program ) then
    print( "File "..program.." already exists.  No action taken" )
    return
  end

  local ref = tArgs[4]
  if ref == nil then ref = "master" end

  local url = GH_URL .. "/" .. USERNAME .. "/" .. REPO .. "/" .. ref .. "/" .. filepath
  local request = http.get( url )
  if request then
    local response = request.readAll()
    request.close()

    local file = fs.open( program, "w" )
    file.write( response )
    file.close()
  else
    print('Error retrieving ' .. program)
  end

end)()
