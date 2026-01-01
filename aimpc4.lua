-- Combined UI Framework with Aimbot Features
-- RightShift toggle | Full Featured Aimbot + ESP

local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// File system
local FOLDER = "kkavasakisaimbot"
local CONFIG_FILE = FOLDER.."/config.json"
local THEME_FILE = FOLDER.."/theme.css"
local NOTICE_FILE = FOLDER.."/notice_accepted.txt"

if writefile and not isfolder(FOLDER) then
	makefolder(FOLDER)
end

--// Check acceptance file
local function checkAcceptanceFile()
	if not isfolder or not isfile then return false end
	if not isfolder(FOLDER) then makefolder(FOLDER) end
	return isfile(NOTICE_FILE)
end

local function saveAcceptance()
	if not writefile then return end
	if not isfolder(FOLDER) then makefolder(FOLDER) end
	writefile(NOTICE_FILE, "Notice accepted by " .. LocalPlayer.Name .. " on " .. os.date("%Y-%m-%d %H:%M:%S"))
end

--// Default Config
local Config = {
	Aimbot = {
		Enabled = false,
		Key = "C",
		TeamCheck = true,
		TargetPart = "Head",
		FOV = 250,
		Sensitivity = 0.5,
		ShowFOV = true
	},
	ESP = {
		Enabled = false,
		Key = "X",
		Boxes = true,
		Names = true,
		Distance = true,
		Health = true
	},
	NoticeAccepted = checkAcceptanceFile()
}

--// Save / Load Config
local function saveConfig()
	if not writefile then return end
	writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
end

local function loadConfig()
	if not readfile or not isfile(CONFIG_FILE) then return end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if ok and data then Config = data end
end

loadConfig()

--// CSS THEME PARSER
local function parseCSS(text)
	local theme = {}
	for key,r,g,b in text:gmatch("%-%-(%w+):%s*(%d+),(%d+),(%d+)") do
		theme[key] = Color3.fromRGB(r,g,b)
	end
	return theme
end

local function themeToCSS(theme)
	local out = {}
	for k,v in pairs(theme) do
		table.insert(out,string.format("--%s: %d,%d,%d",
			k,
			math.floor(v.R*255),
			math.floor(v.G*255),
			math.floor(v.B*255)
		))
	end
	return table.concat(out,"\n")
end

--// Default Theme
local Theme = {
	Main = Color3.fromRGB(25,25,35),
	Secondary = Color3.fromRGB(35,35,50),
	Button = Color3.fromRGB(45,45,60),
	Accent = Color3.fromRGB(180,120,255),
	Text = Color3.fromRGB(255,255,255)
}

--// Load Theme
if readfile and isfile(THEME_FILE) then
	local ok,parsed = pcall(function()
		return parseCSS(readfile(THEME_FILE))
	end)
	if ok and parsed then
		for k,v in pairs(parsed) do Theme[k] = v end
	end
end

local function saveTheme()
	if not writefile then return end
	writefile(THEME_FILE, themeToCSS(Theme))
end

--// Aimbot Variables
local LockOnTarget = nil
local FOVCircle
local ESPBoxes = {}

--// FOV Circle
if Drawing then
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Visible = false
	FOVCircle.Radius = Config.Aimbot.FOV
	FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	FOVCircle.Thickness = 2
	FOVCircle.Filled = false
	FOVCircle.Transparency = 1
end

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false

local Themed = {}

local function applyTheme()
	for obj,props in pairs(Themed) do
		for prop,key in pairs(props) do
			obj[prop] = Theme[key]
		end
	end
end

local function theme(obj,props)
	Themed[obj] = props
	applyTheme()
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(460,380)
Main.Position = UDim2.fromScale(0.5,0.5) - UDim2.fromOffset(230,190)
Main.Visible = false
Main.Active = true
theme(Main,{BackgroundColor3="Main"})
Instance.new("UICorner",Main)

--// Title
local Title = Instance.new("TextLabel",Main)
Title.Size = UDim2.new(1,-20,0,30)
Title.Position = UDim2.fromOffset(10,10)
Title.BackgroundTransparency = 1
Title.Text = "🎯 AIMBOT v2.0"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
theme(Title,{TextColor3="Accent"})

