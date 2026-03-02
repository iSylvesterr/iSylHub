local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local ConfigPath = "iSylHub/Config/" 

if not isfolder("iSylHub") then makefolder("iSylHub") end
if not isfolder("iSylHub/Config") then makefolder("iSylHub/Config") end

ConfigData = {}
Elements = {} 
CURRENT_VERSION = nil

function SaveConfig(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(fileName, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(result) == "table" then
            ConfigData = result
            if LoadConfigElements then
                LoadConfigElements()
            end
            return true
        end
    end
    return false
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        local targetValue = ConfigData[key]
        if element.Set then
            if targetValue ~= nil then
                element:Set(targetValue)
            else
                if element.Type == "Toggle" then
                    element:Set(false)
                elseif element.Type == "Slider" then
                    element:Set(element.Default or 0)
                elseif element.Type == "Dropdown" then
                    element:Set(element.Default or "")
                elseif element.Type == "Input" then
                    element:Set("")
                end
            end
        end
    end
end

-- =============================================
-- THEME CONFIG - warna merah gelap premium
-- =============================================
local THEME = {
    Accent       = Color3.fromRGB(180, 30, 50),    -- merah gelap utama
    AccentBright = Color3.fromRGB(220, 50, 70),    -- merah terang untuk hover
    AccentDim    = Color3.fromRGB(120, 15, 30),    -- merah sangat gelap
    BgDark       = Color3.fromRGB(10, 10, 12),     -- background utama
    BgMid        = Color3.fromRGB(18, 18, 22),     -- background panel / tab bar
    BgLight      = Color3.fromRGB(26, 26, 32),     -- background section
    BgElement    = Color3.fromRGB(26, 26, 32),     -- item menyatu dgn section
    Text         = Color3.fromRGB(235, 235, 235),  -- teks utama
    TextDim      = Color3.fromRGB(150, 150, 155),  -- teks sekunder
    Separator    = Color3.fromRGB(180, 30, 50),    -- garis merah
    TabActive    = Color3.fromRGB(25, 25, 30),     -- tab terpilih
    TabInactive  = Color3.fromRGB(14, 14, 18),     -- tab biasa
}

local Icons = {
    info          = "rbxassetid://10723415903", 
    main          = "rbxassetid://10723407389", 
    auto          = "rbxassetid://10734923214", 
    shop          = "rbxassetid://10734952479", 
    teleport      = "rbxassetid://10734886004", 
    event         = "rbxassetid://10709789505", 
    webhook       = "rbxassetid://10709775560", 
    peformance    = "rbxassetid://10734963400", 
    misc          = "rbxassetid://10734972862", 
    config        = "rbxassetid://10734950309", 
}

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y
    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end
    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition
        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Position = pos })
            Tween:Play()
        end
        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then UpdatePos(input) end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize
        local minSizeX, minSizeY, defSizeX, defSizeY
        if isMobile then
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 470, 270
        else
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 640, 400
        end
        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)
        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object
        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = math.max(StartSize.X.Offset + Delta.X, minSizeX)
            local newHeight = math.max(StartSize.Y.Offset + Delta.Y, minSizeY)
            TweenService:Create(object, TweenInfo.new(0.2), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
        end
        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then UpdateSize(input) end
        end)
    end

    CustomSize(object)
    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(180, 30, 50)
        Circle.ImageTransparency = 0.7
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button
        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = Button.AbsoluteSize.X > Button.AbsoluteSize.Y and Button.AbsoluteSize.X * 1.5 or Button.AbsoluteSize.Y * 1.5
        local Time = 0.4
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.03
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local iSylHub = {}

-- =============================================
-- NOTIFY
-- =============================================
function iSylHub:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "iSylHub"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or THEME.Accent
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    
    local NotifyFunction = {}
    
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end

        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundTransparency = 1
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 350, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }):Play()
                    Count = Count + 1
                end
            end)
        end

        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end

        local CalculationWidth = 280 
        local ContentBounds = TextService:GetTextSize(NotifyConfig.Content, 15, Enum.Font.GothamBold, Vector2.new(CalculationWidth, 9999))
        local TextHeight = ContentBounds.Y
        local HeaderHeight = 36
        local BottomPadding = 15
        local TotalFrameHeight = math.max(HeaderHeight + TextHeight + BottomPadding, 65)

        local NotifyFrame = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        -- LEFT accent bar
        local AccentBar = Instance.new("Frame")
        local Top = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local TextLabel1 = Instance.new("TextLabel")
        local Close = Instance.new("TextButton")
        local ImageLabel = Instance.new("ImageLabel")
        local TextLabel2 = Instance.new("TextLabel")

        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, TotalFrameHeight)
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        -- Main notification frame - flat, dark
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.BackgroundColor3 = THEME.BgMid
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Parent = NotifyFrame

        -- Left red accent bar
        AccentBar.Name = "AccentBar"
        AccentBar.BackgroundColor3 = THEME.Accent
        AccentBar.BorderSizePixel = 0
        AccentBar.Size = UDim2.new(0, 3, 1, 0)
        AccentBar.Position = UDim2.new(0, 0, 0, 0)
        AccentBar.Parent = NotifyFrameReal

        -- Top outline
        local TopLine = Instance.new("Frame")
        TopLine.BackgroundColor3 = THEME.Accent
        TopLine.BorderSizePixel = 0
        TopLine.Size = UDim2.new(1, 0, 0, 1)
        TopLine.Parent = NotifyFrameReal

        Top.Name = "Top"
        Top.BackgroundTransparency = 1
        Top.Size = UDim2.new(1, 0, 0, HeaderHeight)
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = THEME.Text
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundTransparency = 1
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        TextLabel.Size = UDim2.new(0, 0, 1, 0)
        TextLabel.Position = UDim2.new(0, 14, 0, 0)
        TextLabel.Parent = Top

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundTransparency = 1
        TextLabel1.AutomaticSize = Enum.AutomaticSize.X
        TextLabel1.Size = UDim2.new(0, 0, 1, 0)
        TextLabel1.Parent = Top
        task.defer(function()
            TextLabel1.Position = UDim2.new(0, TextLabel.AbsoluteSize.X + 15, 0, 0)
        end)

        Close.Text = ""
        Close.BackgroundTransparency = 1
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.ImageColor3 = THEME.TextDim
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
        ImageLabel.Parent = Close

        TextLabel2.Name = "Content"
        TextLabel2.Font = Enum.Font.Gotham
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextColor3 = THEME.TextDim
        TextLabel2.TextSize = 14
        TextLabel2.BackgroundTransparency = 1
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.TextWrapped = true
        TextLabel2.AutomaticSize = Enum.AutomaticSize.Y
        TextLabel2.Position = UDim2.new(0, 14, 0, HeaderHeight)
        TextLabel2.Size = UDim2.new(1, -20, 0, 0) 
        TextLabel2.Parent = NotifyFrameReal

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 400, 0, 0) }):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function() NotifyFunction:Close() end)

        TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }):Play()

        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    
    return NotifyFunction
end

function notif(msg, delay, color, title, desc)
    return iSylHub:MakeNotify({
        Title = title or "iSylHub",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or THEME.Accent,
        Delay = delay or 4
    })
end

