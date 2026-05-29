-- ============================================================
-- Napoleon UI Library
-- ============================================================
_G.ScriptFullyLoaded = false 

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fdhlnn23/NapoleonUI/refs/heads/main/NPLN-UIv2.lua"))()

local ICON_ID = "96531489912535" 

local function notif(content, duration, title)
    if not _G.ScriptFullyLoaded then
        return
    end

    if Library and Library.MakeNotify then
        Library:MakeNotify({ Title = title or "Napoleon", Content = content, Delay = duration or 4, Icon = "rbxassetid://" .. ICON_ID })
    end
end

-- ============================================================
-- SERVICES & CORE
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- Fight position — TP ke sini saat Auto Farm diaktifkan
local FIGHT_CFRAME = CFrame.new(284.34, 10.83, 333.00) * CFrame.Angles(math.rad(0.00), math.rad(89.17), math.rad(-0.00))

-- Helper: TP character ke CFrame
local function TeleportTo(cf)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
    end
end

local Config = {
    AutoClickImage = false,
    AutoFarm = false,
}

-- Cache Sincy channel agar tidak re-require setiap call
local _fightChannel = nil
local function GetFightChannel()
    if _fightChannel then return _fightChannel end
    local ok, ch = pcall(function()
        return require(ReplicatedStorage.ConsPackages).Sincy.Client.WaitChannel(
            ("Fighting_%*"):format(LocalPlayer.UserId), 0
        )
    end)
    if ok and ch then _fightChannel = ch end
    return _fightChannel
end

-- Helper: true selama fight Active
local function IsFightActive()
    local ch = GetFightChannel()
    if not ch then return false end
    local data = ch:GetData()
    return typeof(data) == "table" and data.Active == true
end

-- ============================================================
-- 1. Anti-AFK (Non-intrusive)
-- ============================================================
-- AutoReconnectController game reset timer u7 via UserInputService.InputChanged.
-- Simulasi mouse movement (delta 0,0) = trigger InputChanged tanpa efek gameplay.
getgenv().AntiAFKEnabled = true

-- Disable existing Idled connections agar tidak bentrok
task.spawn(function()
    pcall(function()
        local gc = getconnections or get_signal_cons
        if gc then
            for _, conn in pairs(gc(LocalPlayer.Idled)) do
                if conn.Disable then conn:Disable() end
            end
        end
    end)
end)

-- Loop setiap 60 detik (timeout game = 900 detik, jadi masih sangat aman)
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    while true do
        task.wait(60)
        if not getgenv().AntiAFKEnabled then continue end

        -- PC: simulasi mouse move → trigger InputChanged → reset u7 AutoReconnectController
        pcall(function()
            VIM:SendMouseMoveEvent(0, 0, game)
        end)

        -- Mobile: simulasi touch Change (jari bergerak, bukan tap) → trigger InputChanged
        -- State.Change tidak create tap/click, jadi tidak ganggu gameplay
        pcall(function()
            VIM:SendTouchEvent(0, Enum.UserInputState.Change, 0, 0, game)
        end)

        -- Bypass Roblox engine idle kick (PC & Mobile)
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- Backup: handle Roblox Idled event
LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFKEnabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- ============================================================
-- WINDOW UI
-- ============================================================
local Window = Library:Window({
    Title = "Napoleon",
    Footer = "Fight A Lucky Block",
    Color = Color3.fromRGB(255, 255, 255),
    Color2 = Color3.fromRGB(192, 192, 192),
    ["Tab Width"] = 130,
    Image = "136289055140268",
    WindowIMG = "93732999692312",
    LogoHUB = "136289055140268"
})
local Tabs = Window

local function LoadInfoTab()
    -- ─── TAB INFO ───
    local InfoTab = Tabs:AddTab({ Name = "Info", Icon = "info" })

    local InfoSection = InfoTab:AddSection("Napoleon — Fight A Lucky Block", true)
    InfoSection:AddParagraph({ 
        Title = "📋 Script Info", 
        Content = "Auto Click ImageButton: Automatically clicks the pop-up ImageButton to spawn items." 
    })

    InfoSection:AddButton({
        Title = "Join Discord",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/RKaZ9vEbpb")
                notif("Discord link copied to clipboard!", 3, "Napoleon")
            else
                notif("Your executor does not support copy. Join manually: discord.gg/RKaZ9vEbpb", 5, "Napoleon")
            end
        end
    })
end

