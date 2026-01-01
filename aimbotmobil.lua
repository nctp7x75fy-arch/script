local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- File system setup
local FolderName = "kkavasakisaimbot"
local FileName = "notice_accepted.txt"

local function checkAcceptanceFile()
  local success, result = pcall(function()
    if not isfolder then return false end
    if not isfolder(FolderName) then makefolder(FolderName) end
    return isfile(FolderName .. "/" .. FileName)
  end)
  return success and result
end

local function saveAcceptance()
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    writefile(FolderName .. "/" .. FileName, "Accepted by " .. LocalPlayer.Name .. " on " .. os.date())
  end)
end

-- Configuration
local Config = {
  AimbotEnabled = false,
  ESPEnabled = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOVRadius = 200,
  Smoothness = 0.15,
  NoticeShown = checkAcceptanceFile(),
  ESPBoxes = {},
  LockTarget = nil,
  UpdateConnection = nil,
  ESPColor = Color3.fromRGB(0, 255, 0),
  FOVColor = Color3.fromRGB(255, 255, 255)
}

-- Mobile GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Draggable functionality
local function makeDraggable(gui)
  local dragging = false
  local dragInput, mousePos, framePos
  
  gui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      mousePos = input.Position
      framePos = gui.Position
      
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)
  
  gui.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
      dragInput = input
    end
  end)
  
  UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
      local delta = input.Position - mousePos
      gui.Position = UDim2.new(
        framePos.X.Scale,
        framePos.X.Offset + delta.X,
        framePos.Y.Scale,
        framePos.Y.Offset + delta.Y
      )
    end
  end)
end

local function createButton(name, text, yPos, color)
  local btn = Instance.new("TextButton")
  btn.Name = name
  btn.Size = UDim2.new(0, 80, 0, 80)
  btn.Position = UDim2.new(1, -95, 0, yPos)
  btn.BackgroundColor3 = color
  btn.BorderSizePixel = 0
  btn.Text = text
  btn.TextColor3 = Color3.new(1, 1, 1)
  btn.TextSize = 16
  btn.Font = Enum.Font.GothamBold
  btn.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 15)
  corner.Parent = btn
  
  local stroke = Instance.new("UIStroke")
  stroke.Color = Color3.new(1, 1, 1)
  stroke.Thickness = 2
  stroke.Transparency = 0.7
  stroke.Parent = btn
  
  makeDraggable(btn)
  
  return btn
end

-- Create buttons
local AimbotBtn = createButton("Aimbot", "AIMBOT\nOFF", 80, Color3.fromRGB(60, 60, 70))
local ESPBtn = createButton("ESP", "ESP\nOFF", 175, Color3.fromRGB(60, 60, 70))
local MenuBtn = createButton("Menu", "MENU", 270, Color3.fromRGB(100, 60, 200))
local HideBtn = createButton("Hide", "HIDE", 365, Color3.fromRGB(80, 80, 90))

-- FOV Circle
local FOVCircle
if Drawing then
  FOVCircle = Drawing.new("Circle")
  FOVCircle.Radius = Config.FOVRadius
  FOVCircle.Color = Config.FOVColor
  FOVCircle.Thickness = 2
  FOVCircle.Visible = false
  FOVCircle.Filled = false
  FOVCircle.Transparency = 1
  FOVCircle.NumSides = 50
end

-- Functions
local function isValidTarget(player)
  if not player or player == LocalPlayer then return false end
  local char = player.Character
  if not char then return false end
  local hum = char:FindFirstChild("Humanoid")
  if not hum or hum.Health <= 0 then return false end
  if Config.TeamCheck and player.Team == LocalPlayer.Team and player.Team then return false end
  return true
end

local function getClosestTarget()
  local closest = nil
  local shortestDist = Config.FOVRadius
  local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
  
  for _, player in ipairs(Players:GetPlayers()) do
    if isValidTarget(player) then
      local char = player.Character
      local part = char:FindFirstChild(Config.TargetPart)
      if part then
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen and pos.Z > 0 then
          local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
          if dist < shortestDist then
            closest = player
            shortestDist = dist
          end
        end
      end
    end
  end
  
  return closest
end

