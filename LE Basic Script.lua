-- LEModz GUI Script
--[[
    Instructions:
    This script creates a fully functional GUI with:
    - Button System (Image + Transparent Button)
    - Key System with online validation
    - Discord link copying
    - 24-hour countdown timer
    - Draggable frames (with screen bounds)
    - Notification system
    
    To use as a loadstring:
    loadstring(game:HttpGet("https://pastebin.com/raw/your_paste_id"))()
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

-- ================================
-- UTILITY FUNCTIONS
-- ================================
local function notify(title, text, duration)
    -- Frame5 Notifier System (Frame5)
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
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
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
    
    -- Message
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
    
    -- Progress bar (timeout)
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 3)
    progress.Position = UDim2.new(0, 0, 1, -3)
    progress.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    progress.BorderSizePixel = 0
    progress.Parent = frame
    
    -- Stack notifications
    local existing = notificationHolder:GetChildren()
    local yOffset = (#existing * 70) + 10
    frame.Position = UDim2.new(0.5, -150, 0, yOffset)
    
    frame.Parent = notificationHolder
    
    -- Animate in
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0.5, -150, 0, yOffset - 20)
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1, Position = UDim2.new(0.5, -150, 0, yOffset)})
    tweenIn:Play()
    
    -- Animate progress bar
    local tweenProgress = TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
    tweenProgress:Play()
    
    -- Auto remove after duration
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
            
            -- Bounds checking - prevent going off screen
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

-- Function to fetch key from raw URL
local function fetchValidKey()
    local success, data = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/LEDeveloper-web/LEScript-Key/refs/heads/main/KEY")
    end)
    if success then
        return data:gsub("%s+", "")
    end
    return nil
end

-- ================================
-- CREATE MAIN GUI
-- ================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LEModzMainGUI"
screenGui.Parent = Player.PlayerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Background Image (loaded from Dropbox)
local bgImageLabel = Instance.new("ImageLabel")
bgImageLabel.Name = "BackgroundImage"
bgImageLabel.Size = UDim2.new(1, 0, 1, 0)
bgImageLabel.BackgroundTransparency = 1
bgImageLabel.Image = "https://www.dropbox.com/scl/fi/c4wq3ddady4yamawm2apg/LEModz_Background.jpeg?rlkey=czewj8x20qdjmar7hcrw977x3&st=dont9vp4&dl=1"
bgImageLabel.ScaleType = Enum.ScaleType.Crop
bgImageLabel.Parent = screenGui

-- ================================
-- FRAME1: ButtonSystem
-- ================================
local frame1 = Instance.new("Frame")
frame1.Name = "ButtonSystem"
frame1.Size = UDim2.new(0, 350, 0, 500)
frame1.Position = UDim2.new(0.5, -175, 0.5, -250)
frame1.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame1.BackgroundTransparency = 0.15
frame1.BorderSizePixel = 0
frame1.Visible = true
frame1.Parent = screenGui

local frame1Corner = Instance.new("UICorner")
frame1Corner.CornerRadius = UDim.new(0, 12)
frame1Corner.Parent = frame1

-- Shape Frame1 (Square)
local shapeFrame1 = Instance.new("Frame")
shapeFrame1.Size = UDim2.new(0, 300, 0, 300)
shapeFrame1.Position = UDim2.new(0.5, -150, 0.5, -150)
shapeFrame1.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
shapeFrame1.BackgroundTransparency = 0.3
shapeFrame1.BorderSizePixel = 2
shapeFrame1.BorderColor3 = Color3.fromRGB(255, 100, 100)
shapeFrame1.Parent = frame1

local shapeCorner = Instance.new("UICorner")
shapeCorner.CornerRadius = UDim.new(0, 8)
shapeCorner.Parent = shapeFrame1

-- Image inside Frame1
local buttonImage = Instance.new("ImageLabel")
buttonImage.Size = UDim2.new(0, 200, 0, 200)
buttonImage.Position = UDim2.new(0.5, -100, 0.5, -100)
buttonImage.BackgroundTransparency = 1
buttonImage.Image = "https://www.dropbox.com/scl/fi/777yhr2rb2kz0q2ms9td3/LEModz_Img_Button.jpg?rlkey=2ru00hr721mxepl347rbfmwok&st=zddam1ge&dl=1"
buttonImage.Parent = shapeFrame1

-- Shape Button (Rectangle) - Transparent button with text
local shapeButton = Instance.new("TextButton")
shapeButton.Size = UDim2.new(0, 200, 0, 50)
shapeButton.Position = UDim2.new(0.5, -100, 1, -60)
shapeButton.BackgroundTransparency = 1
shapeButton.Text = "OPEN"
shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeButton.TextSize = 20
shapeButton.Font = Enum.Font.GothamBold
shapeButton.BorderSizePixel = 0
shapeButton.Parent = shapeFrame1