local function LoadMainTab()
    -- ─── TAB MAIN ───
    local MainTab = Tabs:AddTab({ Name = "Main", Icon = "rod" })

    local AutoSection = MainTab:AddSection("Auto Farm")

    AutoSection:AddToggle({
        Title = "Auto Farm",
        Title2 = "Enable",
        Content = "TP ke posisi fight lalu spam DamageBoostClick",
        Default = false,
        Callback = function(val)
            Config.AutoFarm = val
            if val then
                -- TP langsung ke posisi fight saat toggle dinyalakan
                pcall(TeleportTo, FIGHT_CFRAME)
                notif("Auto Farm Enabled", 3, "Napoleon")
            else
                notif("Auto Farm Disabled", 3, "Napoleon")
            end
        end
    })

    AutoSection:AddToggle({
        Title = "Auto Click ImageButton",
        Title2 = "Enable",
        Content = "Auto click LocalToSpawnPopUps ImageButton",
        Default = false,
        Callback = function(val)
            Config.AutoClickImage = val
            if val then
                notif("Auto Click Enabled", 3, "Napoleon")
            else
                notif("Auto Click Disabled", 3, "Napoleon")
            end
        end
    })

end

local function LoadMiscTab()
    -- ─── TAB MISC ───
    local MiscTab = Tabs:AddTab({ Name = "Misc", Icon = "rbxassetid://130986441300365" })

    local AntiAFKSection = MiscTab:AddSection("Anti AFK")
    AntiAFKSection:AddToggle({
        Title = "Anti AFK",
        Title2 = "Enable",
        Content = "Mencegah kick AFK dengan simulasi input (Button2Down/Up).",
        Default = true,
        Callback = function(val)
            getgenv().AntiAFKEnabled = val
            notif(val and "Anti AFK Aktif" or "Anti AFK Nonaktif", 3, "Napoleon")
        end
    })
end

LoadInfoTab()
LoadMainTab()
LoadMiscTab()

-- ============================================================
-- AUTO CLICK LOGIC
-- ============================================================
local function ClickButton(button)
    if getconnections then
        for _, connection in ipairs(getconnections(button.MouseButton1Click)) do
            pcall(function() connection:Fire() end)
        end
        for _, connection in ipairs(getconnections(button.Activated)) do
            pcall(function() connection:Fire() end)
        end
    end
    if firesignal then
        pcall(function() firesignal(button.MouseButton1Click) end)
        pcall(function() firesignal(button.Activated) end)
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if Config.AutoClickImage then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local mainScreen = playerGui:FindFirstChild("MainScreen")
                    if mainScreen then
                        local hud = mainScreen:FindFirstChild("HUD")
                        if hud then
                            local popups = hud:FindFirstChild("LocalToSpawnPopUps")
                            if popups then
                                local imgBtn = popups:FindFirstChild("ImageButton")
                                -- Click it if it exists and is visible
                                if imgBtn and imgBtn:IsA("ImageButton") and imgBtn.Visible and popups.Visible then
                                    ClickButton(imgBtn)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO FARM LOOP
-- ============================================================

-- Loop 1: Spam DamageBoostClick tepat 20x/detik (server MaxClicksPerSec dari Balance.Combat)
-- Lebih dari 20/detik percuma karena server rate-limit
task.spawn(function()
    local ClickEvent = ReplicatedStorage.ConsPackages.Link.RemoteEvents:FindFirstChild("DamageBoostClick")
    local INTERVAL = 1 / 20 -- 20 clicks/sec = MaxClicksPerSec
    while true do
        task.wait(INTERVAL)
        if Config.AutoFarm and ClickEvent then
            pcall(function() ClickEvent:FireServer() end)
        end
    end
end)

-- Loop 2: Monitor fight via Sincy channel — re-TP saat fight selesai (Active == false)
task.spawn(function()
    while true do
        task.wait(1)
        if not Config.AutoFarm then continue end

        local ch = GetFightChannel()
        if not ch then continue end

        -- Tunggu fight mulai
        if not IsFightActive() then continue end

        -- Fight aktif — tunggu sampai Active == false
        repeat task.wait(0.3) until not IsFightActive() or not Config.AutoFarm

        -- Fight selesai & AutoFarm masih aktif → TP kembali ke posisi
        if Config.AutoFarm then
            task.wait(0.3) -- jeda singkat (ExitDestination sedang diproses)
            pcall(TeleportTo, FIGHT_CFRAME)
        end
    end
end)




_G.ScriptFullyLoaded = true
notif("Script successfully loaded!", 5, "Napoleon")
