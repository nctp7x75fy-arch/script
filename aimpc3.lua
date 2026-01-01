local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- File system setup
local FolderName = "kkavasakisaimbot"
local KeybindsFile = "keybinds.json"

local function loadKeybinds()
  local success, result = pcall(function()
    if not isfile or not readfile then return nil end
    if not isfile(FolderName .. "/" .. KeybindsFile) then return nil end
    local data = readfile(FolderName .. "/" .. KeybindsFile)
    return game:GetService("HttpService"):JSONDecode(data)
  end)
  return success and result or nil
end

local function saveKeybinds(keybinds)
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    local data = game:GetService("HttpService"):JSONEncode(keybinds)
    writefile(FolderName .. "/" .. KeybindsFile, data)
  end)
end

-- Configuration
local savedKeybinds = loadKeybinds()
local Config = {
  AimbotEnabled = false,
  ESPEnabled = false,
  MenuOpen = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOVRadius = 300,
  Sensitivity = 0.5,
  PredictionEnabled = true,
  PredictionStrength = 0.15,
  ESPBoxes = {},
  LockTarget = nil,
  ESPColor = Color3.fromRGB(0, 255, 0),
  FOVColor = Color3.fromRGB(255, 255, 255),
  Keybinds = savedKeybinds or {
    Aimbot = Enum.KeyCode.C,
    ESP = Enum.KeyCode.X,
    Menu = Enum.KeyCode.RightShift
  },
  WaitingForKeybind = nil,
  ShakeReduction = true
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PCAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

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

-- Update FOV position
RunService.RenderStepped:Connect(function()
  if FOVCircle then
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
  end
end)

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
  local mousePos = Vector2.new(Mouse.X, Mouse.Y)
  
  for _, player in ipairs(Players:GetPlayers()) do
    if isValidTarget(player) then
      local char = player.Character
      local part = char:FindFirstChild(Config.TargetPart)
      if part then
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen and pos.Z > 0 then
          local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
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
  
  -- Velocity prediction
  if Config.PredictionEnabled then
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
      local velocity = humanoidRootPart.AssemblyLinearVelocity
      if velocity.Magnitude > 0 then
        targetPos = targetPos + (velocity * Config.PredictionStrength)
      end
    end
  end
  
  -- Camera lock with sensitivity
  local targetScreenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
  
  if onScreen and targetScreenPos.Z > 0 then
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
    local aimPosition = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
    local movement = (aimPosition - mousePosition) * Config.Sensitivity
    
    if Config.ShakeReduction then
      -- Direct camera aim for instant lock
      local camCFrame = Camera.CFrame
      local direction = (targetPos - camCFrame.Position).Unit
      Camera.CFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction)
    else
      -- Mouse movement for smoother aim
      if mousemoverel then
        mousemoverel(movement.X, movement.Y)
      end
    end
  end
end

