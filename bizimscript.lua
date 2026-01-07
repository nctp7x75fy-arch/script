-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "bizimscriptler Hub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Emre",
    Folder = "bizimscriptler",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("User clicked") end,
        Anonymous = false
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
    local function toggleMenu()
    local WindUIObjects = CoreGui:FindFirstChild("WindUI")
    
    if WindUIObjects then
        local mainWindow = WindUIObjects:FindFirstChildOfClass("ScreenGui")
        if mainWindow then
            mainWindow.Enabled = not mainWindow.Enabled
        end
    end
end

-- '.' tuşuna basıldığında menüyü aç/kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Oyun işlediyse (örn: sohbet kutusu) atla
    
    -- '.' (Period) tuşunu kontrol et
    if input.KeyCode == Enum.KeyCode.Period then
        toggleMenu()
    end
end)

-- Eğer Numpad'deki '.' tuşunu da kullanmak isterseniz:
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Numpad . (NumpadDecimal) tuşu
    if input.KeyCode == Enum.KeyCode.NumpadDecimal then
        toggleMenu()
    end
end)
    -- Key System
    KeySystem = {
        Key = { "simpleCS2" },
        Note = "Ekrem abiye sor",
        SaveKey = true,
        URL = "https://discord.gg/yourserver"
    },
})

-- Create Sections and Tabs
local MainSection = Window:Section({
    Title = "Main Scripts",
    Icon = "home",
    Opened = true,
})

local GameScriptsSection = Window:Section({
    Title = "Game Scripts",
    Icon = "gamepad-2",
    Opened = true,
})

local FunScriptsSection = Window:Section({
    Title = "Fun Scripts",
    Icon = "smile",
    Opened = true,
})

local PlayerSection = Window:Section({
    Title = "Player",
    Icon = "user",
    Opened = true,
})

local GameSpecificSection = Window:Section({
    Title = "Game Specific",
    Icon = "target",
    Opened = true,
})

-- Create Tabs
local MainTab = MainSection:Tab({ Title = "Main", Icon = "home" })
local GameScriptsTab = GameScriptsSection:Tab({ Title = "Game Scripts", Icon = "gamepad-2" })
local FunScriptsTab = FunScriptsSection:Tab({ Title = "Fun Scripts", Icon = "smile" })
local PlayerTab = PlayerSection:Tab({ Title = "Player", Icon = "user" })
local InfectiousTab = GameSpecificSection:Tab({ Title = "Infectious Smile", Icon = "skull" })
local ForsakenTab = GameSpecificSection:Tab({ Title = "Forsaken", Icon = "shield" })

-- ==== MAIN TAB ====
MainTab:Button({
    Title = "Infinite Yield",
    Desc = "Universal admin script",
    Icon = "infinity",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MainTab:Button({
    Title = "Azure Script",
    Desc = "Modded Azure script",
    Icon = "cloud",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Actyrn/Scripts/main/AzureModded"))()
    end
})

MainTab:Button({
    Title = "FE Emote",
    Desc = "Frontend emote script",
    Icon = "smile",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gi7331/scripts/main/Emote.lua"))()
    end
})

MainTab:Button({
    Title = "Air Hub Script",
    Desc = "Air Hub universal script",
    Icon = "wind",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/AirHub.lua"))()
    end
})

-- ==== GAME SCRIPTS TAB ====
GameScriptsTab:Button({
    Title = "MM2 Script",
    Desc = "Murder Mystery 2 script",
    Icon = "knife",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/psychic-octo-invention/main/source/yarhm/1.18/yarhm.lua"))()
    end
})

GameScriptsTab:Button({
    Title = "Arsenal Script",
    Desc = "Arsenal FPS script",
    Icon = "crosshair",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/G6Ubkkuv"))()
    end
})

GameScriptsTab:Button({
    Title = "Bedwars Script",
    Desc = "Bedwars Vape V4 script",
    Icon = "bed",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
    end
})

GameScriptsTab:Button({
    Title = "Blox Fruit Script",
    Desc = "Blox Fruits script",
    Icon = "apple",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))()
    end
})

GameScriptsTab:Button({
    Title = "Grow a Garden Script",
    Desc = "Garden growing script",
    Icon = "flower",
    Callback = function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Loader/LoaderV1.lua"))()
    end
})

GameScriptsTab:Button({
    Title = "Bee Swarm Simulator",
    Desc = "Bee Swarm Simulator script",
    Icon = "bug",
    Callback = function()
        local obj = game:GetObjects("rbxassetid://4384103988")[1]
        if obj then
            obj.Parent = game.Players.LocalPlayer.PlayerGui
        end
    end
})

GameScriptsTab:Button({
    Title = "Forsaken Script",
    Desc = "Forsaken game script",
    Icon = "shield",
    Callback = function()
        loadstring(game:HttpGet("https://rifton.top/loader.lua"))()
    end
})

-- ==== FUN SCRIPTS TAB ====
FunScriptsTab:Button({
    Title = "Jerk off R6 Script",
    Desc = "R6 animation script",
    Icon = "user",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
    end
})

FunScriptsTab:Button({
    Title = "Jerk off R15 Script",
    Desc = "R15 animation script",
    Icon = "user",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
    end
})

FunScriptsTab:Button({
    Title = "Fling ALL Script",
    Desc = "Fling all players script",
    Icon = "zap",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wemre3131/Scripts/refs/heads/main/Fling"))()
    end
})

-- ==== PLAYER TAB ====
-- Walkspeed Slider
PlayerTab:Slider({
    Title = "Walkspeed",
    Desc = "Adjust your walking speed",
    Value = {
        Min = 16,
        Max = 500,
        Default = 16,
    },
    Callback = function(speed)
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
})

