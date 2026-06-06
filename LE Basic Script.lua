-- LEModz Key System
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/LEModz/KeySystem/main/Loader.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Asset URLs
local IMG_BUTTON_URL = "https://www.dropbox.com/scl/fi/777yhr2rb2kz0q2ms9td3/LEModz_Img_Button.jpg?rlkey=2ru00hr721mxepl347rbfmwok&st=zddam1ge&dl=1"
local BG_URL = "https://www.dropbox.com/scl/fi/c4wq3ddady4yamawm2apg/LEModz_Background.jpeg?rlkey=czewj8x20qdjmar7hcrw977x3&st=dont9vp4&dl=1"
local KEY_VALIDATION_URL = "https://raw.githubusercontent.com/LEDeveloper-web/LEScript-Key/refs/heads/main/KEY"
local DISCORD_INVITE = "https://discord.gg/NBdp4zuJtt"

-- Get screen size boundaries
local screenSize = UserInputService:GetMouse().ViewSizeX
local screenHeight = UserInputService:GetMouse().ViewSizeY

-- Key Storage
local savedKey = nil
local keyExpiry = nil
local keyConfirmed = false
local countdownStartTime = nil
local countdownRemaining = 0
local validKeys = {}

-- Fetch valid keys from GitHub
local function fetchValidKeys()
    local success, response = pcall(function()
        return game:HttpGet(KEY_VALIDATION_URL)
    end)
    
    if success and response then
        for line in response:gsub("\r", ""):gmatch("[^\n]+") do
            local key = line:gsub("^%s+", ""):gsub("%s+$", "")
            if key ~= "" then
                validKeys[key] = true
            end
        end
        print("LEModz: Loaded valid keys")
        return true
    else
        warn("LEModz: Failed to fetch valid keys")
        return false
    end
end

-- Load or generate key from stored data
local function loadKeyData()
    local success, data = pcall(function()
        if syn and syn.crypt and readfile then
            local fileContent = readfile("LEModz_Key.txt")
            if fileContent and fileContent ~= "" then
                return HttpService:JSONDecode(syn.crypt.decrypt(fileContent))
            end
        end
        return nil
    end)
    
    if success and data and data.key and data.expiry then
        savedKey = data.key
        keyExpiry = data.expiry
        if os.time() < keyExpiry then
            keyConfirmed = true
            countdownStartTime = data.startTime or (os.time() - (24 * 3600) + (keyExpiry - os.time()))
        else
            keyConfirmed = false
            savedKey = nil
            keyExpiry = nil
            countdownStartTime = nil
        end
    end
end

local function saveKeyData(key, duration)
    if syn and syn.crypt and writefile then
        local data = {
            key = key,
            expiry = os.time() + duration,
            startTime = os.time()
        }
        local success, encrypted = pcall(function()
            return syn.crypt.encrypt(HttpService:JSONEncode(data))
        end)
        if success and encrypted then
            writefile("LEModz_Key.txt", encrypted)
        end
        savedKey = key
        keyExpiry = data.expiry
        keyConfirmed = true
        countdownStartTime = os.time()
    end
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEModzGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- ========== NOTIFICATION SYSTEM ==========
local function createNotification(title, message, duration)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 60)
    notifFrame.Position = UDim2.new(0.5, -150, 0, 100)
    notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.BorderSizePixel = 1
    notifFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
    notifFrame.Parent = ScreenGui
    
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = BG_URL
    bg.ScaleType = Enum.ScaleType.Slice
    bg.SliceCenter = Rect.new(20, 20, 20, 20)
    bg.Parent = notifFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notifFrame
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 0, 30)
    msgLabel.Position = UDim2.new(0, 0, 0, 25)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    msgLabel.TextScaled = true
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.Parent = notifFrame
    
    notifFrame.Position = UDim2.new(0.5, -150, 0, -100)
    local tweenIn = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0, 100)})
    tweenIn:Play()
    
    game:GetService("Debris"):AddItem(notifFrame, duration)
    task.wait(duration - 0.5)
    local tweenOut = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0, -100)})
    tweenOut:Play()
    task.wait(0.3)
    notifFrame:Destroy()
