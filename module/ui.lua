-- iSylHub UI Library - Splashscreen Module

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function(gui)
    if gui and gui.Parent then gui.Parent = CoreGui end
end

local UI = {}

-- Helper: Create tween
local function createTween(instance, tweenInfo, properties)
    return TweenService:Create(instance, tweenInfo, properties)
end

-- Helper: Create text label
local function createTextLabel(parent, config)
    local label = Instance.new("TextLabel")
    label.Name = config.name
    label.Size = UDim2.new(0, 0, 0, 0)
    label.Position = config.position or UDim2.new(0.5, 0, 0.5, 0)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = config.font or Enum.Font.Gotham
    label.Text = config.text
    label.TextColor3 = config.textColor or Color3.fromRGB(255, 255, 255)
    label.TextSize = config.textSize or 18
    label.TextStrokeTransparency = config.strokeTransparency or 1
    label.TextStrokeColor3 = config.strokeColor or Color3.fromRGB(0, 0, 0)
    label.ZIndex = config.zIndex or 12
    label.Parent = parent
    
    -- Auto size
    label.Size = UDim2.new(0, label.TextBounds.X + 20, 0, label.TextBounds.Y)
    return label
end

-- Splashscreen Module
UI.Splashscreen = {}
UI.Splashscreen.__index = UI.Splashscreen

function UI.Splashscreen.new(config)
    config = config or {}
    local self = setmetatable({}, UI.Splashscreen)
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "iSylHubUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ProtectGui(self.screenGui)
    self.screenGui.Parent = PlayerGui
    
    self.duration = config.duration or 3
    self.fadeInTime = config.fadeInTime or 0.8
    self.fadeOutTime = config.fadeOutTime or 0.6
    self.logoId = config.logoId or 105242031754218
    self.title = config.title or "iSylHub Premium"
    
    self:createUI()
    return self
end

function UI.Splashscreen:createUI()
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "SplashscreenFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Parent = self.screenGui
    
    -- Blur Effect
    self.blur = Instance.new("BlurEffect")
    self.blur.Size = 24
    self.blur.Parent = Lighting
    
    -- Content Container
    local container = Instance.new("Frame")
    container.Name = "ContentContainer"
    container.Size = UDim2.new(0, 400, 0, 300)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 11
    container.Parent = mainFrame
    
    -- Logo
    self.logo = Instance.new("ImageLabel")
    self.logo.Name = "Logo"
    self.logo.Size = UDim2.new(0, 100, 0, 100)
    self.logo.Position = UDim2.new(0.5, 0, 0.3, 0)
    self.logo.AnchorPoint = Vector2.new(0.5, 0.5)
    self.logo.BackgroundTransparency = 1
    self.logo.BorderSizePixel = 0
    self.logo.Image = "rbxassetid://" .. self.logoId
    self.logo.ImageTransparency = 1
    self.logo.ScaleType = Enum.ScaleType.Fit
    self.logo.ZIndex = 12
    self.logo.Parent = container
    
    -- Welcome Text
    self.welcomeText = createTextLabel(container, {
        name = "WelcomeText",
        position = UDim2.new(0.5, 0, 0.58, 0),
        text = "Welcome to",
        font = Enum.Font.Gotham,
        textColor = Color3.fromRGB(200, 200, 200),
        textSize = 18,
        strokeTransparency = 0.7
    })
    self.welcomeText.TextTransparency = 1
    self.welcomeText.TextStrokeTransparency = 1
    
    -- Title Text
    self.title = createTextLabel(container, {
        name = "Title",
        position = UDim2.new(0.5, 0, 0.68, 0),
        text = self.title,
        font = Enum.Font.GothamBold,
        textColor = Color3.fromRGB(255, 255, 255),
        textSize = 32,
        strokeTransparency = 0.5
    })
    self.title.TextTransparency = 1
    self.title.TextStrokeTransparency = 1
    
    self.mainFrame = mainFrame
end

