-- LEModz GUI Script (Professional Edition)
--[[
    Features:
    - One‑time key system (daily keys from GitHub)
    - Persistent session (24h timer saved locally)
    - Fully draggable frames with screen bounds
    - Notification system with progress bar
    - Menu tabs: Key Duration & Execute
    - Discord invite copying
    - Automatic screen resizing

    State machine:
    L1_Close  → Frame1 visible (main button)
    L1_Open   → Frame2 visible (enter key)
    L2_Close3 → Frame1 visible, timer running in background
    L2_Open3  → Frame4 visible (system panel)

    Usage:
    loadstring(game:HttpGet("https://pastebin.com/raw/kvSfrZB5"))()
--]]

-- ================================
-- SERVICES & SETUP
-- ================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Clipboard support (works on most executors)
local Clipboard = setclipboard or (syn and syn.clipboard) or (function() end)

-- Persistent key storage
local usedKeysStore = {}
local USER_DATA_KEY = "LEModz_UsedKeys_" .. Player.UserId

local function loadUsedKeys()
    if not writefile then return {} end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(USER_DATA_KEY))
    end)
    return success and type(data) == "table" and data or {}
end

local function saveUsedKeys()
    if not writefile then return end
    pcall(function()
        writefile(USER_DATA_KEY, HttpService:JSONEncode(usedKeysStore))
    end)
end

usedKeysStore = loadUsedKeys()

-- ================================
-- NOTIFICATION SYSTEM
-- ================================
local function notify(title, text, duration)
    local notificationHolder = Player.PlayerGui:FindFirstChild("LEModzNotifications")
    if not notificationHolder then
        notificationHolder = Instance.new("ScreenGui")
        notificationHolder.Name = "LEModzNotifications"
        notificationHolder.Parent = Player.PlayerGui
        notificationHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(0.5, -150, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
    frame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Parent = frame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 30)
    msgLabel.Position = UDim2.new(0, 10, 0, 30)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = text
    msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    msgLabel.Parent = frame

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 3)
    progress.Position = UDim2.new(0, 0, 1, -3)
    progress.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    progress.BorderSizePixel = 0
    progress.Parent = frame

    local existing = notificationHolder:GetChildren()
    local yOffset = (#existing * 70) + 10
    frame.Position = UDim2.new(0.5, -150, 0, yOffset)
    frame.Parent = notificationHolder

    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0.5, -150, 0, yOffset - 20)
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0.5, -150, 0, yOffset)
    })
    tweenIn:Play()

    local tweenProgress = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    })
    tweenProgress:Play()

    task.delay(duration, function()
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -150, 0, yOffset - 20)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

-- ================================
-- DRAGGABLE FRAME (with bounds)
-- ================================
local function makeDraggable(frame, parentScreen)
    local dragging = false
    local dragStart, frameStart = nil, nil

    local function updateBounds()
        local maxX = math.max(0, parentScreen.AbsoluteSize.X - frame.AbsoluteSize.X)
        local maxY = math.max(0, parentScreen.AbsoluteSize.Y - frame.AbsoluteSize.Y)
        local newX = math.clamp(frame.Position.X.Offset, 0, maxX)
        local newY = math.clamp(frame.Position.Y.Offset, 0, maxY)
        if newX ~= frame.Position.X.Offset or newY ~= frame.Position.Y.Offset then
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newX = frameStart.X.Offset + delta.X
            local newY = frameStart.Y.Offset + delta.Y
            local maxX = math.max(0, parentScreen.AbsoluteSize.X - frame.AbsoluteSize.X)
            local maxY = math.max(0, parentScreen.AbsoluteSize.Y - frame.AbsoluteSize.Y)
            newX = math.clamp(newX, 0, maxX)
            newY = math.clamp(newY, 0, maxY)
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    parentScreen:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateBounds)
    updateBounds()
end

-- ================================
-- KEY VALIDATION (GitHub)
-- ================================
local function fetchAvailableKeys()
    local success, data = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LEDeveloper-web/LEScript-Key/refs/heads/main/keys.json")
    end)
    if success then
        local success2, keys = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success2 and type(keys) == "table" then
            return keys
        end
    end
    return {}
end