-- =============================================
-- WINDOW
-- =============================================
function iSylHub:Window(GuiConfig)
    GuiConfig              = GuiConfig or {}
    GuiConfig.Title        = GuiConfig.Title or "iSylHub"
    GuiConfig.Footer       = GuiConfig.Footer or "Version 1.0"
    GuiConfig.Color        = GuiConfig.Color or THEME.Accent
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Version      = GuiConfig.Version or 1
    GuiConfig.Icon         = GuiConfig.Icon or "rbxassetid://127299394628001"

    CURRENT_VERSION = GuiConfig.Version
    LoadConfigFromFile()

    local GuiFunc = {}

    -- Root ScreenGui
    local iSylHubGui = Instance.new("ScreenGui")
    iSylHubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    iSylHubGui.Name = "iSylHubGui"
    iSylHubGui.ResetOnSpawn = false
    iSylHubGui.Parent = game:GetService("CoreGui")

    -- Shadow holder
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    if isMobile then
        DropShadowHolder.Size = safeSize(470, 270)
    else
        DropShadowHolder.Size = safeSize(640, 400)
    end
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = iSylHubGui

    DropShadowHolder.Position = UDim2.new(0,
        iSylHubGui.AbsoluteSize.X // 2 - DropShadowHolder.Size.X.Offset // 2,
        0,
        iSylHubGui.AbsoluteSize.Y // 2 - DropShadowHolder.Size.Y.Offset // 2
    )

    -- Drop shadow image
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    -- =============================================
    -- MAIN WINDOW - flat, no corners
    -- =============================================
    local Main = Instance.new("Frame")
    Main.BackgroundColor3 = THEME.BgDark
    Main.BorderSizePixel = 0
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    -- Outline/border merah di sekeliling window
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.Accent
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.3
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = Main

    -- Red left border accent (seperti screenshot referensi)
    local LeftBorder = Instance.new("Frame")
    LeftBorder.Name = "LeftBorder"
    LeftBorder.BackgroundColor3 = THEME.Accent
    LeftBorder.BorderSizePixel = 0
    LeftBorder.Size = UDim2.new(0, 2, 1, 0)
    LeftBorder.Position = UDim2.new(0, 0, 0, 0)
    LeftBorder.ZIndex = 10
    LeftBorder.Parent = Main

    -- Gradient background (merah gelap ke hitam)
    local BgGradient = Instance.new("Frame")
    BgGradient.Name = "BgGradient"
    BgGradient.BackgroundColor3 = THEME.AccentDim
    BgGradient.BorderSizePixel = 0
    BgGradient.Size = UDim2.new(1, 0, 1, 0)
    BgGradient.ZIndex = 0
    BgGradient.Parent = Main

    local BgGradientUI = Instance.new("UIGradient")
    BgGradientUI.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 8, 12)),   -- merah sangat gelap
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(12, 10, 12)), -- hampir hitam
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10))      -- hitam
    })
    BgGradientUI.Rotation = 135
    BgGradientUI.Parent = BgGradient

    -- =============================================
    -- TOP BAR
    -- =============================================
    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = THEME.BgMid
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.ZIndex = 2
    Top.Parent = Main

    -- Top bar bottom separator line (merah)
    local TopSeparator = Instance.new("Frame")
    TopSeparator.BackgroundColor3 = THEME.Accent
    TopSeparator.BorderSizePixel = 0
    TopSeparator.Position = UDim2.new(0, 0, 1, -1)
    TopSeparator.Size = UDim2.new(1, 0, 0, 1)
    TopSeparator.ZIndex = 3
    TopSeparator.Parent = Top

    -- Logo icon di kiri
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Parent = Top
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Position = UDim2.new(0, 8, 0.5, 0)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Size = UDim2.new(0, 22, 0, 22)
    LogoIcon.Image = "rbxassetid://127299394628001"
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.ZIndex = 5

    -- Title
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = THEME.Text
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(0, 200, 1, 0)
    TextLabel.Position = UDim2.new(0, 36, 0, 0)
    TextLabel.ZIndex = 5
    TextLabel.Parent = Top

    -- Separator teks | diantara title dan footer
    local TitleSep = Instance.new("TextLabel")
    TitleSep.Font = Enum.Font.GothamBold
    TitleSep.Text = "|"
    TitleSep.TextColor3 = THEME.Accent
    TitleSep.TextSize = 14
    TitleSep.BackgroundTransparency = 1
    TitleSep.Size = UDim2.new(0, 15, 1, 0)
    TitleSep.ZIndex = 5
    TitleSep.Parent = Top
    task.defer(function()
        TitleSep.Position = UDim2.new(0, 36 + TextLabel.TextBounds.X + 8, 0, 0)
    end)

    -- Footer / subtitle
    local TextLabel1 = Instance.new("TextLabel")
    TextLabel1.Font = Enum.Font.Gotham
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = THEME.TextDim
    TextLabel1.TextSize = 12
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.BackgroundTransparency = 1
    TextLabel1.Size = UDim2.new(0, 200, 1, 0)
    TextLabel1.ZIndex = 5
    TextLabel1.Parent = Top
    task.defer(function()
        TextLabel1.Position = UDim2.new(0, 36 + TextLabel.TextBounds.X + 24, 0, 0)
    end)

    -- Close button
    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.BackgroundTransparency = 1
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.Position = UDim2.new(1, -6, 0.5, 0)
    Close.Size = UDim2.new(0, 26, 0, 26)
    Close.Name = "Close"
    Close.ZIndex = 5
    Close.Parent = Top

    local CloseImg = Instance.new("ImageLabel")
    CloseImg.Image = "rbxassetid://9886659671"
    CloseImg.ImageColor3 = THEME.TextDim
    CloseImg.BackgroundTransparency = 1
    CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseImg.Size = UDim2.new(0.7, 0, 0.7, 0)
    CloseImg.ZIndex = 5
    CloseImg.Parent = Close

    -- Minimize button
    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.BackgroundTransparency = 1
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.Position = UDim2.new(1, -36, 0.5, 0)
    Min.Size = UDim2.new(0, 26, 0, 26)
    Min.Name = "Min"
    Min.ZIndex = 5
    Min.Parent = Top

    local MinImg = Instance.new("ImageLabel")
    MinImg.Image = "rbxassetid://9886659276"
    MinImg.ImageColor3 = THEME.TextDim
    MinImg.BackgroundTransparency = 1
    MinImg.AnchorPoint = Vector2.new(0.5, 0.5)
    MinImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinImg.Size = UDim2.new(0.7, 0, 0.7, 0)
    MinImg.ZIndex = 5
    MinImg.Parent = Min

    -- =============================================
    -- TAB BAR (kiri) - mirip screenshot referensi
    -- =============================================
    local LayersTab = Instance.new("Frame")
    LayersTab.BackgroundColor3 = THEME.BgMid
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 0, 0, 39)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -39)
    LayersTab.Name = "LayersTab"
    LayersTab.ZIndex = 2
    LayersTab.Parent = Main

    -- Vertical separator antara tab dan content
    local TabSeparator = Instance.new("Frame")
    TabSeparator.BackgroundColor3 = THEME.Accent
    TabSeparator.BorderSizePixel = 0
    TabSeparator.Position = UDim2.new(0, GuiConfig["Tab Width"], 0, 39)
    TabSeparator.Size = UDim2.new(0, 1, 1, -39)
    TabSeparator.ZIndex = 5
    TabSeparator.Parent = Main

    -- =============================================
    -- CONTENT AREA (kanan)
    -- =============================================
    local Layers = Instance.new("Frame")
    Layers.BackgroundColor3 = THEME.BgDark
    Layers.BackgroundTransparency = 0
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 1, 0, 39)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 1), 1, -39)
    Layers.Name = "Layers"
    Layers.Parent = Main

    -- Section title bar di atas content
    local SectionTitleBar = Instance.new("Frame")
    SectionTitleBar.BackgroundColor3 = THEME.BgMid
    SectionTitleBar.BorderSizePixel = 0
    SectionTitleBar.Size = UDim2.new(1, 0, 0, 32)
    SectionTitleBar.ZIndex = 3
    SectionTitleBar.Parent = Layers

    local SectionTitleSep = Instance.new("Frame")
    SectionTitleSep.BackgroundColor3 = THEME.Accent
    SectionTitleSep.BorderSizePixel = 0
    SectionTitleSep.Position = UDim2.new(0, 0, 1, -1)
    SectionTitleSep.Size = UDim2.new(1, 0, 0, 1)
    SectionTitleSep.ZIndex = 4
    SectionTitleSep.Parent = SectionTitleBar

    local NameTab = Instance.new("TextLabel")
    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = THEME.Text
    NameTab.TextSize = 15
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundTransparency = 1
    NameTab.Size = UDim2.new(1, -10, 1, 0)
    NameTab.Position = UDim2.new(0, 12, 0, 0)
    NameTab.Name = "NameTab"
    NameTab.ZIndex = 4
    NameTab.Parent = SectionTitleBar

    local LayersReal = Instance.new("Frame")
    LayersReal.BackgroundTransparency = 1
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 0, 32)
    LayersReal.Size = UDim2.new(1, 0, 1, -32)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    local LayersFolder = Instance.new("Folder")
    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    local LayersPageLayout = Instance.new("UIPageLayout")
    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.TweenTime = 0.3
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad
    LayersPageLayout.Parent = LayersFolder

    -- Scrollable tab list
    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollTab.ScrollBarImageColor3 = THEME.Accent
    ScrollTab.ScrollBarThickness = 2
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 0)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    local function UpdateTabScrollSize()
        local OffsetY = 0
        for _, child in ScrollTab:GetChildren() do
            if child.Name ~= "UIListLayout" then
                OffsetY = OffsetY + child.Size.Y.Offset
            end
        end
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end
    ScrollTab.ChildAdded:Connect(UpdateTabScrollSize)
    ScrollTab.ChildRemoved:Connect(UpdateTabScrollSize)

    -- =============================================
    -- DIALOG HELPER
    -- =============================================
    local function CreateDialog(HostParent, TitleText, MsgText, OnYes)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.4
        Overlay.ZIndex = 50
        Overlay.Parent = HostParent

        local Dialog = Instance.new("Frame")
        Dialog.Size = UDim2.new(0, 300, 0, 145)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -72)
        Dialog.BackgroundColor3 = THEME.BgMid
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay

        -- Red left border on dialog
        local DialogAccent = Instance.new("Frame")
        DialogAccent.BackgroundColor3 = THEME.Accent
        DialogAccent.BorderSizePixel = 0
        DialogAccent.Size = UDim2.new(0, 3, 1, 0)
        DialogAccent.ZIndex = 52
        DialogAccent.Parent = Dialog

        -- Top line
        local DialogTopLine = Instance.new("Frame")
        DialogTopLine.BackgroundColor3 = THEME.Accent
        DialogTopLine.BorderSizePixel = 0
        DialogTopLine.Size = UDim2.new(1, 0, 0, 1)
        DialogTopLine.ZIndex = 52
        DialogTopLine.Parent = Dialog

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -10, 0, 36)
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = TitleText or "Confirmation"
        Title.TextSize = 16
        Title.TextColor3 = THEME.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 52
        Title.Parent = Dialog

        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 50)
        Message.Position = UDim2.new(0, 12, 0, 34)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = MsgText or "Are you sure you want to proceed?"
        Message.TextSize = 13
        Message.TextColor3 = THEME.TextDim
        Message.TextWrapped = true
        Message.TextXAlignment = Enum.TextXAlignment.Left
        Message.ZIndex = 52
        Message.Parent = Dialog

        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 32)
        Yes.Position = UDim2.new(0.05, 0, 1, -42)
        Yes.BackgroundColor3 = THEME.Accent
        Yes.BorderSizePixel = 0
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 14
        Yes.TextColor3 = THEME.Text
        Yes.ZIndex = 52
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 4)

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 32)
        Cancel.Position = UDim2.new(0.5, 10, 1, -42)
        Cancel.BackgroundColor3 = THEME.BgLight
        Cancel.BorderSizePixel = 0
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 14
        Cancel.TextColor3 = THEME.TextDim
        Cancel.ZIndex = 52
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 4)

        Yes.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            if OnYes then OnYes() end
        end)
        Cancel.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("iSylHubGui") then
            iSylHubGui:Destroy()
        end
    end

    -- =============================================
    -- MINIMIZE ICON
    -- =============================================
    local MinimizeIcon = Instance.new("ImageButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = iSylHubGui
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0)
    MinimizeIcon.BackgroundColor3 = THEME.BgMid
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0, 20)
    MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
    MinimizeIcon.Image = "rbxassetid://127299394628001"
    MinimizeIcon.ScaleType = Enum.ScaleType.Fit
    MinimizeIcon.Visible = false
    MinimizeIcon.ZIndex = 100

    Instance.new("UICorner", MinimizeIcon).CornerRadius = UDim.new(0, 8)

    -- Red border on minimize icon
    local MinIconStroke = Instance.new("UIStroke")
    MinIconStroke.Color = THEME.Accent
    MinIconStroke.Thickness = 2
    MinIconStroke.Parent = MinimizeIcon

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
        MinimizeIcon.Visible = true
    end)

    MinimizeIcon.Activated:Connect(function()
        MinimizeIcon.Visible = false
        DropShadowHolder.Visible = true
    end)

    -- Draggable minimize icon
    local dragging = false
    local dragStart, startPos
    MinimizeIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MinimizeIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MinimizeIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- =============================================
    -- CLOSE BUTTON
    -- =============================================
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        CreateDialog(DropShadowHolder, "iSylHub", "Do you want to close this window?\nYou will not be able to open it again", function()
            ConfigData = { _version = CURRENT_VERSION }
            if LoadConfigElements then LoadConfigElements() end
            ScriptLoaded = false
            NoclipEnabled = false
            if iSylHubGui then iSylHubGui:Destroy() end
            if game.CoreGui:FindFirstChild("ToggleUIButton") then
                game.CoreGui.ToggleUIButton:Destroy()
            end
        end)
    end)

    -- Hover effect on close
    Close.MouseEnter:Connect(function()
        TweenService:Create(CloseImg, TweenInfo.new(0.15), { ImageColor3 = THEME.Accent }):Play()
    end)
    Close.MouseLeave:Connect(function()
        TweenService:Create(CloseImg, TweenInfo.new(0.15), { ImageColor3 = THEME.TextDim }):Play()
    end)

    -- Toggle key
    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            DropShadowHolder.Visible = not DropShadowHolder.Visible
        end
    end)

    function GuiFunc:ToggleUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://127299394628001"
        MainButton.ScaleType = Enum.ScaleType.Fit

        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if DropShadowHolder then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
                ScreenGui.Enabled = not DropShadowHolder.Visible
            end
        end)

        ScreenGui.Enabled = not DropShadowHolder.Visible

        local tdragging = false
        local tdragStart, tstartPos

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                tdragging = true
                tdragStart = input.Position
                tstartPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then tdragging = false end
                end)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if tdragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - tdragStart
                MainButton.Position = UDim2.new(tstartPos.X.Scale, tstartPos.X.Offset + delta.X, tstartPos.Y.Scale, tstartPos.Y.Offset + delta.Y)
            end
        end)
    end

    GuiFunc:ToggleUI()
    DropShadowHolder.Size = UDim2.new(0, 640, 0, 400)
    MakeDraggable(Top, DropShadowHolder)

    -- Dropdown popup layer
    local MoreBlur = Instance.new("Frame")
    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = THEME.BgMid
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    local ConnectButton = Instance.new("TextButton")
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.BorderSizePixel = 0
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Name = "ConnectButton"
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame")
    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = THEME.BgMid
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    -- Red top line on dropdown
    local DropSelectTopLine = Instance.new("Frame")
    DropSelectTopLine.BackgroundColor3 = THEME.Accent
    DropSelectTopLine.BorderSizePixel = 0
    DropSelectTopLine.Size = UDim2.new(1, 0, 0, 1)
    DropSelectTopLine.Parent = DropdownSelect

    local UIStroke14 = Instance.new("UIStroke")
    UIStroke14.Color = THEME.Accent
    UIStroke14.Thickness = 1
    UIStroke14.Transparency = 0.7
    UIStroke14.Parent = DropdownSelect

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(DropdownSelect, TweenInfo.new(0.2), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.2)
            MoreBlur.Visible = false
        end
    end)

    local DropdownSelectReal = Instance.new("Frame")
    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = THEME.BgMid
    DropdownSelectReal.BackgroundTransparency = 0
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 0, 1, 0)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    local DropdownFolder = Instance.new("Folder")
    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    local DropPageLayout = Instance.new("UIPageLayout")
    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.01
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    -- =============================================
    -- TABS
    -- =============================================
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0

    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame")
        ScrolLayers.ScrollBarImageColor3 = THEME.Accent
        ScrolLayers.ScrollBarThickness = 2
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundTransparency = 1
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        local UIListLayout1 = Instance.new("UIListLayout")
        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        -- Tab button (flat design, mirip screenshot referensi)
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = CountTab == 0 and THEME.TabActive or THEME.TabInactive
        Tab.BackgroundTransparency = 0
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 32)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab

        -- Active indicator: garis merah di kiri tab terpilih
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Name = "ActiveBar"
        ActiveBar.BackgroundColor3 = THEME.Accent
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Size = UDim2.new(0, 3, 1, 0)
        ActiveBar.Position = UDim2.new(0, 0, 0, 0)
        ActiveBar.Visible = CountTab == 0
        ActiveBar.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabName = Instance.new("TextLabel")
        TabName.Font = Enum.Font.GothamBold
        TabName.Text = TabConfig.Name
        TabName.TextColor3 = CountTab == 0 and THEME.Text or THEME.TextDim
        TabName.TextSize = 14
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 1
        TabName.Size = UDim2.new(1, -10, 1, 0)
        TabName.Position = UDim2.new(0, 10, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab

        -- Icon tab (main, webhook, dll tetap ada)
        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 8, 0.5, 0)
        FeatureImg.AnchorPoint = Vector2.new(0, 0.5)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab

        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                FeatureImg.Image = Icons[TabConfig.Icon]
                -- Geser text kalau ada icon
                TabName.Position = UDim2.new(0, 30, 0, 0)
            else
                FeatureImg.Image = TabConfig.Icon
                TabName.Position = UDim2.new(0, 30, 0, 0)
            end
        end

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
        end

        -- Bottom separator line antar tab
        local TabBottomLine = Instance.new("Frame")
        TabBottomLine.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        TabBottomLine.BorderSizePixel = 0
        TabBottomLine.Position = UDim2.new(0, 0, 1, -1)
        TabBottomLine.Size = UDim2.new(1, 0, 0, 1)
        TabBottomLine.Parent = Tab

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            if Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                -- Reset semua tab
                for _, TabFrame in ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(TabFrame, TweenInfo.new(0.2), { BackgroundColor3 = THEME.TabInactive }):Play()
                        if TabFrame:FindFirstChild("ActiveBar") then
                            TabFrame.ActiveBar.Visible = false
                        end
                        if TabFrame:FindFirstChild("TabName") then
                            TweenService:Create(TabFrame.TabName, TweenInfo.new(0.2), { TextColor3 = THEME.TextDim }):Play()
                        end
                    end
                end
                -- Activate current tab
                TweenService:Create(Tab, TweenInfo.new(0.2), { BackgroundColor3 = THEME.TabActive }):Play()
                TweenService:Create(TabName, TweenInfo.new(0.2), { TextColor3 = THEME.Text }):Play()
                ActiveBar.Visible = true
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
            end
        end)

        -- =============================================
        -- SECTIONS
        -- =============================================
        local Sections = {}
        local CountSection = 0

        function Sections:AddSection(Title, AlwaysOpen)
            local Title = Title or "Section"

            local Section = Instance.new("Frame")
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            -- Section header bar
            local SectionReal = Instance.new("Frame")
            SectionReal.BackgroundColor3 = THEME.BgLight
            SectionReal.BackgroundTransparency = 0
            SectionReal.BorderSizePixel = 0
            SectionReal.Size = UDim2.new(1, -8, 0, 28)
            SectionReal.Position = UDim2.new(0, 4, 0, 2)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section
            Instance.new("UICorner", SectionReal).CornerRadius = UDim.new(0, 4)

            -- Left accent line on section header
            local SectionAccent = Instance.new("Frame")
            SectionAccent.BackgroundColor3 = THEME.Accent
            SectionAccent.BorderSizePixel = 0
            SectionAccent.Size = UDim2.new(0, 2, 1, 0)
            SectionAccent.Parent = SectionReal

            local SectionButton = Instance.new("TextButton")
            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 1
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Name = "SectionButton"
            SectionButton.Parent = SectionReal

            local FeatureFrame = Instance.new("Frame")
            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundTransparency = 1
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Name = "FeatureFrame"
            FeatureFrame.Parent = SectionReal

            local FeatureImg = Instance.new("ImageLabel")
            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.ImageColor3 = THEME.TextDim
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundTransparency = 1
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 0, 1, 0)
            FeatureImg.Name = "FeatureImg"
            FeatureImg.Parent = FeatureFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = THEME.Text
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.Size = UDim2.new(1, -50, 1, 0)
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionReal

            -- Items area
            local SectionAdd = Instance.new("Frame")
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.BorderSizePixel = 0
            SectionAdd.ClipsDescendants = true
            SectionAdd.Position = UDim2.new(0, 4, 0, 32)
            SectionAdd.Size = UDim2.new(1, -8, 0, 0)
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            local UIListLayout2 = Instance.new("UIListLayout")
            UIListLayout2.Padding = UDim.new(0, 2)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false
            local isAnimating = false
            local ANIM_TIME = 0.2
            local ANIM_STYLE = Enum.EasingStyle.Quad
            local ANIM_DIR = Enum.EasingDirection.Out

            local function UpdateSizeScroll()
                local OffsetY = 0
                for _, child in ScrolLayers:GetChildren() do
                    if child.Name ~= "UIListLayout" then
                        OffsetY = OffsetY + 3 + child.Size.Y.Offset
                    end
                end
                ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
            end

            local function UpdateSizeSection()
                if OpenSection then
                    local SectionSizeY = 32
                    for _, v in SectionAdd:GetChildren() do
                        if v.Name ~= "UIListLayout" then
                            SectionSizeY = SectionSizeY + v.Size.Y.Offset + 2
                        end
                    end
                    local tweenInfo = TweenInfo.new(ANIM_TIME, ANIM_STYLE, ANIM_DIR)
                    TweenService:Create(FeatureImg, tweenInfo, { Rotation = 0 }):Play()
                    TweenService:Create(Section, tweenInfo, { Size = UDim2.new(1, 0, 0, SectionSizeY) }):Play()
                    TweenService:Create(SectionAdd, tweenInfo, { Size = UDim2.new(1, -8, 0, SectionSizeY - 32) }):Play()
                    task.delay(ANIM_TIME, UpdateSizeScroll)
                end
            end

            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                UpdateSizeSection()
            elseif AlwaysOpen == false then
                OpenSection = false
            else
                OpenSection = true
                UpdateSizeSection()
            end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    if isAnimating then return end
                    isAnimating = true
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    local tweenInfo = TweenInfo.new(ANIM_TIME, ANIM_STYLE, ANIM_DIR)
                    if OpenSection then
                        TweenService:Create(FeatureImg, tweenInfo, { Rotation = -90 }):Play()
                        TweenService:Create(Section, tweenInfo, { Size = UDim2.new(1, 0, 0, 30) }):Play()
                        OpenSection = false
                        task.delay(ANIM_TIME, function()
                            UpdateSizeScroll()
                            isAnimating = false
                        end)
                    else
                        OpenSection = true
                        UpdateSizeSection()
                        task.delay(ANIM_TIME, function() isAnimating = false end)
                    end
                end)
            end

            if AlwaysOpen == true then
                local SectionSizeY = 32
                for _, v in SectionAdd:GetChildren() do
                    if v.Name ~= "UIListLayout" then
                        SectionSizeY = SectionSizeY + v.Size.Y.Offset + 2
                    end
                end
                Section.Size = UDim2.new(1, 0, 0, SectionSizeY)
                SectionAdd.Size = UDim2.new(1, -8, 0, SectionSizeY - 32)
                UpdateSizeScroll()
            end

            SectionAdd.ChildAdded:Connect(function()
                task.wait(0.05)
                UpdateSizeSection()
            end)
            SectionAdd.ChildRemoved:Connect(function()
                task.wait(0.05)
                UpdateSizeSection()
            end)

            local layout = ScrolLayers:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)
            end

            local Items = {}
            local CountItem = 0

            -- ==================
            -- PARAGRAPH
            -- ==================
            function Items:AddParagraph(ParagraphConfig)
                local ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                local ParagraphFunc = {}

                local Paragraph = Instance.new("Frame")
                Paragraph.BackgroundColor3 = THEME.BgElement
                Paragraph.BackgroundTransparency = 0
                Paragraph.BorderSizePixel = 0
                Paragraph.LayoutOrder = CountItem
                Paragraph.Size = UDim2.new(1, 0, 0, 46)
                Paragraph.Name = "Paragraph"
                Paragraph.Parent = SectionAdd
                Instance.new("UICorner", Paragraph).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Paragraph

                local iconOffset = 10
                if ParagraphConfig.Icon then
                    local IconImg = Instance.new("ImageLabel")
                    IconImg.Size = UDim2.new(0, 18, 0, 18)
                    IconImg.Position = UDim2.new(0, 8, 0, 12)
                    IconImg.BackgroundTransparency = 1
                    IconImg.Name = "ParagraphIcon"
                    IconImg.Parent = Paragraph
                    IconImg.Image = Icons and Icons[ParagraphConfig.Icon] or ParagraphConfig.Icon
                    iconOffset = 30
                end

                local ParagraphTitle = Instance.new("TextLabel")
                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = THEME.Text
                ParagraphTitle.TextSize = 13
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 8)
                ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
                ParagraphTitle.Name = "ParagraphTitle"
                ParagraphTitle.Parent = Paragraph

                local ParagraphContent = Instance.new("TextLabel")
                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = THEME.TextDim
                ParagraphContent.TextSize = 13
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 23)
                ParagraphContent.TextWrapped = false
                ParagraphContent.RichText = true
                ParagraphContent.Parent = Paragraph
                ParagraphContent.Size = UDim2.new(1, -16, 0, ParagraphContent.TextBounds.Y)
                ParagraphContent.Name = "ParagraphContent"

                local ParagraphButton
                if ParagraphConfig.ButtonText then
                    ParagraphButton = Instance.new("TextButton")
                    ParagraphButton.Position = UDim2.new(0, 8, 0, 42)
                    ParagraphButton.Size = UDim2.new(1, -16, 0, 26)
                    ParagraphButton.BackgroundColor3 = THEME.Accent
                    ParagraphButton.BorderSizePixel = 0
                    ParagraphButton.Font = Enum.Font.GothamBold
                    ParagraphButton.TextSize = 13
                    ParagraphButton.TextColor3 = THEME.Text
                    ParagraphButton.Text = ParagraphConfig.ButtonText
                    ParagraphButton.Parent = Paragraph
                    if ParagraphConfig.ButtonCallback then
                        ParagraphButton.MouseButton1Click:Connect(ParagraphConfig.ButtonCallback)
                    end
                end

                local function UpdateSize()
                    local totalHeight = ParagraphContent.TextBounds.Y + 30
                    if ParagraphButton then totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 5 end
                    Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
                end
                UpdateSize()
                ParagraphContent:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)

                function ParagraphFunc:SetContent(content)
                    ParagraphContent.Text = content or "Content"
                    UpdateSize()
                end

                CountItem = CountItem + 1
                return ParagraphFunc
            end

            -- ==================
            -- PANEL
            -- ==================
            function Items:AddPanel(PanelConfig)
                PanelConfig = PanelConfig or {}
                PanelConfig.Title = PanelConfig.Title or "Title"
                PanelConfig.Content = PanelConfig.Content or ""
                PanelConfig.Placeholder = PanelConfig.Placeholder or nil
                PanelConfig.Default = PanelConfig.Default or ""
                PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
                PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
                PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
                PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or function() end

                local configKey = "Panel_" .. PanelConfig.Title
                if ConfigData[configKey] ~= nil then PanelConfig.Default = ConfigData[configKey] end

                local PanelFunc = { Value = PanelConfig.Default }
                local baseHeight = 48
                if PanelConfig.Placeholder then baseHeight = baseHeight + 38 end
                baseHeight = baseHeight + (PanelConfig.SubButtonText and 40 or 36)

                local Panel = Instance.new("Frame")
                Panel.BackgroundColor3 = THEME.BgElement
                Panel.BorderSizePixel = 0
                Panel.Size = UDim2.new(1, 0, 0, baseHeight)
                Panel.LayoutOrder = CountItem
                Panel.Parent = SectionAdd
                Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Panel

                local Title = Instance.new("TextLabel")
                Title.Font = Enum.Font.GothamBold
                Title.Text = PanelConfig.Title
                Title.TextSize = 13
                Title.TextColor3 = THEME.Text
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 8)
                Title.Size = UDim2.new(1, -20, 0, 13)
                Title.Parent = Panel

                local Content = Instance.new("TextLabel")
                Content.Font = Enum.Font.Gotham
                Content.Text = PanelConfig.Content
                Content.TextSize = 12
                Content.TextColor3 = THEME.TextDim
                Content.TextXAlignment = Enum.TextXAlignment.Left
                Content.BackgroundTransparency = 1
                Content.RichText = true
                Content.Position = UDim2.new(0, 10, 0, 24)
                Content.Size = UDim2.new(1, -20, 0, 13)
                Content.Parent = Panel

                local InputBox
                if PanelConfig.Placeholder then
                    local InputFrame = Instance.new("Frame")
                    InputFrame.AnchorPoint = Vector2.new(0.5, 0)
                    InputFrame.BackgroundColor3 = THEME.BgMid
                    InputFrame.BorderSizePixel = 0
                    InputFrame.Position = UDim2.new(0.5, 0, 0, 44)
                    InputFrame.Size = UDim2.new(1, -16, 0, 28)
                    InputFrame.Parent = Panel
                    Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

                    InputBox = Instance.new("TextBox")
                    InputBox.Font = Enum.Font.Gotham
                    InputBox.PlaceholderText = PanelConfig.Placeholder
                    InputBox.PlaceholderColor3 = THEME.TextDim
                    InputBox.Text = PanelConfig.Default
                    InputBox.TextSize = 12
                    InputBox.TextColor3 = THEME.Text
                    InputBox.BackgroundTransparency = 1
                    InputBox.TextXAlignment = Enum.TextXAlignment.Left
                    InputBox.Size = UDim2.new(1, -10, 1, -4)
                    InputBox.Position = UDim2.new(0, 5, 0, 2)
                    InputBox.Parent = InputFrame
                end

                local yBtn = PanelConfig.Placeholder and 82 or 44

                local ButtonMain = Instance.new("TextButton")
                ButtonMain.Font = Enum.Font.GothamBold
                ButtonMain.Text = PanelConfig.ButtonText
                ButtonMain.TextColor3 = THEME.Text
                ButtonMain.TextSize = 13
                ButtonMain.BackgroundColor3 = THEME.Accent
                ButtonMain.BorderSizePixel = 0
                ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -10, 0, 28) or UDim2.new(1, -16, 0, 28)
                ButtonMain.Position = UDim2.new(0, 8, 0, yBtn)
                ButtonMain.Parent = Panel
                Instance.new("UICorner", ButtonMain).CornerRadius = UDim.new(0, 4)

                ButtonMain.MouseButton1Click:Connect(function()
                    PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
                end)

                if PanelConfig.SubButtonText then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = PanelConfig.SubButtonText
                    SubButton.TextColor3 = THEME.TextDim
                    SubButton.TextSize = 13
                    SubButton.BackgroundColor3 = THEME.BgLight
                    SubButton.BorderSizePixel = 0
                    SubButton.Size = UDim2.new(0.5, -10, 0, 28)
                    SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
                    SubButton.Parent = Panel
                    Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 4)
                    SubButton.MouseButton1Click:Connect(function()
                        PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
                    end)
                end

                if InputBox then
                    InputBox.FocusLost:Connect(function()
                        PanelFunc.Value = InputBox.Text
                        ConfigData[configKey] = InputBox.Text
                        SaveConfig()
                    end)
                end

                function PanelFunc:GetInput()
                    return InputBox and InputBox.Text or ""
                end

                CountItem = CountItem + 1
                return PanelFunc
            end

            -- ==================
            -- BUTTON
            -- ==================
            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.SubTitle = ButtonConfig.SubTitle or nil
                ButtonConfig.SubCallback = ButtonConfig.SubCallback or function() end
                ButtonConfig.Confirm = ButtonConfig.Confirm or false
                ButtonConfig.ConfirmText = ButtonConfig.ConfirmText or "Are you sure?"

                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = THEME.BgElement
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 36)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd
                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Button

                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 13
                MainButton.TextColor3 = THEME.Text
                MainButton.BackgroundColor3 = THEME.Accent
                MainButton.BorderSizePixel = 0
                MainButton.Size = ButtonConfig.SubTitle and UDim2.new(0.5, -6, 1, -8) or UDim2.new(1, -8, 1, -8)
                MainButton.Position = UDim2.new(0, 4, 0, 4)
                MainButton.Parent = Button
                Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 4)

                -- Hover effect
                MainButton.MouseEnter:Connect(function()
                    TweenService:Create(MainButton, TweenInfo.new(0.15), { BackgroundColor3 = THEME.AccentBright }):Play()
                end)
                MainButton.MouseLeave:Connect(function()
                    TweenService:Create(MainButton, TweenInfo.new(0.15), { BackgroundColor3 = THEME.Accent }):Play()
                end)

                MainButton.MouseButton1Click:Connect(function()
                    CircleClick(MainButton, Mouse.X, Mouse.Y)
                    if ButtonConfig.Confirm then
                        CreateDialog(DropShadowHolder, "Confirmation", ButtonConfig.ConfirmText, ButtonConfig.Callback)
                    else
                        ButtonConfig.Callback()
                    end
                end)

                if ButtonConfig.SubTitle then
                    local SubButton = Instance.new("TextButton")
                    SubButton.Font = Enum.Font.GothamBold
                    SubButton.Text = ButtonConfig.SubTitle
                    SubButton.TextColor3 = THEME.TextDim
                    SubButton.TextSize = 13
                    SubButton.BackgroundColor3 = THEME.BgLight
                    SubButton.BorderSizePixel = 0
                    SubButton.Size = UDim2.new(0.5, -6, 1, -8)
                    SubButton.Position = UDim2.new(0.5, 2, 0, 4)
                    SubButton.Parent = Button
                    Instance.new("UICorner", SubButton).CornerRadius = UDim.new(0, 4)
                    SubButton.MouseButton1Click:Connect(ButtonConfig.SubCallback)
                end

                CountItem = CountItem + 1
            end

            -- ==================
            -- TOGGLE
            -- ==================
            function Items:AddToggle(ToggleConfig)
                local ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Toggle"
                ToggleConfig.Title2 = ToggleConfig.Title2 or ""
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then ToggleConfig.Default = ConfigData[configKey] end

                local ToggleFunc = { Value = ToggleConfig.Default }
                local isInCallback = false

                local Toggle = Instance.new("Frame")
                Toggle.BackgroundColor3 = THEME.BgElement
                Toggle.BorderSizePixel = 0
                Toggle.LayoutOrder = CountItem
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionAdd
                Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Toggle

                local ToggleTitle = Instance.new("TextLabel")
                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 13
                ToggleTitle.TextColor3 = THEME.Text
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 10, 0, 8)
                ToggleTitle.Size = UDim2.new(1, -70, 0, 13)
                ToggleTitle.Name = "ToggleTitle"
                ToggleTitle.Parent = Toggle

                local ToggleTitle2 = Instance.new("TextLabel")
                ToggleTitle2.Font = Enum.Font.Gotham
                ToggleTitle2.Text = ToggleConfig.Title2
                ToggleTitle2.TextSize = 12
                ToggleTitle2.TextColor3 = THEME.TextDim
                ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle2.BackgroundTransparency = 1
                ToggleTitle2.Position = UDim2.new(0, 10, 0, 22)
                ToggleTitle2.Size = UDim2.new(1, -70, 0, 12)
                ToggleTitle2.Visible = ToggleConfig.Title2 ~= ""
                ToggleTitle2.Name = "ToggleTitle2"
                ToggleTitle2.Parent = Toggle

                local ToggleContent = Instance.new("TextLabel")
                ToggleContent.Font = Enum.Font.Gotham
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = THEME.TextDim
                ToggleContent.TextSize = 12
                ToggleContent.TextTransparency = 0.3
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.TextWrapped = true
                ToggleContent.Name = "ToggleContent"
                ToggleContent.Parent = Toggle

                if ToggleConfig.Title2 ~= "" then
                    Toggle.Size = UDim2.new(1, 0, 0, 52)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 35)
                else
                    Toggle.Size = UDim2.new(1, 0, 0, 40)
                    ToggleContent.Position = UDim2.new(0, 10, 0, 22)
                end

                ToggleContent.Size = UDim2.new(1, -70, 0, 12)

                -- Toggle switch (flat)
                local FeatureFrame2 = Instance.new("Frame")
                FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
                FeatureFrame2.BackgroundColor3 = THEME.BgLight
                FeatureFrame2.BorderSizePixel = 0
                FeatureFrame2.Position = UDim2.new(1, -10, 0.5, 0)
                FeatureFrame2.Size = UDim2.new(0, 32, 0, 16)
                FeatureFrame2.Name = "FeatureFrame"
                FeatureFrame2.Parent = Toggle
                Instance.new("UICorner", FeatureFrame2).CornerRadius = UDim.new(1, 0)

                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.BackgroundColor3 = THEME.TextDim
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Size = UDim2.new(0, 12, 0, 12)
                ToggleCircle.Position = UDim2.new(0, 2, 0, 2)
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = FeatureFrame2
                Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Parent = Toggle

                ToggleButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    SaveConfig()

                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = THEME.AccentBright }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 18, 0, 2), BackgroundColor3 = THEME.Text }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = THEME.Accent }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = THEME.Text }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = THEME.TextDim }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = THEME.BgLight }):Play()
                    end

                    if not isInCallback then
                        isInCallback = true
                        task.spawn(function()
                            if typeof(ToggleConfig.Callback) == "function" then
                                local ok, err = pcall(function() ToggleConfig.Callback(Value) end)
                                if not ok then warn("Toggle Callback error:", err) end
                            end
                            task.wait(0.05)
                            isInCallback = false
                        end)
                    end
                end

                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                ToggleFunc.Type = "Toggle"
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            -- ==================
            -- SLIDER
            -- ==================
            function Items:AddSlider(SliderConfig)
                local SliderConfig = SliderConfig or {}
                SliderConfig.Title = SliderConfig.Title or "Slider"
                SliderConfig.Content = SliderConfig.Content or ""
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local configKey = "Slider_" .. SliderConfig.Title
                if ConfigData[configKey] ~= nil then SliderConfig.Default = ConfigData[configKey] end

                local SliderFunc = { Value = SliderConfig.Default }

                local Slider = Instance.new("Frame")
                Slider.BackgroundColor3 = THEME.BgElement
                Slider.BorderSizePixel = 0
                Slider.LayoutOrder = CountItem
                Slider.Size = UDim2.new(1, 0, 0, 46)
                Slider.Name = "Slider"
                Slider.Parent = SectionAdd
                Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Slider

                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Font = Enum.Font.GothamBold
                SliderTitle.Text = SliderConfig.Title
                SliderTitle.TextColor3 = THEME.Text
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Position = UDim2.new(0, 10, 0, 8)
                SliderTitle.Size = UDim2.new(1, -160, 0, 13)
                SliderTitle.Name = "SliderTitle"
                SliderTitle.Parent = Slider

                local SliderContent = Instance.new("TextLabel")
                SliderContent.Font = Enum.Font.Gotham
                SliderContent.Text = SliderConfig.Content
                SliderContent.TextColor3 = THEME.TextDim
                SliderContent.TextSize = 12
                SliderContent.TextTransparency = 0.3
                SliderContent.TextXAlignment = Enum.TextXAlignment.Left
                SliderContent.BackgroundTransparency = 1
                SliderContent.Position = UDim2.new(0, 10, 0, 24)
                SliderContent.Size = UDim2.new(1, -160, 0, 12)
                SliderContent.TextWrapped = true
                SliderContent.Name = "SliderContent"
                SliderContent.Parent = Slider

                -- Value display
                local SliderValueBox = Instance.new("TextBox")
                SliderValueBox.Font = Enum.Font.GothamBold
                SliderValueBox.Text = tostring(SliderConfig.Default)
                SliderValueBox.TextColor3 = THEME.Text
                SliderValueBox.TextSize = 13
                SliderValueBox.BackgroundColor3 = THEME.BgMid
                SliderValueBox.BorderSizePixel = 0
                SliderValueBox.AnchorPoint = Vector2.new(0, 0.5)
                SliderValueBox.Position = UDim2.new(1, -148, 0.5, 0)
                SliderValueBox.Size = UDim2.new(0, 32, 0, 20)
                SliderValueBox.Parent = Slider
                Instance.new("UICorner", SliderValueBox).CornerRadius = UDim.new(0, 3)

                -- Slider track
                local SliderFrame = Instance.new("Frame")
                SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
                SliderFrame.BackgroundColor3 = THEME.BgLight
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Position = UDim2.new(1, -14, 0.5, 0)
                SliderFrame.Size = UDim2.new(0, 100, 0, 4)
                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = Slider
                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(1, 0)

                local SliderDraggable = Instance.new("Frame")
                SliderDraggable.BackgroundColor3 = THEME.Accent
                SliderDraggable.BorderSizePixel = 0
                SliderDraggable.Size = UDim2.fromScale(0.9, 1)
                SliderDraggable.Name = "SliderDraggable"
                SliderDraggable.Parent = SliderFrame
                Instance.new("UICorner", SliderDraggable).CornerRadius = UDim.new(1, 0)

                local SliderCircle = Instance.new("Frame")
                SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
                SliderCircle.BackgroundColor3 = THEME.Text
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Position = UDim2.new(1, 0, 0.5, 0)
                SliderCircle.Size = UDim2.new(0, 8, 0, 8)
                SliderCircle.Name = "SliderCircle"
                SliderCircle.Parent = SliderDraggable
                Instance.new("UICorner", SliderCircle).CornerRadius = UDim.new(1, 0)

                local Dragging = false
                local function Round(Number, Factor)
                    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                    if Result < 0 then Result = Result + Factor end
                    return Result
                end

                function SliderFunc:Set(Value)
                    Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = Value
                    SliderValueBox.Text = tostring(Value)
                    TweenService:Create(SliderDraggable, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                        { Size = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1) }):Play()
                    SliderConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        TweenService:Create(SliderCircle, TweenInfo.new(0.15), { Size = UDim2.new(0, 12, 0, 12) }):Play()
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) *
                            math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)))
                    end
                end)

                SliderFrame.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        TweenService:Create(SliderCircle, TweenInfo.new(0.15), { Size = UDim2.new(0, 8, 0, 8) }):Play()
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) *
                            math.clamp((Input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)))
                    end
                end)

                SliderValueBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local Valid = SliderValueBox.Text:gsub("[^%d]", "")
                    if Valid ~= "" then
                        SliderFunc:Set(math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max))
                    end
                end)

                SliderFunc:Set(SliderConfig.Default)
                CountItem = CountItem + 1
                SliderFunc.Type = "Slider"
                SliderFunc.Default = SliderConfig.Default
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            -- ==================
            -- INPUT
            -- ==================
            function Items:AddInput(InputConfig)
                local InputConfig = InputConfig or {}
                InputConfig.Title = InputConfig.Title or "Input"
                InputConfig.Placeholder = InputConfig.Placeholder or "Type here..."
                InputConfig.Content = InputConfig.Content or ""
                InputConfig.Callback = InputConfig.Callback or function() end
                InputConfig.Default = InputConfig.Default or ""

                local configKey = "Input_" .. InputConfig.Title
                if ConfigData[configKey] ~= nil then InputConfig.Default = ConfigData[configKey] end

                local InputFunc = { Value = InputConfig.Default }

                local Input = Instance.new("Frame")
                Input.BackgroundColor3 = THEME.BgElement
                Input.BorderSizePixel = 0
                Input.LayoutOrder = CountItem
                Input.Size = UDim2.new(1, 0, 0, 46)
                Input.Name = "Input"
                Input.Parent = SectionAdd
                Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Input

                local InputTitle = Instance.new("TextLabel")
                InputTitle.Font = Enum.Font.GothamBold
                InputTitle.Text = InputConfig.Title
                InputTitle.TextColor3 = THEME.Text
                InputTitle.TextSize = 13
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.BackgroundTransparency = 1
                InputTitle.Position = UDim2.new(0, 10, 0, 8)
                InputTitle.Size = UDim2.new(1, -160, 0, 13)
                InputTitle.Parent = Input

                local InputContent = Instance.new("TextLabel")
                InputContent.Font = Enum.Font.Gotham
                InputContent.Text = InputConfig.Content
                InputContent.TextColor3 = THEME.TextDim
                InputContent.TextSize = 12
                InputContent.TextTransparency = 0.3
                InputContent.TextXAlignment = Enum.TextXAlignment.Left
                InputContent.BackgroundTransparency = 1
                InputContent.Position = UDim2.new(0, 10, 0, 24)
                InputContent.Size = UDim2.new(1, -160, 0, 12)
                InputContent.TextWrapped = true
                InputContent.Parent = Input

                local InputFrame = Instance.new("Frame")
                InputFrame.AnchorPoint = Vector2.new(1, 0.5)
                InputFrame.BackgroundColor3 = THEME.BgMid
                InputFrame.BorderSizePixel = 0
                InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
                InputFrame.Size = UDim2.new(0, 145, 0, 28)
                InputFrame.ClipsDescendants = true
                InputFrame.Name = "InputFrame"
                InputFrame.Parent = Input
                Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

                -- Red bottom line on focus
                local InputFocusLine = Instance.new("Frame")
                InputFocusLine.BackgroundColor3 = THEME.Accent
                InputFocusLine.BorderSizePixel = 0
                InputFocusLine.Position = UDim2.new(0, 0, 1, -1)
                InputFocusLine.Size = UDim2.new(0, 0, 0, 1)
                InputFocusLine.Name = "FocusLine"
                InputFocusLine.Parent = InputFrame

                local InputTextBox = Instance.new("TextBox")
                InputTextBox.Font = Enum.Font.Gotham
                InputTextBox.PlaceholderColor3 = THEME.TextDim
                InputTextBox.PlaceholderText = InputConfig.Placeholder
                InputTextBox.Text = InputConfig.Default
                InputTextBox.TextColor3 = THEME.Text
                InputTextBox.TextSize = 13
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.BackgroundTransparency = 1
                InputTextBox.BorderSizePixel = 0
                InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
                InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
                InputTextBox.Size = UDim2.new(1, -10, 1, -4)
                InputTextBox.ClearTextOnFocus = false
                InputTextBox.Parent = InputFrame

                -- Focus line animation
                InputTextBox.Focused:Connect(function()
                    TweenService:Create(InputFocusLine, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 1) }):Play()
                end)
                InputTextBox.FocusLost:Connect(function()
                    TweenService:Create(InputFocusLine, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 1) }):Play()
                    InputFunc:Set(InputTextBox.Text)
                end)

                function InputFunc:Set(Value)
                    InputTextBox.Text = Value
                    InputFunc.Value = Value
                    InputConfig.Callback(Value)
                    ConfigData[configKey] = Value
                    SaveConfig()
                end

                InputFunc:Set(InputFunc.Value)
                CountItem = CountItem + 1
                InputFunc.Type = "Input"
                Elements[configKey] = InputFunc
                return InputFunc
            end

            -- ==================
            -- DROPDOWN
            -- ==================
            function Items:AddDropdown(DropdownConfig)
                local DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Dropdown"
                DropdownConfig.Content = DropdownConfig.Content or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Callback = DropdownConfig.Callback or function() end

                local configKey = "Dropdown_" .. DropdownConfig.Title
                if ConfigData[configKey] ~= nil then DropdownConfig.Default = ConfigData[configKey] end

                local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }

                local Dropdown = Instance.new("Frame")
                Dropdown.BackgroundColor3 = THEME.BgElement
                Dropdown.BorderSizePixel = 0
                Dropdown.LayoutOrder = CountItem
                Dropdown.Size = UDim2.new(1, 0, 0, 46)
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = SectionAdd
                Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 5)
                local _s = Instance.new("UIStroke")
                _s.Color = Color3.fromRGB(255,255,255)
                _s.Thickness = 1
                _s.Transparency = 0.92
                _s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                _s.Parent = Dropdown

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Parent = Dropdown

                local DropdownTitle = Instance.new("TextLabel")
                DropdownTitle.Font = Enum.Font.GothamBold
                DropdownTitle.Text = DropdownConfig.Title
                DropdownTitle.TextColor3 = THEME.Text
                DropdownTitle.TextSize = 13
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Position = UDim2.new(0, 10, 0, 8)
                DropdownTitle.Size = UDim2.new(1, -160, 0, 13)
                DropdownTitle.Parent = Dropdown

                local DropdownContent = Instance.new("TextLabel")
                DropdownContent.Font = Enum.Font.Gotham
                DropdownContent.Text = DropdownConfig.Content
                DropdownContent.TextColor3 = THEME.TextDim
                DropdownContent.TextSize = 12
                DropdownContent.TextTransparency = 0.3
                DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0, 10, 0, 24)
                DropdownContent.Size = UDim2.new(1, -160, 0, 12)
                DropdownContent.TextWrapped = true
                DropdownContent.Parent = Dropdown

                local SelectOptionsFrame = Instance.new("Frame")
                SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
                SelectOptionsFrame.BackgroundColor3 = THEME.BgMid
                SelectOptionsFrame.BorderSizePixel = 0
                SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
                SelectOptionsFrame.Size = UDim2.new(0, 145, 0, 28)
                SelectOptionsFrame.LayoutOrder = CountDropdown
                SelectOptionsFrame.Name = "SelectOptionsFrame"
                SelectOptionsFrame.Parent = Dropdown
                Instance.new("UICorner", SelectOptionsFrame).CornerRadius = UDim.new(0, 4)

                -- Red bottom line on select frame
                local SelectLine = Instance.new("Frame")
                SelectLine.BackgroundColor3 = THEME.Accent
                SelectLine.BorderSizePixel = 0
                SelectLine.Position = UDim2.new(0, 0, 1, -1)
                SelectLine.Size = UDim2.new(1, 0, 0, 1)
                SelectLine.Parent = SelectOptionsFrame

                local OptionSelecting = Instance.new("TextLabel")
                OptionSelecting.Font = Enum.Font.Gotham
                OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                OptionSelecting.TextColor3 = THEME.TextDim
                OptionSelecting.TextSize = 13
                OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
                OptionSelecting.BackgroundTransparency = 1
                OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
                OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
                OptionSelecting.Size = UDim2.new(1, -28, 1, -4)
                OptionSelecting.Name = "OptionSelecting"
                OptionSelecting.Parent = SelectOptionsFrame

                local OptionImg = Instance.new("ImageLabel")
                OptionImg.Image = "rbxassetid://16851841101"
                OptionImg.ImageColor3 = THEME.TextDim
                OptionImg.AnchorPoint = Vector2.new(1, 0.5)
                OptionImg.BackgroundTransparency = 1
                OptionImg.Position = UDim2.new(1, -2, 0.5, 0)
                OptionImg.Size = UDim2.new(0, 20, 0, 20)
                OptionImg.Parent = SelectOptionsFrame

                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Parent = DropdownFolder

                local SearchBox = Instance.new("TextBox")
                SearchBox.PlaceholderText = "Search..."
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.Text = ""
                SearchBox.TextSize = 13
                SearchBox.TextColor3 = THEME.Text
                SearchBox.PlaceholderColor3 = THEME.TextDim
                SearchBox.BackgroundColor3 = THEME.BgLight
                SearchBox.BorderSizePixel = 0
                SearchBox.Size = UDim2.new(1, 0, 0, 26)
                SearchBox.ClearTextOnFocus = false
                SearchBox.Parent = DropdownContainer
                Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 3)

                local ScrollSelect = Instance.new("ScrollingFrame")
                ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
                ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
                ScrollSelect.ScrollBarImageColor3 = THEME.Accent
                ScrollSelect.ScrollBarThickness = 2
                ScrollSelect.BorderSizePixel = 0
                ScrollSelect.BackgroundTransparency = 1
                ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollSelect.Parent = DropdownContainer

                local UIListLayout4 = Instance.new("UIListLayout")
                UIListLayout4.Padding = UDim.new(0, 1)
                UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout4.Parent = ScrollSelect

                UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    for _, option in pairs(ScrollSelect:GetChildren()) do
                        if option.Name == "Option" and option:FindFirstChild("OptionText") then
                            local text = string.lower(option.OptionText.Text)
                            option.Visible = query == "" or string.find(text, query, 1, true)
                        end
                    end
                end)

                local DropCount = 0

                function DropdownFunc:Clear()
                    for _, DropFrame in ScrollSelect:GetChildren() do
                        if DropFrame.Name == "Option" then DropFrame:Destroy() end
                    end
                    DropdownFunc.Value = DropdownConfig.Multi and {} or nil
                    DropdownFunc.Options = {}
                    OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                    DropCount = 0
                end

                function DropdownFunc:AddOption(option)
                    local label, value
                    if typeof(option) == "table" and option.Label and option.Value ~= nil then
                        label, value = tostring(option.Label), option.Value
                    else
                        label, value = tostring(option), option
                    end

                    local Option = Instance.new("Frame")
                    Option.BackgroundColor3 = THEME.BgMid
                    Option.BackgroundTransparency = 1
                    Option.Size = UDim2.new(1, 0, 0, 28)
                    Option.Name = "Option"
                    Option.Parent = ScrollSelect

                    local OptionButton = Instance.new("TextButton")
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.Size = UDim2.new(1, 0, 1, 0)
                    OptionButton.Text = ""
                    OptionButton.Parent = Option

                    local OptionText = Instance.new("TextLabel")
                    OptionText.Font = Enum.Font.Gotham
                    OptionText.Text = label
                    OptionText.TextSize = 13
                    OptionText.TextColor3 = THEME.Text
                    OptionText.Position = UDim2.new(0, 10, 0, 0)
                    OptionText.Size = UDim2.new(1, -20, 1, 0)
                    OptionText.BackgroundTransparency = 1
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.Name = "OptionText"
                    OptionText.Parent = Option

                    -- Left accent bar (hidden by default)
                    local ChooseBar = Instance.new("Frame")
                    ChooseBar.BackgroundColor3 = THEME.Accent
                    ChooseBar.BorderSizePixel = 0
                    ChooseBar.Size = UDim2.new(0, 2, 1, 0)
                    ChooseBar.Visible = false
                    ChooseBar.Name = "ChooseBar"
                    ChooseBar.Parent = Option

                    Option:SetAttribute("RealValue", value)

                    OptionButton.MouseEnter:Connect(function()
                        if not ChooseBar.Visible then
                            TweenService:Create(Option, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play()
                        end
                    end)
                    OptionButton.MouseLeave:Connect(function()
                        if not ChooseBar.Visible then
                            TweenService:Create(Option, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
                        end
                    end)

                    OptionButton.Activated:Connect(function()
                        if DropdownConfig.Multi then
                            if not table.find(DropdownFunc.Value, value) then
                                table.insert(DropdownFunc.Value, value)
                            else
                                for i, v in pairs(DropdownFunc.Value) do
                                    if v == value then table.remove(DropdownFunc.Value, i) break end
                                end
                            end
                        else
                            DropdownFunc.Value = value
                        end
                        DropdownFunc:Set(DropdownFunc.Value)
                    end)
                end

                function DropdownFunc:Set(Value)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end
                    ConfigData[configKey] = DropdownFunc.Value
                    SaveConfig()

                    local texts = {}
                    for _, Drop in ScrollSelect:GetChildren() do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v
                            if selected then
                                Drop.ChooseBar.Visible = true
                                TweenService:Create(Drop, TweenInfo.new(0.15), { BackgroundTransparency = 0.8 }):Play()
                                TweenService:Create(Drop.OptionText, TweenInfo.new(0.15), { TextColor3 = THEME.AccentBright }):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                Drop.ChooseBar.Visible = false
                                TweenService:Create(Drop, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
                                TweenService:Create(Drop.OptionText, TweenInfo.new(0.15), { TextColor3 = THEME.Text }):Play()
                            end
                        end
                    end

                    OptionSelecting.Text = (#texts == 0)
                        and (DropdownConfig.Multi and "Select Options" or "Select Option")
                        or table.concat(texts, ", ")
                    OptionSelecting.TextColor3 = #texts > 0 and THEME.Text or THEME.TextDim

                    if DropdownConfig.Callback then
                        if DropdownConfig.Multi then
                            DropdownConfig.Callback(DropdownFunc.Value)
                        else
                            DropdownConfig.Callback(DropdownFunc.Value ~= nil and tostring(DropdownFunc.Value) or "")
                        end
                    end
                end

                DropdownButton.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.2), { BackgroundTransparency = 0.05 }):Play()
                        local maxWidth = 0
                        for _, v in ipairs(DropdownConfig.Options) do
                            local text = (type(v) == "table" and v.Label) or tostring(v)
                            local size = TextService:GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(math.huge, 28))
                            if size.X > maxWidth then maxWidth = size.X end
                        end
                        local newWidth = math.max(maxWidth + 50, 150)
                        DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
                        DropdownSelect.Size = UDim2.new(0, newWidth, DropdownSelect.Size.Y.Scale, DropdownSelect.Size.Y.Offset)
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.2), { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
                    end
                end)

                function DropdownFunc:SetValues(newList, selecting)
                    newList = newList or {}
                    selecting = selecting or (DropdownConfig.Multi and {} or nil)
                    DropdownFunc:Clear()
                    for _, v in ipairs(newList) do DropdownFunc:AddOption(v) end
                    DropdownFunc.Options = newList
                    DropdownFunc:Set(selecting)
                end

                function DropdownFunc:SetValue(val) self:Set(val) end
                function DropdownFunc:GetValue() return self.Value end

                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
                CountItem = CountItem + 1
                CountDropdown = CountDropdown + 1
                DropdownFunc.Type = "Dropdown"
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            -- ==================
            -- DIVIDER
            -- ==================
            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Parent = SectionAdd
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.BackgroundColor3 = THEME.Accent
                Divider.BackgroundTransparency = 0.6
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem
                CountItem = CountItem + 1
                return Divider
            end

            -- ==================
            -- SUBSECTION
            -- ==================
            function Items:AddSubSection(title)
                title = title or "Sub Section"
                local SubSection = Instance.new("Frame")
                SubSection.BackgroundColor3 = THEME.BgMid
                SubSection.BorderSizePixel = 0
                SubSection.Size = UDim2.new(1, 0, 0, 22)
                SubSection.LayoutOrder = CountItem
                SubSection.Name = "SubSection"
                SubSection.Parent = SectionAdd
                Instance.new("UICorner", SubSection).CornerRadius = UDim.new(0, 4)

                -- Red left accent
                local SubAccent = Instance.new("Frame")
                SubAccent.BackgroundColor3 = THEME.Accent
                SubAccent.BorderSizePixel = 0
                SubAccent.Size = UDim2.new(0, 2, 1, 0)
                SubAccent.Parent = SubSection

                local Label = Instance.new("TextLabel")
                Label.Parent = SubSection
                Label.AnchorPoint = Vector2.new(0, 0.5)
                Label.Position = UDim2.new(0, 10, 0.5, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold
                Label.Text = title
                Label.TextColor3 = THEME.TextDim
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left

                CountItem = CountItem + 1
                return SubSection
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    return Tabs
end

return iSylHub
