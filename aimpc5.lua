local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- File system setup
local FolderName = "kkavasakisaimbot"
local FileName = "notice_accepted.txt"
local ConfigFile = "config.json"

-- Check if file system is available
local function checkAcceptanceFile()
	if not isfolder then return false end
	if not isfolder(FolderName) then makefolder(FolderName) end
	if isfile(FolderName .. "/" .. FileName) then return true end
	return false
end

-- Save acceptance to file
local function saveAcceptance()
	if not writefile then return end
	if not isfolder(FolderName) then makefolder(FolderName) end
	writefile(FolderName .. "/" .. FileName, "Notice accepted by " .. LocalPlayer.Name .. " on " .. os.date("%Y-%m-%d %H:%M:%S"))
end

-- Load config
local function loadConfig()
	if not isfile or not readfile then return nil end
	if isfile(FolderName .. "/" .. ConfigFile) then
		local success, result = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile(FolderName .. "/" .. ConfigFile))
		end)
		if success then return result end
	end
	return nil
end

-- Save config
local function saveConfig()
	if not writefile then return end
	if not isfolder(FolderName) then makefolder(FolderName) end
	local data = {
		FOV = Config.FOV,
		Smoothness = Config.Smoothness,
		TargetPart = Config.TargetPart,
		TeamCheck = Config.TeamCheck,
		ShowFOV = Config.ShowFOV,
		FOVColor = {Config.FOVColor.R, Config.FOVColor.G, Config.FOVColor.B},
		ESPColor = {Config.ESPColor.R, Config.ESPColor.G, Config.ESPColor.B}
	}
	writefile(FolderName .. "/" .. ConfigFile, game:GetService("HttpService"):JSONEncode(data))
end

-- Configuration
local savedConfig = loadConfig()
local Config = {
	Enabled = false,
	Key = Enum.KeyCode.C,
	MenuKey = Enum.KeyCode.RightShift,
	ESPKey = Enum.KeyCode.X,
	ESPEnabled = false,
	TeamCheck = savedConfig and savedConfig.TeamCheck or true,
	TargetPart = savedConfig and savedConfig.TargetPart or "Head",
	FOV = savedConfig and savedConfig.FOV or 250,
	Smoothness = savedConfig and savedConfig.Smoothness or 0.5,
	ShowFOV = savedConfig and savedConfig.ShowFOV or true,
	FOVColor = savedConfig and savedConfig.FOVColor and Color3.new(savedConfig.FOVColor[1], savedConfig.FOVColor[2], savedConfig.FOVColor[3]) or Color3.fromRGB(255, 255, 255),
	LockOnTarget = nil,
	NoticeShown = checkAcceptanceFile(),
	MenuOpen = false,
	ESPColor = savedConfig and savedConfig.ESPColor and Color3.new(savedConfig.ESPColor[1], savedConfig.ESPColor[2], savedConfig.ESPColor[3]) or Color3.fromRGB(255, 0, 0),
	ESPBoxes = {}
}

-- Create Notice GUI
local function createNoticeGUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AimbotNotice"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 450, 0, 280)
	Frame.Position = UDim2.new(0.5, -225, 0.5, -140)
	Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Frame.BorderSizePixel = 0
	Frame.Parent = ScreenGui
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 15)
	UICorner.Parent = Frame
	
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(100, 60, 200)
	UIStroke.Thickness = 2
	UIStroke.Parent = Frame
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -40, 0, 50)
	Title.Position = UDim2.new(0, 20, 0, 15)
	Title.BackgroundTransparency = 1
	Title.Text = "⚠️ AIMBOT NOTICE"
	Title.TextColor3 = Color3.fromRGB(200, 100, 255)
	Title.TextSize = 26
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Frame
	
	local Message = Instance.new("TextLabel")
	Message.Size = UDim2.new(1, -40, 0, 130)
	Message.Position = UDim2.new(0, 20, 0, 70)
	Message.BackgroundTransparency = 1
	Message.Text = "Enhanced Aimbot is ready to use!\n\nPress C to toggle Aimbot ON/OFF\nPress X to toggle ESP ON/OFF\nPress Right Shift to open settings menu\n\nThis script is written by kkavasaki__"
	Message.TextColor3 = Color3.fromRGB(220, 220, 220)
	Message.TextSize = 16
	Message.Font = Enum.Font.Gotham
	Message.TextWrapped = true
	Message.TextYAlignment = Enum.TextYAlignment.Top
	Message.Parent = Frame
	
	local OKButton = Instance.new("TextButton")
	OKButton.Size = UDim2.new(0, 180, 0, 45)
	OKButton.Position = UDim2.new(0.5, -90, 1, -65)
	OKButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	OKButton.Text = "I UNDERSTAND"
	OKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	OKButton.TextSize = 18
	OKButton.Font = Enum.Font.GothamBold
	OKButton.Parent = Frame
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 10)
	ButtonCorner.Parent = OKButton
	
	OKButton.MouseEnter:Connect(function()
		TweenService:Create(OKButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 80, 220)}):Play()
	end)
	
	OKButton.MouseLeave:Connect(function()
		TweenService:Create(OKButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 60, 200)}):Play()
	end)
	
	OKButton.MouseButton1Click:Connect(function()
		Config.NoticeShown = true
		saveAcceptance()
		ScreenGui:Destroy()
		
		game.StarterGui:SetCore("SendNotification", {
			Title = "Aimbot Ready",
			Text = "Press Right Shift to open settings",
			Duration = 3
		})
	end)
	
	ScreenGui.Parent = LocalPlayer.PlayerGui