local function validateKey(key)
    local availableKeys = fetchAvailableKeys()
    local today = os.date("%Y-%m-%d")
    local userId = tostring(Player.UserId)

    -- Check if key exists today
    local keyFound = false
    for _, validKey in ipairs(availableKeys) do
        if validKey == key then
            keyFound = true
            break
        end
    end
    if not keyFound then
        return false, "Key not found in today's key list"
    end

    -- Check if user already used this key today
    local userData = usedKeysStore[userId]
    if userData and userData.key == key and userData.date == today then
        return false, "This key has already been used by you today"
    end

    return true, "Key is valid"
end

local function markKeyAsUsed(key)
    local today = os.date("%Y-%m-%d")
    usedKeysStore[tostring(Player.UserId)] = {
        key = key,
        date = today,
        usedAt = os.time()
    }
    saveUsedKeys()
end

-- ================================
-- CREATE MAIN GUI
-- ================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LEModzMainGUI"
screenGui.Parent = Player.PlayerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local BACKGROUND_DECAL_ID = "123674130876025"

local function createBackground(frame, decalId)
    local bg = Instance.new("ImageLabel")
    bg.Name = "BackgroundImage"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = "rbxassetid://" .. decalId
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ImageTransparency = 0.85
    bg.Parent = frame
    return bg
end

-- Get current screen size (responsive)
local function getScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

-- Helper to resize all frames when screen changes
local function resizeFrames()
    local newSize = getScreenSize()
    local frame1Size = math.min(newSize.X, newSize.Y) / 8
    frame1.Size = UDim2.new(0, frame1Size, 0, frame1Size)
    frame1.Position = UDim2.new(0.5, -frame1Size/2, 0.5, -frame1Size/2)

    local quarterSize = math.min(newSize.X, newSize.Y) / 4
    frame2.Size = UDim2.new(0, quarterSize, 0, quarterSize)
    frame2.Position = UDim2.new(0.5, -quarterSize/2, 0.5, -quarterSize/2)
    frame3.Size = UDim2.new(0, quarterSize, 0, quarterSize)
    frame3.Position = UDim2.new(0.5, -quarterSize/2, 0.5, -quarterSize/2)

    local frame4Width = newSize.X * 0.7
    local frame4Height = newSize.Y * 0.9
    frame4.Size = UDim2.new(0, frame4Width, 0, frame4Height)
    frame4.Position = UDim2.new(0.5, -frame4Width/2, 0.5, -frame4Height/2)
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeFrames)

-- ================================
-- FRAME1: ButtonSystem (1/8 cube)
-- ================================
local frame1 = Instance.new("Frame")
frame1.Name = "ButtonSystem"
frame1.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame1.BackgroundTransparency = 0.15
frame1.BorderSizePixel = 0
frame1.Parent = screenGui

local frame1Bg = createBackground(frame1, BACKGROUND_DECAL_ID)

local frame1Corner = Instance.new("UICorner")
frame1Corner.CornerRadius = UDim.new(0, 12)
frame1Corner.Parent = frame1

-- Inner shape
local innerPadding = 0.05
local shapeFrame1 = Instance.new("Frame")
shapeFrame1.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
shapeFrame1.BackgroundTransparency = 0.5
shapeFrame1.BorderSizePixel = 2
shapeFrame1.BorderColor3 = Color3.fromRGB(255, 100, 100)
shapeFrame1.Parent = frame1

local shapeCorner = Instance.new("UICorner")
shapeCorner.CornerRadius = UDim.new(0, 8)
shapeCorner.Parent = shapeFrame1

local buttonImage = Instance.new("ImageLabel")
buttonImage.BackgroundTransparency = 1
buttonImage.Image = "rbxassetid://123674130876025"
buttonImage.ScaleType = Enum.ScaleType.Fit
buttonImage.Parent = shapeFrame1

local shapeButton = Instance.new("TextButton")
shapeButton.BackgroundTransparency = 0
shapeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
shapeButton.Text = "OPEN"
shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeButton.Font = Enum.Font.GothamBold
shapeButton.BorderSizePixel = 0
shapeButton.Parent = shapeFrame1

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = shapeButton

-- ================================
-- FRAME2: KeySystem (1/4 cube)
-- ================================
local frame2 = Instance.new("Frame")
frame2.Name = "KeySystem"
frame2.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame2.BackgroundTransparency = 0.15
frame2.BorderSizePixel = 0
frame2.Visible = false
frame2.Parent = screenGui

