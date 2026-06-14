-- GUILEPanel Script - Optimized for All Devices (PC/Mobile/Console)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "GUILEPanel"
GUI.Parent = game.CoreGui
GUI.ResetOnSpawn = false

-- Safe clipboard function for all devices
local function CopyToClipboard(text)
    local success = false
    local errMsg = ""
    
    -- Try different clipboard methods
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
        success, errMsg = pcall(func)
        if success then break end
    end
    
    return success, errMsg
end

-- LEFrame1 (Loading Screen)
local LEFrame1 = Instance.new("Frame")
LEFrame1.Size = UDim2.new(0.8, 0, 0.8, 0)
LEFrame1.Position = UDim2.new(0.1, 0, 0.1, 0)
LEFrame1.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
LEFrame1.BackgroundTransparency = 0.15
LEFrame1.BorderSizePixel = 0
LEFrame1.Parent = GUI

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 10)
Corner1.Parent = LEFrame1

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0.8, 0)
LoadingText.Position = UDim2.new(0, 0, 0.1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading Executor Script"
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 28
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Parent = LEFrame1

-- Loading spinner
local Spinner = Instance.new("Frame")
Spinner.Size = UDim2.new(0, 50, 0, 50)
Spinner.Position = UDim2.new(0.5, -25, 0.7, 0)
Spinner.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Spinner.BackgroundTransparency = 0
Spinner.BorderSizePixel = 0
Spinner.Parent = LEFrame1

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

-- LEFrame2 (Main Menu Button)
local LEFrame2 = Instance.new("Frame")
LEFrame2.Size = UDim2.new(0.15, 0, 0.15, 0)
LEFrame2.Position = UDim2.new(0.425, 0, 0.425, 0)
LEFrame2.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LEFrame2.BackgroundTransparency = 0
LEFrame2.BorderSizePixel = 0
LEFrame2.Visible = false
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

-- Glow effect for LEFrame2
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1.1, 0, 1.1, 0)
Glow.Position = UDim2.new(-0.05, 0, -0.05, 0)
Glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Glow.BackgroundTransparency = 0.7
Glow.BorderSizePixel = 0
Glow.Parent = LEFrame2

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 55)
GlowCorner.Parent = Glow

local LEButton1 = Instance.new("TextButton")
LEButton1.Size = UDim2.new(1, 0, 1, 0)
LEButton1.Position = UDim2.new(0, 0, 0, 0)
LEButton1.BackgroundTransparency = 1
LEButton1.Text = "LE"
LEButton1.TextColor3 = Color3.fromRGB(0, 0, 0)
LEButton1.TextSize = 40
LEButton1.Font = Enum.Font.GothamBold
LEButton1.Parent = LEFrame2