local function aimAt(target)
  if not target or not target.Character then return end
  local part = target.Character:FindFirstChild(Config.TargetPart)
  if not part then return end
  
  local targetPos = part.Position
  local camCFrame = Camera.CFrame
  local direction = (targetPos - camCFrame.Position).Unit
  local newCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction)
  
  Camera.CFrame = camCFrame:Lerp(newCFrame, Config.Smoothness)
end

-- Skeleton ESP System
local function createESP(player)
  if not Drawing or Config.ESPBoxes[player] then return end
  
  local esp = {}
  
  -- Create skeleton lines
  esp.Lines = {
    -- Head to Torso
    HeadTorso = Drawing.new("Line"),
    -- Torso to Arms
    TorsoLeftArm = Drawing.new("Line"),
    TorsoRightArm = Drawing.new("Line"),
    -- Arms
    LeftArmLower = Drawing.new("Line"),
    RightArmLower = Drawing.new("Line"),
    -- Torso to Legs
    TorsoLeftLeg = Drawing.new("Line"),
    TorsoRightLeg = Drawing.new("Line"),
    -- Legs
    LeftLegLower = Drawing.new("Line"),
    RightLegLower = Drawing.new("Line")
  }
  
  for _, line in pairs(esp.Lines) do
    line.Thickness = 2
    line.Color = Config.ESPColor
    line.Visible = false
    line.Transparency = 1
  end
  
  esp.Name = Drawing.new("Text")
  esp.Name.Size = 14
  esp.Name.Center = true
  esp.Name.Outline = true
  esp.Name.Color = Config.ESPColor
  esp.Name.Visible = false
  esp.Name.Font = 2
  
  Config.ESPBoxes[player] = esp
end

local function removeESP(player)
  local esp = Config.ESPBoxes[player]
  if esp then
    if esp.Lines then
      for _, line in pairs(esp.Lines) do
        line:Remove()
      end
    end
    if esp.Name then esp.Name:Remove() end
    Config.ESPBoxes[player] = nil
  end
end

local function updateESP()
  if not Config.ESPEnabled then
    for _, esp in pairs(Config.ESPBoxes) do
      for _, line in pairs(esp.Lines) do
        line.Visible = false
      end
      esp.Name.Visible = false
    end
    return
  end
  
  for player, esp in pairs(Config.ESPBoxes) do
    if isValidTarget(player) then
      local char = player.Character
      local head = char:FindFirstChild("Head")
      local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
      local hum = char:FindFirstChild("Humanoid")
      
      if head and torso and hum then
        -- Get all limbs
        local leftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
        local rightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
        local leftLowerArm = char:FindFirstChild("LeftLowerArm")
        local rightLowerArm = char:FindFirstChild("RightLowerArm")
        local leftHand = char:FindFirstChild("LeftHand")
        local rightHand = char:FindFirstChild("RightHand")
        
        local lowerTorso = char:FindFirstChild("LowerTorso")
        local leftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
        local rightUpperLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
        local leftLowerLeg = char:FindFirstChild("LeftLowerLeg")
        local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
        local leftFoot = char:FindFirstChild("LeftFoot")
        local rightFoot = char:FindFirstChild("RightFoot")
        
        local function drawLine(line, part1, part2)
          if part1 and part2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
            
            if onScreen1 and onScreen2 and pos1.Z > 0 and pos2.Z > 0 then
              line.From = Vector2.new(pos1.X, pos1.Y)
              line.To = Vector2.new(pos2.X, pos2.Y)
              line.Color = Config.ESPColor
              line.Visible = true
              return true
            end
          end
          line.Visible = false
          return false
        end
        
        -- Draw skeleton
        local anyVisible = false
        anyVisible = drawLine(esp.Lines.HeadTorso, head, torso) or anyVisible
        
        if leftUpperArm then
          anyVisible = drawLine(esp.Lines.TorsoLeftArm, torso, leftUpperArm) or anyVisible
          if leftLowerArm then
            anyVisible = drawLine(esp.Lines.LeftArmLower, leftUpperArm, leftLowerArm) or anyVisible
            if leftHand then
              anyVisible = drawLine(esp.Lines.LeftArmLower, leftLowerArm, leftHand) or anyVisible
            end
          end
        end
        
        if rightUpperArm then
          anyVisible = drawLine(esp.Lines.TorsoRightArm, torso, rightUpperArm) or anyVisible
          if rightLowerArm then
            anyVisible = drawLine(esp.Lines.RightArmLower, rightUpperArm, rightLowerArm) or anyVisible
            if rightHand then
              anyVisible = drawLine(esp.Lines.RightArmLower, rightLowerArm, rightHand) or anyVisible
            end
          end
        end
        
        local hipBase = lowerTorso or torso
        if leftUpperLeg then
          anyVisible = drawLine(esp.Lines.TorsoLeftLeg, hipBase, leftUpperLeg) or anyVisible
          if leftLowerLeg then
            anyVisible = drawLine(esp.Lines.LeftLegLower, leftUpperLeg, leftLowerLeg) or anyVisible
            if leftFoot then
              anyVisible = drawLine(esp.Lines.LeftLegLower, leftLowerLeg, leftFoot) or anyVisible
            end
          end
        end
        
        if rightUpperLeg then
          anyVisible = drawLine(esp.Lines.TorsoRightLeg, hipBase, rightUpperLeg) or anyVisible
          if rightLowerLeg then
            anyVisible = drawLine(esp.Lines.RightLegLower, rightUpperLeg, rightLowerLeg) or anyVisible
            if rightFoot then
              anyVisible = drawLine(esp.Lines.RightLegLower, rightLowerLeg, rightFoot) or anyVisible
            end
          end
        end
        
        -- Name and info
        if anyVisible then
          local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
          local dist = math.floor((Camera.CFrame.Position - torso.Position).Magnitude)
          local hp = math.floor(hum.Health)
          local maxHp = math.floor(hum.MaxHealth)
          
          esp.Name.Text = player.Name .. " | " .. hp .. "/" .. maxHp .. " | " .. dist .. " studs"
          esp.Name.Position = Vector2.new(headPos.X, headPos.Y)
          esp.Name.Color = Config.ESPColor
          esp.Name.Visible = true
        else
          esp.Name.Visible = false
        end
      else
        for _, line in pairs(esp.Lines) do
          line.Visible = false
        end
        esp.Name.Visible = false
      end
    else
      for _, line in pairs(esp.Lines) do
        line.Visible = false
      end
      esp.Name.Visible = false
    end
  end
