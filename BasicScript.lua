-- Load the Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "Movement Controller",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MovementConfig",
    IntroEnabled = true,
    IntroText = "Loading Movement Controller",
    IntroIcon = nil
})

-- Create Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = nil,
    PremiumOnly = false
})

-- Create Main Section
local MainSection = MainTab:AddSection({
    Name = "Movement Settings"
})

-- Function to get character safely
local function GetCharacter()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or character.Parent == nil then
        return nil
    end
    return character
end

-- WalkSpeed Slider
local WalkSpeedSlider = MainSection:AddSlider({
    Name = "WalkSpeed",
    Min = 1,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "studs/s",
    Callback = function(Value)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.WalkSpeed = Value
        end
    end    
})

-- JumpPower Slider
local JumpPowerSlider = MainSection:AddSlider({
    Name = "JumpPower",
    Min = 1,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "power",
    Callback = function(Value)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.JumpPower = Value
        end
    end    
})

-- Default WalkSpeed Button
local DefaultWalkSpeedButton = MainSection:AddButton({
    Name = "Default WalkSpeed",
    Callback = function()
        WalkSpeedSlider:Set(16)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.WalkSpeed = 16
        end
        OrionLib:MakeNotification({
            Name = "WalkSpeed Reset",
            Content = "WalkSpeed has been set to default (16)",
            Image = nil,
            Time = 3
        })
    end    
})

-- Default JumpPower Button
local DefaultJumpPowerButton = MainSection:AddButton({
    Name = "Default JumpPower",
    Callback = function()
        JumpPowerSlider:Set(50)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.JumpPower = 50
        end
        OrionLib:MakeNotification({
            Name = "JumpPower Reset",
            Content = "JumpPower has been set to default (50)",
            Image = nil,
            Time = 3
        })
    end    
})

-- Create Troll Tab
local TrollTab = Window:MakeTab({
    Name = "Troll",
    Icon = nil,
    PremiumOnly = false
})

-- Create Troll A Section
local TrollASection = TrollTab:AddSection({
    Name = "Troll A"
})

-- Variable to store username (saved)
local savedUsername = ""
local targetUsername = ""

-- Try to load saved username from config
local function LoadSavedUsername()
    local success, data = pcall(function()
        return readfile("UsernameSave.txt")
    end)
    if success and data then
        savedUsername = data
        targetUsername = savedUsername
        KillPlayerTextbox:Set(savedUsername)
    end
end

-- Save username to file
local function SaveUsername(username)
    if username ~= "" then
        pcall(function()
            writefile("UsernameSave.txt", username)
            savedUsername = username
        end)
    end
end

-- Extended Textbox for entering username
local KillPlayerTextbox = TrollASection:AddTextbox({
    Name = "Put Username (Click to edit)",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        targetUsername = Value
        if Value ~= "" then
            SaveUsername(Value)
        end
    end    
})

-- Load previously saved username
LoadSavedUsername()

-- Clear Button to reset the textbox
local ClearButton = TrollASection:AddButton({
    Name = "Clear Username",
    Callback = function()
        targetUsername = ""
        KillPlayerTextbox:Set("")
        pcall(function()
            writefile("UsernameSave.txt", "")
        end)
        OrionLib:MakeNotification({
            Name = "Cleared",
            Content = "Username has been cleared!",
            Image = nil,
            Time = 2
        })
    end    
})

-- Confirm Button to kill player
local ConfirmKillButton = TrollASection:AddButton({
    Name = "Confirm Button",
    Callback = function()
        if targetUsername == "" or targetUsername == nil then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please enter a username first!",
                Image = nil,
                Time = 3
            })
            return
        end
        
        -- Find the player
        local targetPlayer = nil
        for _, player in pairs(game.Players:GetPlayers()) do
            if string.lower(player.Name) == string.lower(targetUsername) or string.lower(player.DisplayName) == string.lower(targetUsername) then
                targetPlayer = player
                break
            end
        end
        
        if targetPlayer then
            -- Kill the player
            if targetPlayer.Character and targetPlayer.Character.Humanoid then
                targetPlayer.Character.Humanoid.Health = 0
                OrionLib:MakeNotification({
                    Name = "Killed",
                    Content = "You killed " .. targetPlayer.Name,
                    Image = nil,
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = targetPlayer.Name .. " does not have a character!",
                    Image = nil,
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player not found: " .. targetUsername,
                Image = nil,
                Time = 3
            })
        end
    end    
})

-- Create Floating Circle to open/close UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingButtonGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(0, 20, 0, 100)
floatingButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
floatingButton.BackgroundTransparency = 0
floatingButton.BorderSizePixels = 0
floatingButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
floatingButton.ImageTransparency = 1
floatingButton.Parent = screenGui

-- Add corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = floatingButton

-- Add a text label inside the button
local buttonText = Instance.new("TextLabel")
buttonText.Size = UDim2.new(1, 0, 1, 0)
buttonText.BackgroundTransparency = 1
buttonText.Text = "M"
buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonText.TextScaled = true
buttonText.Font = Enum.Font.GothamBold
buttonText.Parent = floatingButton

-- Make button draggable
local dragging = false
local dragStart
local startPos

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = floatingButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        floatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle UI when button is clicked
local uiVisible = true
floatingButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if uiVisible then
        OrionLib:Open()
        floatingButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    else
        OrionLib:Close()
        floatingButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Handle character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    -- Wait for humanoid to load
    character:WaitForChild("Humanoid")
    
    -- Re-apply current slider values
    local currentWalkSpeed = WalkSpeedSlider.Value
    local currentJumpPower = JumpPowerSlider.Value
    
    if currentWalkSpeed then
        character.Humanoid.WalkSpeed = currentWalkSpeed
    end
    
    if currentJumpPower then
        character.Humanoid.JumpPower = currentJumpPower
    end
end)

-- Initialize the UI
OrionLib:Init()

-- Auto-open UI to show it exists, then close after 2 seconds
task.wait(2)
OrionLib:Close()