-- LEFrame3 (Main Panel)
local LEFrame3 = Instance.new("Frame")
LEFrame3.Size = UDim2.new(0.85, 0, 0.85, 0)
LEFrame3.Position = UDim2.new(0.075, 0, 0.075, 0)
LEFrame3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LEFrame3.BackgroundTransparency = 0.5
LEFrame3.BorderSizePixel = 0
LEFrame3.Visible = false
LEFrame3.Parent = GUI

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 10)
Corner3.Parent = LEFrame3

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0.12, 0)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = LEFrame3

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.25, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LEDelta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.12, 0, 0.8, 0)
CloseButton.Position = UDim2.new(0.87, 0, 0.1, 0)
CloseButton.BackgroundTransparency = 0
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0.12, 0, 0.8, 0)
MenuButton.Position = UDim2.new(0.01, 0, 0.1, 0)
MenuButton.BackgroundTransparency = 0
MenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MenuButton.Text = "☰"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Font = Enum.Font.GothamBold
MenuButton.Parent = TopBar

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 8)
MenuCorner.Parent = MenuButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(0.96, 0, 0.86, 0)
ContentFrame.Position = UDim2.new(0.02, 0, 0.13, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = LEFrame3

-- Main Menu Content
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.new(1, 0, 1, 0)
MainContent.BackgroundTransparency = 1
MainContent.Visible = true
MainContent.Parent = ContentFrame

local LEText1 = Instance.new("TextLabel")
LEText1.Size = UDim2.new(0.9, 0, 0.35, 0)
LEText1.Position = UDim2.new(0.05, 0, 0.05, 0)
LEText1.BackgroundTransparency = 1
LEText1.Text = "Welcome to LEDelta\n\nJoin my Official LEModz Discord"
LEText1.TextColor3 = Color3.fromRGB(255, 255, 255)
LEText1.TextSize = 22
LEText1.TextScaled = true
LEText1.Font = Enum.Font.GothamBold
LEText1.TextXAlignment = Enum.TextXAlignment.Center
LEText1.TextYAlignment = Enum.TextYAlignment.Center
LEText1.Parent = MainContent

local LEButton2 = Instance.new("TextButton")
LEButton2.Size = UDim2.new(0.5, 0, 0.12, 0)
LEButton2.Position = UDim2.new(0.25, 0, 0.45, 0)
LEButton2.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
LEButton2.Text = "Copy Discord Link"
LEButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
LEButton2.TextSize = 18
LEButton2.Font = Enum.Font.GothamBold
LEButton2.AutoButtonColor = true
LEButton2.Parent = MainContent

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = LEButton2

local LEText2 = Instance.new("TextLabel")
LEText2.Size = UDim2.new(0.8, 0, 0.1, 0)
LEText2.Position = UDim2.new(0.1, 0, 0.62, 0)
LEText2.BackgroundTransparency = 1
LEText2.Text = "Tap the button above to copy the link"
LEText2.TextColor3 = Color3.fromRGB(169, 169, 169)
LEText2.TextSize = 16
LEText2.Font = Enum.Font.Gotham
LEText2.TextXAlignment = Enum.TextXAlignment.Center
LEText2.Parent = MainContent

local NoteText = Instance.new("TextLabel")
NoteText.Size = UDim2.new(0.8, 0, 0.1, 0)
NoteText.Position = UDim2.new(0.1, 0, 0.75, 0)
NoteText.BackgroundTransparency = 1
NoteText.Text = "📋 Open browser app to paste the link"
NoteText.TextColor3 = Color3.fromRGB(255, 200, 100)
NoteText.TextSize = 14
NoteText.Font = Enum.Font.Gotham
NoteText.TextXAlignment = Enum.TextXAlignment.Center
NoteText.Parent = MainContent

-- Dragging system for all devices
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
    
    -- Clamp to screen bounds
    newX = math.clamp(newX, 0, 0.85)
    newY = math.clamp(newY, 0, 0.85)
    
    dragData.frame.Position = UDim2.new(newX, 0, newY, 0)
end

local function StopDrag()
    dragData.active = false
    dragData.frame = nil
end

-- Touch and mouse support for LEFrame2
LEButton1.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(LEFrame2)
    end
end)

-- Touch and mouse support for LEFrame3
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

-- Spinner animation
local angle = 0
local spinConnection
spinConnection = RunService.RenderStepped:Connect(function()
    if LEFrame1.Visible then
        angle = angle + 8
        Spinner.Rotation = angle
    end
end)

-- Button press animations
local function AnimateButton(button, scale)
    local originalSize = button.Size
    local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(originalSize.X.Scale * scale, 0, originalSize.Y.Scale * scale, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        local resetTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = originalSize
        })
        resetTween:Play()
    end)
end

-- Pulsing glow animation for LEFrame2
local pulseConnection
local pulseDirection = 1
local currentPulse = 0

pulseConnection = RunService.RenderStepped:Connect(function()
    if LEFrame2.Visible then
        currentPulse = currentPulse + (0.05 * pulseDirection)
        if currentPulse >= 1 then
            currentPulse = 1
            pulseDirection = -1
        elseif currentPulse <= 0 then
            currentPulse = 0
            pulseDirection = 1
        end
        Glow.BackgroundTransparency = 0.5 + (currentPulse * 0.3)
    end
end)

-- Loading simulation
task.wait(2.5)

-- Fade out LEFrame1
local fadeTween = TweenService:Create(LEFrame1, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1
})
fadeTween:Play()
fadeTween.Completed:Connect(function()
    LEFrame1.Visible = false
    LEFrame2.Visible = true
end)

-- Button Functions
LEButton1.MouseButton1Click:Connect(function()
    AnimateButton(LEButton1, 0.95)
    LEFrame2.Visible = false
    LEFrame3.Visible = true
end)

-- Touch support for mobile
LEButton1.TouchTap:Connect(function()
    AnimateButton(LEButton1, 0.95)
    LEFrame2.Visible = false
    LEFrame3.Visible = true
end)

CloseButton.MouseButton1Click:Connect(function()
    AnimateButton(CloseButton, 0.9)
    LEFrame3.Visible = false
    LEFrame2.Visible = true
end)

CloseButton.TouchTap:Connect(function()
    AnimateButton(CloseButton, 0.9)
    LEFrame3.Visible = false
    LEFrame2.Visible = true
end)