end

-- Button Functions
local function toggleAimbot()
  if not Config.NoticeShown then return end
  
  Config.AimbotEnabled = not Config.AimbotEnabled
  
  if Config.AimbotEnabled then
    AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    AimbotBtn.Text = "AIMBOT\nON"
    if FOVCircle then FOVCircle.Visible = true end
  else
    AimbotBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AimbotBtn.Text = "AIMBOT\nOFF"
    if FOVCircle then FOVCircle.Visible = false end
    Config.LockTarget = nil
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = Config.AimbotEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

local function toggleESP()
  if not Config.NoticeShown then return end
  
  Config.ESPEnabled = not Config.ESPEnabled
  
  if Config.ESPEnabled then
    ESPBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    ESPBtn.Text = "ESP\nON"
    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  else
    ESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ESPBtn.Text = "ESP\nOFF"
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = Config.ESPEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

local function showMenu()
  if not Config.NoticeShown then return end
  
  local menu = Instance.new("Frame")
  menu.Name = "Menu"
  menu.Size = UDim2.new(0, 350, 0, 400)
  menu.Position = UDim2.new(0.5, -175, 0.5, -200)
  menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  menu.BorderSizePixel = 0
  menu.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = menu
  
  makeDraggable(menu)
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 35)
  title.Position = UDim2.new(0, 15, 0, 10)
  title.BackgroundTransparency = 1
  title.Text = "🎯 AIMBOT SETTINGS"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 20
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = menu
  
  -- Color Pickers Frame
  local colorsFrame = Instance.new("ScrollingFrame")
  colorsFrame.Size = UDim2.new(1, -30, 0, 290)
  colorsFrame.Position = UDim2.new(0, 15, 0, 55)
  colorsFrame.BackgroundTransparency = 1
  colorsFrame.BorderSizePixel = 0
  colorsFrame.ScrollBarThickness = 6
  colorsFrame.CanvasSize = UDim2.new(0, 0, 0, 290)
  colorsFrame.Parent = menu
  
  local function createColorPicker(name, yPos, currentColor, onChange)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorsFrame
    
    local colors = {
      {Color3.fromRGB(255, 0, 0), "Red"},
      {Color3.fromRGB(0, 255, 0), "Green"},
      {Color3.fromRGB(0, 0, 255), "Blue"},
      {Color3.fromRGB(255, 255, 0), "Yellow"},
      {Color3.fromRGB(255, 0, 255), "Magenta"},
      {Color3.fromRGB(0, 255, 255), "Cyan"},
      {Color3.fromRGB(255, 255, 255), "White"},
      {Color3.fromRGB(255, 128, 0), "Orange"},
      {Color3.fromRGB(128, 0, 255), "Purple"}
    }
    
    for i, colorData in ipairs(colors) do
      local colorBtn = Instance.new("TextButton")
      colorBtn.Size = UDim2.new(0, 30, 0, 30)
      colorBtn.Position = UDim2.new(0, (i-1) * 35, 0, yPos + 30)
      colorBtn.BackgroundColor3 = colorData[1]
      colorBtn.BorderSizePixel = 0
      colorBtn.Text = ""
      colorBtn.Parent = colorsFrame
      
      local btnCorner = Instance.new("UICorner")
      btnCorner.CornerRadius = UDim.new(0, 8)
      btnCorner.Parent = colorBtn
      
      local stroke = Instance.new("UIStroke")
      stroke.Color = Color3.new(1, 1, 1)
      stroke.Thickness = 2
      stroke.Transparency = 0.7
      stroke.Parent = colorBtn
      
      colorBtn.MouseButton1Click:Connect(function()
        onChange(colorData[1])
        game.StarterGui:SetCore("SendNotification", {
          Title = name,
          Text = "Color set to " .. colorData[2],
          Duration = 1
        })
      end)
    end
  end
  
  createColorPicker("ESP Color:", 0, Config.ESPColor, function(color)
    Config.ESPColor = color
  end)
  
  createColorPicker("FOV Color:", 75, Config.FOVColor, function(color)
    Config.FOVColor = color
    if FOVCircle then
      FOVCircle.Color = color
    end
  end)
  
  -- Info section
  local info = Instance.new("TextLabel")
  info.Size = UDim2.new(1, 0, 0, 80)
  info.Position = UDim2.new(0, 0, 0, 160)
  info.BackgroundTransparency = 1
  info.Text = string.format([[Status:
Aimbot: %s | ESP: %s
FOV: %d | Target: %s
Smoothness: %.2f | Team Check: %s]], 
    Config.AimbotEnabled and "ON ✓" or "OFF ✗",
    Config.ESPEnabled and "ON ✓" or "OFF ✗",
    Config.FOVRadius,
    Config.TargetPart,
    Config.Smoothness,
    Config.TeamCheck and "ON" or "OFF"
  )
  info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
  info.TextSize = 13
  info.Font = Enum.Font.Gotham
  info.TextXAlignment = Enum.TextXAlignment.Left
  info.TextYAlignment = Enum.TextYAlignment.Top
  info.Parent = colorsFrame
  
  local credits = Instance.new("TextLabel")
  credits.Size = UDim2.new(1, 0, 0, 20)
  credits.Position = UDim2.new(0, 0, 0, 250)
  credits.BackgroundTransparency = 1
  credits.Text = "Script by kkavasaki__"
  credits.TextColor3 = Color3.fromRGB(200, 100, 255)
  credits.TextSize = 12
  credits.Font = Enum.Font.GothamBold
  credits.TextXAlignment = Enum.TextXAlignment.Left
  credits.Parent = colorsFrame
  
  local closeBtn = Instance.new("TextButton")
  closeBtn.Size = UDim2.new(0, 120, 0, 35)
  closeBtn.Position = UDim2.new(0.5, -60, 1, -45)
  closeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "CLOSE"
  closeBtn.TextColor3 = Color3.new(1, 1, 1)
  closeBtn.TextSize = 16
  closeBtn.Font = Enum.Font.GothamBold
  closeBtn.Parent = menu
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = closeBtn
  
  closeBtn.MouseButton1Click:Connect(function()
    menu:Destroy()
  end)