end

-- GUIN1: Notify after loading
createNotification("✅ LEModz System", "Loadstring Script Loaded Successfully!", 3)

-- Background Image for GUI and GUIGetKey
local function applyBackground(frame, url)
    local bg = Instance.new("ImageLabel")
    bg.Name = "Background"
    bg.Size = UDim2.new(1,0,1,0)
    bg.Position = UDim2.new(0,0,0,0)
    bg.BackgroundTransparency = 1
    bg.Image = url
    bg.ScaleType = Enum.ScaleType.Slice
    bg.SliceCenter = Rect.new(20,20,20,20)
    bg.Parent = frame
end

-- ========== DRAG SYSTEM WITH BOUNDARIES ==========
local function makeDraggableWithBounds(frame, dragButton, frameSize)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local startMousePos = nil
    
    -- Get actual screen size for boundaries
    local function getScreenBounds()
        local viewportSize = UserInputService:GetMouse().ViewSizeX
        local viewportHeight = UserInputService:GetMouse().ViewSizeY
        return viewportSize, viewportHeight
    end
    
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            startMousePos = input.Position
        end
    end)
    
    dragButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            local screenW, screenH = getScreenBounds()
            
            -- Calculate new position with boundaries
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            -- Apply boundaries (prevent going off-screen)
            -- Left boundary (minimum 0)
            if newX < 0 then
                newX = 0
            end
            -- Right boundary (screen width minus frame width)
            if newX + frameSize.X.Offset > screenW then
                newX = screenW - frameSize.X.Offset
            end
            -- Top boundary
            if newY < 0 then
                newY = 0
            end
            -- Bottom boundary (screen height minus frame height)
            if newY + frameSize.Y.Offset > screenH then
                newY = screenH - frameSize.Y.Offset
            end
            
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Create GUI (Key System - Main Key Entry)
local GUI = Instance.new("Frame")
GUI.Name = "GUI"
GUI.Size = UDim2.new(0, 400, 0, 200)
GUI.Position = UDim2.new(0.5, -200, 0.5, -100)
GUI.BackgroundColor3 = Color3.fromRGB(30,30,40)
GUI.BackgroundTransparency = 0.1
GUI.BorderSizePixel = 0
GUI.Visible = false
GUI.Parent = ScreenGui
applyBackground(GUI, BG_URL)

-- Title for GUI
local titleGUI = Instance.new("TextLabel")
titleGUI.Size = UDim2.new(1,0,0,40)
titleGUI.Position = UDim2.new(0,0,0,0)
titleGUI.BackgroundTransparency = 1
titleGUI.Text = "LEModz | Key"
titleGUI.TextColor3 = Color3.fromRGB(255,215,0)
titleGUI.TextScaled = true
titleGUI.Font = Enum.Font.GothamBold
titleGUI.Parent = GUI

-- Key Entry Box
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0, 250, 0, 40)
keyBox.Position = UDim2.new(0.5, -125, 0.5, -20)
keyBox.BackgroundColor3 = Color3.fromRGB(20,20,30)
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.PlaceholderText = "Enter Key"
keyBox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
keyBox.BorderSizePixel = 1
keyBox.BorderColor3 = Color3.fromRGB(80,80,100)
keyBox.Parent = GUI

-- Get Key Button (GUI)
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0, 100, 0, 40)
getKeyBtn.Position = UDim2.new(0.5, -160, 0.8, -20)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(50,50,70)
getKeyBtn.Text = "Get Key"
getKeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextSize = 16
getKeyBtn.Parent = GUI

-- Confirm Key Button
local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(0, 100, 0, 40)
confirmBtn.Position = UDim2.new(0.5, 60, 0.8, -20)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
confirmBtn.Text = "Confirm Key"
confirmBtn.TextColor3 = Color3.fromRGB(255,255,255)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 16
confirmBtn.Parent = GUI

