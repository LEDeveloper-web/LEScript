local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LE Basic Executed",
   Icon = 0,
   LoadingTitle = "LE Basic Executed",
   LoadingSubtitle = "by LEModz",
   ShowText = "LEModz",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LEBasicExecuted",
      FileName = "LEBasicExecuted"
   },

   Discord = {
      Enabled = true,
      Invite = "NBdp4zuJtt",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LE Basic Executed",
      Subtitle = "Enter License Key",
      Note = "Join our Discord to get a key: discord.gg/NBdp4zuJtt",
      FileName = "LEBasicKey",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/kiQUiJhe"}
   }
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

-- ============= MAIN TAB =============
local MainTab = Window:CreateTab("Main", nil)

local MovementSection = MainTab:CreateSection("Movement Settings")

-- WalkSpeed Slider
local WalkSpeedSlider = MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {1, 100},
   Increment = 1,
   Suffix = "studs/s",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.WalkSpeed = Value
        end
   end
})

-- JumpPower Slider
local JumpPowerSlider = MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {1, 200},
   Increment = 1,
   Suffix = "power",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.JumpPower = Value
        end
   end
})

local ResetSection = MainTab:CreateSection("Reset Options")

-- Default WalkSpeed Button
local DefaultWalkSpeedButton = MainTab:CreateButton({
   Name = "Default WalkSpeed (16)",
   Callback = function()
        WalkSpeedSlider.CurrentValue = 16
        WalkSpeedSlider:SetValue(16)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.WalkSpeed = 16
        end
        Rayfield:Notify({
            Title = "WalkSpeed Reset",
            Content = "WalkSpeed has been set to default (16)",
            Duration = 3,
            Image = nil
        })
   end
})

-- Default JumpPower Button
local DefaultJumpPowerButton = MainTab:CreateButton({
   Name = "Default JumpPower (50)",
   Callback = function()
        JumpPowerSlider.CurrentValue = 50
        JumpPowerSlider:SetValue(50)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.JumpPower = 50
        end
        Rayfield:Notify({
            Title = "JumpPower Reset",
            Content = "JumpPower has been set to default (50)",
            Duration = 3,
            Image = nil
        })
   end
})

-- ============= FLY SETTINGS =============
local FlySection = MainTab:CreateSection("Fly Settings")

-- Fly Variables
local flying = false
local flySpeed = 16
local noclipEnabled = false
local bodyVelocity = nil
local bodyGyro = nil
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Fly Functions
local function startFly(speed, noclip)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e10, 1e10, 1e10)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e10, 1e10, 1e10)
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp
    end
    
    flying = true
    humanoid.PlatformStand = true
end

local function updateFlyDirection(speed)
    if not flying then return end
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = camera.CFrame.UpVector
    
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + up
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDirection = moveDirection - up
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    
    if bodyVelocity then
        bodyVelocity.Velocity = moveDirection * speed
    end
    if bodyGyro then
        bodyGyro.CFrame = camera.CFrame
    end
end

local function stopFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        if noclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    
    flying = false
end

-- Fly input handler for Q key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not flying then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        stopFly()
        flying = false
        if FlyToggle then FlyToggle.CurrentValue = false end
    end
end)

-- Fly update loop
game:GetService("RunService").RenderStepped:Connect(function()
    if flying then
        updateFlyDirection(flySpeed)
    end
end)

-- Fly Speed Slider
local FlySpeedSlider = MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {1, 50},
   Increment = 1,
   Suffix = "speed",
   CurrentValue = 16,
   Flag = "FlySpeed",
   Callback = function(Value)
        flySpeed = Value
   end
})

-- Fly Toggle
local FlyToggle = MainTab:CreateToggle({
   Name = "Fly - ON/OFF",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
        if Value then
            startFly(flySpeed, noclipEnabled)
            Rayfield:Notify({
                Title = "Fly Enabled",
                Content = "Press Q to stop flying",
                Duration = 3,
                Image = nil
            })
        else
            stopFly()
        end
   end
})

-- Fly Noclip Toggle
local FlyNoclipToggle = MainTab:CreateToggle({
   Name = "Fly Noclip - ON/OFF",
   CurrentValue = false,
   Flag = "FlyNoclip",
   Callback = function(Value)
        noclipEnabled = Value
        if flying then
            local wasFlying = flying
            if wasFlying then
                stopFly()
                startFly(flySpeed, noclipEnabled)
            end
        end
        local status = Value and "enabled" or "disabled"
        Rayfield:Notify({
            Title = "Noclip",
            Content = "Noclip " .. status,
            Duration = 2,
            Image = nil
        })
   end
})

