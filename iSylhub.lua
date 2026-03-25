local games = {
    [5750914919] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [16732694052] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [131716211654599] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fisch.lua",
    [78632820802305] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/GetFish.lua",
    [130342654546662] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/SambungKata.lua",
    [110369730911937] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/cdid.lua",
    [6701277882] = "https://raw.githubusercontent.com/iSylvesterr/library/refs/heads/main/Fish%20it.lua",
}

if game.GameId == 0 then
    game:GetPropertyChangedSignal("GameId"):Wait()
end

local currentPlaceID = game.PlaceId
local currentUniverseID = game.GameId

local scriptURL = games[currentUniverseID] or games[currentPlaceID]
local isUniverse = (games[currentUniverseID] ~= nil)

if scriptURL then
    local function playLoadingAnimation()
        local totalSteps = 5
        for i = 1, totalSteps do
            local percent = math.floor((i / totalSteps) * 100)
            local barFilled = string.rep("=", i * 2)
            local barEmpty = string.rep(" ", (totalSteps * 2) - (i * 2))
            
            local hexColor = "#FFA500" 
            if percent == 100 then 
                hexColor = "#00FF00" 
            end
            
            local modeText = isUniverse and "Universe" or "Place"
            local printMsg = string.format("<font color=\"%s\">[iSylHub] Loading %s\n[%s%s] %d%%</font>", hexColor, modeText, barFilled, barEmpty, percent)
            
            print(printMsg)
            task.wait(0.25)
        end
    end
    
    playLoadingAnimation()
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptURL))()
    end)

    if not success then
        local errMsg = "<font color=\"#FF0000\">[iSylHub] Gagal memuat script! Error: " .. tostring(err) .. "</font>"
        print(errMsg)
        game.Players.LocalPlayer:Kick("\niSylHub Error:\n" .. tostring(err))
    else
        print("<font color=\"#00FFFF\">[iSylHub] Script berhasil dieksekusi!</font>")
    end
else
    local failMsg = "<font color=\"#FF0000\">[iSylHub] Map not supported yet!\nPlaceId: " .. tostring(currentPlaceID) .. "\nUniverseId: " .. tostring(currentUniverseID) .. "</font>"
    print(failMsg)
    game.Players.LocalPlayer:Kick("\nMap not supported yet!")
end