-- Skeleton ESP System
local function createESP(player)
  if not Drawing or Config.ESPBoxes[player] then return end
  
  local esp = {}
  
  esp.Lines = {
    HeadTorso = Drawing.new("Line"),
    TorsoLeftArm = Drawing.new("Line"),
    TorsoRightArm = Drawing.new("Line"),
    LeftArmLower = Drawing.new("Line"),
    RightArmLower = Drawing.new("Line"),
    TorsoLeftLeg = Drawing.new("Line"),
    TorsoRightLeg = Drawing.new("Line"),
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

-- Toggle Functions
local function toggleAimbot()
  Config.AimbotEnabled = not Config.AimbotEnabled
  
  if Config.AimbotEnabled then
    if FOVCircle then FOVCircle.Visible = true end
  else
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
  Config.ESPEnabled = not Config.ESPEnabled
  
  if Config.ESPEnabled then
    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = Config.ESPEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

-- Menu System
local function getKeyCodeName(keycode)
  return string.gsub(tostring(keycode), "Enum.KeyCode.", "")
end

local function createMenu()
  if Config.MenuOpen then return end
  Config.MenuOpen = true
  
  local menu = Instance.new("Frame")
  menu.Name = "Menu"
  menu.Size = UDim2.new(0, 420, 0, 640)
  menu.Position = UDim2.new(0.5, -210, 0.5, -320)
  menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
  menu.BorderSizePixel = 0
  menu.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = menu
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 40)
  title.Position = UDim2.new(0, 15, 0, 10)
  title.BackgroundTransparency = 1
  title.Text = "🎯 PC AIMBOT SETTINGS"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 22
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = menu
  
  -- Keybinds Section
  local keybindsTitle = Instance.new("TextLabel")
  keybindsTitle.Size = UDim2.new(1, -30, 0, 25)
  keybindsTitle.Position = UDim2.new(0, 15, 0, 60)
  keybindsTitle.BackgroundTransparency = 1
  keybindsTitle.Text = "⌨️ KEYBINDS"
  keybindsTitle.TextColor3 = Color3.new(1, 1, 1)
  keybindsTitle.TextSize = 18
  keybindsTitle.Font = Enum.Font.GothamBold
  keybindsTitle.TextXAlignment = Enum.TextXAlignment.Left
  keybindsTitle.Parent = menu
  
  local function createKeybindButton(name, yPos, keybindKey)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -20, 0, 35)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ":"
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 35)
    btn.Position = UDim2.new(0.55, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel = 0
    btn.Text = getKeyCodeName(Config.Keybinds[keybindKey])
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = menu
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
      Config.WaitingForKeybind = keybindKey
      btn.Text = "Press a key..."
      btn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    end)
    
    return btn
  end
  
  local aimbotBtn = createKeybindButton("Aimbot Toggle", 95, "Aimbot")
  local espBtn = createKeybindButton("ESP Toggle", 140, "ESP")
  local menuBtn = createKeybindButton("Menu Toggle", 185, "Menu")
  
  -- Settings Section
  local settingsTitle = Instance.new("TextLabel")
  settingsTitle.Size = UDim2.new(1, -30, 0, 25)
  settingsTitle.Position = UDim2.new(0, 15, 0, 235)
  settingsTitle.BackgroundTransparency = 1
  settingsTitle.Text = "⚙️ AIMBOT SETTINGS"
  settingsTitle.TextColor3 = Color3.new(1, 1, 1)
  settingsTitle.TextSize = 18
  settingsTitle.Font = Enum.Font.GothamBold
  settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
  settingsTitle.Parent = menu
  
  local function createToggle(name, yPos, configKey)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 30)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 70, 0, 30)
    toggle.Position = UDim2.new(1, -85, 0, yPos)
    toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    toggle.BorderSizePixel = 0
    toggle.Text = Config[configKey] and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 13
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = menu
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
      Config[configKey] = not Config[configKey]
      toggle.Text = Config[configKey] and "ON" or "OFF"
      toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    end)
  end
  
  createToggle("Velocity Prediction", 270, "PredictionEnabled")
  createToggle("Shake Reduction (Camera Lock)", 310, "ShakeReduction")
  createToggle("Team Check", 350, "TeamCheck")
  
  -- Color Section
  local colorTitle = Instance.new("TextLabel")
  colorTitle.Size = UDim2.new(1, -30, 0, 25)
  colorTitle.Position = UDim2.new(0, 15, 0, 395)
  colorTitle.BackgroundTransparency = 1
  colorTitle.Text = "🎨 COLORS"
  colorTitle.TextColor3 = Color3.new(1, 1, 1)
  colorTitle.TextSize = 18
  colorTitle.Font = Enum.Font.GothamBold
  colorTitle.TextXAlignment = Enum.TextXAlignment.Left
  colorTitle.Parent = menu
  
  local function createColorPicker(name, yPos, currentColor, onChange)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
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
      colorBtn.Size = UDim2.new(0, 35, 0, 35)
      colorBtn.Position = UDim2.new(0, 15 + (i-1) * 42, 0, yPos + 25)
      colorBtn.BackgroundColor3 = colorData[1]
      colorBtn.BorderSizePixel = 0
      colorBtn.Text = ""
      colorBtn.Parent = menu
      
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
          Text = "Set to " .. colorData[2],
          Duration = 1
        })
      end)
    end
  end
  
  createColorPicker("ESP Color:", 430, Config.ESPColor, function(color)
    Config.ESPColor = color
  end)
  
  createColorPicker("FOV Color:", 500, Config.FOVColor, function(color)
    Config.FOVColor = color
    if FOVCircle then FOVCircle.Color = color end
  end)
  
  -- Info
  local info = Instance.new("TextLabel")
  info.Size = UDim2.new(1, -30, 0, 40)
  info.Position = UDim2.new(0, 15, 0, 570)
  info.BackgroundTransparency = 1
  info.Text = "Status: Aimbot [" .. (Config.AimbotEnabled and "ON" or "OFF") .. "] | ESP [" .. (Config.ESPEnabled and "ON" or "OFF") .. "]\nCamera Lock Mode | FOV: " .. Config.FOVRadius .. " | Script by kkavasaki__"
  info.TextColor3 = Color3.new(0.7, 0.7, 0.7)
  info.TextSize = 12
  info.Font = Enum.Font.Gotham
  info.TextXAlignment = Enum.TextXAlignment.Left
  info.TextYAlignment = Enum.TextYAlignment.Top
  info.Parent = menu
  
  local closeBtn = Instance.new("TextButton")
  closeBtn.Size = UDim2.new(0, 140, 0, 35)
  closeBtn.Position = UDim2.new(0.5, -70, 1, -50)
  closeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "CLOSE (RightShift)"
  closeBtn.TextColor3 = Color3.new(1, 1, 1)
  closeBtn.TextSize = 14
  closeBtn.Font = Enum.Font.GothamBold
  closeBtn.Parent = menu
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = closeBtn
  
  local function closeMenu()
    Config.MenuOpen = false
    menu:Destroy()
  end
  
  closeBtn.MouseButton1Click:Connect(closeMenu)
  
  -- Update keybind buttons
  local keybindButtons = {aimbotBtn, espBtn, menuBtn}
  local keybindKeys = {"Aimbot", "ESP", "Menu"}
  
  RunService.RenderStepped:Connect(function()
    if not menu.Parent then return end
    for i, btn in ipairs(keybindButtons) do
      if Config.WaitingForKeybind ~= keybindKeys[i] then
        btn.Text = getKeyCodeName(Config.Keybinds[keybindKeys[i]])
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
      end
    end
  end)
  
  return closeMenu
