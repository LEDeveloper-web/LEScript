-- GUILEPanel Script - With Full State Management & Rejoin Detection
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Create GUI (Full Screen)
local GUI = Instance.new("ScreenGui")
GUI.Name = "GUILEPanel"
GUI.Parent = CoreGui
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true

-- State Management
local GameState = {
    L1_LOADING = "L1_LOADING",
    L1_COMPLETE = "L1_COMPLETE",
    L2_OPEN = "L2_OPEN",
    L3_OPEN = "L3_OPEN"
}

local currentState = GameState.L1_LOADING

-- Safe clipboard function for all devices
local function CopyToClipboard(text)
    local success = false
    
    local clipboardFunctions = {
        function() setclipboard(text) end,
        function() toclipboard(text) end,
        function() Clipboard:set(text) end,
        function() 
            if syn and syn.clipboard then syn.clipboard(text) end
        end,
        function()
            if game:GetService("GuiService") and game:GetService("GuiService"):AddClipboardText then
                game:GetService("GuiService"):AddClipboardText(text)
            end
        end
    }
    
    for _, func in ipairs(clipboardFunctions) do
        success = pcall(func)
        if success then break end
    end
    
    return success
end

-- ============ LEFrame1 (Loading Screen - L1) ============
local LEFrame1 = Instance.new("Frame")
LEFrame1.Size = UDim2.new(1, 0, 1, 0)
LEFrame1.Position = UDim2.new(0, 0, 0, 0)
LEFrame1.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
LEFrame1.BackgroundTransparency = 0
LEFrame1.BorderSizePixel = 0
LEFrame1.Visible = true  -- L1 starts visible
LEFrame1.Parent = GUI

-- Loading Screen Background Effect
local LoadBackground = Instance.new("Frame")
LoadBackground.Size = UDim2.new(1, 0, 1, 0)
LoadBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
LoadBackground.BackgroundTransparency = 0.3
LoadBackground.Parent = LEFrame1

-- Loading Container
local LoadContainer = Instance.new("Frame")
LoadContainer.Size = UDim2.new(0.6, 0, 0.5, 0)
LoadContainer.Position = UDim2.new(0.2, 0, 0.25, 0)
LoadContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
LoadContainer.BackgroundTransparency = 0.2
LoadContainer.BorderSizePixel = 0
LoadContainer.Parent = LEFrame1

local LoadContainerCorner = Instance.new("UICorner")
LoadContainerCorner.CornerRadius = UDim.new(0, 20)
LoadContainerCorner.Parent = LoadContainer

-- Loading text (changes during loading)
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0.3, 0)
LoadingText.Position = UDim2.new(0, 0, 0.35, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Executor Script..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 32
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextScaled = true
LoadingText.Parent = LoadContainer

-- Loading spinner
local Spinner = Instance.new("Frame")
Spinner.Size = UDim2.new(0, 80, 0, 80)
Spinner.Position = UDim2.new(0.5, -40, 0.6, 0)
Spinner.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Spinner.BackgroundTransparency = 0
Spinner.BorderSizePixel = 0
Spinner.Parent = LoadContainer

local SpinnerCorner = Instance.new("UICorner")
SpinnerCorner.CornerRadius = UDim.new(1, 0)
SpinnerCorner.Parent = Spinner

local InnerSpinner = Instance.new("Frame")
InnerSpinner.Size = UDim2.new(0.7, 0, 0.7, 0)
InnerSpinner.Position = UDim2.new(0.15, 0, 0.15, 0)
InnerSpinner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InnerSpinner.BackgroundTransparency = 0
InnerSpinner.BorderSizePixel = 0
InnerSpinner.Parent = Spinner

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(1, 0)
InnerCorner.Parent = InnerSpinner

-- Loading progress bar
local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0.6, 0, 0.05, 0)
ProgressBar.Position = UDim2.new(0.2, 0, 0.8, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBar.BackgroundTransparency = 0
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = LoadContainer

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(0, 10)
ProgressBarCorner.Parent = ProgressBar

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ProgressFill.BackgroundTransparency = 0
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBar

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(0, 10)
ProgressFillCorner.Parent = ProgressFill

-- ============ LEFrame2 (Main Menu Button - L2) ============
local LEFrame2 = Instance.new("Frame")
LEFrame2.Size = UDim2.new(0.2, 0, 0.2, 0)
LEFrame2.Position = UDim2.new(0.4, 0, 0.4, 0)
LEFrame2.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LEFrame2.BackgroundTransparency = 0
LEFrame2.BorderSizePixel = 0
LEFrame2.Visible = false  -- L2 starts hidden
LEFrame2.Parent = GUI

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 50)
Corner2.Parent = LEFrame2

