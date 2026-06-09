-- LEModz GUI Script
--[[
    Instructions:
    This script creates a fully functional GUI with:
    - Button System (Image + Transparent Button)
    - Key System with online validation (one-time key per user per day)
    - Discord link copying
    - 24-hour countdown timer
    - Draggable frames (with screen bounds)
    - Notification system
    
    Key Management:
    - Keys are stored on GitHub as a list
    - Each key can only be used once per user
    - When a key is used, it gets marked as used for that user
    - Next day, the GitHub repo owner can change the key list
    - Users can request a new key from Discord daily
    
    To use as a loadstring:
    loadstring(game:HttpGet("https://pastebin.com/raw/kvSfrZB5"))()
--]]

-- ================================
-- SERVICES & SETUP
-- ================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Clipboard = setclipboard or (syn and syn.clipboard) or (function() end)
local TweenService = game:GetService("TweenService")

-- Check if running on mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Storage for used keys (persists across script reloads)
local usedKeysStore = {}
local USER_DATA_KEY = "LEModz_UsedKeys_" .. Player.UserId

-- Load previously used keys from data store
local function loadUsedKeys()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile and readfile(USER_DATA_KEY) or "{}")
    end)
    if success and type(data) == "table" then
        usedKeysStore = data
    else
        usedKeysStore = {}
    end
end

-- Save used keys to data store
local function saveUsedKeys()
    pcall(function()
        if writefile then
            writefile(USER_DATA_KEY, game:GetService("HttpService"):JSONEncode(usedKeysStore))
        end
    end)
end

loadUsedKeys()

-- ================================
-- UTILITY FUNCTIONS
-- ================================
local function notify(title, text, duration)
    -- Frame5 Notifier System
    local notificationHolder = Player.PlayerGui:FindFirstChild("LEModzNotifications") or Instance.new("ScreenGui")
    if not notificationHolder.Parent then
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
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1, Position = UDim2.new(0.5, -150, 0, yOffset)})
    tweenIn:Play()
    
    local tweenProgress = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
    tweenProgress:Play()
    
    task.delay(duration, function()
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0, yOffset - 20)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

-- Function to make frames draggable with bounds
local function makeDraggable(frame, parentScreen)
    local dragging = false
    local dragStartPos = nil
    local frameStartPos = nil
    local screenBounds = parentScreen.AbsoluteSize
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            local newX = frameStartPos.X.Offset + delta.X
            local newY = frameStartPos.Y.Offset + delta.Y
            
            local maxX = parentScreen.AbsoluteSize.X - frame.AbsoluteSize.X
            local maxY = parentScreen.AbsoluteSize.Y - frame.AbsoluteSize.Y
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
end

-- Function to fetch available keys from GitHub
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

-- Function to check if a key is valid and unused
local function validateKey(key)
    local availableKeys = fetchAvailableKeys()
    local today = os.date("%Y-%m-%d")
    local userIdentifier = Player.UserId
    
    -- Check if key exists in available keys
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
    
    -- Check if this user has already used this key today
    local userKeyData = usedKeysStore[tostring(userIdentifier)]
    if userKeyData and userKeyData.key == key and userKeyData.date == today then
        return false, "This key has already been used by you today"
    end
    
    return true, "Key is valid"
end

-- Function to mark a key as used
local function markKeyAsUsed(key)
    local today = os.date("%Y-%m-%d")
    local userIdentifier = Player.UserId
    
    usedKeysStore[tostring(userIdentifier)] = {
        key = key,
        date = today,
        usedAt = os.time()
    }
    saveUsedKeys()
end

-- Function to check if user already has an active session today
local function hasActiveSession()
    local today = os.date("%Y-%m-%d")
    local userIdentifier = Player.UserId
    local userData = usedKeysStore[tostring(userIdentifier)]
    
    if userData and userData.date == today then
        -- User has used a key today, check if their timer is still running
        if countdownActive and countdownEndTime and countdownEndTime > os.time() then
            return true, userData.key
        end
    end
    return false, nil
end

-- ================================
-- CREATE MAIN GUI
-- ================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LEModzMainGUI"
screenGui.Parent = Player.PlayerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Roblox Decal ID for all backgrounds
local BACKGROUND_DECAL_ID = "123674130876025"