end

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed then return end
  
  -- Handle keybind assignment
  if Config.WaitingForKeybind then
    if input.KeyCode ~= Enum.KeyCode.Unknown then
      Config.Keybinds[Config.WaitingForKeybind] = input.KeyCode
      saveKeybinds(Config.Keybinds)
      game.StarterGui:SetCore("SendNotification", {
        Title = "Keybind Updated",
        Text = Config.WaitingForKeybind .. " set to " .. getKeyCodeName(input.KeyCode),
        Duration = 2
      })
      Config.WaitingForKeybind = nil
    end
    return
  end
  
  -- Handle keybind actions
  if input.KeyCode == Config.Keybinds.Aimbot then
    toggleAimbot()
    Config.LockTarget = nil
  elseif input.KeyCode == Config.Keybinds.ESP then
    toggleESP()
  elseif input.KeyCode == Config.Keybinds.Menu then
    if Config.MenuOpen then
      local menu = ScreenGui:FindFirstChild("Menu")
      if menu then
        Config.MenuOpen = false
        menu:Destroy()
      end
    else
      createMenu()
    end
  end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
  updateESP()
  
  if Config.AimbotEnabled then
    -- Check if current target is still valid
    if Config.LockTarget and not isValidTarget(Config.LockTarget) then
      Config.LockTarget = nil
    end
    
    -- Get new target if needed
    if not Config.LockTarget then
      local newTarget = getClosestTarget()
      if newTarget then
        Config.LockTarget = newTarget
        game.StarterGui:SetCore("SendNotification", {
          Title = "Target Locked",
          Text = "Locked onto " .. newTarget.Name,
          Duration = 1.5
        })
      end
    end
    
    -- Aim at locked target
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
    if Config.AimbotEnabled then
      game.StarterGui:SetCore("SendNotification", {
        Title = "Target Lost",
        Text = "Target left the game",
        Duration = 1.5
      })
    end
  end
end)

Playerslocal UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- File system setup
local FolderName = "kkavasakisaimbot"
local KeybindsFile = "keybinds.json"

local function loadKeybinds()
  local success, result = pcall(function()
    if not isfile or not readfile then return nil end
    if not isfile(FolderName .. "/" .. KeybindsFile) then return nil end
    local data = readfile(FolderName .. "/" .. KeybindsFile)
    return game:GetService("HttpService"):JSONDecode(data)
  end)
  return success and result or nil
end

local function saveKeybinds(keybinds)
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    local data = game:GetService("HttpService"):JSONEncode(keybinds)
    writefile(FolderName .. "/" .. KeybindsFile, data)
  end)
end