-- Gradient for LEFrame2
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
})
Gradient.Rotation = 45
Gradient.Parent = LEFrame2

-- Glow effect
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1.15, 0, 1.15, 0)
Glow.Position = UDim2.new(-0.075, 0, -0.075, 0)
Glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Glow.BackgroundTransparency = 0.6
Glow.BorderSizePixel = 0
Glow.Parent = LEFrame2

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 60)
GlowCorner.Parent = Glow

local LEButton1 = Instance.new("TextButton")
LEButton1.Size = UDim2.new(1, 0, 1, 0)
LEButton1.Position = UDim2.new(0, 0, 0, 0)
LEButton1.BackgroundTransparency = 1
LEButton1.Text = "LE"
LEButton1.TextColor3 = Color3.fromRGB(0, 0, 0)
LEButton1.TextSize = 60
LEButton1.Font = Enum.Font.GothamBold
LEButton1.TextScaled = true
LEButton1.Parent = LEFrame2

-- ============ LEFrame3 (Main Panel - L3) ============
local LEFrame3 = Instance.new("Frame")
LEFrame3.Size = UDim2.new(1, 0, 1, 0)
LEFrame3.Position = UDim2.new(0, 0, 0, 0)
LEFrame3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LEFrame3.BackgroundTransparency = 0.3
LEFrame3.BorderSizePixel = 0
LEFrame3.Visible = false  -- L3 starts hidden
LEFrame3.Parent = GUI

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0.1, 0)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
TopBar.Parent = LEFrame3

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.25, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LEDelta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 28
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