local frame2Bg = createBackground(frame2, BACKGROUND_DECAL_ID)
local frame2Corner = Instance.new("UICorner")
frame2Corner.CornerRadius = UDim.new(0, 12)
frame2Corner.Parent = frame2

-- Title bar
local titleBar2 = Instance.new("Frame")
titleBar2.Size = UDim2.new(1, 0, 0, 40)
titleBar2.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar2.BackgroundTransparency = 0.5
titleBar2.BorderSizePixel = 0
titleBar2.Parent = frame2
local titleBar2Corner = Instance.new("UICorner")
titleBar2Corner.CornerRadius = UDim.new(0, 12)
titleBar2Corner.Parent = titleBar2

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(0, 200, 1, 0)
title2.Position = UDim2.new(0.5, -100, 0, 0)
title2.BackgroundTransparency = 1
title2.Text = "LEModz | Key System"
title2.TextColor3 = Color3.fromRGB(255, 200, 100)
title2.TextSize = 16
title2.Font = Enum.Font.GothamBold
title2.Parent = titleBar2

local closeBtn2 = Instance.new("TextButton")
closeBtn2.Size = UDim2.new(0, 60, 0, 30)
closeBtn2.Position = UDim2.new(1, -70, 0.5, -15)
closeBtn2.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn2.Text = "Close"
closeBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn2.Font = Enum.Font.Gotham
closeBtn2.TextSize = 14
closeBtn2.Parent = titleBar2
local closeBtn2Corner = Instance.new("UICorner")
closeBtn2Corner.CornerRadius = UDim.new(0, 6)
closeBtn2Corner.Parent = closeBtn2

local keyStatusLabel = Instance.new("TextLabel")
keyStatusLabel.Size = UDim2.new(1, -20, 0, 25)
keyStatusLabel.Position = UDim2.new(0, 10, 0, 48)
keyStatusLabel.BackgroundTransparency = 1
keyStatusLabel.Text = "Keys reset daily! Get your key from Discord"
keyStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
keyStatusLabel.TextSize = 11
keyStatusLabel.Font = Enum.Font.Gotham
keyStatusLabel.TextWrapped = true
keyStatusLabel.Parent = frame2

local keyInput = Instance.new("TextBox")
keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
keyInput.Text = ""
keyInput.PlaceholderText = "Enter Key"
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 14
keyInput.Parent = frame2
local keyInputCorner = Instance.new("UICorner")
keyInputCorner.CornerRadius = UDim.new(0, 6)
keyInputCorner.Parent = keyInput

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
getKeyBtn.Text = "Get Key"
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Font = Enum.Font.Gotham
getKeyBtn.TextSize = 12
getKeyBtn.Parent = frame2
local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 6)
getKeyCorner.Parent = getKeyBtn

local confirmKeyBtn = Instance.new("TextButton")
confirmKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
confirmKeyBtn.Text = "Confirm"
confirmKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmKeyBtn.Font = Enum.Font.Gotham
confirmKeyBtn.TextSize = 12
confirmKeyBtn.Parent = frame2
local confirmKeyCorner = Instance.new("UICorner")
confirmKeyCorner.CornerRadius = UDim.new(0, 6)
confirmKeyCorner.Parent = confirmKeyBtn

-- ================================
-- FRAME3: GetKey Frame (1/4 cube)
-- ================================
local frame3 = Instance.new("Frame")
frame3.Name = "GetKeyFrame"
frame3.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame3.BackgroundTransparency = 0.15
frame3.BorderSizePixel = 0
frame3.Visible = false
frame3.Parent = screenGui

local frame3Bg = createBackground(frame3, BACKGROUND_DECAL_ID)
local frame3Corner = Instance.new("UICorner")
frame3Corner.CornerRadius = UDim.new(0, 12)
frame3Corner.Parent = frame3