-- Configuration
local savedKeybinds = loadKeybinds()
local Config = {
  AimbotEnabled = false,
  ESPEnabled = false,
  MenuOpen = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOVRadius = 300,
  Sensitivity = 0.5,
  PredictionEnabled = true,
  PredictionStrength = 0.15,
  ESPBoxes = {},
  LockTarget = nil,
  ESPColor = Color3.fromRGB(0, 255, 0),
  FOVColor = Color3.fromRGB(255, 255, 255),
  Keybinds = savedKeybinds or {
    Aimbot = Enum.KeyCode.C,
    ESP = Enum.KeyCode.X,
    Menu = Enum.KeyCode.RightShift
  },
  WaitingForKeybind = nil,
  ShakeReduction = true
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PCAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

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

-- Update FOV position
RunService.RenderStepped:Connect(function()
  if FOVCircle then
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
  end
end)

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
  local mousePos = Vector2.new(Mouse.X, Mouse.Y)
  
  for _, player in ipairs(Players:GetPlayers()) do
    if isValidTarget(player) then
      local char = player.Character
      local part = char:FindFirstChild(Config.TargetPart)
      if part then
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen and pos.Z > 0 then
          local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
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
  
  -- Velocity prediction
  if Config.PredictionEnabled then
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
      local velocity = humanoidRootPart.AssemblyLinearVelocity
      if velocity.Magnitude > 0 then
        targetPos = targetPos + (velocity * Config.PredictionStrength)
      end
    end
  end
  
  -- Camera lock with sensitivity
  local targetScreenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
  
  if onScreen and targetScreenPos.Z > 0 then
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
    local aimPosition = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
    local movement = (aimPosition - mousePosition) * Config.Sensitivity
    
    if Config.ShakeReduction then
      -- Direct camera aim for instant lock
      local camCFrame = Camera.CFrame
      local direction = (targetPos - camCFrame.Position).Unit
      Camera.CFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction)
    else
      -- Mouse movement for smoother aim
      if mousemoverel then
        mousemoverel(movement.X, movement.Y)
      end
    end
  end
end