-- ================================
-- FRAME2: KeySystem
-- ================================
local frame2 = Instance.new("Frame")
frame2.Name = "KeySystem"
frame2.Size = UDim2.new(0, 350, 0, 250)
frame2.Position = UDim2.new(0.5, -175, 0.5, -125)
frame2.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame2.BackgroundTransparency = 0.15
frame2.BorderSizePixel = 0
frame2.Visible = false
frame2.Parent = screenGui

local frame2Corner = Instance.new("UICorner")
frame2Corner.CornerRadius = UDim.new(0, 12)
frame2Corner.Parent = frame2

-- Title
local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, 0, 0, 40)
title2.Position = UDim2.new(0, 0, 0, 0)
title2.BackgroundTransparency = 1
title2.Text = "LEModz | Key"
title2.TextColor3 = Color3.fromRGB(255, 200, 100)
title2.TextSize = 18
title2.Font = Enum.Font.GothamBold
title2.Parent = frame2

-- Key Input Box
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 250, 0, 40)
keyInput.Position = UDim2.new(0.5, -125, 0.5, -60)
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

-- Get Key Button
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0, 100, 0, 35)
getKeyBtn.Position = UDim2.new(0.2, -50, 0.7, 0)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
getKeyBtn.Text = "Get Key"
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Font = Enum.Font.Gotham
getKeyBtn.TextSize = 14
getKeyBtn.Parent = frame2

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 6)
getKeyCorner.Parent = getKeyBtn

-- Confirm Key Button
local confirmKeyBtn = Instance.new("TextButton")
confirmKeyBtn.Size = UDim2.new(0, 100, 0, 35)
confirmKeyBtn.Position = UDim2.new(0.8, -50, 0.7, 0)
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
frame3.Size = UDim2.new(0, 350, 0, 200)
frame3.Position = UDim2.new(0.5, -175, 0.5, -100)
frame3.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame3.BackgroundTransparency = 0.15
frame3.BorderSizePixel = 0
frame3.Visible = false
frame3.Parent = screenGui

local frame3Corner = Instance.new("UICorner")
frame3Corner.CornerRadius = UDim.new(0, 12)
frame3Corner.Parent = frame3

local title3 = Instance.new("TextLabel")
title3.Size = UDim2.new(1, 0, 0, 40)
title3.Position = UDim2.new(0, 0, 0, 0)
title3.BackgroundTransparency = 1
title3.Text = "LEModz | Get Key"
title3.TextColor3 = Color3.fromRGB(255, 200, 100)
title3.TextSize = 18
title3.Font = Enum.Font.GothamBold
title3.Parent = frame3

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -40, 0, 40)
infoText.Position = UDim2.new(0, 20, 0.4, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "Free Key in Discord Link"
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.TextSize = 14
infoText.Font = Enum.Font.Gotham
infoText.Parent = frame3

-- Back to Enter Key Button
local backToKeyBtn = Instance.new("TextButton")
backToKeyBtn.Size = UDim2.new(0, 130, 0, 35)
backToKeyBtn.Position = UDim2.new(0.25, -65, 0.7, 0)
backToKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
backToKeyBtn.Text = "Back to Enter Key"
backToKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backToKeyBtn.Font = Enum.Font.Gotham
backToKeyBtn.TextSize = 12
backToKeyBtn.Parent = frame3

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backToKeyBtn

-- Discord Button
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 130, 0, 35)
discordBtn.Position = UDim2.new(0.75, -65, 0.7, 0)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Discord"
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

local frame4Corner = Instance.new("UICorner")
frame4Corner.CornerRadius = UDim.new(0, 12)
frame4Corner.Parent = frame4

-- Title Bar with Menu Button and Close Button
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = frame4

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

-- Menu Button (opens/closes menu sidebar)
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

-- Title Label
local title4 = Instance.new("TextLabel")
title4.Size = UDim2.new(0, 200, 1, 0)
title4.Position = UDim2.new(0.5, -100, 0, 0)
title4.BackgroundTransparency = 1
title4.Text = "LEModz System"
title4.TextColor3 = Color3.fromRGB(255, 200, 100)
title4.TextSize = 18
title4.Font = Enum.Font.GothamBold
title4.Parent = titleBar

-- Close Button (Close3 logic)
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

-- Menu Sidebar (hidden by default)
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

-- Menu items (placeholder for future features)
local menuItem1 = Instance.new("TextLabel")
menuItem1.Size = UDim2.new(1, 0, 0, 40)
menuItem1.Position = UDim2.new(0, 0, 0, 10)
menuItem1.BackgroundTransparency = 1
menuItem1.Text = "Options"
menuItem1.TextColor3 = Color3.fromRGB(220, 220, 220)
menuItem1.Font = Enum.Font.Gotham
menuItem1.TextSize = 16
menuItem1.Parent = menuSidebar