end

-- Create Enhanced Menu GUI with Sliders
local function createMenuGUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AimbotMenu"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 420, 0, 500)
	Frame.Position = UDim2.new(0.5, -210, 0.5, -250)
	Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Frame.BorderSizePixel = 0
	Frame.Parent = ScreenGui
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 15)
	UICorner.Parent = Frame
	
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(100, 60, 200)
	UIStroke.Thickness = 2
	UIStroke.Parent = Frame
	
	-- Header
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	Header.BorderSizePixel = 0
	Header.Parent = Frame
	
	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 15)
	HeaderCorner.Parent = Header
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -40, 1, 0)
	Title.Position = UDim2.new(0, 20, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "🎯 AIMBOT SETTINGS"
	Title.TextColor3 = Color3.fromRGB(200, 100, 255)
	Title.TextSize = 24
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header
	
	-- Scrolling Frame for content
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Size = UDim2.new(1, -20, 1, -130)
	ScrollFrame.Position = UDim2.new(0, 10, 0, 70)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 6
	ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 60, 200)
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollFrame.Parent = Frame
	
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Padding = UDim.new(0, 15)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ListLayout.Parent = ScrollFrame
	
	-- Helper function to create slider
	local function createSlider(name, minVal, maxVal, currentVal, callback)
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, -20, 0, 70)
		Container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		Container.BorderSizePixel = 0
		Container.Parent = ScrollFrame
		
		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 10)
		ContainerCorner.Parent = Container
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -20, 0, 25)
		Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1
		Label.Text = name .. ": " .. tostring(math.floor(currentVal))
		Label.TextColor3 = Color3.fromRGB(220, 220, 220)
		Label.TextSize = 16
		Label.Font = Enum.Font.GothamBold
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container
		
		local SliderBack = Instance.new("Frame")
		SliderBack.Size = UDim2.new(1, -20, 0, 8)
		SliderBack.Position = UDim2.new(0, 10, 0, 40)
		SliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		SliderBack.BorderSizePixel = 0
		SliderBack.Parent = Container
		
		local SliderBackCorner = Instance.new("UICorner")
		SliderBackCorner.CornerRadius = UDim.new(1, 0)
		SliderBackCorner.Parent = SliderBack
		
		local SliderFill = Instance.new("Frame")
		SliderFill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
		SliderFill.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
		SliderFill.BorderSizePixel = 0
		SliderFill.Parent = SliderBack
		
		local SliderFillCorner = Instance.new("UICorner")
		SliderFillCorner.CornerRadius = UDim.new(1, 0)
		SliderFillCorner.Parent = SliderFill
		
		local SliderButton = Instance.new("TextButton")
		SliderButton.Size = UDim2.new(1, 0, 1, 10)
		SliderButton.Position = UDim2.new(0, 0, 0, -5)
		SliderButton.BackgroundTransparency = 1
		SliderButton.Text = ""
		SliderButton.Parent = SliderBack
		
		local dragging = false
		
		SliderButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		
		SliderButton.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mousePos = UserInputService:GetMouseLocation()
				local relativePos = mousePos.X - SliderBack.AbsolutePosition.X
				local percentage = math.clamp(relativePos / SliderBack.AbsoluteSize.X, 0, 1)
				local value = minVal + (maxVal - minVal) * percentage
				
				SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
				Label.Text = name .. ": " .. tostring(math.floor(value))
				callback(value)
			end
		end)
		
		return Container
	end
	
	-- Helper function to create toggle
	local function createToggle(name, currentVal, callback)
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, -20, 0, 50)
		Container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		Container.BorderSizePixel = 0
		Container.Parent = ScrollFrame
		
		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 10)
		ContainerCorner.Parent = Container
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -80, 1, 0)
		Label.Position = UDim2.new(0, 15, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = name
		Label.TextColor3 = Color3.fromRGB(220, 220, 220)
		Label.TextSize = 16
		Label.Font = Enum.Font.GothamBold
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container
		
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Size = UDim2.new(0, 60, 0, 30)
		ToggleButton.Position = UDim2.new(1, -70, 0.5, -15)
		ToggleButton.BackgroundColor3 = currentVal and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(60, 60, 70)
		ToggleButton.Text = currentVal and "ON" or "OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.TextSize = 14
		ToggleButton.Font = Enum.Font.GothamBold
		ToggleButton.Parent = Container
		
		local ToggleCorner = Instance.new("UICorner")
		ToggleCorner.CornerRadius = UDim.new(0, 8)
		ToggleCorner.Parent = ToggleButton
		
		ToggleButton.MouseButton1Click:Connect(function()
			currentVal = not currentVal
			ToggleButton.Text = currentVal and "ON" or "OFF"
			TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
				BackgroundColor3 = currentVal and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(60, 60, 70)
			}):Play()
			callback(currentVal)
		end)
		
		return Container
	end
	
	-- Helper function to create dropdown
	local function createDropdown(name, options, currentVal, callback)
		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, -20, 0, 50)
		Container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		Container.BorderSizePixel = 0
		Container.Parent = ScrollFrame
		
		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 10)
		ContainerCorner.Parent = Container
		
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.5, -10, 1, 0)
		Label.Position = UDim2.new(0, 15, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = name
		Label.TextColor3 = Color3.fromRGB(220, 220, 220)
		Label.TextSize = 16
		Label.Font = Enum.Font.GothamBold
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Container
		
		local Dropdown = Instance.new("TextButton")
		Dropdown.Size = UDim2.new(0.4, 0, 0, 30)
		Dropdown.Position = UDim2.new(0.55, 0, 0.5, -15)
		Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		Dropdown.Text = currentVal
		Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
		Dropdown.TextSize = 14
		Dropdown.Font = Enum.Font.Gotham
		Dropdown.Parent = Container
		
		local DropdownCorner = Instance.new("UICorner")
		DropdownCorner.CornerRadius = UDim.new(0, 8)
		DropdownCorner.Parent = Dropdown
		
		local currentIndex = table.find(options, currentVal) or 1
		
		Dropdown.MouseButton1Click:Connect(function()
			currentIndex = currentIndex % #options + 1
			currentVal = options[currentIndex]
			Dropdown.Text = currentVal
			callback(currentVal)
		end)
		
		return Container
	end
	
	-- Status Section
	local StatusContainer = Instance.new("Frame")
	StatusContainer.Size = UDim2.new(1, -20, 0, 70)
	StatusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	StatusContainer.BorderSizePixel = 0
	StatusContainer.Parent = ScrollFrame
	
	local StatusCorner = Instance.new("UICorner")
	StatusCorner.CornerRadius = UDim.new(0, 10)
	StatusCorner.Parent = StatusContainer
	
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Size = UDim2.new(1, -20, 1, -10)
	StatusLabel.Position = UDim2.new(0, 10, 0, 5)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Text = "Aimbot: " .. (Config.Enabled and "✓ ENABLED" or "✗ DISABLED") .. "\nESP: " .. (Config.ESPEnabled and "✓ ENABLED" or "✗ DISABLED")
	StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	StatusLabel.TextSize = 15
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.TextWrapped = true
	StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = StatusContainer
	
	-- Create sliders and toggles
	createSlider("FOV Size", 50, 500, Config.FOV, function(value)
		Config.FOV = value
		if FOVCircle then FOVCircle.Radius = value end
		saveConfig()
	end)
	
	createSlider("Smoothness", 0.1, 1, Config.Smoothness, function(value)
		Config.Smoothness = value
		saveConfig()
	end)
	
	createToggle("Show FOV Circle", Config.ShowFOV, function(value)
		Config.ShowFOV = value
		if FOVCircle then FOVCircle.Visible = Config.Enabled and value end
		saveConfig()
	end)
	
	createToggle("Team Check", Config.TeamCheck, function(value)
		Config.TeamCheck = value
		saveConfig()
	end)
	
	createDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, Config.TargetPart, function(value)
		Config.TargetPart = value
		saveConfig()
	end)
	
	-- Keybinds Info
	local KeybindsContainer = Instance.new("Frame")
	KeybindsContainer.Size = UDim2.new(1, -20, 0, 90)
	KeybindsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	KeybindsContainer.BorderSizePixel = 0
	KeybindsContainer.Parent = ScrollFrame
	
	local KeybindsCorner = Instance.new("UICorner")
	KeybindsCorner.CornerRadius = UDim.new(0, 10)
	KeybindsCorner.Parent = KeybindsContainer
	
	local KeybindsLabel = Instance.new("TextLabel")
	KeybindsLabel.Size = UDim2.new(1, -20, 1, -10)
	KeybindsLabel.Position = UDim2.new(0, 10, 0, 5)
	KeybindsLabel.BackgroundTransparency = 1
	KeybindsLabel.Text = "⌨️ Keybinds:\n• C - Toggle Aimbot\n• X - Toggle ESP\n• Right Shift - Toggle Menu"
	KeybindsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	KeybindsLabel.TextSize = 14
	KeybindsLabel.Font = Enum.Font.Gotham
	KeybindsLabel.TextWrapped = true
	KeybindsLabel.TextYAlignment = Enum.TextYAlignment.Top
	KeybindsLabel.TextXAlignment = Enum.TextXAlignment.Left
	KeybindsLabel.Parent = KeybindsContainer
	
	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 150, 0, 45)
	CloseButton.Position = UDim2.new(0.5, -75, 1, -55)
	CloseButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	CloseButton.Text = "CLOSE"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 18
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = Frame
	
	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 10)
	CloseCorner.Parent = CloseButton
	
	CloseButton.MouseEnter:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 80, 220)}):Play()
	end)
	
	CloseButton.MouseLeave:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 60, 200)}):Play()
	end)
	
	CloseButton.MouseButton1Click:Connect(function()
		Config.MenuOpen = false
		ScreenGui:Destroy()
	end)
	
	ScreenGui.Parent = LocalPlayer.PlayerGui
	return ScreenGui