-- Fly Controls Label
local FlyInfo = MainTab:CreateLabel({
    Name = "Controls: WASD - Move | Space - Up | Ctrl - Down | Q - Stop"
})

-- ============= TROLL TAB =============
local TrollTab = Window:CreateTab("Troll", nil)

-- Troll A Section - Kill Player
local TrollASection = TrollTab:CreateSection("Troll A - Kill Player")

-- Variables for username
local savedUsername = ""
local targetUsername = ""

-- Load saved username
local function LoadSavedUsername()
    local success, data = pcall(function()
        return readfile("UsernameSave.txt")
    end)
    if success and data then
        savedUsername = data
        targetUsername = savedUsername
        KillPlayerTextbox.CurrentValue = savedUsername
    end
end

-- Save username
local function SaveUsername(username)
    if username ~= "" then
        pcall(function()
            writefile("UsernameSave.txt", username)
            savedUsername = username
        end)
    end
end

-- Username Input
local KillPlayerTextbox = TrollTab:CreateInput({
   Name = "Target Username",
   CurrentValue = "",
   PlaceholderText = "Enter username here...",
   RemoveTextAfterFocusLost = false,
   Flag = "TargetUsername",
   Callback = function(Text)
        targetUsername = Text
        if Text ~= "" then
            SaveUsername(Text)
        end
   end
})

-- Clear Username Button
local ClearButton = TrollTab:CreateButton({
   Name = "Clear Username",
   Callback = function()
        targetUsername = ""
        KillPlayerTextbox.CurrentValue = ""
        pcall(function()
            writefile("UsernameSave.txt", "")
        end)
        Rayfield:Notify({
            Title = "Cleared",
            Content = "Username has been cleared!",
            Duration = 2,
            Image = nil
        })
   end
})

-- Kill Confirm Button
local ConfirmKillButton = TrollTab:CreateButton({
   Name = "Kill Player",
   Callback = function()
        if targetUsername == "" or targetUsername == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a username first!",
                Duration = 3,
                Image = nil
            })
            return
        end
        
        local targetPlayer = nil
        for _, player in pairs(game.Players:GetPlayers()) do
            if string.lower(player.Name) == string.lower(targetUsername) or string.lower(player.DisplayName) == string.lower(targetUsername) then
                targetPlayer = player
                break
            end
        end
        
        if targetPlayer then
            if targetPlayer.Character and targetPlayer.Character.Humanoid then
                targetPlayer.Character.Humanoid.Health = 0
                Rayfield:Notify({
                    Title = "Killed",
                    Content = "You killed " .. targetPlayer.Name,
                    Duration = 3,
                    Image = nil
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = targetPlayer.Name .. " does not have a character!",
                    Duration = 3,
                    Image = nil
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Player not found: " .. targetUsername,
                Duration = 3,
                Image = nil
            })
        end
   end
})

-- Troll B Section - Hand Item
local TrollBSection = TrollTab:CreateSection("Troll B - Hand Item (Model ID)")

-- Variables for hand item
local currentItem = nil
local itemConnection = nil
local character = player.Character or player.CharacterAdded:Wait()

-- Function to clear hand item
local function clearHandItem()
    if itemConnection then
        itemConnection:Disconnect()
        itemConnection = nil
    end
    
    if currentItem then
        currentItem:Destroy()
        currentItem = nil
    end
    
    local char = player.Character
    if char then
        local existingItem = char:FindFirstChild("HeldItem")
        if existingItem then
            existingItem:Destroy()
        end
    end
end

-- Function to equip hand item
local function equipHandItem(modelId)
    clearHandItem()
    
    local char = player.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    local rightHand = char:FindFirstChild("RightHand")
    if not rightHand then
        repeat
            task.wait()
            rightHand = char:FindFirstChild("RightHand")
        until rightHand
    end
    
    local success, model = pcall(function()
        return game:GetService("InsertService"):LoadAsset(modelId)
    end)
    
    if not success or not model then
        return false
    end
    
    local itemPart = nil
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            itemPart = child
            break
        end
    end
    
    if not itemPart then
        model:Destroy()
        return false
    end
    
    currentItem = itemPart:Clone()
    currentItem.Name = "HeldItem"
    currentItem.Size = Vector3.new(1, 1, 2)
    currentItem.CanCollide = false
    currentItem.Anchored = false
    currentItem.Parent = char
    
    local weld = Instance.new("Weld")
    weld.Part0 = rightHand
    weld.Part1 = currentItem
    weld.C0 = CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, 0)
    weld.Parent = currentItem
    
    model:Destroy()
    
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = currentItem
    clickDetector.MaxActivationDistance = 10
    
    clickDetector.MouseClick:Connect(function(clicker)
        if clicker and clicker.Parent then
            local targetHumanoid = clicker.Parent:FindFirstChild("Humanoid")
            if targetHumanoid then
                targetHumanoid.Health = 0
                Rayfield:Notify({
                    Title = "Item Used",
                    Content = "You killed " .. clicker.Parent.Name .. " with the item!",
                    Duration = 2,
                    Image = nil
                })
            end
        end
    end)
    
    if itemConnection then itemConnection:Disconnect() end
    itemConnection = player.CharacterAdded:Connect(function(newChar)
        character = newChar
        if currentItem then
            task.wait(0.5)
            local newRightHand = newChar:FindFirstChild("RightHand")
            if newRightHand and currentItem then
                currentItem.Parent = newChar
                local newWeld = Instance.new("Weld")
                newWeld.Part0 = newRightHand
                newWeld.Part1 = currentItem
                newWeld.C0 = CFrame.new(0, -0.5, 0)
                newWeld.Parent = currentItem
            end
        end
    end)
    
    return true