end

local function toggleButtons()
  local visible = AimbotBtn.Visible
  AimbotBtn.Visible = not visible
  ESPBtn.Visible = not visible
  MenuBtn.Visible = not visible
  HideBtn.Text = visible and "SHOW" or "HIDE"
end

-- Connect buttons
AimbotBtn.MouseButton1Click:Connect(toggleAimbot)
ESPBtn.MouseButton1Click:Connect(toggleESP)
MenuBtn.MouseButton1Click:Connect(showMenu)
HideBtn.MouseButton1Click:Connect(toggleButtons)

-- Main Loop
RunService.RenderStepped:Connect(function()
  -- Update FOV Circle
  if FOVCircle then
    local center = Camera.ViewportSize / 2
    FOVCircle.Position = Vector2.new(center.X, center.Y)
  end
  
  -- Update ESP
  updateESP()
  
  -- Aimbot - Always get closest target
  if Config.AimbotEnabled then
    local newTarget = getClosestTarget()
    
    if newTarget and newTarget ~= Config.LockTarget then
      Config.LockTarget = newTarget
      game.StarterGui:SetCore("SendNotification", {
        Title = "Target Locked",
        Text = Config.LockTarget.Name,
        Duration = 1
      })
    elseif not newTarget then
      Config.LockTarget = nil
    end
    
    if Config.LockTarget then
      aimAt(Config.LockTarget)
    end
  end
end)