-- Skeleton ESP System
local function createESP(player)
  if not Drawing or Config.ESPBoxes[player] then return end
  
  local esp = {}
  
  esp.Lines = {
    HeadTorso = Drawing.new("Line"),
    TorsoLeftArm = Drawing.new("Line"),
    TorsoRightArm = Drawing.new("Line"),
    LeftArmLower = Drawing.new("Line"),
    RightArmLower = Drawing.new("Line"),
    TorsoLeftLeg = Drawing.new("Line"),
    TorsoRightLeg = Drawing.new("Line"),
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

-- Toggle Functions
local function toggleAimbot()
  Config.AimbotEnabled = not Config.AimbotEnabled
  
  if Config.AimbotEnabled then
    if FOVCircle then FOVCircle.Visible = true end
  else
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
  Config.ESPEnabled = not Config.ESPEnabled
  
  if Config.ESPEnabled then
    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = Config.ESPEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

-- Menu System
local function getKeyCodeName(keycode)
  return string.gsub(tostring(keycode), "Enum.KeyCode.", "")
end

local function createMenu()
  if Config.MenuOpen then return end
  Config.MenuOpen = true
  
  local menu = Instance.new("Frame")
  menu.Name = "Menu"
  menu.Size = UDim2.new(0, 420, 0, 640)
  menu.Position = UDim2.new(0.5, -210, 0.5, -320)
  menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
  menu.BorderSizePixel = 0
  menu.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = menu
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 40)
  title.Position = UDim2.new(0, 15, 0, 10)
  title.BackgroundTransparency = 1
  title.Text = "🎯 PC AIMBOT SETTINGS"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 22
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = menu
  
  -- Keybinds Section
  local keybindsTitle = Instance.new("TextLabel")
  keybindsTitle.Size = UDim2.new(1, -30, 0, 25)
  keybindsTitle.Position = UDim2.new(0, 15, 0, 60)
  keybindsTitle.BackgroundTransparency = 1
  keybindsTitle.Text = "⌨️ KEYBINDS"
  keybindsTitle.TextColor3 = Color3.new(1, 1, 1)
  keybindsTitle.TextSize = 18
  keybindsTitle.Font = Enum.Font.GothamBold
  keybindsTitle.TextXAlignment = Enum.TextXAlignment.Left
  keybindsTitle.Parent = menu
  
  local function createKeybindButton(name, yPos, keybindKey)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -20, 0, 35)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ":"
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 35)
    btn.Position = UDim2.new(0.55, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel = 0
    btn.Text = getKeyCodeName(Config.Keybinds[keybindKey])
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = menu
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
      Config.WaitingForKeybind = keybindKey
      btn.Text = "Press a key..."
      btn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    end)
    
    return btn
  end
  
  local aimbotBtn = createKeybindButton("Aimbot Toggle", 95, "Aimbot")
  local espBtn = createKeybindButton("ESP Toggle", 140, "ESP")
  local menuBtn = createKeybindButton("Menu Toggle", 185, "Menu")
  
  -- Settings Section
  local settingsTitle = Instance.new("TextLabel")
  settingsTitle.Size = UDim2.new(1, -30, 0, 25)
  settingsTitle.Position = UDim2.new(0, 15, 0, 235)
  settingsTitle.BackgroundTransparency = 1
  settingsTitle.Text = "⚙️ AIMBOT SETTINGS"
  settingsTitle.TextColor3 = Color3.new(1, 1, 1)
  settingsTitle.TextSize = 18
  settingsTitle.Font = Enum.Font.GothamBold
  settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
  settingsTitle.Parent = menu
  
  local function createToggle(name, yPos, configKey)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 30)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 70, 0, 30)
    toggle.Position = UDim2.new(1, -85, 0, yPos)
    toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    toggle.BorderSizePixel = 0
    toggle.Text = Config[configKey] and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 13
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = menu
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
      Config[configKey] = not Config[configKey]
      toggle.Text = Config[configKey] and "ON" or "OFF"
      toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    end)
  end
  
  createToggle("Velocity Prediction", 270, "PredictionEnabled")
  createToggle("Shake Reduction (Camera Lock)", 310, "ShakeReduction")
  createToggle("Team Check", 350, "TeamCheck")
  
  -- Color Section
  local colorTitle = Instance.new("TextLabel")
  colorTitle.Size = UDim2.new(1, -30, 0, 25)
  colorTitle.Position = UDim2.new(0, 15, 0, 395)
  colorTitle.BackgroundTransparency = 1
  colorTitle.Text = "🎨 COLORS"
  colorTitle.TextColor3 = Color3.new(1, 1, 1)
  colorTitle.TextSize = 18
  colorTitle.Font = Enum.Font.GothamBold
  colorTitle.TextXAlignment = Enum.TextXAlignment.Left
  colorTitle.Parent = menu
  
  local function createColorPicker(name, yPos, currentColor, onChange)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = menu
    
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
      colorBtn.Size = UDim2.new(0, 35, 0, 35)
      colorBtn.Position = UDim2.new(0, 15 + (i-1) * 42, 0, yPos + 25)
      colorBtn.BackgroundColor3 = colorData[1]
      colorBtn.BorderSizePixel = 0
      colorBtn.Text = ""
      colorBtn.Parent = menu
      
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
          Text = "Set to " .. colorData[2],
          Duration = 1
        })
      end)
    end
  end
  
  createColorPicker("ESP Color:", 430, Config.ESPColor, function(color)
    Config.ESPColor = color
  end)
  
  createColorPicker("FOV Color:", 500, Config.FOVColor, function(color)
    Config.FOVColor = color
    if FOVCircle then FOVCircle.Color = color end
  end)
  
  -- Info
  local info = Instance.new("TextLabel")
  info.Size = UDim2.new(1, -30, 0, 40)
  info.Position = UDim2.new(0, 15, 0, 570)
  info.BackgroundTransparency = 1
  info.Text = "Status: Aimbot [" .. (Config.AimbotEnabled and "ON" or "OFF") .. "] | ESP [" .. (Config.ESPEnabled and "ON" or "OFF") .. "]\nCamera Lock Mode | FOV: " .. Config.FOVRadius .. " | Script by kkavasaki__"
  info.TextColor3 = Color3.new(0.7, 0.7, 0.7)
  info.TextSize = 12
  info.Font = Enum.Font.Gotham
  info.TextXAlignment = Enum.TextXAlignment.Left
  info.TextYAlignment = Enum.TextYAlignment.Top
  info.Parent = menu
  
  local closeBtn = Instance.new("TextButton")
  closeBtn.Size = UDim2.new(0, 140, 0, 35)
  closeBtn.Position = UDim2.new(0.5, -70, 1, -50)
  closeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "CLOSE (RightShift)"
  closeBtn.TextColor3 = Color3.new(1, 1, 1)
  closeBtn.TextSize = 14
  closeBtn.Font = Enum.Font.GothamBold
  closeBtn.Parent = menu
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = closeBtn
  
  local function closeMenu()
    Config.MenuOpen = false
    menu:Destroy()
  end
  
  closeBtn.MouseButton1Click:Connect(closeMenu)
  
  -- Update keybind buttons
  local keybindButtons = {aimbotBtn, espBtn, menuBtn}
  local keybindKeys = {"Aimbot", "ESP", "Menu"}
  
  RunService.RenderStepped:Connect(function()
    if not menu.Parent then return end
    for i, btn in ipairs(keybindButtons) do
      if Config.WaitingForKeybind ~= keybindKeys[i] then
        btn.Text = getKeyCodeName(Config.Keybinds[keybindKeys[i]])
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
      end
    end
  end)
  
  return closeMenu