--// Drag functionality
do
	local drag, start, pos
	Main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			start = i.Position
			pos = Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position-start
			Main.Position = pos + UDim2.fromOffset(d.X,d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
	end)
end

--// Tabs
local Tabs = {"Aimbot","ESP","Visuals","Config"}
local Pages = {}

local TabBar = Instance.new("Frame",Main)
TabBar.Position = UDim2.fromOffset(10,50)
TabBar.Size = UDim2.fromOffset(120,310)
TabBar.BackgroundTransparency = 1

local Holder = Instance.new("Frame",Main)
Holder.Position = UDim2.fromOffset(140,50)
Holder.Size = UDim2.fromOffset(310,310)
Holder.BackgroundTransparency = 1

local function switchTab(n)
	for k,v in pairs(Pages) do v.Visible = (k==n) end
end

for i,n in ipairs(Tabs) do
	local b = Instance.new("TextButton",TabBar)
	b.Size = UDim2.fromOffset(120,36)
	b.Position = UDim2.fromOffset(0,(i-1)*42)
	b.Text = n
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	theme(b,{BackgroundColor3="Button",TextColor3="Text"})
	Instance.new("UICorner",b)

	b.MouseButton1Click:Connect(function()
		switchTab(n)
	end)

	local p = Instance.new("ScrollingFrame",Holder)
	p.Size = UDim2.fromScale(1,1)
	p.Visible = i==1
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 4
	local layout = Instance.new("UIListLayout",p)
	layout.Padding = UDim.new(0,8)
	Pages[n] = p
end

--// Toggle Widget
local function Toggle(parent,name,getValue,setValue)
	local f = Instance.new("Frame",parent)
	f.Size = UDim2.new(1,-10,0,32)
	theme(f,{BackgroundColor3="Secondary"})
	Instance.new("UICorner",f)

	local t = Instance.new("TextLabel",f)
	t.Size = UDim2.new(1,-60,1,0)
	t.Position = UDim2.fromOffset(10,0)
	t.BackgroundTransparency = 1
	t.Text = name
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	theme(t,{TextColor3="Text"})

	local b = Instance.new("TextButton",f)
	b.Size = UDim2.fromOffset(44,20)
	b.Position = UDim2.new(1,-54,0.5,-10)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	Instance.new("UICorner",b)

	local function refresh()
		local val = getValue()
		b.Text = val and "ON" or "OFF"
		b.BackgroundColor3 = val and Theme.Accent or Theme.Button
	end

	refresh()
	b.MouseButton1Click:Connect(function()
		setValue(not getValue())
		saveConfig()
		refresh()
	end)
	
	return f
end

--// Slider Widget
local function Slider(parent,name,min,max,getValue,setValue)
	local f = Instance.new("Frame",parent)
	f.Size = UDim2.new(1,-10,0,50)
	theme(f,{BackgroundColor3="Secondary"})
	Instance.new("UICorner",f)

	local t = Instance.new("TextLabel",f)
	t.Size = UDim2.new(1,-20,0,20)
	t.Position = UDim2.fromOffset(10,5)
	t.BackgroundTransparency = 1
	t.Text = name
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	theme(t,{TextColor3="Text"})

	local val = Instance.new("TextLabel",f)
	val.Size = UDim2.fromOffset(60,20)
	val.Position = UDim2.new(1,-70,0,5)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.GothamBold
	val.TextSize = 12
	theme(val,{TextColor3="Accent"})

	local slider = Instance.new("Frame",f)
	slider.Size = UDim2.new(1,-20,0,4)
	slider.Position = UDim2.fromOffset(10,32)
	theme(slider,{BackgroundColor3="Button"})
	Instance.new("UICorner",slider)

	local fill = Instance.new("Frame",slider)
	fill.Size = UDim2.fromScale(0.5,1)
	theme(fill,{BackgroundColor3="Accent"})
	Instance.new("UICorner",fill)

	local function update()
		local v = getValue()
		val.Text = tostring(math.floor(v))
		fill.Size = UDim2.fromScale((v-min)/(max-min),1)
	end

	update()

	local dragging = false
	slider.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = (i.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			pos = math.clamp(pos, 0, 1)
			local newVal = min + (max - min) * pos
			setValue(newVal)
			update()
			saveConfig()
		end
	end)

	return f