-- Player Events
Players.PlayerRemoving:Connect(function(player)
  removeESP(player)
  if Config.LockTarget == player then
    Config.LockTarget = nil
  end
end)

Players.PlayerAdded:Connect(function(player)
  player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Config.ESPEnabled then
      createESP(player)
    end
  end)
end)

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
  if player ~= LocalPlayer then
    createESP(player)
  end
end

-- Notice GUI
if not Config.NoticeShown then
  local notice = Instance.new("Frame")
  notice.Size = UDim2.new(0, 340, 0, 320)
  notice.Position = UDim2.new(0.5, -170, 0.5, -160)
  notice.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  notice.BorderSizePixel = 0
  notice.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = notice
  
  makeDraggable(notice)
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 35)
  title.Position = UDim2.new(0, 15, 0, 15)
  title.BackgroundTransparency = 1
  title.Text = "⚠️ MOBILE AIMBOT"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 22
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = notice
  
  local msg = Instance.new("TextLabel")
  msg.Size = UDim2.new(1, -30, 0, 190)
  msg.Position = UDim2.new(0, 15, 0, 60)
  msg.BackgroundTransparency = 1
  msg.Text = [[Mobile aimbot ready!

Features:
• Skeleton ESP
• Customizable Colors
• Drag to move buttons
• Auto target switching

Buttons (right side):
• AIMBOT - Toggle aimbot
• ESP - Toggle skeleton ESP
• MENU - Change colors
• HIDE - Hide buttons

Script by kkavasaki__]]
  msg.TextColor3 = Color3.new(0.9, 0.9, 0.9)
  msg.TextSize = 13
  msg.Font = Enum.Font.Gotham
  msg.TextWrapped = true
  msg.TextXAlignment = Enum.TextXAlignment.Left
  msg.TextYAlignment = Enum.TextYAlignment.Top
  msg.Parent = notice
  
  local okBtn = Instance.new("TextButton")
  okBtn.Size = UDim2.new(0, 140, 0, 40)
  okBtn.Position = UDim2.new(0.5, -70, 1, -55)
  okBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  okBtn.BorderSizePixel = 0
  okBtn.Text = "OK"
  okBtn.TextColor3 = Color3.new(1, 1, 1)
  okBtn.TextSize = 18
  okBtn.Font = Enum.Font.GothamBold
  okBtn.Parent = notice
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = okBtn
  
  okBtn.MouseButton1Click:Connect(function()
    Config.NoticeShown = true
    saveAcceptance()
    notice:Destroy()
    game.StarterGui:SetCore("SendNotification", {
      Title = "Aimbot Ready",
      Text = "Open MENU to customize colors!",
      Duration = 3
    })
  end)
else
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot Loaded",
    Text = "Skeleton ESP & Custom Colors!",
    Duration = 2
  })
end

ScreenGui.Parent = game:GetService("CoreGui")

print("Mobile Aimbot with Skeleton ESP loaded by kkavasaki__")