function UI.Splashscreen:show()
    local fadeInfo = TweenInfo.new(self.fadeInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local scaleInfo = TweenInfo.new(self.fadeInTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Fade In
    local fadeInTweens = {
        createTween(self.mainFrame, fadeInfo, {BackgroundTransparency = 0.3}),
        createTween(self.logo, fadeInfo, {ImageTransparency = 0}),
        createTween(self.welcomeText, fadeInfo, {TextTransparency = 0, TextStrokeTransparency = 0.7}),
        createTween(self.title, fadeInfo, {TextTransparency = 0, TextStrokeTransparency = 0.5}),
        createTween(self.logo, scaleInfo, {Size = UDim2.new(0, 150, 0, 150)})
    }
    
    for _, tween in ipairs(fadeInTweens) do tween:Play() end
    wait(self.fadeInTime)
    
    -- Color Animation
    local colorTime = self.duration - self.fadeInTime - self.fadeOutTime
    if colorTime > 0 then
        local white, red = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0)
        local transitionTime = colorTime / 3
        
        -- White -> Red
        local t1 = createTween(self.title, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine), {TextColor3 = red})
        t1:Play()
        t1.Completed:Wait()
        
        -- Red -> White -> Red (if time allows)
        if colorTime > transitionTime * 1.5 then
            local t2 = createTween(self.title, TweenInfo.new(transitionTime * 0.3, Enum.EasingStyle.Sine), {TextColor3 = white})
            t2:Play()
            t2.Completed:Wait()
            
            local finalTime = colorTime - (transitionTime * 1.3)
            if finalTime > 0.1 then
                local t3 = createTween(self.title, TweenInfo.new(finalTime, Enum.EasingStyle.Sine), {TextColor3 = red})
                t3:Play()
                t3.Completed:Wait()
            else
                self.title.TextColor3 = red
            end
        else
            self.title.TextColor3 = red
        end
    else
        self.title.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- Fade Out
    local fadeOutInfo = TweenInfo.new(self.fadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local fadeOutTweens = {
        createTween(self.mainFrame, fadeOutInfo, {BackgroundTransparency = 1}),
        createTween(self.logo, fadeOutInfo, {ImageTransparency = 1}),
        createTween(self.welcomeText, fadeOutInfo, {TextTransparency = 1, TextStrokeTransparency = 1}),
        createTween(self.title, fadeOutInfo, {TextTransparency = 1, TextStrokeTransparency = 1}),
        createTween(self.blur, fadeOutInfo, {Size = 0})
    }
    
    for _, tween in ipairs(fadeOutTweens) do tween:Play() end
    fadeOutTweens[1].Completed:Connect(function() self:destroy() end)
end

function UI.Splashscreen:destroy()
    if self.screenGui then self.screenGui:Destroy() end
    if self.blur then self.blur.Size = 0 end
end

-- Form Module
UI.Form = {}
UI.Form.__index = UI.Form

function UI.Form.new(config)
    config = config or {}
    local self = setmetatable({}, UI.Form)
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "iSylHubForm"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ProtectGui(self.screenGui)
    self.screenGui.Parent = PlayerGui
    
    self.onSubmit = config.onSubmit or function() end
    self.onClose = config.onClose or function() end
    self.title = config.title or "Enter Token"
    self.placeholder = config.placeholder or "Paste your token here..."
    self.getTokenLink = config.getTokenLink or "https://example.com/get-token"
    
    self:createUI()
    return self
end

function UI.Form:createUI()
    -- Background Overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 20
    overlay.Parent = self.screenGui
    
    -- Blur Effect
    self.blur = Instance.new("BlurEffect")
    self.blur.Size = 20
    self.blur.Parent = Lighting
    
    -- Main Form Container
    local formContainer = Instance.new("Frame")
    formContainer.Name = "FormContainer"
    formContainer.Size = UDim2.new(0, 380, 0, 240)
    formContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    formContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    formContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    formContainer.BorderSizePixel = 0
    formContainer.ZIndex = 21
    formContainer.Parent = overlay
    
    -- Rounded Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = formContainer
    
    -- Border (red accent)
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(200, 50, 50)
    border.Thickness = 1.5
    border.Transparency = 0.3
    border.Parent = formContainer
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 22
    titleBar.Parent = formContainer
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = self.title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 23
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 22
    closeBtn.ZIndex = 23
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Close Button Hover
    closeBtn.MouseEnter:Connect(function()
        createTween(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        createTween(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end)
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -40, 1, -75)
    contentArea.Position = UDim2.new(0, 20, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ZIndex = 22
    contentArea.Parent = formContainer
    
    -- Input Label
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Name = "InputLabel"
    inputLabel.Size = UDim2.new(1, 0, 0, 20)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Font = Enum.Font.Gotham
    inputLabel.Text = "Token"
    inputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    inputLabel.TextSize = 13
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.ZIndex = 23
    inputLabel.Parent = contentArea
    
    -- Input Frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, 0, 0, 42)
    inputFrame.Position = UDim2.new(0, 0, 0, 25)
    inputFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 23
    inputFrame.Parent = contentArea
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local inputBorder = Instance.new("UIStroke")
    inputBorder.Color = Color3.fromRGB(60, 60, 70)
    inputBorder.Thickness = 1
    inputBorder.Parent = inputFrame
    
    -- Input TextBox
    self.inputBox = Instance.new("TextBox")
    self.inputBox.Name = "InputBox"
    self.inputBox.Size = UDim2.new(1, -20, 1, -10)
    self.inputBox.Position = UDim2.new(0, 10, 0, 5)
    self.inputBox.BackgroundTransparency = 1
    self.inputBox.Font = Enum.Font.Gotham
    self.inputBox.PlaceholderText = self.placeholder
    self.inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    self.inputBox.Text = ""
    self.inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.inputBox.TextSize = 14
    self.inputBox.TextXAlignment = Enum.TextXAlignment.Left
    self.inputBox.TextYAlignment = Enum.TextYAlignment.Center
    self.inputBox.ClearTextOnFocus = false
    self.inputBox.ZIndex = 24
    self.inputBox.Parent = inputFrame
    
    -- Input Focus Effect
    self.inputBox.Focused:Connect(function()
        createTween(inputBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(220, 50, 50), Thickness = 2}):Play()
    end)
    self.inputBox.FocusLost:Connect(function()
        createTween(inputBorder, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 70), Thickness = 1}):Play()
    end)
    
    -- Submit Button
    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "SubmitButton"
    submitBtn.Size = UDim2.new(1, 0, 0, 40)
    submitBtn.Position = UDim2.new(0, 0, 0, 75)
    submitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    submitBtn.BorderSizePixel = 0
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Text = "Submit"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 15
    submitBtn.ZIndex = 23
    submitBtn.Parent = contentArea
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 8)
    submitCorner.Parent = submitBtn
    
    -- Submit Button Hover
    submitBtn.MouseEnter:Connect(function()
        createTween(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 60, 60)}):Play()
    end)
    submitBtn.MouseLeave:Connect(function()
        createTween(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Signup Text Container
    local signupContainer = Instance.new("Frame")
    signupContainer.Name = "SignupContainer"
    signupContainer.Size = UDim2.new(1, 0, 0, 20)
    signupContainer.Position = UDim2.new(0, 0, 0, 125)
    signupContainer.BackgroundTransparency = 1
    signupContainer.BorderSizePixel = 0
    signupContainer.ZIndex = 23
    signupContainer.Parent = contentArea
    
    -- "Don't have a token?" Text
    local signupText = Instance.new("TextLabel")
    signupText.Name = "SignupText"
    signupText.Size = UDim2.new(0, 0, 1, 0)
    signupText.Position = UDim2.new(0, 0, 0, 0)
    signupText.BackgroundTransparency = 1
    signupText.Font = Enum.Font.Gotham
    signupText.Text = "Don't have a token? "
    signupText.TextColor3 = Color3.fromRGB(150, 150, 150)
    signupText.TextSize = 12
    signupText.TextXAlignment = Enum.TextXAlignment.Left
    signupText.ZIndex = 24
    signupText.Parent = signupContainer
    
    -- Auto size text
    signupText.Size = UDim2.new(0, signupText.TextBounds.X, 1, 0)
    
    -- "Get one" Clickable Text
    local getOneBtn = Instance.new("TextButton")
    getOneBtn.Name = "GetOneButton"
    getOneBtn.Size = UDim2.new(0, 0, 1, 0)
    getOneBtn.Position = UDim2.new(0, signupText.TextBounds.X, 0, 0)
    getOneBtn.BackgroundTransparency = 1
    getOneBtn.BorderSizePixel = 0
    getOneBtn.Font = Enum.Font.GothamBold
    getOneBtn.Text = "Get one"
    getOneBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    getOneBtn.TextSize = 12
    getOneBtn.TextXAlignment = Enum.TextXAlignment.Left
    getOneBtn.ZIndex = 24
    getOneBtn.Parent = signupContainer
    
    -- Auto size button
    getOneBtn.Size = UDim2.new(0, getOneBtn.TextBounds.X, 1, 0)
    
    -- Get one button hover
    getOneBtn.MouseEnter:Connect(function()
        createTween(getOneBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(240, 60, 60)}):Play()
    end)
    getOneBtn.MouseLeave:Connect(function()
        createTween(getOneBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Copy to clipboard function
    local function copyToClipboard()
        local setclipboard = setclipboard or (syn and syn.write_clipboard)
        
        if setclipboard then
            setclipboard(self.getTokenLink)
        end
        
        -- Visual feedback
        local originalText = getOneBtn.Text
        getOneBtn.Text = "Copied!"
        getOneBtn.TextColor3 = Color3.fromRGB(100, 200, 100)
        
        wait(1)
        
        getOneBtn.Text = originalText
        createTween(getOneBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end
    
    -- Get one button click
    getOneBtn.MouseButton1Click:Connect(copyToClipboard)
    
    -- Submit function
    local function submit()
        local token = self.inputBox.Text
        if token and #token:gsub("%s+", "") > 0 then
            self.onSubmit(token:gsub("%s+", ""))
        end
    end
    
    -- Button Click Events
    submitBtn.MouseButton1Click:Connect(submit)
    
    -- Enter key to submit
    self.inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then submit() end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.onClose()
        self:destroy()
    end)
    
    -- ESC key to close
    self.closeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
            self.onClose()
            self:destroy()
        end
    end)
    
    -- Store references
    self.overlay = overlay
    self.formContainer = formContainer
    self.inputFrame = inputFrame
    self.inputBorder = inputBorder
    
    -- Initial state (hidden)
    overlay.BackgroundTransparency = 1
    formContainer.Size = UDim2.new(0, 0, 0, 0)
    formContainer.BackgroundTransparency = 1
end

function UI.Form:show()
    -- Fade in overlay
    createTween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.5}):Play()
    
    -- Scale and fade in form
    self.formContainer.Size = UDim2.new(0, 0, 0, 0)
    self.formContainer.BackgroundTransparency = 1
    
    local scaleTween = createTween(self.formContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 215),
        BackgroundTransparency = 0
    })
    scaleTween:Play()
