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

-- Variable to store username
local targetUsername = ""

-- Textbox for entering username
local KillPlayerTextbox = TrollASection:AddTextbox({
    Name = "Put Username",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        targetUsername = Value
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
            -- Kill the player by removing their character or setting health to 0
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
        
        -- Clear the textbox
        targetUsername = ""
        KillPlayerTextbox:Set("")
    end    
})

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
