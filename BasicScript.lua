-- Load the Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the Window
local Window = Rayfield:CreateWindow({
    Name = "LE Basic Executed",
    Icon = nil,
    LoadingTitle = "Executed Script",
    LoadingSubtitle = "Loading...",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MovementConfig",
        FileName = "MovementConfig"
    },
    DragSettings = {
        Enabled = true,
        Locked = false
    },
    Keybind = {
        Enabled = false
    }
})

-- Create Main Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = nil
})

-- Create Main Section
local MainSection = MainTab:CreateSection({
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
local WalkSpeedSlider = MainSection:CreateSlider({
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
local JumpPowerSlider = MainSection:CreateSlider({
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

-- Fly Section
local FlySection = MainTab:CreateSection({
    Name = "Fly Settings"
})

-- Fly Variables
local flying = false
local flySpeed = 1
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
        if FlyToggle then FlyToggle:SetValue(false) end
    end
end)

-- Fly update loop
game:GetService("RunService").RenderStepped:Connect(function()
    if flying then
        updateFlyDirection(flySpeed)
    end
end)

-- Fly Speed Slider
local FlySpeedSlider = FlySection:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 10},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 1,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
        if flying then
            -- Speed will be applied in update loop
        end
    end
})

-- Fly Toggle
local FlyToggle = FlySection:CreateToggle({
    Name = "Fly - ON/OFF",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value then
            startFly(flySpeed, noclipEnabled)
            Rayfield:Notify({
                Title = "Fly",
                Content = "Fly enabled! Press Q to stop.",
                Duration = 3
            })
        else
            stopFly()
        end
    end
})

-- Fly Noclip Toggle
local FlyNoclipToggle = FlySection:CreateToggle({
    Name = "Fly Noclip - ON/OFF",
    CurrentValue = false,
    Flag = "FlyNoclip",
    Callback = function(Value)
        noclipEnabled = Value
        if flying then
            -- Restart fly with new noclip setting
            local wasFlying = flying
            if wasFlying then
                stopFly()
                startFly(flySpeed, noclipEnabled)
            end
        end
        if Value then
            Rayfield:Notify({
                Title = "Noclip",
                Content = "Noclip enabled! You can fly through walls.",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Noclip",
                Content = "Noclip disabled! Collision restored.",
                Duration = 2
            })
        end
    end
})

-- Default WalkSpeed Button
local DefaultWalkSpeedButton = MainSection:CreateButton({
    Name = "Default WalkSpeed",
    Callback = function()
        WalkSpeedSlider:SetValue(16)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.WalkSpeed = 16
        end
        Rayfield:Notify({
            Title = "WalkSpeed Reset",
            Content = "WalkSpeed has been set to default (16)",
            Duration = 3
        })
    end
})

-- Default JumpPower Button
local DefaultJumpPowerButton = MainSection:CreateButton({
    Name = "Default JumpPower",
    Callback = function()
        JumpPowerSlider:SetValue(50)
        local character = GetCharacter()
        if character and character.Humanoid then
            character.Humanoid.JumpPower = 50
        end
        Rayfield:Notify({
            Title = "JumpPower Reset",
            Content = "JumpPower has been set to default (50)",
            Duration = 3
        })
    end
})

-- Create Troll Tab
local TrollTab = Window:CreateTab({
    Name = "Troll",
    Icon = nil
})

-- Create Troll A Section
local TrollASection = TrollTab:CreateSection({
    Name = "Troll A - Kill Player"
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
        KillPlayerTextbox:SetValue(savedUsername)
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
local KillPlayerTextbox = TrollASection:CreateInput({
    Name = "Put Username",
    PlaceholderText = "Enter username here...",
    RemoveTextAfterFocusLost = false,
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
local ClearButton = TrollASection:CreateButton({
    Name = "Clear Username",
    Callback = function()
        targetUsername = ""
        KillPlayerTextbox:SetValue("")
        pcall(function()
            writefile("UsernameSave.txt", "")
        end)
        Rayfield:Notify({
            Title = "Cleared",
            Content = "Username has been cleared!",
            Duration = 2
        })
    end
})

-- Confirm Button to kill player
local ConfirmKillButton = TrollASection:CreateButton({
    Name = "Confirm Button",
    Callback = function()
        if targetUsername == "" or targetUsername == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a username first!",
                Duration = 3
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
                Rayfield:Notify({
                    Title = "Killed",
                    Content = "You killed " .. targetPlayer.Name,
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = targetPlayer.Name .. " does not have a character!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Player not found: " .. targetUsername,
                Duration = 3
            })
        end
    end
})

-- ============= TROLL B SECTION - MODEL ID (HAND ITEM) =============
local TrollBSection = TrollTab:CreateSection({
    Name = "Troll B - Hand Item (Model ID)"
})

-- Variables for hand item
local currentItem = nil
local itemConnection = nil
local character = player.Character or player.CharacterAdded:Wait()

-- Function to clear current hand item
local function clearHandItem()
    if itemConnection then
        itemConnection:Disconnect()
        itemConnection = nil
    end
    
    if currentItem then
        currentItem:Destroy()
        currentItem = nil
    end
    
    -- Also try to remove from character
    local char = player.Character
    if char then
        local existingItem = char:FindFirstChild("HeldItem")
        if existingItem then
            existingItem:Destroy()
        end
    end
end

-- Function to equip item in hand
local function equipHandItem(modelId)
    -- Clear any existing item
    clearHandItem()
    
    local char = player.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    local rightHand = char:FindFirstChild("RightHand")
    if not rightHand then
        -- Wait for right hand to load
        repeat
            task.wait()
            rightHand = char:FindFirstChild("RightHand")
        until rightHand
    end
    
    -- Load the model
    local success, model = pcall(function()
        return game:GetService("InsertService"):LoadAsset(modelId)
    end)
    
    if not success or not model then
        return false
    end
    
    -- Find a part to use as the held item
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
    
    -- Clone and setup the item
    currentItem = itemPart:Clone()
    currentItem.Name = "HeldItem"
    currentItem.Size = Vector3.new(1, 1, 2)
    currentItem.CanCollide = false
    currentItem.Anchored = false
    currentItem.Parent = char
    
    -- Create weld to attach to hand
    local weld = Instance.new("Weld")
    weld.Part0 = rightHand
    weld.Part1 = currentItem
    weld.C0 = CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, 0)
    weld.Parent = currentItem
    
    model:Destroy()
    
    -- Add click function to item
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
                    Duration = 2
                })
            end
        end
    end)
    
    -- Handle character respawn
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
local ModelIDInput = TrollBSection:CreateInput({
    Name = "Model ID",
    PlaceholderText = "Enter Model ID (e.g., 1234567890)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        -- Store for confirm button
    end
})

-- Confirm Button for Model ID
local ConfirmModelButton = TrollBSection:CreateButton({
    Name = "Equip Item in Hand",
    Callback = function()
        local modelId = ModelIDInput.Value
        if modelId == "" or modelId == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a Model ID first!",
                Duration = 3
            })
            return
        end
        
        -- Convert to number if possible
        local numId = tonumber(modelId)
        if not numId then
            Rayfield:Notify({
                Title = "Error",
                Content = "Invalid Model ID! Please enter a number.",
                Duration = 3
            })
            return
        end
        
        local success = equipHandItem(numId)
        if success then
            Rayfield:Notify({
                Title = "Item Equipped",
                Content = "Item has been equipped in your hand! Click on players to kill them.",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to load model. Check if Model ID is valid.",
                Duration = 3
            })
        end
    end
})

