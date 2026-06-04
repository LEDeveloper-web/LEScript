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
    IntroIcon = "rbxassetid://4483345998"
})

-- Create Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Create Main Section
local MainSection = MainTab:AddSection({
    Name = "Movement Settings"
})

-- WalkSpeed Slider
local WalkSpeedSlider = MainSection:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "studs/s",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

-- JumpPower Slider
local JumpPowerSlider = MainSection:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "power",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end    
})

-- Default WalkSpeed Button
local DefaultWalkSpeedButton = MainSection:AddButton({
    Name = "Default WalkSpeed",
    Callback = function()
        WalkSpeedSlider:Set(16)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        OrionLib:MakeNotification({
            Name = "WalkSpeed Reset",
            Content = "WalkSpeed has been set to default (16)",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- Default JumpPower Button
local DefaultJumpPowerButton = MainSection:AddButton({
    Name = "Default JumpPower",
    Callback = function()
        JumpPowerSlider:Set(50)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        OrionLib:MakeNotification({
            Name = "JumpPower Reset",
            Content = "JumpPower has been set to default (50)",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- Initialize the UI
OrionLib:Init()
