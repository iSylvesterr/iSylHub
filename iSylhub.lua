local games = {
    [5750914919] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [16732694052] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [131716211654599] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [78632820802305] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/GetFish.lua",
}

local currentPlaceID = game.PlaceId
local currentUniverseID = game.GameId
local scriptURL = games[currentUniverseID] or games[currentPlaceID]

if scriptURL then
    print("iSylHub: Loading script for ID " .. (games[currentUniverseID] and "Universe" or "Place"));
    (loadstring or load)(game:HttpGet(scriptURL))()
else
    local msg = "\nMap not supported yet!\nPlaceId: " .. tostring(currentPlaceID) .. "\nUniverseId: " .. tostring(currentUniverseID)
    game.Players.LocalPlayer:Kick(msg)
    print(msg)
end