end

function UI.Form:destroy()
    -- Disconnect events
    if self.closeConnection then self.closeConnection:Disconnect() end
    
    -- Fade out
    createTween(self.overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    createTween(self.formContainer, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    wait(0.2)
    if self.screenGui then self.screenGui:Destroy() end
    if self.blur then self.blur.Size = 0 end
end

-- Notification Module
UI.Notification = {}
UI.Notification.__index = UI.Notification

-- Notification types with colors and durations
local NotificationTypes = {
    INFO = {
        color = Color3.fromRGB(96, 205, 255),
        bgColor = Color3.fromRGB(20, 30, 40),
        icon = "ℹ",
        duration = 4
    },
    SUCCESS = {
        color = Color3.fromRGB(100, 200, 100),
        bgColor = Color3.fromRGB(20, 35, 25),
        icon = "✓",
        duration = 3
    },
    WARNING = {
        color = Color3.fromRGB(255, 200, 80),
        bgColor = Color3.fromRGB(40, 35, 20),
        icon = "⚠",
        duration = 5
    },
    ERROR = {
        color = Color3.fromRGB(220, 50, 50),
        bgColor = Color3.fromRGB(40, 20, 20),
        icon = "✕",
        duration = 6
    }
}

-- Notification stack manager
local notificationStack = {
    screenGui = nil,
    notifications = {},
    spacing = 10
}

local function initNotificationStack()
    if not notificationStack.screenGui then
        notificationStack.screenGui = Instance.new("ScreenGui")
        notificationStack.screenGui.Name = "iSylHubNotifications"
        notificationStack.screenGui.ResetOnSpawn = false
        notificationStack.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ProtectGui(notificationStack.screenGui)
        notificationStack.screenGui.Parent = PlayerGui
    end
    return notificationStack.screenGui
end

local function updateNotificationPositions()
    local startY = 20
    local currentY = startY
    
    for i, notification in ipairs(notificationStack.notifications) do
        if notification.frame and notification.frame.Parent then
            local targetY = currentY
            createTween(notification.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, -notification.width - 20, 0, targetY)
            }):Play()
            currentY = currentY + notification.height + notificationStack.spacing
        end
    end