-- Close Button (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.08, 0, 0.7, 0)
CloseButton.Position = UDim2.new(0.91, 0, 0.15, 0)
CloseButton.BackgroundTransparency = 0
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- Menu Button
local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0.08, 0, 0.7, 0)
MenuButton.Position = UDim2.new(0.01, 0, 0.15, 0)
MenuButton.BackgroundTransparency = 0
MenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MenuButton.Text = "☰"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Font = Enum.Font.GothamBold
MenuButton.Parent = TopBar

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0.9, 0)
ContentFrame.Position = UDim2.new(0, 0, 0.1, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = LEFrame3

-- Main Menu Content
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = true
MainContent.Parent = ContentFrame

-- Center Container for Main Content
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0.6, 0, 0.6, 0)
MainContainer.Position = UDim2.new(0.2, 0, 0.2, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainContainer.BackgroundTransparency = 0.2
MainContainer.BorderSizePixel = 0
MainContainer.Parent = MainContent

local MainContainerCorner = Instance.new("UICorner")
MainContainerCorner.CornerRadius = UDim.new(0, 20)
MainContainerCorner.Parent = MainContainer

-- Welcome Text
local LEText1 = Instance.new("TextLabel")
LEText1.Size = UDim2.new(0.9, 0, 0.35, 0)
LEText1.Position = UDim2.new(0.05, 0, 0.05, 0)
LEText1.BackgroundTransparency = 1
LEText1.Text = "Welcome to LEDelta\n\nJoin my Official LEModz Discord"
LEText1.TextColor3 = Color3.fromRGB(255, 255, 255)
LEText1.TextSize = 28
LEText1.TextScaled = true
LEText1.Font = Enum.Font.GothamBold
LEText1.TextXAlignment = Enum.TextXAlignment.Center
LEText1.TextYAlignment = Enum.TextYAlignment.Center
LEText1.Parent = MainContainer

-- Copy Button
local LEButton2 = Instance.new("TextButton")
LEButton2.Size = UDim2.new(0.5, 0, 0.12, 0)
LEButton2.Position = UDim2.new(0.25, 0, 0.48, 0)
LEButton2.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
LEButton2.Text = "Copy Discord Link"
LEButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
LEButton2.TextSize = 20
LEButton2.Font = Enum.Font.GothamBold
LEButton2.AutoButtonColor = true
LEButton2.Parent = MainContainer

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = LEButton2

-- Instruction Text
local LEText2 = Instance.new("TextLabel")
LEText2.Size = UDim2.new(0.8, 0, 0.1, 0)
LEText2.Position = UDim2.new(0.1, 0, 0.65, 0)
LEText2.BackgroundTransparency = 1
LEText2.Text = "Tap the button above to copy the link"
LEText2.TextColor3 = Color3.fromRGB(169, 169, 169)
LEText2.TextSize = 18
LEText2.Font = Enum.Font.Gotham
LEText2.TextXAlignment = Enum.TextXAlignment.Center
LEText2.Parent = MainContainer

-- Note Text
local NoteText = Instance.new("TextLabel")
NoteText.Size = UDim2.new(0.8, 0, 0.1, 0)
NoteText.Position = UDim2.new(0.1, 0, 0.78, 0)
NoteText.BackgroundTransparency = 1
NoteText.Text = "📋 Open browser app to paste the link"
NoteText.TextColor3 = Color3.fromRGB(255, 200, 100)
NoteText.TextSize = 16
NoteText.Font = Enum.Font.Gotham
NoteText.TextXAlignment = Enum.TextXAlignment.Center
NoteText.Parent = MainContainer

-- ============ Dragging System ============
local dragData = {
    active = false,
    startPos = nil,
    frame = nil,
    startMousePos = nil
}

local function StartDrag(frame)
    dragData.active = true
    dragData.frame = frame
    dragData.startPos = frame.Position
    dragData.startMousePos = UserInputService:GetMouseLocation()
end

local function UpdateDrag()
    if not dragData.active or not dragData.frame then return end
    
    local currentMousePos = UserInputService:GetMouseLocation()
    local delta = currentMousePos - dragData.startMousePos
    
    local newX = dragData.startPos.X.Scale + (delta.X / GUI.AbsoluteSize.X)
    local newY = dragData.startPos.Y.Scale + (delta.Y / GUI.AbsoluteSize.Y)
    
    newX = math.clamp(newX, 0, 0.8)
    newY = math.clamp(newY, 0, 0.8)
    
    dragData.frame.Position = UDim2.new(newX, 0, newY, 0)
end

local function StopDrag()
    dragData.active = false
    dragData.frame = nil
end

LEButton1.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(LEFrame2)
    end
end)

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(LEFrame3)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        StopDrag()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.active and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        UpdateDrag()
    end
end)

-- ============ Animation Functions ============
local function AnimateButton(button, scale)
    local originalSize = button.Size
    local tween = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(originalSize.X.Scale * scale, 0, originalSize.Y.Scale * scale, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        local resetTween = TweenService:Create(button, TweenInfo.new(0.08), {Size = originalSize})
        resetTween:Play()
    end)
end

-- ============ L1 Loading Sequence ============
local progress = 0
local angle = 0

-- Progress bar animation
local progressConnection
progressConnection = RunService.RenderStepped:Connect(function()
    if currentState == GameState.L1_LOADING and progress < 1 then
        progress = progress + 0.008
        ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        
        -- Update loading text based on progress
        if progress < 0.3 then
            LoadingText.Text = "Loading Executor Script..."
        elseif progress < 0.6 then
            LoadingText.Text = "Initializing Components..."
        elseif progress < 0.9 then
            LoadingText.Text = "Almost Ready..."
        end
    elseif progress >= 1 and currentState == GameState.L1_LOADING then
        if progressConnection then progressConnection:Disconnect() end
        -- Script completed executed
        LoadingText.Text = "✓ Script Completed Executed!"
        task.wait(1)
        CompleteL1Loading()
    end
end)

-- Spinner animation
local spinConnection
spinConnection = RunService.RenderStepped:Connect(function()
    if LEFrame1.Visible then
        angle = angle + 10
        Spinner.Rotation = angle
    end
end)