local title3 = Instance.new("TextLabel")
title3.Size = UDim2.new(1, 0, 0, 35)
title3.Position = UDim2.new(0, 0, 0, 0)
title3.BackgroundTransparency = 1
title3.Text = "Get One-Time Key"
title3.TextColor3 = Color3.fromRGB(255, 200, 100)
title3.TextSize = 16
title3.Font = Enum.Font.GothamBold
title3.Parent = frame3

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -30, 0, 110)
infoText.Position = UDim2.new(0, 15, 0.22, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "• Keys reset DAILY\n• Each key works ONCE per user\n• Get your unique key from Discord\n• Key lasts 24 hours after activation"
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.TextSize = 11
infoText.Font = Enum.Font.Gotham
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = frame3

local backToKeyBtn = Instance.new("TextButton")
backToKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
backToKeyBtn.Text = "Back"
backToKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backToKeyBtn.Font = Enum.Font.Gotham
backToKeyBtn.TextSize = 12
backToKeyBtn.Parent = frame3
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backToKeyBtn

local discordBtn = Instance.new("TextButton")
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Discord"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.Font = Enum.Font.Gotham
discordBtn.TextSize = 12
discordBtn.Parent = frame3
local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = discordBtn

-- ================================
-- FRAME4: SystemPanel (70% x 90%)
-- ================================
local frame4 = Instance.new("Frame")
frame4.Name = "SystemPanel"
frame4.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame4.BackgroundTransparency = 0.15
frame4.BorderSizePixel = 0
frame4.Visible = false
frame4.Parent = screenGui

local frame4Bg = createBackground(frame4, BACKGROUND_DECAL_ID)
local frame4Corner = Instance.new("UICorner")
frame4Corner.CornerRadius = UDim.new(0, 12)
frame4Corner.Parent = frame4

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = frame4
local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 70, 0, 32)
menuBtn.Position = UDim2.new(0, 12, 0.5, -16)
menuBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
menuBtn.Text = "Menu"
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.Font = Enum.Font.Gotham
menuBtn.TextSize = 14
menuBtn.Parent = titleBar
local menuBtnCorner = Instance.new("UICorner")
menuBtnCorner.CornerRadius = UDim.new(0, 6)
menuBtnCorner.Parent = menuBtn

local title4 = Instance.new("TextLabel")
title4.Size = UDim2.new(0, 200, 1, 0)
title4.Position = UDim2.new(0.5, -100, 0, 0)
title4.BackgroundTransparency = 1
title4.Text = "LEModz System"
title4.TextColor3 = Color3.fromRGB(255, 200, 100)
title4.TextSize = 20
title4.Font = Enum.Font.GothamBold
title4.Parent = titleBar

local closeBtn4 = Instance.new("TextButton")
closeBtn4.Size = UDim2.new(0, 70, 0, 32)
closeBtn4.Position = UDim2.new(1, -82, 0.5, -16)
closeBtn4.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn4.Text = "Close"
closeBtn4.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn4.Font = Enum.Font.Gotham
closeBtn4.TextSize = 14
closeBtn4.Parent = titleBar
local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn4

-- Sidebar menu
local menuSidebar = Instance.new("Frame")
menuSidebar.Size = UDim2.new(0, 180, 1, -45)
menuSidebar.Position = UDim2.new(-181, 0, 0, 45)
menuSidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
menuSidebar.BackgroundTransparency = 0.2
menuSidebar.BorderSizePixel = 0
menuSidebar.Visible = false
menuSidebar.Parent = frame4
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = menuSidebar

local menuTab1 = Instance.new("TextButton")
menuTab1.Size = UDim2.new(1, -20, 0, 50)
menuTab1.Position = UDim2.new(0, 10, 0, 10)
menuTab1.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
menuTab1.BackgroundTransparency = 0.3
menuTab1.Text = "Key Duration"
menuTab1.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTab1.Font = Enum.Font.GothamBold
menuTab1.TextSize = 15
menuTab1.BorderSizePixel = 0
menuTab1.Parent = menuSidebar
local menuTab1Corner = Instance.new("UICorner")
menuTab1Corner.CornerRadius = UDim.new(0, 6)
menuTab1Corner.Parent = menuTab1

local menuTab2 = Instance.new("TextButton")
menuTab2.Size = UDim2.new(1, -20, 0, 50)
menuTab2.Position = UDim2.new(0, 10, 0, 70)
menuTab2.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
menuTab2.BackgroundTransparency = 0.3
menuTab2.Text = "Execute"
menuTab2.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTab2.Font = Enum.Font.GothamBold
menuTab2.TextSize = 15
menuTab2.BorderSizePixel = 0
menuTab2.Parent = menuSidebar
local menuTab2Corner = Instance.new("UICorner")
menuTab2Corner.CornerRadius = UDim.new(0, 6)
menuTab2Corner.Parent = menuTab2