end

-- FOV Circle Drawing
local FOVCircle
if Drawing then
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Visible = false
	FOVCircle.Radius = Config.FOV
	FOVCircle.Color = Config.FOVColor
	FOVCircle.Thickness = 2
	FOVCircle.Filled = false
	FOVCircle.Transparency = 1
end

-- Toggle function
local function toggleAimbot()
	if not Config.NoticeShown then
		game.StarterGui:SetCore("SendNotification", {
			Title = "Notice Required",
			Text = "Please accept the notice first!",
			Duration = 2
		})
		return
	end
	
	Config.Enabled = not Config.Enabled
	if FOVCircle then
		FOVCircle.Visible = Config.Enabled and Config.ShowFOV
	end
	
	if not Config.Enabled then
		Config.LockOnTarget = nil
	end
	
	local message = Config.Enabled and "Aimbot: ON" or "Aimbot: OFF"
	game.StarterGui:SetCore("SendNotification", {
		Title = "Aimbot",
		Text = message,
		Duration = 2
	})
end

-- Toggle menu
local function toggleMenu()
	if not Config.NoticeShown then return end
	
	Config.MenuOpen = not Config.MenuOpen
	
	if Config.MenuOpen then
		createMenuGUI()
	else
		local gui = LocalPlayer.PlayerGui:FindFirstChild("AimbotMenu")
		if gui then gui:Destroy() end
	end