-- Pulse animation for LEFrame2
local pulseDirection = 1
local currentPulse = 0
local pulseConnection
pulseConnection = RunService.RenderStepped:Connect(function()
    if LEFrame2.Visible then
        currentPulse = currentPulse + (0.03 * pulseDirection)
        if currentPulse >= 1 then
            currentPulse = 1
            pulseDirection = -1
        elseif currentPulse <= 0 then
            currentPulse = 0
            pulseDirection = 1
        end
        Glow.BackgroundTransparency = 0.4 + (currentPulse * 0.3)
    end
end)

-- ============ State Management Functions ============

function CompleteL1Loading()
    if currentState ~= GameState.L1_LOADING then return end
    
    currentState = GameState.L1_COMPLETE
    
    -- Fade out LEFrame1
    local fadeTween = TweenService:Create(LEFrame1, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        LEFrame1.Visible = false
        LEFrame2.Visible = true
        currentState = GameState.L2_OPEN
        print("✅ L1 Complete - L2 Now Open")
    end)
end

function OpenL3()
    if currentState ~= GameState.L2_OPEN then return end
    
    AnimateButton(LEButton1, 0.95)
    LEFrame2.Visible = false
    LEFrame3.Visible = true
    currentState = GameState.L3_OPEN
    print("📂 L3 Opened")
end

function CloseL3()
    if currentState ~= GameState.L3_OPEN then return end
    
    AnimateButton(CloseButton, 0.9)
    LEFrame3.Visible = false
    LEFrame2.Visible = true
    currentState = GameState.L2_OPEN
    print("📁 L3 Closed - Back to L2")
end

function ResetToL1()
    print("🔄 Game Rejoin Detected - Resetting to L1")
    
    -- Reset all UI states
    LEFrame1.Visible = true
    LEFrame1.BackgroundTransparency = 0
    LEFrame2.Visible = false
    LEFrame3.Visible = false
    
    -- Reset progress
    progress = 0
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingText.Text = "Loading Executor Script..."
    
    -- Reset state
    currentState = GameState.L1_LOADING
    
    -- Restart progress animation
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.RenderStepped:Connect(function()
        if currentState == GameState.L1_LOADING and progress < 1 then
            progress = progress + 0.008
            ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
            
            if progress < 0.3 then
                LoadingText.Text = "Loading Executor Script..."
            elseif progress < 0.6 then
                LoadingText.Text = "Initializing Components..."
            elseif progress < 0.9 then
                LoadingText.Text = "Almost Ready..."
            end
        elseif progress >= 1 and currentState == GameState.L1_LOADING then
            if progressConnection then progressConnection:Disconnect() end
            LoadingText.Text = "✓ Script Completed Executed!"
            task.wait(1)
            CompleteL1Loading()
        end
    end)
end

-- ============ Game Rejoin/Leave Detection ============
local function SetupRejoinDetection()
    -- Detect when player leaves the game
    LocalPlayer.AncestryChanged:Connect(function()
        if not LocalPlayer.Parent then
            print("⚠️ Player leaving game...")
        end
    end)
    
    -- Detect when player respawns or rejoins
    LocalPlayer.CharacterAdded:Connect(function(character)
        print("🔄 Character added - Checking game state")
        task.wait(1)
        
        -- Check if we need to reset to L1
        if currentState ~= GameState.L1_LOADING then
            ResetToL1()
        end
    end)
    
    -- Also detect when the player's PlayerGui changes (rejoin)
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if player == LocalPlayer then
            task.wait(0.5)
            if currentState ~= GameState.L1_LOADING then
                ResetToL1()
            end
        end
    end)
end

-- ============ Button Connections ============

-- L2 → L3 (Open L3 when LEButton1 clicked)
LEButton1.MouseButton1Click:Connect(OpenL3)
LEButton1.TouchTap:Connect(OpenL3)

-- L3 → L2 (Close L3 when X button clicked)
CloseButton.MouseButton1Click:Connect(CloseL3)
CloseButton.TouchTap:Connect(CloseL3)