end

--// Dropdown Widget
local function Dropdown(parent,name,options,getValue,setValue)
	local f = Instance.new("Frame",parent)
	f.Size = UDim2.new(1,-10,0,32)
	theme(f,{BackgroundColor3="Secondary"})
	Instance.new("UICorner",f)

	local t = Instance.new("TextLabel",f)
	t.Size = UDim2.new(0.5,-10,1,0)
	t.Position = UDim2.fromOffset(10,0)
	t.BackgroundTransparency = 1
	t.Text = name
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	theme(t,{TextColor3="Text"})

	local b = Instance.new("TextButton",f)
	b.Size = UDim2.new(0.5,-20,0,24)
	b.Position = UDim2.new(0.5,10,0.5,-12)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	theme(b,{BackgroundColor3="Button",TextColor3="Text"})
	Instance.new("UICorner",b)

	local function refresh()
		b.Text = getValue()
	end

	refresh()

	local currentIndex = 1
	for i,v in ipairs(options) do
		if v == getValue() then currentIndex = i break end
	end

	b.MouseButton1Click:Connect(function()
		currentIndex = currentIndex % #options + 1
		setValue(options[currentIndex])
		refresh()
		saveConfig()
	end)

	return f
end

--// Aimbot Page
Toggle(Pages.Aimbot,"Enable Aimbot",
	function() return Config.Aimbot.Enabled end,
	function(v) Config.Aimbot.Enabled = v end)

Toggle(Pages.Aimbot,"Team Check",
	function() return Config.Aimbot.TeamCheck end,
	function(v) Config.Aimbot.TeamCheck = v end)

Toggle(Pages.Aimbot,"Show FOV Circle",
	function() return Config.Aimbot.ShowFOV end,
	function(v) 
		Config.Aimbot.ShowFOV = v
		if FOVCircle then FOVCircle.Visible = v and Config.Aimbot.Enabled end
	end)

Slider(Pages.Aimbot,"FOV Radius",50,400,
	function() return Config.Aimbot.FOV end,
	function(v) 
		Config.Aimbot.FOV = v
		if FOVCircle then FOVCircle.Radius = v end
	end)

Slider(Pages.Aimbot,"Sensitivity",0.1,1,
	function() return Config.Aimbot.Sensitivity end,
	function(v) Config.Aimbot.Sensitivity = v end)

Dropdown(Pages.Aimbot,"Target Part",{"Head","Torso","HumanoidRootPart"},
	function() return Config.Aimbot.TargetPart end,
	function(v) Config.Aimbot.TargetPart = v end)

--// ESP Page
Toggle(Pages.ESP,"Enable ESP",
	function() return Config.ESP.Enabled end,
	function(v) Config.ESP.Enabled = v end)

Toggle(Pages.ESP,"Show Boxes",
	function() return Config.ESP.Boxes end,
	function(v) Config.ESP.Boxes = v end)

Toggle(Pages.ESP,"Show Names",
	function() return Config.ESP.Names end,
	function(v) Config.ESP.Names = v end)

Toggle(Pages.ESP,"Show Distance",
	function() return Config.ESP.Distance end,
	function(v) Config.ESP.Distance = v end)

Toggle(Pages.ESP,"Show Health",
	function() return Config.ESP.Health end,
	function(v) Config.ESP.Health = v end)

--// Config Page
do
	local save = Instance.new("TextButton",Pages.Config)
	save.Size = UDim2.new(1,-10,0,36)
	save.Text = "💾 Save Config"
	save.Font = Enum.Font.GothamBold
	save.TextSize = 14
	theme(save,{BackgroundColor3="Button",TextColor3="Text"})
	Instance.new("UICorner",save)
	save.MouseButton1Click:Connect(saveConfig)

	local load = Instance.new("TextButton",Pages.Config)
	load.Size = UDim2.new(1,-10,0,36)
	load.Text = "📂 Load Config"
	load.Font = Enum.Font.GothamBold
	load.TextSize = 14
	theme(load,{BackgroundColor3="Button",TextColor3="Text"})
	Instance.new("UICorner",load)
	load.MouseButton1Click:Connect(loadConfig)

	local saveThemeBtn = Instance.new("TextButton",Pages.Config)
	saveThemeBtn.Size = UDim2.new(1,-10,0,36)
	saveThemeBtn.Text = "🎨 Save Theme"
	saveThemeBtn.Font = Enum.Font.GothamBold
	saveThemeBtn.TextSize = 14
	theme(saveThemeBtn,{BackgroundColor3="Button",TextColor3="Text"})
	Instance.new("UICorner",saveThemeBtn)
	saveThemeBtn.MouseButton1Click:Connect(saveTheme)