-- Copy Discord link with device-specific feedback
LEButton2.MouseButton1Click:Connect(function()
    AnimateButton(LEButton2, 0.95)
    local DiscordLink = "https://discord.gg/NBdp4zuJtt"
    
    local success = CopyToClipboard(DiscordLink)
    
    if success then
        LEButton2.Text = "✓ Copied!"
        LEText2.Text = "✓ Link copied to clipboard!"
        task.wait(1.5)
        LEButton2.Text = "Copy Discord Link"
        LEText2.Text = "Open browser app and paste the link"
    else
        LEButton2.Text = "⚠️ Copy Failed"
        LEText2.Text = "Manual copy: " .. DiscordLink
        task.wait(2)
        LEButton2.Text = "Copy Discord Link"
        LEText2.Text = "Tap the button above to copy the link"
    end
end)

LEButton2.TouchTap:Connect(function()
    AnimateButton(LEButton2, 0.95)
    local DiscordLink = "https://discord.gg/NBdp4zuJtt"
    
    local success = CopyToClipboard(DiscordLink)
    
    if success then
        LEButton2.Text = "✓ Copied!"
        LEText2.Text = "✓ Link copied to clipboard!"
        task.wait(1.5)
        LEButton2.Text = "Copy Discord Link"
        LEText2.Text = "Open browser app and paste the link"
    else
        LEButton2.Text = "⚠️ Copy Failed"
        LEText2.Text = "Manual copy: " .. DiscordLink
        task.wait(2)
        LEButton2.Text = "Copy Discord Link"
        LEText2.Text = "Tap the button above to copy the link"
    end
end)

-- Menu system (Optimized for all devices)
local menuOpen = false
local MenuPanel = nil

local function CreateMenu()
    if menuOpen then
        if MenuPanel then MenuPanel:Destroy() end
        menuOpen = false
        return
    end
    
    MenuPanel = Instance.new("Frame")
    MenuPanel.Size = UDim2.new(0, 180, 0, 250)
    MenuPanel.Position = UDim2.new(0, 5, 0, TopBar.AbsoluteSize.Y + 5)
    MenuPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MenuPanel.BackgroundTransparency = 0.05
    MenuPanel.BorderSizePixel = 0
    MenuPanel.Parent = LEFrame3
    
    local MenuPanelCorner = Instance.new("UICorner")
    MenuPanelCorner.CornerRadius = UDim.new(0, 10)
    MenuPanelCorner.Parent = MenuPanel
    
    local MenuShadow = Instance.new("Frame")
    MenuShadow.Size = UDim2.new(1, 0, 1, 0)
    MenuShadow.Position = UDim2.new(0.02, 0, 0.02, 0)
    MenuShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MenuShadow.BackgroundTransparency = 0.5
    MenuShadow.BorderSizePixel = 0
    MenuShadow.ZIndex = -1
    MenuShadow.Parent = MenuPanel
    
    local menuItems = {
        {name = "Main (Default)", callback = function()
            MainContent.Visible = true
            MenuPanel:Destroy()
            menuOpen = false
        end}
    }
    
    for i, item in ipairs(menuItems) do
        local menuItem = Instance.new("TextButton")
        menuItem.Size = UDim2.new(0.95, 0, 0, 40)
        menuItem.Position = UDim2.new(0.025, 0, 0, (i-1) * 42)
        menuItem.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
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
        
        -- Hover effect
        menuItem.MouseEnter:Connect(function()
            TweenService:Create(menuItem, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        menuItem.MouseLeave:Connect(function()
            TweenService:Create(menuItem, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)
    end
    
    menuOpen = true
    
    -- Close menu when clicking outside
    local function closeMenu()
        if MenuPanel then
            MenuPanel:Destroy()
            menuOpen = false
        end
        UserInputService.InputBegan:Disconnect(closeConnection)
    end
    
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) then
            task.wait(0.1)
            closeMenu()
        end
    end)
end

MenuButton.MouseButton1Click:Connect(CreateMenu)
MenuButton.TouchTap:Connect(CreateMenu)

-- Resize for mobile devices
local function OptimizeForDevice()
    if UserInputService.TouchEnabled then
        -- Mobile optimization
        LEButton1.TextSize = 50
        Title.TextSize = 20
        CloseButton.TextSize = 18
        MenuButton.TextSize = 20
        LEButton2.TextSize = 16
        LEText2.TextSize = 14
        NoteText.TextSize = 12
    end
end

OptimizeForDevice()

print("✅ GUILEPanel Loaded Successfully on All Devices!")