end

function UI.Notification.show(notificationType, message, config)
    config = config or {}
    notificationType = string.upper(notificationType)
    
    if not NotificationTypes[notificationType] then
        notificationType = "INFO"
    end
    
    local notifData = NotificationTypes[notificationType]
    local screenGui = initNotificationStack()
    
    local self = setmetatable({}, UI.Notification)
    self.type = notificationType
    self.message = message or "Notification"
    self.duration = config.duration or notifData.duration
    self.width = config.width or 350
    self.height = 70
    
    -- Main notification frame
    local frame = Instance.new("Frame")
    frame.Name = "Notification_" .. notificationType
    frame.Size = UDim2.new(0, self.width, 0, self.height)
    frame.Position = UDim2.new(1, self.width + 20, 0, 0)
    frame.BackgroundColor3 = notifData.bgColor
    frame.BorderSizePixel = 0
    frame.ZIndex = 30
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Left accent border
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = notifData.color
    accent.BorderSizePixel = 0
    accent.ZIndex = 31
    accent.Parent = frame
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 20, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundColor3 = notifData.color
    icon.BackgroundTransparency = 0.8
    icon.BorderSizePixel = 0
    icon.Font = Enum.Font.GothamBold
    icon.Text = notifData.icon
    icon.TextColor3 = notifData.color
    icon.TextSize = 20
    icon.ZIndex = 31
    icon.Parent = frame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = icon
    
    -- Type label
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Name = "Type"
    typeLabel.Size = UDim2.new(0, 0, 0, 18)
    typeLabel.Position = UDim2.new(0, 70, 0, 12)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.Text = notificationType
    typeLabel.TextColor3 = notifData.color
    typeLabel.TextSize = 12
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.ZIndex = 31
    typeLabel.Parent = frame
    
    typeLabel.Size = UDim2.new(0, typeLabel.TextBounds.X, 0, 18)
    
    -- Message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -80, 0, 0)
    messageLabel.Position = UDim2.new(0, 70, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = self.message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 31
    messageLabel.Parent = frame
    
    -- Auto adjust height based on message
    messageLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        local textHeight = math.min(messageLabel.TextBounds.Y, 40)
        self.height = math.max(70, 50 + textHeight)
        frame.Size = UDim2.new(0, self.width, 0, self.height)
    end)
    
    local textHeight = math.min(messageLabel.TextBounds.Y, 40)
    self.height = math.max(70, 50 + textHeight)
    frame.Size = UDim2.new(0, self.width, 0, self.height)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 16
    closeBtn.ZIndex = 31
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        createTween(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        createTween(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    -- Calculate position before adding to stack
    local startY = 20
    local targetY = startY
    for _, notif in ipairs(notificationStack.notifications) do
        if notif.frame and notif.frame.Parent then
            targetY = targetY + notif.height + notificationStack.spacing
        end
    end
    
    -- Add to stack
    local notificationData = {
        frame = frame,
        width = self.width,
        height = self.height
    }
    table.insert(notificationStack.notifications, notificationData)
    
    -- Slide in animation to calculated position (simple and smooth)
    local slideIn = createTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -self.width - 20, 0, targetY)
    })
    slideIn:Play()
    
    -- Auto dismiss function
    local function dismiss()
        local index = nil
        for i, notif in ipairs(notificationStack.notifications) do
            if notif.frame == frame then
                index = i
                break
            end
        end
        
        if index then
            table.remove(notificationStack.notifications, index)
        end
        
        -- Slide out animation
        local currentY = frame.Position.Y.Offset
        local slideOut = createTween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, self.width + 20, 0, currentY)
        })
        slideOut:Play()
        
        slideOut.Completed:Wait()
        if frame and frame.Parent then
            frame:Destroy()
        end
        updateNotificationPositions()
    end
    
    -- Close button click
    closeBtn.MouseButton1Click:Connect(dismiss)
    
    -- Auto dismiss after duration
    spawn(function()
        wait(self.duration)
        if frame and frame.Parent then
            dismiss()
        end
    end)
    
    self.frame = frame
    self.dismiss = dismiss
    return self
