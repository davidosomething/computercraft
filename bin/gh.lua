---
-- bin/gh
-- v1.0.0
--
-- github repo client
-- based on https://raw.githubusercontent.com/seriallos/computercraft/master/gist.lua
-- pastebin QwW6Xg6M
--
-- @author David O'Trakoun <me@davidosomething.com>
--

local USERNAME = "davidosomething"

if not http then
  print("GitHub requires HTTP API")
  return
end

local tArgs = { ... }

if (#tArgs ~= 3) then
  print( "USAGE: dko get FILEPATH DEST" )
  return
end

local action = tArgs[1]
local filepath = tArgs[2]
local program = tArgs[3]

if "get" ~= action then
  print( "Only 'get' is supported right now" )
  return
end

if fs.exists( program ) then
  print( "File "..program.." already exists.  No action taken" )
  return
end

-- TODO: maybe handle multifile gists?
local url = "https://raw.githubusercontent.com/" .. USERNAME .. "/computercraft/master/" .. filepath

local request = http.get( url )
local response = request.readAll()
request.close()

local file = fs.open( program, "w" )
file.write( response )
file.close()