end

--// ESP Functions
local function createESP(player)
	if not Drawing then return end
	
	local esp = {
		Box = Drawing.new("Square"),
		Name = Drawing.new("Text"),
		Info = Drawing.new("Text")
	}
	
	esp.Box.Visible = false
	esp.Box.Color = Color3.fromRGB(255, 0, 0)
	esp.Box.Thickness = 2
	esp.Box.Transparency = 1
	esp.Box.Filled = false
	
	esp.Name.Visible = false
	esp.Name.Color = Color3.fromRGB(255, 255, 255)
	esp.Name.Size = 14
	esp.Name.Center = true
	esp.Name.Outline = true
	esp.Name.Font = 2
	
	esp.Info.Visible = false
	esp.Info.Color = Color3.fromRGB(255, 255, 255)
	esp.Info.Size = 12
	esp.Info.Center = true
	esp.Info.Outline = true
	esp.Info.Font = 2
	
	ESPBoxes[player] = esp
end

local function removeESP(player)
	local esp = ESPBoxes[player]
	if esp then
		esp.Box:Remove()
		esp.Name:Remove()
		esp.Info:Remove()
		ESPBoxes[player] = nil
	end
end

local function updateESP()
	if not Config.ESP.Enabled or not Drawing then
		for _, esp in pairs(ESPBoxes) do
			esp.Box.Visible = false
			esp.Name.Visible = false
			esp.Info.Visible = false
		end
		return
	end
	
	for player, esp in pairs(ESPBoxes) do
		if player and player.Parent and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local head = player.Character:FindFirstChild("Head")
			local humanoid = player.Character:FindFirstChild("Humanoid")
			
			if hrp and head and humanoid and humanoid.Health > 0 then
				local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				
				if onScreen and vector.Z > 0 then
					local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
					local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
					
					local height = math.abs(headPos.Y - legPos.Y)
					local width = height / 2
					
					if Config.ESP.Boxes then
						esp.Box.Size = Vector2.new(width, height)
						esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
						esp.Box.Visible = true
					else
						esp.Box.Visible = false
					end
					
					if Config.ESP.Names then
						esp.Name.Text = player.Name
						esp.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 18)
						esp.Name.Visible = true
					else
						esp.Name.Visible = false
					end
					
					if Config.ESP.Distance or Config.ESP.Health then
						local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
						local health = math.floor(humanoid.Health)
						local maxHealth = math.floor(humanoid.MaxHealth)
						
						local infoText = ""
						if Config.ESP.Health then infoText = health .. "/" .. maxHealth end
						if Config.ESP.Distance then 
							if infoText ~= "" then infoText = infoText .. " | " end
							infoText = infoText .. distance .. "m"
						end
						
						esp.Info.Text = infoText
						esp.Info.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
						esp.Info.Visible = true
					else
						esp.Info.Visible = false
					end
				else
					esp.Box.Visible = false
					esp.Name.Visible = false
					esp.Info.Visible = false
				end
			else
				esp.Box.Visible = false
				esp.Name.Visible = false
				esp.Info.Visible = false
			end
		end
	end
end

--// Aimbot Functions
local function isTeamMate(player)
	if not Config.Aimbot.TeamCheck then return false end
	return player.Team == LocalPlayer.Team and player.Team ~= nil
end

local function isValidTarget(player)
	if player == LocalPlayer then return false end
	if not player.Character then return false end
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	if isTeamMate(player) then return false end
	return true
end

local function getClosestPlayerInFOV()
	local closestPlayer = nil
	local shortestDistance = Config.Aimbot.FOV
	
	for _, player in pairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
			
			if targetPart then
				local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				
				if onScreen and screenPoint.Z > 0 then
					local vectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
					
					if vectorDistance < shortestDistance then
						closestPlayer = player
						shortestDistance = vectorDistance
					end
				end
			end
		end
	end
	
	return closestPlayer
