-- Frame Commander Script
-- Place this in a LocalScript inside StarterPlayerScripts or StarterGui

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create Main Frame
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrameCommanderGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 30)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -15)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Title Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LE CMD Delta"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamMedium
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = TitleBar

-- CMD Button (Hidden when closed)
local CMDButton = Instance.new("TextButton")
CMDButton.Name = "CMDButton"
CMDButton.Size = UDim2.new(0, 35, 0, 25)
CMDButton.Position = UDim2.new(0, 5, 0, 2.5)
CMDButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CMDButton.BorderSizePixel = 0
CMDButton.Text = "CMD"
CMDButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CMDButton.TextSize = 12
CMDButton.Font = Enum.Font.GothamBold
CMDButton.Visible = false
CMDButton.Parent = TitleBar

local CMDCorner = Instance.new("UICorner")
CMDCorner.CornerRadius = UDim.new(0, 4)
CMDCorner.Parent = CMDButton

-- Open Button (+)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 25, 0, 25)
OpenButton.Position = UDim2.new(1, -30, 0, 2.5)
OpenButton.BackgroundTransparency = 1
OpenButton.Text = "+"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 18
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Parent = TitleBar

-- Close Button (×) (Hidden when closed)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 2.5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Visible = false
CloseButton.Parent = TitleBar

-- Content Frame (Hidden when closed)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Visible = false
ContentFrame.Parent = MainFrame

-- Command History ScrollingFrame
local HistoryFrame = Instance.new("ScrollingFrame")
HistoryFrame.Name = "HistoryFrame"
HistoryFrame.Size = UDim2.new(1, -10, 1, -50)
HistoryFrame.Position = UDim2.new(0, 5, 0, 5)
HistoryFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
HistoryFrame.BorderSizePixel = 0
HistoryFrame.ScrollBarThickness = 6
HistoryFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
HistoryFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
HistoryFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
HistoryFrame.Parent = ContentFrame

local HistoryCorner = Instance.new("UICorner")
HistoryCorner.CornerRadius = UDim.new(0, 4)
HistoryCorner.Parent = HistoryFrame

-- History List (UIListLayout)
local HistoryList = Instance.new("UIListLayout")
HistoryList.Name = "HistoryList"
HistoryList.SortOrder = Enum.SortOrder.LayoutOrder
HistoryList.Padding = UDim.new(0, 2)
HistoryList.Parent = HistoryFrame

-- Command Entry Frame
local EntryFrame = Instance.new("Frame")
EntryFrame.Name = "EntryFrame"
EntryFrame.Size = UDim2.new(1, -10, 0, 35)
EntryFrame.Position = UDim2.new(0, 5, 1, -40)
EntryFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
EntryFrame.BorderSizePixel = 0
EntryFrame.Parent = ContentFrame

local EntryCorner = Instance.new("UICorner")
EntryCorner.CornerRadius = UDim.new(0, 4)
EntryCorner.Parent = EntryFrame

-- Command Input Box
local CommandBox = Instance.new("TextBox")
CommandBox.Name = "CommandBox"
CommandBox.Size = UDim2.new(1, -40, 1, 0)
CommandBox.Position = UDim2.new(0, 5, 0, 0)
CommandBox.BackgroundTransparency = 1
CommandBox.Text = ""
CommandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandBox.TextSize = 13
CommandBox.Font = Enum.Font.Gotham
CommandBox.ClearTextOnFocus = false
CommandBox.PlaceholderText = "Enter Command Here..."
CommandBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
CommandBox.Parent = EntryFrame

-- Execute Button (√)
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(0, 30, 1, 0)
ExecuteButton.Position = UDim2.new(1, -35, 0, 0)
ExecuteButton.BackgroundTransparency = 1
ExecuteButton.Text = "√"
ExecuteButton.TextColor3 = Color3.fromRGB(100, 255, 100)
ExecuteButton.TextSize = 18
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.Parent = EntryFrame

-- Command Popup (CMD Menu)
local PopupFrame = Instance.new("Frame")
PopupFrame.Name = "PopupFrame"
PopupFrame.Size = UDim2.new(0, 200, 0, 250)
PopupFrame.Position = UDim2.new(0, 5, 0, 35)
PopupFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
PopupFrame.BorderSizePixel = 0
PopupFrame.Visible = false
PopupFrame.Parent = TitleBar

local PopupCorner = Instance.new("UICorner")
PopupCorner.CornerRadius = UDim.new(0, 6)
PopupCorner.Parent = PopupFrame

local PopupShadow = Instance.new("Frame")
PopupShadow.Name = "PopupShadow"
PopupShadow.Size = UDim2.new(1, 0, 1, 0)
PopupShadow.Position = UDim2.new(0, 0, 0, 0)
PopupShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PopupShadow.BackgroundTransparency = 0.5
PopupShadow.BorderSizePixel = 0
PopupShadow.Parent = PopupFrame