-- Clear Item Button
local ClearItemButton = TrollBSection:CreateButton({
    Name = "Clear Hand Item",
    Callback = function()
        clearHandItem()
        Rayfield:Notify({
            Title = "Item Cleared",
            Content = "Hand item has been removed.",
            Duration = 2
        })
    end
})

-- Example Model IDs Info
local ExampleInfo = TrollBSection:CreateLabel({
    Name = "Example Model IDs: 1234567890 (Sword), 9876543210 (Gun)"
})

-- ============= END OF TROLL B SECTION =============

-- Create Floating Circle to open/close UI
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
        Rayfield:Open()
        floatingButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    else
        Rayfield:Close()
        floatingButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

-- Handle character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    -- Wait for humanoid to load
    character:WaitForChild("Humanoid")
    
    -- Re-apply current slider values
    local currentWalkSpeed = WalkSpeedSlider.CurrentValue
    local currentJumpPower = JumpPowerSlider.CurrentValue
    
    if currentWalkSpeed then
        character.Humanoid.WalkSpeed = currentWalkSpeed
    end
    
    if currentJumpPower then
        character.Humanoid.JumpPower = currentJumpPower
    end
    
    -- If fly was enabled before respawn, restart it
    if FlyToggle.CurrentValue then
        task.wait(0.5)
        startFly(flySpeed, noclipEnabled)
    end
    
    -- If there was a hand item, re-equip it
    if currentItem then
        task.wait(0.5)
        local newRightHand = character:FindFirstChild("RightHand")
        if newRightHand and currentItem then
            currentItem.Parent = character
            local newWeld = Instance.new("Weld")
            newWeld.Part0 = newRightHand
            newWeld.Part1 = currentItem
            newWeld.C0 = CFrame.new(0, -0.5, 0)
            newWeld.Parent = currentItem
        end
    end
end)

-- Auto-open UI to show it exists, then close after 2 seconds
task.wait(2)
Rayfield:Close()

-- Notify that script loaded successfully
Rayfield:Notify({
    Title = "LE Basic Executed",
    Content = "Script loaded successfully!",
    Duration = 3
})