end

-- Demo
local function demo()
    UI.Splashscreen.new({
        duration = 3,
        fadeInTime = 0.8,
        fadeOutTime = 0.6,
        logoId = 8992230677,
        title = "iSylHub Premium"
    }):show()
    
    -- Show form after splashscreen
    wait(2)
    
    local form = UI.Form.new({
        title = "Enter Your Token",
        placeholder = "Paste your token here...",
        getTokenLink = "https://example.com/get-token",
        onSubmit = function(token)
            print("Token submitted:", token)
            form:destroy()
        end,
        onClose = function()
            print("Form closed")
        end
    })
    
    form:show()
    
    -- Demo notifications
    wait(1)
    UI.Notification.show("INFO", "This is an info notification", {duration = 4})
    
    wait(0.5)
    UI.Notification.show("SUCCESS", "Operation completed successfully!", {duration = 3})
    
    wait(0.5)
    UI.Notification.show("WARNING", "Please check your connection", {duration = 5})
    
    wait(0.5)
    UI.Notification.show("ERROR", "Failed to connect to server", {duration = 6})
    
    wait(1)
    UI.Notification.show("INFO", "Multiple notifications will stack automatically", {duration = 4})
    
    wait(0.5)
    UI.Notification.show("SUCCESS", "Stacking system works perfectly!", {duration = 3})
end

-- demo()

return UI