-- Copy Discord Link
local function CopyLink()
    if currentState ~= GameState.L3_OPEN then return end
    
    AnimateButton(LEButton2, 0.95)
    local DiscordLink = "https://discord.gg/NBdp4zuJtt"
    
    local success = CopyToClipboard(DiscordLink)
    
    if success then
        local originalText = LEButton2.Text
        LEButton2.Text = "✓ Copied!"
        LEText2.Text = "✓ Link copied to clipboard!"
        task.wait(1.5)
        LEButton2.Text = originalText
        LEText2.Text = "Open browser app and paste the link"
    else
        LEButton2.Text = "⚠️ Copy Failed"
        LEText2.Text = "Manual: " .. DiscordLink
        task.wait(2)
        LEButton2.Text = "Copy Discord Link"
        LEText2.Text = "Tap the button above to copy the link"
    end
end

LEButton2.MouseButton1Click:Connect(CopyLink)
LEButton2.TouchTap:Connect(CopyLink)

-- ============ Menu System ============
local menuOpen = false
local MenuPanel = nil

local function ToggleMenu()
    if currentState ~= GameState.L3_OPEN then return end
    
    if menuOpen then
        if MenuPanel then MenuPanel:Destroy() end
        menuOpen = false
        return
    end
    
    MenuPanel = Instance.new("Frame")
    MenuPanel.Size = UDim2.new(0, 200, 0, 300)
    MenuPanel.Position = UDim2.new(0, 10, 0, TopBar.AbsoluteSize.Y + 5)
    MenuPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MenuPanel.BackgroundTransparency = 0.05
    MenuPanel.BorderSizePixel = 0
    MenuPanel.Parent = LEFrame3
    
    local MenuPanelCorner = Instance.new("UICorner")
    MenuPanelCorner.CornerRadius = UDim.new(0, 10)
    MenuPanelCorner.Parent = MenuPanel
    
    local menuItems = {
        {name = "★ Main (Default)", callback = function()
            MainContent.Visible = true
            MenuPanel:Destroy()
            menuOpen = false
        end}
    }
    
    for i, item in ipairs(menuItems) do
        local menuItem = Instance.new("TextButton")
        menuItem.Size = UDim2.new(0.95, 0, 0, 45)
        menuItem.Position = UDim2.new(0.025, 0, 0, (i-1) * 48)
        menuItem.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        menuItem.BackgroundTransparency = 0.3
        menuItem.Text = item.name
        menuItem.TextColor3 = Color3.fromRGB(255, 255, 255)
        menuItem.TextSize = 16
        menuItem.Font = Enum.Font.Gotham
        menuItem.Parent = MenuPanel
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = menuItem
        
        menuItem.MouseButton1Click:Connect(item.callback)
        menuItem.TouchTap:Connect(item.callback)
        
        menuItem.MouseEnter:Connect(function()
            TweenService:Create(menuItem, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        menuItem.MouseLeave:Connect(function()
            TweenService:Create(menuItem, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)
    end
    
    menuOpen = true
    
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) then
            task.wait(0.1)
            if MenuPanel then
                MenuPanel:Destroy()
                menuOpen = false
            end
            closeConnection:Disconnect()
        end
    end)
end

MenuButton.MouseButton1Click:Connect(ToggleMenu)
MenuButton.TouchTap:Connect(ToggleMenu)

-- ============ Device Optimization ============
local function OptimizeForDevice()
    if UserInputService.TouchEnabled then
        LEButton1.TextSize = 80
        Title.TextSize = 24
        CloseButton.TextSize = 22
        MenuButton.TextSize = 22
        LEButton2.TextSize = 18
        LEText2.TextSize = 16
        NoteText.TextSize = 14
        
        CloseButton.Size = UDim2.new(0.12, 0, 0.7, 0)
        CloseButton.Position = UDim2.new(0.87, 0, 0.15, 0)
        MenuButton.Size = UDim2.new(0.12, 0, 0.7, 0)
    end
end

-- ============ Initialize ============
OptimizeForDevice()
SetupRejoinDetection()

print("✅ GUILEPanel Loaded Successfully!")
print("📋 L1: Loading Screen Active")
print("📋 Will auto-detect game rejoins and reset to L1")
print("📋 State Machine: L1 → L2 → L3")
