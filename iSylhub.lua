local games = {
    [5750914919]      = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [16732694052]     = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [131716211654599] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [78632820802305]  = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/GetFish.lua",
    [130342654546662] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/SambungKata.lua",
    [110369730911937] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/cdid.lua",
    [6701277882]      = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fish%20it.lua",
}


if game.GameId == 0 then
    game:GetPropertyChangedSignal("GameId"):Wait()
end

local currentPlaceID = game.PlaceId
local currentUniverseID = game.GameId


local scriptURL = games[currentUniverseID] or games[currentPlaceID]
local isUniverse = (games[currentUniverseID] ~= nil)

if scriptURL then
    print("iSylHub: Loading script for " .. (isUniverse and "Universe ID: " .. tostring(currentUniverseID) or "Place ID: " .. tostring(currentPlaceID)))
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptURL))()
    end)

    if not success then
        local errorMsg = "iSylHub: Gagal memuat script! Error: " .. tostring(err)
        warn(errorMsg)
        game.Players.LocalPlayer:Kick("\n" .. errorMsg)
    end
else
    local msg = "\n[iSylHub] Map not supported yet!\nPlaceId: " .. tostring(currentPlaceID) .. "\nUniverseId: " .. tostring(currentUniverseID)
    game.Players.LocalPlayer:Kick(msg)
    print(msg)
end
