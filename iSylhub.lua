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
    -- Membuat UI Loading Sementara di Layar
    local CoreGui = game:GetService("CoreGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "iSylHubLoader"
    pcall(function() sg.Parent = (gethui and gethui()) or CoreGui end)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0, 30)
    txt.Position = UDim2.new(0, 0, 0, -30) -- Mulai tersembunyi di atas luar layar
    txt.BackgroundTransparency = 0.3
    txt.BackgroundColor3 = Color3.new(0, 0, 0)
    txt.TextColor3 = Color3.new(1, 1, 1) -- Warna awal: Putih
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Parent = sg
    
    -- Animasi UI turun ke dalam layar
    game:GetService("TweenService"):Create(txt, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.5)

    local modeText = isUniverse and "Universe" or "Place"
    local totalSteps = 10
    
    for i = 1, totalSteps do
        local percent = math.floor((i / totalSteps) * 100)
        local barFilled = string.rep("=", i)
        local barEmpty = string.rep("-", totalSteps - i)
        
        txt.Text = string.format("[iSylHub] Loading %s | [%s%s] %d%%", modeText, barFilled, barEmpty, percent)
        
        if percent == 100 then
            txt.TextColor3 = Color3.fromRGB(50, 255, 50) -- Berubah jadi Hijau
            txt.Text = "[iSylHub] Successfully Loaded!"
        end
        
        task.wait(0.15)
    end
    
    task.wait(0.5)
    -- Animasi UI naik ke luar layar lalu dihancurkan (supaya bersih)
    local tweenOut = game:GetService("TweenService"):Create(txt, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, -30)})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    sg:Destroy()
    
    -- Eksekusi script utama
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptURL))()
    end)

    if not success then
        warn("[iSylHub] Gagal memuat script! Error: " .. tostring(err))
        game.Players.LocalPlayer:Kick("\niSylHub Error:\n" .. tostring(err))
    else
        print("[iSylHub] Script berhasil dieksekusi!")
    end
else
    warn("[iSylHub] Map not supported yet!\nPlaceId: " .. tostring(currentPlaceID) .. "\nUniverseId: " .. tostring(currentUniverseID))
    game.Players.LocalPlayer:Kick("\nMap not supported yet!")
end