end

--// Update FOV Circle
if FOVCircle then
	RunService.RenderStepped:Connect(function()
		FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
	end)
end

--// Main Loop
RunService.RenderStepped:Connect(function()
	updateESP()
	
	if Config.Aimbot.Enabled and Config.NoticeAccepted and mousemoverel then
		if LockOnTarget and isValidTarget(LockOnTarget) then
			local targetPart = LockOnTarget.Character:FindFirstChild(Config.Aimbot.TargetPart)
			if targetPart then
				local targetPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				
				if onScreen and targetPosition.Z > 0 then
					local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
					local aimPosition = Vector2.new(targetPosition.X, targetPosition.Y)
					local movement = (aimPosition - mousePosition) * Config.Aimbot.Sensitivity
					
					mousemoverel(movement.X, movement.Y)
				end
			end
		else
			LockOnTarget = getClosestPlayerInFOV()
		end
	end
end)

--// Input Handling
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	
	if i.KeyCode == Enum.KeyCode.RightShift then
		Main.Visible = not Main.Visible
	elseif i.KeyCode == Enum.KeyCode.C then
		if not Config.NoticeAccepted then return end
		Config.Aimbot.Enabled = not Config.Aimbot.Enabled
		if FOVCircle then FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV end
		if not Config.Aimbot.Enabled then LockOnTarget = nil end
	elseif i.KeyCode == Enum.KeyCode.X then
		if not Config.NoticeAccepted then return end
		Config.ESP.Enabled = not Config.ESP.Enabled
	end
end)

--// Player Management
Players.PlayerRemoving:Connect(function(player)
	if LockOnTarget == player then LockOnTarget = nil end
	removeESP(player)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if player ~= LocalPlayer then createESP(player) end
	end)
end)

--// Initialize ESP
for _, player in pairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then createESP(player) end
end

--// Notice GUI
if not Config.NoticeAccepted then
	local NoticeGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	NoticeGui.ResetOnSpawn = false
	
	local Frame = Instance.new("Frame", NoticeGui)
	Frame.Size = UDim2.fromOffset(400, 250)
	Frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(200, 125)
	Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	Frame.BorderSizePixel = 0
	Instance.new("UICorner", Frame)
	
	local Title = Instance.new("TextLabel", Frame)
	Title.Size = UDim2.new(1, -40, 0, 40)
	Title.Position = UDim2.fromOffset(20, 20)
	Title.BackgroundTransparency = 1
	Title.Text = "⚠️ AIMBOT NOTICE"
	Title.TextColor3 = Color3.fromRGB(200, 100, 255)
	Title.TextSize = 24
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	
	local Message = Instance.new("TextLabel", Frame)
	Message.Size = UDim2.new(1, -40, 0, 100)
	Message.Position = UDim2.fromOffset(20, 70)
	Message.BackgroundTransparency = 1
	Message.Text = "Aimbot is ready to use!\n\nPress C to toggle Aimbot\nPress X to toggle ESP\nPress Right Shift to open menu\n\nBy kkavasaki__"
	Message.TextColor3 = Color3.fromRGB(220, 220, 220)
	Message.TextSize = 16
	Message.Font = Enum.Font.Gotham
	Message.TextWrapped = true
	Message.TextYAlignment = Enum.TextYAlignment.Top
	
	local OKButton = Instance.new("TextButton", Frame)
	OKButton.Size = UDim2.fromOffset(150, 40)
	OKButton.Position = UDim2.fromScale(0.5, 1) - UDim2.fromOffset(75, 60)
	OKButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
	OKButton.Text = "ACCEPT"
	OKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	OKButton.TextSize = 18
	OKButton.Font = Enum.Font.GothamBold
	Instance.new("UICorner", OKButton)
	
	OKButton.MouseButton1Click:Connect(function()
		Config.NoticeAccepted = true
		saveAcceptance()
		saveConfig()
		NoticeGui:Destroy()
	end)
end

print("UI Framework loaded | Aimbot + ESP + Config + Theme support")