-- Jumppower Slider
PlayerTab:Slider({
    Title = "Jumppower",
    Desc = "Adjust your jump power",
    Value = {
        Min = 50,
        Max = 500,
        Default = 50,
    },
    Callback = function(power)
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
        end
    end
})

-- TP Tool
PlayerTab:Button({
    Title = "TP Tool",
    Desc = "Get a teleport tool",
    Icon = "move",
    Callback = function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Tp tool"
        tool.Activated:Connect(function()
            local pos = mouse.Hit + Vector3.new(0,2.5,0)
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then 
                hrp.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) 
            end
        end)
        tool.Parent = game.Players.LocalPlayer.Backpack
    end
})

-- Instant React
PlayerTab:Button({
    Title = "Instant React",
    Desc = "Instantly interact with proximity prompts",
    Icon = "zap",
    Callback = function()
        local ProximityPromptService = game:GetService("ProximityPromptService")
        local instantInteractEnabled = true

        ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
            if instantInteractEnabled then
                fireproximityprompt(prompt)
            end
        end)
    end
})

-- Noclip
PlayerTab:Button({
    Title = "Noclip (Press N)",
    Desc = "Toggle noclip with N key",
    Icon = "ghost",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")

        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local noclipEnabled = false

        local function setCollision(state)
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide ~= state then
                    part.CanCollide = state
                end
            end
        end

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.N then
                noclipEnabled = not noclipEnabled
            end
        end)

        RunService.Stepped:Connect(function()
            if noclipEnabled and character then
                setCollision(false)
            end
        end)

        player.CharacterAdded:Connect(function(char)
            character = char
            wait(1)
            if noclipEnabled then
                setCollision(false)
            end
        end)
    end
})

-- R15 to R6
PlayerTab:Button({
    Title = "R15 To R6 (FE)",
    Desc = "Convert R15 to R6 animations",
    Icon = "user",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Imagnir/r6_anims_for_r15/main/r6_anims.lua"))()
    end
})

-- Fly Speed Slider
local flySpeed = 50
PlayerTab:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flying speed",
    Value = {
        Min = 1,
        Max = 300,
        Default = 50,
    },
    Callback = function(speed)
        flySpeed = speed
    end
})

-- Fly Toggle
local flying = false
local bv, bg, conn
PlayerTab:Button({
    Title = "Toggle Fly (V)",
    Desc = "Toggle fly mode",
    Icon = "plane",
    Callback = function()
        flying = not flying
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if flying then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            
            conn = game:GetService("RunService").Heartbeat:Connect(function()
                local cam = workspace.CurrentCamera.CFrame
                local move = Vector3.new()
                local UIS = game:GetService("UserInputService")
                
                if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                
                bv.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.new()) * flySpeed
                bg.CFrame = cam
            end)
        else
            if conn then conn:Disconnect() end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
})

-- ESP Toggle
local espEnabled = false
local espCache = {}
PlayerTab:Button({
    Title = "ESP Toggle",
    Desc = "Toggle player ESP",
    Icon = "eye",
    Callback = function()
        espEnabled = not espEnabled
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if espEnabled and not espCache[p] then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.FillTransparency = 0.8
                    hl.OutlineColor = Color3.new(1, 0, 0)
                    espCache[p] = hl
                elseif not espEnabled and espCache[p] then
                    espCache[p]:Destroy()
                    espCache[p] = nil
                end
            end
        end
    end
})

-- Server Hop
PlayerTab:Button({
    Title = "Server Hop",
    Desc = "Join a different server",
    Icon = "shuffle",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local hs = game:GetService("HttpService")
        local success, result = pcall(function()
            return hs:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if success then 
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    return ts:TeleportToPlaceInstance(game.PlaceId, server.id)
                end
            end 
        end
    end
})

-- Rejoin
PlayerTab:Button({
    Title = "Rejoin",
    Desc = "Rejoin current server",
    Icon = "refresh-cw",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

-- Fly Jump
PlayerTab:Button({
    Title = "Fly Jump (Press F)",
    Desc = "Toggle fly jump with F key",
    Icon = "arrow-up",
    Callback = function()
        local UIS = game:GetService("UserInputService")
        local player = game:GetService("Players").LocalPlayer
        local humanoid
        local enabled = false

        local function enableFlyJump()
            local character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            UIS.JumpRequest:Connect(function()
                if enabled and humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                end
            end)
        end

        UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.F then
                enabled = not enabled
                if enabled then
                    enableFlyJump()
                else
                    print("FlyJump disabled")
                end
            end
        end)

        player.CharacterAdded:Connect(function()
            if enabled then
                wait(1)
                enableFlyJump()
            end
        end)
    end
})

-- Anti-AFK
PlayerTab:Button({
    Title = "Anti-AFK",
    Desc = "Prevent getting kicked for being AFK",
    Icon = "shield",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        player.Idled:Connect(function()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
})

-- ==== INFECTIOUS SMILE TAB ====
local tools = {"Bat", "Bottle", "Branch", "Katana", "Spear", "Chain", "Hatchet", "Knife"}
for _, tool in ipairs(tools) do
    InfectiousTab:Button({
        Title = "No " .. tool .. " Cooldown",
        Desc = "Remove cooldown for " .. tool,
        Icon = "sword",
        Callback = function()
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild(tool) then
                    local cooldown = char[tool]:FindFirstChild("Cooldown")
                    if cooldown then 
                        cooldown.Value = 0 
                    end
                end
            end)
        end
    })
end

-- ==== FORSAKEN TAB ====
ForsakenTab:Button({
    Title = "Infinite Stamina",
    Desc = "Get infinite stamina in Forsaken",
    Icon = "battery",
    Callback = function()
        pcall(function()
            require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).StaminaLossDisabled = true
        end)
    end
})

-- Select first tab
Window:SelectTab(1)