-- Countdown Box (CB1)
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
local currentState = "L1_Close" -- L1_Close, L1_Open, L2_Close3, L2_Open3
local countdownEndTime = nil
local countdownActive = false
local countdownConnection = nil
local keyValidated = false

-- Timer update function (L3)
local function updateTimerDisplay()
    if not countdownActive or not countdownEndTime then
        timerLabel.Text = "00H 00M 00S"
        return
    end
    
    local remaining = countdownEndTime - os.time()
    if remaining <= 0 then
        -- Timer ended, go back to L1 logic
        countdownActive = false
        if countdownConnection then
            countdownConnection:Disconnect()
            countdownConnection = nil
        end
        timerLabel.Text = "00H 00M 00S"
        -- Reset to L1 Close state
        currentState = "L1_Close"
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
        notify("Timer Ended", "Your key has expired. Please re-enter a new key.", 5)
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
    
    -- Real-time timer update (L3)
    countdownConnection = game:GetService("RunService").Heartbeat:Connect(function()
        updateTimerDisplay()
    end)
    updateTimerDisplay()
end

-- ================================
-- BUTTON FUNCTIONALITY
-- ================================

-- Frame1: OPEN button (goes to L1_Open)
shapeButton.MouseButton1Click:Connect(function()
    if currentState == "L1_Close" then
        currentState = "L1_Open"
        frame1.Visible = false
        frame2.Visible = true
        frame3.Visible = false
        frame4.Visible = false
    end
end)

-- Frame2: Get Key button (goes to Frame3)
getKeyBtn.MouseButton1Click:Connect(function()
    frame2.Visible = false
    frame3.Visible = true
    frame1.Visible = false
    frame4.Visible = false
end)

-- Frame2: Confirm Key button
confirmKeyBtn.MouseButton1Click:Connect(function()
    local enteredKey = keyInput.Text:gsub("%s+", "")
    local validKey = fetchValidKey()
    
    if validKey and enteredKey == validKey then
        keyValidated = true
        -- Start 24-hour countdown (L3)
        startCountdown(24 * 60 * 60)
        -- Notify Frame5-C
        notify("Key Confirmed", "Key has been Confirmed, Key Countdown in 24H", 5)
        -- Go to L2 Close3 (Frame1 visible)
        currentState = "L2_Close3"
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
        frame4.Visible = false
    else
        notify("Invalid Key", "The key you entered is invalid. Please get a valid key from Discord.", 4)
    end
end)

-- Frame3: Back button
backToKeyBtn.MouseButton1Click:Connect(function()
    frame3.Visible = false
    frame2.Visible = true
end)

-- Frame3: Discord button (copies link)
discordBtn.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/NBdp4zuJtt"
    if Clipboard then
        Clipboard(discordLink)
        notify("Discord Link Copied", "Discord Link Copied, Join Discord Server Now, the Key is Waiting", 5) -- Frame5-B
    else
        notify("Copy Failed", "Your executor does not support clipboard copying. Link: " .. discordLink, 8)
    end
end)

-- Frame4: Close button (Close3 logic - goes back to Frame1)
closeBtn4.MouseButton1Click:Connect(function()
    if currentState == "L2_Open3" then
        currentState = "L2_Close3"
        frame4.Visible = false
        frame1.Visible = true
        frame2.Visible = false
        frame3.Visible = false
    end
end)

-- Frame4: Menu button (opens/closes sidebar)
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

-- Frame1 button from L2 (when key is validated, button on Frame1 goes to Frame4)
-- Override shapeButton behavior when in L2 state
local originalClick = shapeButton.MouseButton1Click
shapeButton.MouseButton1Click:Connect(function()
    if currentState == "L2_Close3" and keyValidated then
        currentState = "L2_Open3"
        frame1.Visible = false
        frame4.Visible = true
        frame2.Visible = false
        frame3.Visible = false
    elseif currentState == "L1_Close" then
        currentState = "L1_Open"
        frame1.Visible = false
        frame2.Visible = true
        frame3.Visible = false
        frame4.Visible = false
    end
end)

-- ================================
-- NOTIFY SCRIPT LOADED (Frame5-A)
-- ================================
notify("LEModz Loaded", "Loadstring Script Loaded Successfully!", 4)

-- ================================
-- INITIAL STATE: L1_Close
-- ================================
currentState = "L1_Close"
frame1.Visible = true
frame2.Visible = false
frame3.Visible = false
frame4.Visible = false

-- Clean up on player leaving (optional)
Player:OnTeleport(function()
    screenGui:Destroy()
end)

-- ================================
-- RETURN THE GUI FOR LOADSTRING
-- ================================
return screenGui