-- Content panel
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -200, 1, -55)
contentPanel.Position = UDim2.new(0, 190, 0, 55)
contentPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
contentPanel.BackgroundTransparency = 0.3
contentPanel.BorderSizePixel = 0
contentPanel.Parent = frame4
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentPanel

-- Tab 1: Key Duration
local keyDurationPanel = Instance.new("Frame")
keyDurationPanel.Size = UDim2.new(1, 0, 1, 0)
keyDurationPanel.BackgroundTransparency = 1
keyDurationPanel.Visible = true
keyDurationPanel.Parent = contentPanel

local countdownBox = Instance.new("Frame")
countdownBox.Size = UDim2.new(0, 320, 0, 140)
countdownBox.Position = UDim2.new(0.5, -160, 0.4, 0)
countdownBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
countdownBox.BackgroundTransparency = 0.2
countdownBox.BorderSizePixel = 2
countdownBox.BorderColor3 = Color3.fromRGB(255, 100, 100)
countdownBox.Parent = keyDurationPanel
local countdownCorner2 = Instance.new("UICorner")
countdownCorner2.CornerRadius = UDim.new(0, 10)
countdownCorner2.Parent = countdownBox

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 70)
timerLabel.Position = UDim2.new(0, 0, 0, 20)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00H 00M 00S"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 34
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = countdownBox

local keyInfoLabel = Instance.new("TextLabel")
keyInfoLabel.Size = UDim2.new(1, 0, 0, 30)
keyInfoLabel.Position = UDim2.new(0, 0, 1, -35)
keyInfoLabel.BackgroundTransparency = 1
keyInfoLabel.Text = "Session expires after 24 hours"
keyInfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
keyInfoLabel.TextSize = 13
keyInfoLabel.Font = Enum.Font.Gotham
keyInfoLabel.Parent = countdownBox

-- Tab 2: Execute (Player Info)
local executePanel = Instance.new("Frame")
executePanel.Size = UDim2.new(1, 0, 1, 0)
executePanel.BackgroundTransparency = 1
executePanel.Visible = false
executePanel.Parent = contentPanel

local playerInfoCard = Instance.new("Frame")
playerInfoCard.Size = UDim2.new(0, 420, 0, 240)
playerInfoCard.Position = UDim2.new(0.5, -210, 0.45, -120)
playerInfoCard.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
playerInfoCard.BackgroundTransparency = 0.2
playerInfoCard.BorderSizePixel = 2
playerInfoCard.BorderColor3 = Color3.fromRGB(255, 100, 100)
playerInfoCard.Parent = executePanel
local playerCardCorner = Instance.new("UICorner")
playerCardCorner.CornerRadius = UDim.new(0, 10)
playerCardCorner.Parent = playerInfoCard

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, 0, 0, 35)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
playerTitle.BackgroundTransparency = 0.5
playerTitle.Text = "Player Profile"
playerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
playerTitle.TextSize = 16
playerTitle.Font = Enum.Font.GothamBold
playerTitle.Parent = playerInfoCard
local playerTitleCorner = Instance.new("UICorner")
playerTitleCorner.CornerRadius = UDim.new(0, 10)
playerTitleCorner.Parent = playerTitle

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(0, 120, 0, 35)
usernameLabel.Position = UDim2.new(0, 15, 0, 50)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = "Username:"
usernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
usernameLabel.TextSize = 14
usernameLabel.Font = Enum.Font.Gotham
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = playerInfoCard

local usernameValue = Instance.new("TextLabel")
usernameValue.Size = UDim2.new(0, 250, 0, 35)
usernameValue.Position = UDim2.new(0, 145, 0, 50)
usernameValue.BackgroundTransparency = 1
usernameValue.Text = Player.Name
usernameValue.TextColor3 = Color3.fromRGB(255, 255, 255)
usernameValue.TextSize = 14
usernameValue.Font = Enum.Font.GothamBold
usernameValue.TextXAlignment = Enum.TextXAlignment.Left
usernameValue.Parent = playerInfoCard