local PopupShadowCorner = Instance.new("UICorner")
PopupShadowCorner.CornerRadius = UDim.new(0, 6)
PopupShadowCorner.Parent = PopupShadow

local PopupList = Instance.new("ScrollingFrame")
PopupList.Name = "PopupList"
PopupList.Size = UDim2.new(1, -10, 1, -10)
PopupList.Position = UDim2.new(0, 5, 0, 5)
PopupList.BackgroundTransparency = 1
PopupList.BorderSizePixel = 0
PopupList.ScrollBarThickness = 4
PopupList.CanvasSize = UDim2.new(0, 0, 0, 0)
PopupList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PopupList.Parent = PopupFrame

local PopupListLayout = Instance.new("UIListLayout")
PopupListLayout.Name = "PopupListLayout"
PopupListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PopupListLayout.Padding = UDim.new(0, 2)
PopupListLayout.Parent = PopupList

-- Command definitions
local Commands = {
	{cmd = "/walkspeed <value>", desc = "Set walk speed"},
	{cmd = "/walkspeed default", desc = "Reset walk speed"},
	{cmd = "/jumppower <value>", desc = "Set jump power"},
	{cmd = "/jumppower default", desc = "Reset jump power"},
	{cmd = "/users", desc = "List all players"},
	{cmd = "/help", desc = "Show this help"},
	{cmd = "/clear", desc = "Clear command history"},
}

-- History storage
local CommandHistory = {}
local MAX_VISIBLE = 10

-- State
local isOpen = false
local isAnimating = false

-- Dragging variables
local isDragging = false
local dragStart = nil
local startPos = nil

-- Functions
local function AddCommandToHistory(command)
	table.insert(CommandHistory, command)
	
	local label = Instance.new("TextLabel")
	label.Name = "HistoryItem"
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = "> " .. command
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = HistoryFrame
	
	-- Update canvas
	HistoryFrame.CanvasSize = UDim2.new(0, 0, 0, #CommandHistory * 22)
	
	-- Auto-scroll to bottom
	RunService.Heartbeat:Wait()
	HistoryFrame.CanvasPosition = Vector2.new(0, HistoryFrame.CanvasSize.Y.Offset)
end

local function ClearHistory()
	for _, child in ipairs(HistoryFrame:GetChildren()) do
		if child:IsA("TextLabel") and child.Name == "HistoryItem" then
			child:Destroy()
		end
	end
	CommandHistory = {}
	HistoryFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function ExecuteCommand(input)
	local cmd = string.lower(string.gsub(input, "^%s*(.-)%s*$", "%1")) -- Trim
	
	if cmd == "" then return end
	
	AddCommandToHistory(cmd)
	
	-- Parse and execute commands
	local parts = {}
	for word in string.gmatch(cmd, "%S+") do
		table.insert(parts, word)
	end
	
	local command = parts[1]
	
	if command == "/walkspeed" then
		if parts[2] == "default" then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.WalkSpeed = 16
			end
		elseif parts[2] and tonumber(parts[2]) then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.WalkSpeed = tonumber(parts[2])
			end
		else
			AddCommandToHistory("Usage: /walkspeed <value> or /walkspeed default")
		end
	elseif command == "/jumppower" then
		if parts[2] == "default" then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.JumpPower = 50
			end
		elseif parts[2] and tonumber(parts[2]) then
			if Player.Character and Player.Character:FindFirstChild("Humanoid") then
				Player.Character.Humanoid.JumpPower = tonumber(parts[2])
			end
		else
			AddCommandToHistory("Usage: /jumppower <value> or /jumppower default")
		end
	elseif command == "/users" then
		local players = Players:GetPlayers()
		local names = {}
		for _, p in ipairs(players) do
			table.insert(names, p.Name)
		end
		AddCommandToHistory("Players: " .. table.concat(names, ", "))
	elseif command == "/help" then
		AddCommandToHistory("Available Commands:")
		for _, data in ipairs(Commands) do
			AddCommandToHistory("  " .. data.cmd .. " - " .. data.desc)
		end
	elseif command == "/clear" then
		ClearHistory()
	else
		AddCommandToHistory("Unknown command. Type /help for list.")
	end
	
	CommandBox.Text = ""
end

-- Popup functions
local function BuildPopup()
	-- Clear existing
	for _, child in ipairs(PopupList:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	for _, data in ipairs(Commands) do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -10, 0, 20)
		label.BackgroundTransparency = 1
		label.Text = data.cmd
		label.TextColor3 = Color3.fromRGB(200, 200, 210)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = PopupList
		
		-- Add description as tooltip (or just smaller text)
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -10, 0, 14)
		descLabel.Position = UDim2.new(0, 5, 0, 18)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = data.desc
		descLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
		descLabel.TextSize = 10
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = label
	end
	
	PopupList.CanvasSize = UDim2.new(0, 0, 0, #Commands * 36)
end

-- Toggle popup and execute /help
local function TogglePopup()
	if PopupFrame.Visible then
		PopupFrame.Visible = false
	else
		PopupFrame.Visible = true
		BuildPopup()
		-- Auto execute /help command
		ExecuteCommand("/help")
	end
end

-- Animation functions
local function OpenFrame()
	if isOpen or isAnimating then return end
	isAnimating = true
	
	-- Show content
	ContentFrame.Visible = true
	CMDButton.Visible = true
	CloseButton.Visible = true
	OpenButton.Visible = false
	
	-- Hide popup if visible
	PopupFrame.Visible = false
	
	-- Animate
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {Size = UDim2.new(0, 500, 0, 300)}
	local tween = TweenService:Create(MainFrame, tweenInfo, goal)
	tween:Play()
	tween.Completed:Connect(function()
		isOpen = true
		isAnimating = false
	end)
end

local function CloseFrame()
	if not isOpen or isAnimating then return end
	isAnimating = true
	
	-- Hide popup
	PopupFrame.Visible = false
	
	-- Animate
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {Size = UDim2.new(0, 300, 0, 30)}
	local tween = TweenService:Create(MainFrame, tweenInfo, goal)
	tween:Play()
	tween.Completed:Connect(function()
		ContentFrame.Visible = false
		CMDButton.Visible = false
		CloseButton.Visible = false
		OpenButton.Visible = true
		isOpen = false
		isAnimating = false
	end)
end

-- Dragging functions
local function StartDrag(input)
	if isAnimating then return end
	isDragging = true
	dragStart = input.Position
	startPos = MainFrame.Position
end

local function UpdateDrag(input)
	if not isDragging or isAnimating then return end
	
	local delta = input.Position - dragStart
	local newPos = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
	
	-- Keep within screen bounds
	local screenSize = Player:GetMouse().ViewSizeX or 1920
	local frameSize = MainFrame.AbsoluteSize
	local maxX = screenSize - frameSize.X
	local maxY = (Player:GetMouse().ViewSizeY or 1080) - 30
	
	newPos = UDim2.new(
		0,
		math.clamp(newPos.X.Offset, 0, maxX),
		0,
		math.clamp(newPos.Y.Offset, 0, maxY)
	)
	
	MainFrame.Position = newPos
end

local function StopDrag()
	isDragging = false
	dragStart = nil
	startPos = nil
end

-- Click functions
OpenButton.MouseButton1Click:Connect(OpenFrame)
CloseButton.MouseButton1Click:Connect(CloseFrame)
CMDButton.MouseButton1Click:Connect(TogglePopup)

-- Execute command on button click
ExecuteButton.MouseButton1Click:Connect(function()
	local input = CommandBox.Text
	ExecuteCommand(input)
end)

-- Execute command on Enter key
CommandBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local input = CommandBox.Text
		ExecuteCommand(input)
	end
end)