-- Function to create a background image label for any frame
local function createBackground(frame, decalId)
    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "BackgroundImage"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = "rbxassetid://" .. decalId
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.Parent = frame
    return bgImage
end

-- ================================
-- FRAME1: ButtonSystem (1/8 Screen Size - Cube/Center)
-- Layout: Image on Top, Button Below
-- ================================
local frame1 = Instance.new("Frame")
frame1.Name = "ButtonSystem"

-- Get screen size
local screenSize = workspace.CurrentCamera.ViewportSize
local frameSize = math.min(screenSize.X, screenSize.Y) / 8  -- Cube (square)

frame1.Size = UDim2.new(0, frameSize, 0, frameSize)
frame1.Position = UDim2.new(0.5, -frameSize/2, 0.5, -frameSize/2)
frame1.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame1.BackgroundTransparency = 0.15
frame1.BorderSizePixel = 0
frame1.Visible = true
frame1.Parent = screenGui

-- Background for Frame1
local frame1Bg = createBackground(frame1, BACKGROUND_DECAL_ID)
frame1Bg.ImageTransparency = 0.85

local frame1Corner = Instance.new("UICorner")
frame1Corner.CornerRadius = UDim.new(0, 12)
frame1Corner.Parent = frame1

-- Shape Frame1 (Inner border - slightly smaller)
local innerPadding = frameSize * 0.05
local innerSize = frameSize - (innerPadding * 2)
local shapeFrame1 = Instance.new("Frame")
shapeFrame1.Size = UDim2.new(0, innerSize, 0, innerSize)
shapeFrame1.Position = UDim2.new(0.5, -innerSize/2, 0.5, -innerSize/2)
shapeFrame1.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
shapeFrame1.BackgroundTransparency = 0.5
shapeFrame1.BorderSizePixel = 2
shapeFrame1.BorderColor3 = Color3.fromRGB(255, 100, 100)
shapeFrame1.Parent = frame1

local shapeCorner = Instance.new("UICorner")
shapeCorner.CornerRadius = UDim.new(0, 8)
shapeCorner.Parent = shapeFrame1

-- Image on TOP (60% of frame height, centered horizontally)
local imageHeight = innerSize * 0.6
local imageWidth = imageHeight  -- Keep square aspect ratio
local buttonImage = Instance.new("ImageLabel")
buttonImage.Size = UDim2.new(0, imageWidth, 0, imageHeight)
buttonImage.Position = UDim2.new(0.5, -imageWidth/2, 0.15, 0)
buttonImage.BackgroundTransparency = 1
buttonImage.Image = "rbxassetid://123674130876025"
buttonImage.ScaleType = Enum.ScaleType.Fit
buttonImage.Parent = shapeFrame1

-- Shape Button BELOW the image (20% of frame height)
local buttonHeight = innerSize * 0.2
local buttonWidth = innerSize * 0.7
local shapeButton = Instance.new("TextButton")
shapeButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
shapeButton.Position = UDim2.new(0.5, -buttonWidth/2, 0.78, 0)
shapeButton.BackgroundTransparency = 0
shapeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
shapeButton.Text = "OPEN"
shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeButton.TextSize = math.floor(buttonHeight * 0.5)
shapeButton.Font = Enum.Font.GothamBold
shapeButton.BorderSizePixel = 0
shapeButton.Parent = shapeFrame1

-- Button corner rounding
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = shapeButton

-- ================================
-- FRAME2: KeySystem
-- ================================
local frame2 = Instance.new("Frame")
frame2.Name = "KeySystem"
frame2.Size = UDim2.new(0, 350, 0, 280)
frame2.Position = UDim2.new(0.5, -175, 0.5, -140)
frame2.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame2.BackgroundTransparency = 0.15
frame2.BorderSizePixel = 0
frame2.Visible = false
frame2.Parent = screenGui

local frame2Bg = createBackground(frame2, BACKGROUND_DECAL_ID)
frame2Bg.ImageTransparency = 0.85

local frame2Corner = Instance.new("UICorner")
frame2Corner.CornerRadius = UDim.new(0, 12)
frame2Corner.Parent = frame2

