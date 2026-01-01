-- PC AIMBOT + SKELETON ESP + UI
-- by kkavasaki__

--// Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until LP.Character
repeat task.wait() until LP.Character:FindFirstChild("HumanoidRootPart")

--// Config
local Config = {
	Aimbot = false,
	ESP = false,
	MenuOpen = false,

	FOV = 200,
	Smoothness = 1, -- strongest
	TargetPart = "Head",
	TeamCheck = true,

	Prediction = true,
	PredictionAmount = 0.165,

	ESPColor = Color3.fromRGB(0,255,0),
	FOVColor = Color3.fromRGB(255,255,255),

	Target = nil,
	ESPObjects = {}
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PCAimbot"

--// FOV Circle
local FOVCircle
if Drawing then
	FOVCircle = Drawing.new("Circle")
	FOVCircle.Filled = false
	FOVCircle.Thickness = 2
	FOVCircle.NumSides = 64
	FOVCircle.Transparency = 1
	FOVCircle.Color = Config.FOVColor
	FOVCircle.Radius = Config.FOV
	FOVCircle.Visible = false
end

--// Utility
local function isValid(plr)
	if not plr or plr == LP then return false end
	if Config.TeamCheck and plr.Team == LP.Team then return false end
	local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
	return hum and hum.Health > 0
end

--// Closest target
local function getClosest()
	local closest, dist = nil, Config.FOV
	local center = Camera.ViewportSize / 2

	for _,p in ipairs(Players:GetPlayers()) do
		if isValid(p) then
			local part = p.Character:FindFirstChild(Config.TargetPart)
			if part then
				local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
				if onscreen and pos.Z > 0 then
					local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
					if mag < dist then
						dist = mag
						closest = p
					end
				end
			end
		end
	end
	return closest
end

--// Aim
local function aimAt(p)
	local part = p.Character:FindFirstChild(Config.TargetPart)
	if not part then return end

	local pos = part.Position
	if Config.Prediction then
		pos += part.AssemblyLinearVelocity * Config.PredictionAmount
	end

	local cf = Camera.CFrame
	local new = CFrame.new(cf.Position, pos)
	Camera.CFrame = cf:Lerp(new, Config.Smoothness)
end

--// Skeleton ESP
local Bones = {
	{"Head","UpperTorso"},
	{"UpperTorso","LeftUpperArm"},
	{"LeftUpperArm","LeftLowerArm"},
	{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},
	{"RightUpperArm","RightLowerArm"},
	{"RightLowerArm","RightHand"},
	{"UpperTorso","LowerTorso"},
	{"LowerTorso","LeftUpperLeg"},
	{"LeftUpperLeg","LeftLowerLeg"},
	{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},
	{"RightUpperLeg","RightLowerLeg"},
	{"RightLowerLeg","RightFoot"},
}

local function createESP(p)
	if Config.ESPObjects[p] then return end
	local lines = {}

	for _ = 1,#Bones do
		local l = Drawing.new("Line")
		l.Thickness = 2
		l.Color = Config.ESPColor
		l.Transparency = 1
		l.Visible = false
		table.insert(lines,l)
	end

	Config.ESPObjects[p] = lines
end

local function updateESP()
	for p,lines in pairs(Config.ESPObjects) do
		if Config.ESP and isValid(p) then
			for i,bone in ipairs(Bones) do
				local a = p.Character:FindFirstChild(bone[1])
				local b = p.Character:FindFirstChild(bone[2])
				local line = lines[i]

				if a and b then
					local ap,ao = Camera:WorldToViewportPoint(a.Position)
					local bp,bo = Camera:WorldToViewportPoint(b.Position)
					if ao and bo then
						line.From = Vector2.new(ap.X,ap.Y)
						line.To = Vector2.new(bp.X,bp.Y)
						line.Visible = true
					else
						line.Visible = false
					end
				else
					line.Visible = false
				end
			end
		else
			for _,l in ipairs(lines) do
				l.Visible = false
			end
		end
	end
end

--// Menu UI
local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.fromOffset(350,260)
Menu.Position = UDim2.fromScale(0.5,0.5) - UDim2.fromOffset(175,130)
Menu.BackgroundColor3 = Color3.fromRGB(25,25,35)
Menu.Visible = false
Instance.new("UICorner",Menu).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel",Menu)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "PC AIMBOT"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(200,100,255)

local function slider(text,y,min,max,default,callback)
	local label = Instance.new("TextLabel",Menu)
	label.Position = UDim2.new(0,15,0,y)
	label.Size = UDim2.new(1,-30,0,20)
	label.BackgroundTransparency = 1
	label.Text = text..": "..default
	label.TextXAlignment = Left
	label.TextColor3 = Color3.new(1,1,1)

	local bar = Instance.new("Frame",Menu)
	bar.Position = UDim2.new(0,15,0,y+25)
	bar.Size = UDim2.new(1,-30,0,8)
	bar.BackgroundColor3 = Color3.fromRGB(60,60,70)
	Instance.new("UICorner",bar)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,80,255)
	Instance.new("UICorner",fill)

	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local move; move = UIS.InputChanged:Connect(function(m)
				if m.UserInputType == Enum.UserInputType.MouseMovement then
					local pct = math.clamp((m.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
					local val = min + (max-min)*pct
					fill.Size = UDim2.new(pct,0,1,0)
					label.Text = text..": "..math.floor(val*100)/100
					callback(val)
				end
			end)
			UIS.InputEnded:Once(function() move:Disconnect() end)
		end
	end)
end

slider("FOV",60,50,500,Config.FOV,function(v)
	Config.FOV = v
	FOVCircle.Radius = v
end)

slider("Smoothness",120,0.05,1,Config.Smoothness,function(v)
	Config.Smoothness = v
end)

--// Input
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end

	if i.KeyCode == Enum.KeyCode.RightShift then
		Config.MenuOpen = not Config.MenuOpen
		Menu.Visible = Config.MenuOpen
	end

	if i.KeyCode == Enum.KeyCode.C then
		Config.Aimbot = not Config.Aimbot
		FOVCircle.Visible = Config.Aimbot
	end

	if i.KeyCode == Enum.KeyCode.X then
		Config.ESP = not Config.ESP
	end
end)

--// Loop
RunService.RenderStepped:Connect(function()
	local c = Camera.ViewportSize/2
	FOVCircle.Position = Vector2.new(c.X,c.Y)

	updateESP()

	if Config.Aimbot then
		Config.Target = getClosest()
		if Config.Target then
			aimAt(Config.Target)
		end
	end
end)

-- Init
for _,p in ipairs(Players:GetPlayers()) do
	if p ~= LP then
		createESP(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.5)
		createESP(p)
	end)
end)

print("PC Aimbot loaded | RightShift = Menu")