-- Drag events on TitleBar
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		StartDrag(input)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		UpdateDrag(input)
	end
end)

TitleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		StopDrag()
	end
end)

-- Also allow dragging on MainFrame (but not on buttons)
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Check if click is on a button
		local target = input.Position
		local buttons = {OpenButton, CloseButton, CMDButton, ExecuteButton}
		for _, btn in ipairs(buttons) do
			if btn.Visible then
				local absPos = btn.AbsolutePosition
				local absSize = btn.AbsoluteSize
				if target.X >= absPos.X and target.X <= absPos.X + absSize.X and
				   target.Y >= absPos.Y and target.Y <= absPos.Y + absSize.Y then
					return -- Don't drag if clicking a button
				end
			end
		end
		StartDrag(input)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		UpdateDrag(input)
	end
end)

MainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		StopDrag()
	end
end)

-- Close popup when clicking outside
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if PopupFrame.Visible then
			local mousePos = UserInputService:GetMouseLocation()
			local popupPos = PopupFrame.AbsolutePosition
			local popupSize = PopupFrame.AbsoluteSize
			
			-- Check if click is inside popup
			if mousePos.X < popupPos.X or mousePos.X > popupPos.X + popupSize.X or
			   mousePos.Y < popupPos.Y or mousePos.Y > popupPos.Y + popupSize.Y then
				PopupFrame.Visible = false
			end
		end
	end
end)

-- Initialize history with welcome message
AddCommandToHistory("LE CMD Delta loaded. Type /help for commands.")

-- Set initial state (closed)
MainFrame.Size = UDim2.new(0, 300, 0, 30)
ContentFrame.Visible = false
CMDButton.Visible = false
CloseButton.Visible = false
OpenButton.Visible = true

print("LE CMD Delta loaded successfully!")