local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, 0, 0, 40)
title2.Position = UDim2.new(0, 0, 0, 0)
title2.BackgroundTransparency = 1
title2.Text = "LEModz | Key System"
title2.TextColor3 = Color3.fromRGB(255, 200, 100)
title2.TextSize = 18
title2.Font = Enum.Font.GothamBold
title2.Parent = frame2

-- Status label for today's key info
local keyStatusLabel = Instance.new("TextLabel")
keyStatusLabel.Size = UDim2.new(1, -20, 0, 30)
keyStatusLabel.Position = UDim2.new(0, 10, 0, 45)
keyStatusLabel.BackgroundTransparency = 1
keyStatusLabel.Text = "Keys reset daily! Get your key from Discord"
keyStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
keyStatusLabel.TextSize = 11
keyStatusLabel.Font = Enum.Font.Gotham
keyStatusLabel.TextWrapped = true
keyStatusLabel.Parent = frame2

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 250, 0, 40)
keyInput.Position = UDim2.new(0.5, -125, 0.5, -40)
keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
keyInput.Text = ""
keyInput.PlaceholderText = "Enter One-Time Key"
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 14
keyInput.Parent = frame2

local keyInputCorner = Instance.new("UICorner")
keyInputCorner.CornerRadius = UDim.new(0, 6)
keyInputCorner.Parent = keyInput

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0, 100, 0, 35)
getKeyBtn.Position = UDim2.new(0.2, -50, 0.8, 0)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
getKeyBtn.Text = "Get Key"
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Font = Enum.Font.Gotham
getKeyBtn.TextSize = 14
getKeyBtn.Parent = frame2

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 6)
getKeyCorner.Parent = getKeyBtn

local confirmKeyBtn = Instance.new("TextButton")
confirmKeyBtn.Size = UDim2.new(0, 100, 0, 35)
confirmKeyBtn.Position = UDim2.new(0.8, -50, 0.8, 0)
confirmKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
confirmKeyBtn.Text = "Confirm Key"
confirmKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmKeyBtn.Font = Enum.Font.Gotham
confirmKeyBtn.TextSize = 14
confirmKeyBtn.Parent = frame2

local confirmKeyCorner = Instance.new("UICorner")
confirmKeyCorner.CornerRadius = UDim.new(0, 6)
confirmKeyCorner.Parent = confirmKeyBtn

-- ================================
-- FRAME3: GetKey Frame
-- ================================
local frame3 = Instance.new("Frame")
frame3.Name = "GetKeyFrame"
frame3.Size = UDim2.new(0, 350, 0, 220)
frame3.Position = UDim2.new(0.5, -175, 0.5, -110)
frame3.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame3.BackgroundTransparency = 0.15
frame3.BorderSizePixel = 0
frame3.Visible = false
frame3.Parent = screenGui

local frame3Bg = createBackground(frame3, BACKGROUND_DECAL_ID)
frame3Bg.ImageTransparency = 0.85

local frame3Corner = Instance.new("UICorner")
frame3Corner.CornerRadius = UDim.new(0, 12)
frame3Corner.Parent = frame3

local title3 = Instance.new("TextLabel")
title3.Size = UDim2.new(1, 0, 0, 40)
title3.Position = UDim2.new(0, 0, 0, 0)
title3.BackgroundTransparency = 1
title3.Text = "LEModz | Get One-Time Key"
title3.TextColor3 = Color3.fromRGB(255, 200, 100)
title3.TextSize = 18
title3.Font = Enum.Font.GothamBold
title3.Parent = frame3

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -40, 0, 50)
infoText.Position = UDim2.new(0, 20, 0.35, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "• Keys reset DAILY\n• Each key works ONCE per user\n• Get your unique key from Discord\n• Key lasts 24 hours after activation"
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.TextSize = 12
infoText.Font = Enum.Font.Gotham
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = frame3

local backToKeyBtn = Instance.new("TextButton")
backToKeyBtn.Size = UDim2.new(0, 130, 0, 35)
backToKeyBtn.Position = UDim2.new(0.25, -65, 0.75, 0)
backToKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
backToKeyBtn.Text = "Back to Enter Key"
backToKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backToKeyBtn.Font = Enum.Font.Gotham
backToKeyBtn.TextSize = 12
backToKeyBtn.Parent = frame3

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backToKeyBtn

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 130, 0, 35)
discordBtn.Position = UDim2.new(0.75, -65, 0.75, 0)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Join Discord"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.Font = Enum.Font.Gotham
discordBtn.TextSize = 14
discordBtn.Parent = frame3