end

-- Model ID Input
local ModelIDInput = TrollTab:CreateInput({
   Name = "Model ID",
   CurrentValue = "",
   PlaceholderText = "Enter Model ID (e.g., 1234567890)",
   RemoveTextAfterFocusLost = false,
   Flag = "ModelID",
   Callback = function(Text)
        -- Store for confirm button
   end
})

-- Equip Item Button
local ConfirmModelButton = TrollTab:CreateButton({
   Name = "Equip Item in Hand",
   Callback = function()
        local modelId = ModelIDInput.CurrentValue
        if modelId == "" or modelId == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a Model ID first!",
                Duration = 3,
                Image = nil
            })
            return
        end
        
        local numId = tonumber(modelId)
        if not numId then
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid Model ID! Please enter a number.",
                Duration = 3,
                Image = nil
            })
            return
        end
        
        local success = equipHandItem(numId)
        if success then
            Rayfield:Notify({
                Title = "Item Equipped",
                Content = "Item equipped! Click on players to kill them.",
                Duration = 4,
                Image = nil
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to load model. Check if Model ID is valid.",
                Duration = 3,
                Image = nil
            })
        end
   end
})

-- Clear Item Button
local ClearItemButton = TrollTab:CreateButton({
   Name = "Clear Hand Item",
   Callback = function()
        clearHandItem()
        Rayfield:Notify({
            Title = "Item Cleared",
            Content = "Hand item has been removed.",
            Duration = 2,
            Image = nil
        })
   end
})

-- Example IDs Label
local ExampleInfo = TrollTab:CreateLabel({
    Name = "Example IDs: 1234567890 (Sword), 9876543210 (Gun)"
})

-- ============= SETTINGS TAB =============
local SettingsTab = Window:CreateTab("Settings", nil)

local UISettingsSection = SettingsTab:CreateSection("UI Settings")

-- Theme Dropdown
local ThemeDropdown = SettingsTab:CreateDropdown({
   Name = "Theme",
   Options = {"Default", "Dark", "Light", "Midnight", "Ocean", "Sunset"},
   CurrentOption = {"Default"},
   MultipleOptions = false,
   Flag = "Theme",
   Callback = function(Options)
        Rayfield:ChangeTheme(Options[1])
        Rayfield:Notify({
            Title = "Theme Changed",
            Content = "Theme set to: " .. Options[1],
            Duration = 2,
            Image = nil
        })
   end
})

-- UI Toggle Button
local UIToggleButton = SettingsTab:CreateButton({
   Name = "Toggle UI",
   Callback = function()
        Rayfield:Toggle()
   end
})

-- Info Label
local InfoLabel = SettingsTab:CreateLabel({
    Name = "LE Basic Executed v1.0.0 | Library: Rayfield | Controls: K - Toggle UI | Q - Stop flying"
})

-- ============= FLOATING BUTTON =============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingButtonGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, 50, 0, 50)
floatingButton.Position = UDim2.new(0, 20, 0, 100)
floatingButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
floatingButton.BackgroundTransparency = 0
floatingButton.BorderSizePixel = 0
floatingButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
floatingButton.ImageTransparency = 1
floatingButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = floatingButton

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

local uiVisible = true
floatingButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    if uiVisible then
        Rayfield:Open()
        floatingButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    else
        Rayfield:Close()
        floatingButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Load saved username on startup
LoadSavedUsername()

-- Welcome notification
Rayfield:Notify({
   Title = "LE Basic Executed",
   Content = "Script loaded! Press K to toggle UI. Join discord.gg/NBdp4zuJtt for keys.",
   Duration = 8,
   Image = nil
})

-- Auto-close UI after 2 seconds
task.wait(2)
Rayfield:Close()