local userIdLabel = Instance.new("TextLabel")
userIdLabel.Size = UDim2.new(0, 120, 0, 35)
userIdLabel.Position = UDim2.new(0, 15, 0, 95)
userIdLabel.BackgroundTransparency = 1
userIdLabel.Text = "User ID:"
userIdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
userIdLabel.TextSize = 14
userIdLabel.Font = Enum.Font.Gotham
userIdLabel.TextXAlignment = Enum.TextXAlignment.Left
userIdLabel.Parent = playerInfoCard

local userIdValue = Instance.new("TextLabel")
userIdValue.Size = UDim2.new(0, 250, 0, 35)
userIdValue.Position = UDim2.new(0, 145, 0, 95)
userIdValue.BackgroundTransparency = 1
userIdValue.Text = tostring(Player.UserId)
userIdValue.TextColor3 = Color3.fromRGB(255, 255, 255)
userIdValue.TextSize = 14
userIdValue.Font = Enum.Font.GothamBold
userIdValue.TextXAlignment = Enum.TextXAlignment.Left
userIdValue.Parent = playerInfoCard

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0, 120, 0, 35)
timeLabel.Position = UDim2.new(0, 15, 0, 140)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Time:"
timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timeLabel.TextSize = 14
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = playerInfoCard

local timeValue = Instance.new("TextLabel")
timeValue.Size = UDim2.new(0, 250, 0, 35)
timeValue.Position = UDim2.new(0, 145, 0, 140)
timeValue.BackgroundTransparency = 1
timeValue.Text = os.date("%Y/%m/%d , %H:%M:%S")
timeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
timeValue.TextSize = 13
timeValue.Font = Enum.Font.GothamBold
timeValue.TextXAlignment = Enum.TextXAlignment.Left
timeValue.Parent = playerInfoCard

local abxLabel = Instance.new("TextLabel")
abxLabel.Size = UDim2.new(0, 100, 0, 35)
abxLabel.Position = UDim2.new(0, 15, 1, -50)
abxLabel.BackgroundTransparency = 1
abxLabel.Text = "ABX"
abxLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
abxLabel.TextSize = 14
abxLabel.Font = Enum.Font.GothamBold
abxLabel.TextXAlignment = Enum.TextXAlignment.Left
abxLabel.Parent = playerInfoCard

local codesLabel = Instance.new("TextLabel")
codesLabel.Size = UDim2.new(0, 100, 0, 35)
codesLabel.Position = UDim2.new(0, 145, 1, -50)
codesLabel.BackgroundTransparency = 1
codesLabel.Text = "Codes"
codesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
codesLabel.TextSize = 14
codesLabel.Font = Enum.Font.GothamBold
codesLabel.TextXAlignment = Enum.TextXAlignment.Left
codesLabel.Parent = playerInfoCard

-- ================================
-- APPLY INITIAL SIZES & DRAGGABLE
-- ================================
resizeFrames()
makeDraggable(frame1, screenGui)
makeDraggable(frame2, screenGui)
makeDraggable(frame3, screenGui)
makeDraggable(frame4, screenGui)

-- ================================
-- STATE MACHINE
-- ================================
local currentState = "L1_Close"
local keyValidated = false
local countdownEndTime = nil
local countdownActive = false
local countdownConnection = nil

local function updateTimerDisplay()
    if not countdownActive or not countdownEndTime then
        timerLabel.Text = "00H 00M 00S"
        return
    end
    local remaining = countdownEndTime - os.time()
    if remaining <= 0 then
        countdownActive = false
        if countdownConnection then
            countdownConnection:Disconnect()
            countdownConnection = nil
        end
        timerLabel.Text = "00H 00M 00S"
        notify("Key Expired", "Your 24-hour session has ended. Get a new key from Discord tomorrow!", 5)
        currentState = "L1_Close"
        keyValidated = false
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
    else
        local hours = math.floor(remaining / 3600)
        local minutes = math.floor((remaining % 3600) / 60)
        local seconds = remaining % 60
        timerLabel.Text = string.format("%02dH %02dM %02dS", hours, minutes, seconds)
    end
end