local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = discordBtn

-- ================================
-- FRAME4: SystemPanel
-- ================================
local frame4 = Instance.new("Frame")
frame4.Name = "SystemPanel"
frame4.Size = UDim2.new(0, 500, 0, 400)
frame4.Position = UDim2.new(0.5, -250, 0.5, -200)
frame4.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame4.BackgroundTransparency = 0.15
frame4.BorderSizePixel = 0
frame4.Visible = false
frame4.Parent = screenGui

local frame4Bg = createBackground(frame4, BACKGROUND_DECAL_ID)
frame4Bg.ImageTransparency = 0.85

local frame4Corner = Instance.new("UICorner")
frame4Corner.CornerRadius = UDim.new(0, 12)
frame4Corner.Parent = frame4

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = frame4

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 60, 0, 30)
menuBtn.Position = UDim2.new(0, 10, 0.5, -15)
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
title4.TextSize = 18
title4.Font = Enum.Font.GothamBold
title4.Parent = titleBar

local closeBtn4 = Instance.new("TextButton")
closeBtn4.Size = UDim2.new(0, 60, 0, 30)
closeBtn4.Position = UDim2.new(1, -70, 0.5, -15)
closeBtn4.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn4.Text = "Close"
closeBtn4.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn4.Font = Enum.Font.Gotham
closeBtn4.TextSize = 14
closeBtn4.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn4

local menuSidebar = Instance.new("Frame")
menuSidebar.Size = UDim2.new(0, 150, 1, -40)
menuSidebar.Position = UDim2.new(-151, 0, 0, 40)
menuSidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
menuSidebar.BackgroundTransparency = 0.2
menuSidebar.BorderSizePixel = 0
menuSidebar.Visible = false
menuSidebar.Parent = frame4

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = menuSidebar

local menuItem1 = Instance.new("TextLabel")
menuItem1.Size = UDim2.new(1, 0, 0, 40)
menuItem1.Position = UDim2.new(0, 0, 0, 10)
menuItem1.BackgroundTransparency = 1
menuItem1.Text = "Key Active ✅"
menuItem1.TextColor3 = Color3.fromRGB(220, 220, 220)
menuItem1.Font = Enum.Font.Gotham
menuItem1.TextSize = 16
menuItem1.Parent = menuSidebar

local countdownBox = Instance.new("Frame")
countdownBox.Size = UDim2.new(0, 300, 0, 100)
countdownBox.Position = UDim2.new(0.5, -150, 0.5, -50)
countdownBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
countdownBox.BackgroundTransparency = 0.3
countdownBox.BorderSizePixel = 0
countdownBox.Parent = frame4

local countdownCorner = Instance.new("UICorner")
countdownCorner.CornerRadius = UDim.new(0, 8)
countdownCorner.Parent = countdownBox

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "24H 0M 0S"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 28
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = countdownBox

-- Key expiry info label
local keyExpiryLabel = Instance.new("TextLabel")
keyExpiryLabel.Size = UDim2.new(1, 0, 0, 30)
keyExpiryLabel.Position = UDim2.new(0, 0, 1, -35)
keyExpiryLabel.BackgroundTransparency = 1
keyExpiryLabel.Text = "Session expires after 24 hours"
keyExpiryLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
keyExpiryLabel.TextSize = 12
keyExpiryLabel.Font = Enum.Font.Gotham
keyExpiryLabel.Parent = frame4

-- ================================
-- DRAG FUNCTIONALITY FOR ALL FRAMES
-- ================================
makeDraggable(frame1, screenGui)
makeDraggable(frame2, screenGui)
makeDraggable(frame3, screenGui)
makeDraggable(frame4, screenGui)

-- ================================
-- LOGIC STATE
-- ================================
local currentState = "L1_Close"
local countdownEndTime = nil
local countdownActive = false
local countdownConnection = nil
local keyValidated = false
local currentUsedKey = nil