-- Create GUIGetKey (Link System)
local GUIGetKey = Instance.new("Frame")
GUIGetKey.Name = "GUIGetKey"
GUIGetKey.Size = UDim2.new(0, 400, 0, 150)
GUIGetKey.Position = UDim2.new(0.5, -200, 0.5, -75)
GUIGetKey.BackgroundColor3 = Color3.fromRGB(30,30,40)
GUIGetKey.BackgroundTransparency = 0.1
GUIGetKey.BorderSizePixel = 0
GUIGetKey.Visible = false
GUIGetKey.Parent = ScreenGui
applyBackground(GUIGetKey, BG_URL)

-- Title for GUIGetKey
local titleGetKey = Instance.new("TextLabel")
titleGetKey.Size = UDim2.new(1,0,0,40)
titleGetKey.Position = UDim2.new(0,0,0,0)
titleGetKey.BackgroundTransparency = 1
titleGetKey.Text = "LEModz | Get Key"
titleGetKey.TextColor3 = Color3.fromRGB(255,215,0)
titleGetKey.TextScaled = true
titleGetKey.Font = Enum.Font.GothamBold
titleGetKey.Parent = GUIGetKey

-- Discord Link Text
local discordLinkLabel = Instance.new("TextLabel")
discordLinkLabel.Size = UDim2.new(1,0,0,40)
discordLinkLabel.Position = UDim2.new(0,0,0.4,0)
discordLinkLabel.BackgroundTransparency = 1
discordLinkLabel.Text = "Free Key in Discord Link"
discordLinkLabel.TextColor3 = Color3.fromRGB(200,200,255)
discordLinkLabel.TextScaled = true
discordLinkLabel.Font = Enum.Font.Gotham
discordLinkLabel.Parent = GUIGetKey

-- Back to Enter Key Button
local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 150, 0, 40)
backBtn.Position = UDim2.new(0.5, -170, 0.8, -20)
backBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)
backBtn.Text = "Back to Enter Key"
backBtn.TextColor3 = Color3.fromRGB(255,255,255)
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 14
backBtn.Parent = GUIGetKey

-- Discord Button
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 100, 0, 40)
discordBtn.Position = UDim2.new(0.5, 70, 0.8, -20)
discordBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
discordBtn.Text = "Discord"
discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 16
discordBtn.Parent = GUIGetKey

-- Create GUI2 (Main Panel)
local GUI2 = Instance.new("Frame")
GUI2.Name = "GUI2"
GUI2.Size = UDim2.new(0, 650, 0, 500)
GUI2.Position = UDim2.new(0.5, -325, 0.5, -250)
GUI2.BackgroundColor3 = Color3.fromRGB(25,25,35)
GUI2.BackgroundTransparency = 0.05
GUI2.BorderSizePixel = 0
GUI2.Visible = false
GUI2.Parent = ScreenGui
applyBackground(GUI2, BG_URL)

-- GUI2 Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,40)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = Color3.fromRGB(40,40,55)
topBar.BackgroundTransparency = 0.2
topBar.BorderSizePixel = 0
topBar.Parent = GUI2

-- Menu Button
local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 60, 1, 0)
menuBtn.Position = UDim2.new(0,0,0,0)
menuBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
menuBtn.Text = "Menu"
menuBtn.TextColor3 = Color3.fromRGB(255,255,255)
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextSize = 16
menuBtn.Parent = topBar

-- Title for GUI2
local titleGUI2 = Instance.new("TextLabel")
titleGUI2.Size = UDim2.new(1, -180, 1, 0)
titleGUI2.Position = UDim2.new(0,60,0,0)
titleGUI2.BackgroundTransparency = 1
titleGUI2.Text = "LEModz Panel"
titleGUI2.TextColor3 = Color3.fromRGB(255,215,0)
titleGUI2.TextScaled = true
titleGUI2.Font = Enum.Font.GothamBold
titleGUI2.Parent = topBar