end

-- ESP Functions
local function createESP(player)
	if not Drawing then return end
	
	local esp = {
		Box = Drawing.new("Square"),
		Info = Drawing.new("Text")
	}
	
	esp.Box.Visible = false
	esp.Box.Color = Config.ESPColor
	esp.Box.Thickness = 2
	esp.Box.Transparency = 1
	esp.Box.Filled = false
	
	esp.Info.Visible = false
	esp.Info.Color = Color3.fromRGB(255, 255, 255)
	esp.Info.Size = 13
	esp.Info.Center = true
	esp.Info.Outline = true
	esp.Info.Font = 2
	
	Config.ESPBoxes[player] = esp
end

local function removeESP(player)
	local esp = Config.ESPBoxes[player]
	if esp then
		for _, drawing in pairs(esp) do
			drawing:Remove()
		end
		Config.ESPBoxes[player] = nil
	end
end

local function updateESP()
	if not Config.ESPEnabled then
		for _, esp in pairs(Config.ESPBoxes) do
			for _, drawing in pairs(esp) do
				drawing.Visible = false
			end
		end
		return
	end
	
	for player, esp in pairs(Config.ESPBoxes) do
		if isValidTarget(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local head = player.Character:FindFirstChild("Head")
			local humanoid = player.Character:FindFirstChild("Humanoid")
			
			if hrp and head and humanoid then
				local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				
				if onScreen then
					local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
					local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
					
					local height = math.abs(headPos.Y - legPos.Y)
					local width = height / 2
					
					esp.Box.Size = Vector2.new(width, height)
					esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
					esp.Box.Visible = true
					
					local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
					local health = math.floor(humanoid.Health)
					local maxHealth = math.floor(humanoid.MaxHealth)
					
					esp.Info.Text = player.Name