-- Timer update function
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
        
        -- Key expired, reset the stored key usage for next day
        -- But keep record that it was used today to prevent reuse of same day key
        notify("Key Expired", "Your 24-hour session has ended. Get a new key from Discord tomorrow!", 5)
        
        -- Reset to L1 Close state
        currentState = "L1_Close"
        keyValidated = false
        currentUsedKey = nil
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
    
    countdownConnection = game:GetService("RunService").Heartbeat:Connect(function()
        updateTimerDisplay()
    end)
    updateTimerDisplay()
end

-- ================================
-- BUTTON FUNCTIONALITY
-- ================================

-- Frame1: OPEN button
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
        frame4.Visible = true
        frame2.Visible = false
        frame3.Visible = false
    end
end)

-- Frame2: Get Key button
getKeyBtn.MouseButton1Click:Connect(function()
    frame2.Visible = false
    frame3.Visible = true
    frame1.Visible = false
    frame4.Visible = false
end)

-- Frame2: Confirm Key button
confirmKeyBtn.MouseButton1Click:Connect(function()
    local enteredKey = keyInput.Text:gsub("%s+", "")
    
    if enteredKey == "" then
        notify("Error", "Please enter a key", 3)
        return
    end
    
    local isValid, message = validateKey(enteredKey)
    
    if isValid then
        -- Mark the key as used for this user
        markKeyAsUsed(enteredKey)
        keyValidated = true
        currentUsedKey = enteredKey
        
        -- Start 24-hour countdown
        startCountdown(24 * 60 * 60)
        
        notify("Key Confirmed", "Key validated! You have 24 hours of access.", 5)
        
        -- Go to L2 Close3 (Frame1 visible)
        currentState = "L2_Close3"
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
        
        -- Clear input
        keyInput.Text = ""
    else
        notify("Key Invalid", message, 4)
    end
end)

-- Frame3: Back button
backToKeyBtn.MouseButton1Click:Connect(function()
    frame3.Visible = false
    frame2.Visible = true
end)

-- Frame3: Discord button
discordBtn.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/NBdp4zuJtt"
    if Clipboard then
        Clipboard(discordLink)
        notify("Discord Invite Copied", "Join Discord to get your daily one-time key!", 5)
    else
        notify("Copy Failed", "Your executor doesn't support copy. Link: " .. discordLink, 8)
    end
end)

-- Frame4: Close button
closeBtn4.MouseButton1Click:Connect(function()
    if currentState == "L2_Open3" then
        currentState = "L2_Close3"
        frame4.Visible = false
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
    end
end)

-- Frame4: Menu button
local menuOpen = false
menuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuSidebar.Visible = menuOpen
    if menuOpen then
        menuSidebar:TweenPosition(UDim2.new(0, 0, 0, 40), "Out", "Quad", 0.3, true)
    else
        menuSidebar:TweenPosition(UDim2.new(-151, 0, 0, 40), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        menuSidebar.Visible = false
    end
end)

-- ================================
-- CHECK FOR EXISTING ACTIVE SESSION ON LOAD
-- ================================
local hasSession, usedKey = hasActiveSession()
if hasSession and usedKey then
    keyValidated = true
    currentUsedKey = usedKey
    currentState = "L2_Close3"
    frame1.Visible = true
    frame2.Visible = false
    frame3.Visible = false
    frame4.Visible = false
    
    -- Calculate remaining time from stored data
    local userIdentifier = Player.UserId
    local userData = usedKeysStore[tostring(userIdentifier)]
    if userData and userData.usedAt then
        local elapsed = os.time() - userData.usedAt
        local remaining = (24 * 60 * 60) - elapsed
        if remaining > 0 then
            startCountdown(remaining)
            notify("Session Restored", "Your active session has been restored!", 3)
        end
    end
end

-- ================================
-- NOTIFY SCRIPT LOADED
-- ================================
notify("LEModz Loaded", "One-time key system active! Get your key from Discord.", 4)

-- ================================
-- INITIAL STATE
-- ================================
if not keyValidated then
    currentState = "L1_Close"
    frame1.Visible = true
    frame2.Visible = false
    frame3.Visible = false
    frame4.Visible = false
end

-- ================================
-- CLEANUP
-- ================================
Player:OnTeleport(function()
    screenGui:Destroy()
end)

-- ================================
-- RETURN THE GUI FOR LOADSTRING
-- ================================
return screenGui