local function startCountdown(durationSeconds)
    countdownEndTime = os.time() + durationSeconds
    countdownActive = true
    if countdownConnection then
        countdownConnection:Disconnect()
    end
    countdownConnection = RunService.Heartbeat:Connect(updateTimerDisplay)
    updateTimerDisplay()
end

local function restoreSession()
    local today = os.date("%Y-%m-%d")
    local userData = usedKeysStore[tostring(Player.UserId)]
    if userData and userData.date == today and userData.usedAt then
        local elapsed = os.time() - userData.usedAt
        if elapsed < 24 * 60 * 60 then
            keyValidated = true
            currentState = "L2_Close3"
            frame1.Visible = true
            frame2.Visible = false
            frame3.Visible = false
            frame4.Visible = false
            startCountdown(24 * 60 * 60 - elapsed)
            notify("Session Restored", "Your active session has been restored!", 3)
            return true
        end
    end
    return false
end

-- ================================
-- BUTTON ACTIONS
-- ================================
shapeButton.MouseButton1Click:Connect(function()
    if currentState == "L1_Close" then
        currentState = "L1_Open"
        frame1.Visible = false
        frame2.Visible = true
        frame3.Visible = false
        frame4.Visible = false
    elseif currentState == "L2_Close3" and keyValidated then
        currentState = "L2_Open3"
        frame1.Visible = false
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = true
    end
end)

closeBtn2.MouseButton1Click:Connect(function()
    if currentState == "L1_Open" then
        currentState = "L1_Close"
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
        keyInput.Text = ""
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    if currentState == "L1_Open" then
        frame2.Visible = false
        frame3.Visible = true
    end
end)

confirmKeyBtn.MouseButton1Click:Connect(function()
    if currentState ~= "L1_Open" then return end
    local enteredKey = keyInput.Text:gsub("%s+", "")
    if enteredKey == "" then
        notify("Error", "Please enter a key", 3)
        return
    end
    local isValid, msg = validateKey(enteredKey)
    if isValid then
        markKeyAsUsed(enteredKey)
        keyValidated = true
        startCountdown(24 * 60 * 60)
        notify("Key Confirmed", "Key validated! You have 24 hours of access.", 5)
        currentState = "L2_Close3"
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
        keyInput.Text = ""
    else
        notify("Key Invalid", msg, 4)
    end
end)

backToKeyBtn.MouseButton1Click:Connect(function()
    if currentState == "L1_Open" then
        frame3.Visible = false
        frame2.Visible = true
    end
end)

discordBtn.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/NBdp4zuJtt"
    if Clipboard then
        Clipboard(discordLink)
        notify("Discord Invite Copied", "Join Discord to get your daily one-time key!", 5)
    else
        notify("Copy Failed", "Your executor doesn't support copy. Link: " .. discordLink, 8)
    end
end)

closeBtn4.MouseButton1Click:Connect(function()
    if currentState == "L2_Open3" then
        currentState = "L2_Close3"
        frame4.Visible = false
        frame1.Visible = true
    end
end)

-- ================================
-- TAB SWITCHING
-- ================================
local function setActiveTab(tabIndex)
    if tabIndex == 1 then
        menuTab1.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        menuTab2.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        keyDurationPanel.Visible = true
        executePanel.Visible = false
    else
        menuTab1.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        menuTab2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        keyDurationPanel.Visible = false
        executePanel.Visible = true
    end
end

menuTab1.MouseButton1Click:Connect(function() setActiveTab(1) end)
menuTab2.MouseButton1Click:Connect(function() setActiveTab(2) end)

-- Menu sidebar animation
local menuOpen = false
menuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuSidebar.Visible = menuOpen
    if menuOpen then
        menuSidebar:TweenPosition(UDim2.new(0, 0, 0, 45), "Out", "Quad", 0.3, true)
    else
        menuSidebar:TweenPosition(UDim2.new(-181, 0, 0, 45), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        menuSidebar.Visible = false
    end
end)

-- ================================
-- INITIALIZE
-- ================================
if not restoreSession() then
    currentState = "L1_Close"
    frame1.Visible = true
    frame2.Visible = false
    frame3.Visible = false
    frame4.Visible = false
    keyValidated = false
end

setActiveTab(1)
notify("LEModz Loaded", "One-time key system active! Get your key from Discord.", 4)

-- ================================
-- RETURN GUI
-- ================================
return screenGui