-- Close Button (GUI2)
local closeBtn2 = Instance.new("TextButton")
closeBtn2.Size = UDim2.new(0, 60, 1, 0)
closeBtn2.Position = UDim2.new(1, -60, 0, 0)
closeBtn2.BackgroundColor3 = Color3.fromRGB(150,50,50)
closeBtn2.Text = "Close"
closeBtn2.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn2.Font = Enum.Font.GothamBold
closeBtn2.TextSize = 16
closeBtn2.Parent = topBar

-- ========== COUNTDOWN BOX (CB1) ==========
local countdownBox = Instance.new("Frame")
countdownBox.Name = "CountdownBox"
countdownBox.Size = UDim2.new(0, 200, 0, 80)
countdownBox.Position = UDim2.new(1, -210, 0, 50)
countdownBox.BackgroundColor3 = Color3.fromRGB(20,20,35)
countdownBox.BackgroundTransparency = 0.2
countdownBox.BorderSizePixel = 1
countdownBox.BorderColor3 = Color3.fromRGB(255,215,0)
countdownBox.Parent = GUI2

-- Countdown Box Title
local cbTitle = Instance.new("TextLabel")
cbTitle.Size = UDim2.new(1,0,0,25)
cbTitle.Position = UDim2.new(0,0,0,0)
cbTitle.BackgroundTransparency = 1
cbTitle.Text = "⏱ KEY TIMER"
cbTitle.TextColor3 = Color3.fromRGB(255,215,0)
cbTitle.TextScaled = true
cbTitle.Font = Enum.Font.GothamBold
cbTitle.Parent = countdownBox

-- Countdown Display (H:M:S)
local countdownDisplay = Instance.new("TextLabel")
countdownDisplay.Size = UDim2.new(1,0,0,45)
countdownDisplay.Position = UDim2.new(0,0,0,28)
countdownDisplay.BackgroundTransparency = 1
countdownDisplay.Text = "24:00:00"
countdownDisplay.TextColor3 = Color3.fromRGB(255,255,255)
countdownDisplay.TextScaled = true
countdownDisplay.Font = Enum.Font.GothamBold
countdownDisplay.TextSize = 24
countdownDisplay.Parent = countdownBox

-- UTC Time Display
local utcDisplay = Instance.new("TextLabel")
utcDisplay.Size = UDim2.new(0, 200, 0, 25)
utcDisplay.Position = UDim2.new(1, -210, 0, 135)
utcDisplay.BackgroundTransparency = 1
utcDisplay.Text = "UTC: --:--:--"
utcDisplay.TextColor3 = Color3.fromRGB(180,180,200)
utcDisplay.TextScaled = true
utcDisplay.Font = Enum.Font.Gotham
utcDisplay.Parent = GUI2

-- Menu Panel (hidden by default)
local menuPanel = Instance.new("Frame")
menuPanel.Size = UDim2.new(0, 200, 1, -40)
menuPanel.Position = UDim2.new(0,0,0,40)
menuPanel.BackgroundColor3 = Color3.fromRGB(35,35,50)
menuPanel.BackgroundTransparency = 0.3
menuPanel.BorderSizePixel = 0
menuPanel.Visible = false
menuPanel.Parent = GUI2

-- Menu Items container
local menuItems = Instance.new("ScrollingFrame")
menuItems.Size = UDim2.new(1,0,1,0)
menuItems.Position = UDim2.new(0,0,0,0)
menuItems.BackgroundTransparency = 1
menuItems.BorderSizePixel = 0
menuItems.CanvasSize = UDim2.new(0,0,0,300)
menuItems.Parent = menuPanel

-- Main Content Area (for scripts/features)
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -200, 1, -40)
contentArea.Position = UDim2.new(0,0,0,40)
contentArea.BackgroundColor3 = Color3.fromRGB(30,30,45)
contentArea.BackgroundTransparency = 0.2
contentArea.BorderSizePixel = 0
contentArea.Parent = GUI2