end

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed then return end
  
  -- Handle keybind assignment
  if Config.WaitingForKeybind then
    if input.KeyCode ~= Enum.KeyCode.Unknown then
      Config.Keybinds[Config.WaitingForKeybind] = input.KeyCode
      saveKeybinds(Config.Keybinds)
      game.StarterGui:SetCore("SendNotification", {
        Title = "Keybind Updated",
        Text = Config.WaitingForKeybind .. " set to " .. getKeyCodeName(input.KeyCode),
        Duration = 2
      })
      Config.WaitingForKeybind = nil
    end
    return
  end
  
  -- Handle keybind actions
  if input.KeyCode == Config.Keybinds.Aimbot then
    toggleAimbot()
    Config.LockTarget = nil
  elseif input.KeyCode == Config.Keybinds.ESP then
    toggleESP()
  elseif input.KeyCode == Config.Keybinds.Menu then
    if Config.MenuOpen then
      local menu = ScreenGui:FindFirstChild("Menu")
      if menu then
        Config.MenuOpen = false
        menu:Destroy()
      end
    else
      createMenu()
    end
  end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
  updateESP()
  
  if Config.AimbotEnabled then
    -- Check if current target is still valid
    if Config.LockTarget and not isValidTarget(Config.LockTarget) then
      Config.LockTarget = nil
    end
    
    -- Get new target if needed
    if not Config.LockTarget then
      local newTarget = getClosestTarget()
      if newTarget then
        Config.LockTarget = newTarget
        game.StarterGui:SetCore("SendNotification", {
          Title = "Target Locked",
          Text = "Locked onto " .. newTarget.Name,
          Duration = 1.5
        })
      end
    end
    
    -- Aim at locked target
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
    if Config.AimbotEnabled then
      game.StarterGui:SetCore("SendNotification", {
        Title = "Target Lost",
        Text = "Target left the game",
        Duration = 1.5
      })
    end
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

ScreenGui.Parent = game:GetService("CoreGui")

game.StarterGui:SetCore("SendNotification", {
  Title = "PC Aimbot Loaded",
  Text = "Press " .. getKeyCodeName(Config.Keybinds.Menu) .. " to open menu",
  Duration = 5
})

print("PC Aimbot loaded by kkavasaki__")
print("Default Keybinds:")
print("Aimbot: " .. getKeyCodeName(Config.Keybinds.Aimbot))
print("ESP: " .. getKeyCodeName(Config.Keybinds.ESP))
print("Menu: " .. getKeyCodeName(Config.Keybinds.Menu))
print("Using Camera Lock Mode")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- File system setup
local FolderName = "kkavasakisaimbot"
local KeybindsFile = "keybinds.json"

local function loadKeybinds()
  local success, result = pcall(function()
    if not isfile or not readfile then return nil end
    if not isfile(FolderName .. "/" .. KeybindsFile) then return nil end
    local data = readfile(FolderName .. "/" .. KeybindsFile)
    return game:GetService("HttpService"):JSONDecode(data)
  end)
  return success and result or nil
end

local function saveKeybinds(keybinds)
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    local data = game:GetService("HttpService"):JSONEncode(keybinds)
    writefile(FolderName .. "/" .. KeybindsFile, data)
  end)
end

-- Configuration
local savedKeybinds = loadKeybinds()
local Config = {
  AimbotEnabled = false,
  ESPEnabled = false,
  MenuOpen = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOVRadius = 300,
  Sensitivity = 0.5,
  PredictionEnabled = true,
  PredictionStrength = 0.15,
  ESPBoxes = {},
  LockTarget = nil,
  ESPColor = Color3.fromRGB(0, 255, 0),
  FOVColor = Color3.fromRGB(255, 255, 255),
  Keybinds = savedKeybinds or {
    Aimbot = Enum.KeyCode.C,
    ESP = Enum.KeyCode.X,
    Menu = Enum.KeyCode.RightShift
  },
  WaitingForKeybind = nil,
  ShakeReduction = true
}