-- Add sample menu items
local sampleItems = {"Feature 1", "Feature 2", "Feature 3", "Feature 4", "Settings"}
for i, itemName in ipairs(sampleItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0,5,0,(i-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btn.Text = itemName
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = menuItems
    
    btn.MouseButton1Click:Connect(function()
        titleGUI2.Text = "LEModz | " .. itemName
        for _, child in ipairs(contentArea:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1,0,1,0)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Text = "Content for " .. itemName .. "\n\nPlace your script features here!"
        contentLabel.TextColor3 = Color3.fromRGB(255,255,255)
        contentLabel.TextScaled = true
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.Parent = contentArea
    end)
end

-- Create Image Button (toggle to open GUI)
local imgButton = Instance.new("ImageButton")
imgButton.Name = "ImgButton"
imgButton.Size = UDim2.new(0, 80, 0, 80)
imgButton.Position = UDim2.new(0.02, 0, 0.85, 0)
imgButton.BackgroundTransparency = 1
imgButton.Image = IMG_BUTTON_URL
imgButton.Parent = ScreenGui

-- Apply draggable with bounds to all GUI elements
makeDraggableWithBounds(GUI, titleGUI, GUI.Size)
makeDraggableWithBounds(GUIGetKey, titleGetKey, GUIGetKey.Size)
makeDraggableWithBounds(GUI2, topBar, GUI2.Size)
makeDraggableWithBounds(imgButton, imgButton, imgButton.Size)

-- Logic State Management
local currentState = "L1"
local countdownEnd = nil
local countdownActive = false

-- Format time from seconds to HH:MM:SS
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Update UTC Clock Display
local function updateUTCDisplay()
    local utcTime = os.date("!%H:%M:%S")
    utcDisplay.Text = "🌐 UTC: " .. utcTime
end

-- Update Countdown Display (L3 Timer)
local function updateCountdownDisplay()
    if countdownActive and countdownEnd then
        local remaining = countdownEnd - os.time()
        if remaining <= 0 then
            countdownActive = false
            keyConfirmed = false
            savedKey = nil
            keyExpiry = nil
            countdownStartTime = nil
            countdownDisplay.Text = "00:00:00"
            currentState = "L1"
            imgButton.Visible = true
            GUI.Visible = false
            GUIGetKey.Visible = false
            GUI2.Visible = false
        else
            countdownDisplay.Text = formatTime(remaining)
        end
    else
        countdownDisplay.Text = "00:00:00"
    end
end

-- Start the 24-hour countdown (L3)
local function startL3Countdown()
    countdownEnd = os.time() + (24 * 60 * 60)
    countdownActive = true
    countdownStartTime = os.time()
    
    if syn and syn.crypt and writefile then
        local data = {
            key = savedKey or "valid_key",
            expiry = countdownEnd,
            startTime = countdownStartTime
        }
        local success, encrypted = pcall(function()
            return syn.crypt.encrypt(HttpService:JSONEncode(data))
        end)
        if success and encrypted then
            writefile("LEModz_Key.txt", encrypted)
        end
    end
end

-- Check if key is valid from GitHub
local function isKeyValidFromGitHub(key)
    if not next(validKeys) then
        fetchValidKeys()
    end
    return validKeys[key] == true
end

-- Timer update thread (real-time, runs every second)
spawn(function()
    while true do
        wait(1)
        updateUTCDisplay()
        updateCountdownDisplay()
        
        if countdownActive and countdownEnd and os.time() >= countdownEnd then
            countdownActive = false
            keyConfirmed = false
            savedKey = nil
            keyExpiry = nil
            countdownStartTime = nil
            currentState = "L1"
            imgButton.Visible = true
            GUI.Visible = false
            GUIGetKey.Visible = false
            GUI2.Visible = false
        end
    end
end)

-- Button Functionality

local function setStateL1()
    imgButton.Visible = true
    GUI.Visible = false
    GUIGetKey.Visible = false
    GUI2.Visible = false
    currentState = "L1"
end

local function setStateGUI()
    imgButton.Visible = false
    GUI.Visible = true
    GUIGetKey.Visible = false
    GUI2.Visible = false
    currentState = "GUI"
end

local function setStateGUIGetKey()
    imgButton.Visible = false
    GUI.Visible = false
    GUIGetKey.Visible = true
    GUI2.Visible = false
    currentState = "GUIGetKey"
end

local function setStateL2()
    imgButton.Visible = true
    GUI.Visible = false
    GUIGetKey.Visible = false
    GUI2.Visible = false
    currentState = "L2"
end

local function setStateGUI2()
    if countdownActive then
        imgButton.Visible = false
        GUI.Visible = false
        GUIGetKey.Visible = false
        GUI2.Visible = true
        currentState = "L3"
        if countdownEnd then
            local remaining = countdownEnd - os.time()
            titleGUI2.Text = "LEModz | " .. formatTime(remaining) .. " Remaining"
        end
    else
        setStateL1()
    end
end

-- Image Button Click
imgButton.MouseButton1Click:Connect(function()
    if countdownActive then
        setStateGUI2()
    else
        setStateGUI()
    end
end)

-- Get Key Button
getKeyBtn.MouseButton1Click:Connect(function()
    setStateGUIGetKey()
end)

-- Back Button
backBtn.MouseButton1Click:Connect(function()
    setStateGUI()
end)

-- Discord Button - Copy link and show notification (GUIN2)
discordBtn.MouseButton1Click:Connect(function()
    setclipboard and setclipboard(DISCORD_INVITE)
    createNotification("🔗 Discord Link", "Discord Link Copied! Join Discord Server Now, the Key is Waiting!", 4)
    if syn and syn.request then
        syn.request({
            Url = DISCORD_INVITE,
            Method = "GET"
        })
    end
end)

-- Confirm Key Button - Validate from GitHub URL
confirmBtn.MouseButton1Click:Connect(function()
    local enteredKey = keyBox.Text
    if isKeyValidFromGitHub(enteredKey) then
        savedKey = enteredKey
        startL3Countdown()
        keyConfirmed = true
        setStateL2()
        -- GUIN3: Notify after key confirmation
        createNotification("✅ Key Confirmed", "Key has been Confirmed! Key Countdown: 24 Hours", 5)
    else
        keyBox.PlaceholderText = "Invalid Key!"
        keyBox.PlaceholderColor3 = Color3.fromRGB(255,100,100)
        wait(2)
        keyBox.PlaceholderText = "Enter Key"
        keyBox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    end
end)

-- GUI2 Menu Button Toggle
local menuOpen = false
menuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuPanel.Visible = menuOpen
    if menuOpen then
        contentArea.Size = UDim2.new(1, -200, 1, -40)
        contentArea.Position = UDim2.new(0,200,0,40)
    else
        contentArea.Size = UDim2.new(1,0,1,-40)
        contentArea.Position = UDim2.new(0,0,0,40)
    end
end)

-- Close Button for GUI2
closeBtn2.MouseButton1Click:Connect(function()
    setStateL1()
end)

-- Update timer display in GUI2 title when visible
spawn(function()
    while true do
        wait(0.5)
        if GUI2.Visible and countdownActive and countdownEnd then
            local remaining = countdownEnd - os.time()
            if remaining > 0 then
                titleGUI2.Text = "LEModz | " .. formatTime(remaining)
            else
                titleGUI2.Text = "LEModz | EXPIRED"
            end
        end
    end
end)

-- Fetch valid keys on startup
fetchValidKeys()

-- Load saved key data
loadKeyData()

-- Restore countdown if key was valid
if savedKey and keyExpiry and os.time() < keyExpiry then
    countdownEnd = keyExpiry
    countdownActive = true
    keyConfirmed = true
    countdownStartTime = keyExpiry - (24 * 3600)
    setStateL2()
end

-- Initial state
setStateL1()

print("LEModz Key System Loaded Successfully!")
print("UTC Time: " .. os.date("!%Y-%m-%d %H:%M:%S"))
