-- Souza Hub - MM2 Atualizado
-- Interface: Rayfield

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "Souza Hub",
    LoadingTitle = "Souza Hub",
    LoadingSubtitle = "by Souza",
    ConfigurationSaving = { Enabled = true, FolderName = "SouzaHub", FileName = "config" },
    Discord = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local Settings = {
    Aimbot = false,
    SilentAim = false,
    AimLock = false,
    AimFOV = 90,
    FOVCircle = false,
    AutoShoot = false,
    AutoKillMurderer = false,
    AutoKillSheriff = false,
    KillAura = false,
    KnifeAura = false,
    ThrowKnifeAssist = false,
    KnifeReach = 20,
    GunAccuracy = 50,
    GunPrediction = false,
    AutoPickupGun = false,
    InstantGunPickup = false,
    PlayerESP = false,
    NameESP = false,
    DistanceESP = false,
    BoxESP = false,
    TracerESP = false,
    HighlightESP = false,
    MurdererESP = false,
    SheriffESP = false,
    InnocentESP = false,
    HeroESP = false,
    GunESP = false,
    RoleColors = false,
    RoleChams = false,
    DetectMurderer = false,
    DetectSheriff = false,
    DetectHero = false,
    RoleNotifications = false,
    MurdererAlert = false,
    SheriffAlert = false,
    ShowGunPickup = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fly = false,
    Noclip = false,
    ClickTP = false,
    Dash = false,
    Spin = false,
    BunnyHop = false,
    AntiVoid = false,
    AutoFarmCoins = false,
    AutoCollectCoins = false,
    AutoFarmCandy = false,
    CoinTP = false,
    AutoFarmXP = false,
    AutoFarmWins = false,
    AutoRejoin = false,
    ServerHop = false,
    AutoDodge = false,
    AutoEscapeMurderer = false,
    AntiKnife = false,
    AntiGun = false,
    AntiFling = false,
    AntiAFK = false,
    AutoReset = false,
    SafeSpot = false,
    Fullbright = false,
    RemoveFog = false,
    XRay = false,
    RemoveDoors = false,
    RemoveMapObjects = false,
    PlayerChams = false,
    Crosshair = false,
    CustomFOV = 70,
    NightVision = false,
    Spectate = false,
    View = false,
    Follow = false,
    Orbit = false,
    FreezeLocal = false,
    FreezeVisual = false,
    GunDropESP = false,
    AutoGrabGun = false,
    GunAimAssist = false,
    GunPrediction2 = false,
    ThrowPrediction = false,
    AutoThrow = false,
    KnifeTarget = nil,
    AimButton = false,
    ShootButton = false,
    ThrowKnifeButton = false,
    FlyControls = false,
    TPButton = false,
    AntiAFK2 = false,
    FPSBoost = false,
    RemoveTextures = false,
    LowGraphics = false,
    ChatSpy = false,
    Spinbot = false,
    FakeLagVisual = false,
    FakeKnife = false
}

local function Notify(title, message)
    Rayfield:Notify({ Title = title, Content = message, Duration = 5, Image = "check" })
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

local function getRole(player)
    if not player or player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return nil end

    if char:FindFirstChild("Murderer") or char:FindFirstChild("murderer") then return "Murderer" end
    if char:FindFirstChild("Sheriff") or char:FindFirstChild("sheriff") then return "Sheriff" end
    if char:FindFirstChild("Hero") or char:FindFirstChild("hero") then return "Hero" end

    if player:FindFirstChild("Murderer") or player:FindFirstChild("murderer") then return "Murderer" end
    if player:FindFirstChild("Sheriff") or player:FindFirstChild("sheriff") then return "Sheriff" end
    if player:FindFirstChild("Hero") or player:FindFirstChild("hero") then return "Hero" end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local name = tool.Name:lower()
        if name:find("knife") or name:find("faca") then return "Murderer" end
        if name:find("gun") or name:find("pistol") or name:find("revolver") then
            if char:FindFirstChild("Hero") or player:FindFirstChild("Hero") then return "Hero" else return "Sheriff" end
        end
    end

    local roleVal = player:FindFirstChild("Role") or player:FindFirstChild("role")
    if roleVal and roleVal:IsA("StringValue") then
        local val = roleVal.Value:lower()
        if val:find("murderer") then return "Murderer" end
        if val:find("sheriff") then return "Sheriff" end
        if val:find("hero") then return "Hero" end
    end

    return "Innocent"
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then return p end
    end
    return nil
end

local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Sheriff" then return p end
    end
    return nil
end

local function getHero()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Hero" then return p end
    end
    return nil
end

local function getNearestPlayer(maxDist)
    local nearest = nil
    local dist = maxDist or math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if mag < dist then dist = mag; nearest = p end
        end
    end
    return nearest
end

local function findGunDrop()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("revolver")) then return v end
    end
    return nil
end

local function findKnife()
    if LocalPlayer.Character then
        local knife = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if knife and (knife.Name:lower():find("knife") or knife.Name:lower():find("faca")) then return knife end
    end
    if LocalPlayer.Backpack then
        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then return tool end
    end
    return nil
end

local function findCoin()
    local closest = nil
    local minDist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("moeda")) then
            local dist = (v.Position - root.Position).Magnitude
            if dist < minDist then minDist = dist; closest = v end
        end
    end
    return closest
end

local function getPlayerByName(name)
    return Players:FindFirstChild(name)
end

local function getRoot(player)
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(player)
    local char = player and player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function fireClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

local function shootGun()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") or tool.Name:lower():find("revolver")) then
        tool:Activate()
        fireClick()
    end
end

local function throwKnife()
    local knife = findKnife()
    if knife then knife:Activate(); fireClick() end
end

-- ESP
local ESPObjects = {}
local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Remove then obj:Remove() elseif obj.Destroy then obj:Destroy() end
    end
    table.clear(ESPObjects)
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255,0,0)
    elseif role == "Sheriff" then return Color3.fromRGB(0,100,255)
    elseif role == "Hero" then return Color3.fromRGB(255,215,0)
    elseif role == "Innocent" then return Color3.fromRGB(0,255,0)
    else return Color3.fromRGB(255,255,255) end
end

local function createESP(player)
    if not Settings.PlayerESP then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return end
    local role = getRole(player)
    local color = getRoleColor(role)

    if Settings.HighlightESP then
        local highlight = Instance.new("Highlight")
        highlight.Parent = char
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5
        table.insert(ESPObjects, highlight)
    end

    if Settings.BoxESP then
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Color = color
        box.Filled = false
        box.Transparency = 1
        table.insert(ESPObjects, box)
        coroutine.wrap(function()
            while Settings.BoxESP and Settings.PlayerESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                local headPos = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local height = math.abs(headPos.Y - pos.Y)
                    local width = height / 2.5
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(pos.X - width/2, pos.Y - height)
                    box.Visible = true
                else box.Visible = false end
                task.wait()
            end
            box:Remove()
        end)()
    end

    if Settings.NameESP then
        local name = Drawing.new("Text")
        name.Text = player.Name .. " [" .. (role or "Unknown") .. "]"
        name.Color = color
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.new(0,0,0)
        table.insert(ESPObjects, name)
        coroutine.wrap(function()
            while Settings.NameESP and Settings.PlayerESP and player.Character and player.Character:FindFirstChild("Head") do
                local pos, onScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.7, 0))
                if onScreen then name.Position = Vector2.new(pos.X, pos.Y); name.Visible = true else name.Visible = false end
                task.wait()
            end
            name:Remove()
        end)()
    end

    if Settings.DistanceESP then
        local distText = Drawing.new("Text")
        distText.Color = color
        distText.Size = 12
        distText.Center = true
        distText.Outline = true
        table.insert(ESPObjects, distText)
        coroutine.wrap(function()
            while Settings.DistanceESP and Settings.PlayerESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                distText.Text = string.format("%.0f m", dist)
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position + Vector3.new(0, 1.2, 0))
                if onScreen then distText.Position = Vector2.new(pos.X, pos.Y); distText.Visible = true else distText.Visible = false end
                task.wait()
            end
            distText:Remove()
        end)()
    end

    if Settings.TracerESP then
        local tracer = Drawing.new("Line")
        tracer.Color = color
        tracer.Thickness = 1
        tracer.Transparency = 1
        table.insert(ESPObjects, tracer)
        coroutine.wrap(function()
            while Settings.TracerESP and Settings.PlayerESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                else tracer.Visible = false end
                task.wait()
            end
            tracer:Remove()
        end)()
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.PlayerESP then
            clearESP()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then createESP(player) end
            end
        else clearESP() end
    end
end)

-- Combat loops
task.spawn(function()
    while true do
        task.wait()
        if Settings.Aimbot or Settings.AimLock then
            local target = getNearestPlayer(Settings.AimFOV)
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AutoShoot then shootGun() end
        if Settings.AutoKillMurderer then
            local m = getMurderer()
            if m and m.Character and m.Character:FindFirstChild("Head") then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, m.Character.Head.Position)
                    tool:Activate()
                end
            end
        end
        if Settings.AutoKillSheriff then
            local s = getSheriff()
            if s and s.Character and s.Character:FindFirstChild("Head") then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, s.Character.Head.Position)
                    tool:Activate()
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if Settings.KillAura or Settings.KnifeAura then
            local target = getNearestPlayer(20)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                local knife = findKnife()
                if knife then knife:Activate() end
            end
        end
    end
end)

-- Movement
local flyBodyGyro, flyBodyVelocity
local function stopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
end
local function startFly()
    local root = getRoot(LocalPlayer)
    local humanoid = getHumanoid(LocalPlayer)
    if not root or not humanoid then return end
    stopFly()
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
    flyBodyGyro.cframe = root.CFrame
    flyBodyGyro.Parent = root
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.zero
    flyBodyVelocity.maxForce = Vector3.new(9e9,9e9,9e9)
    flyBodyVelocity.Parent = root
end

task.spawn(function()
    while true do
        task.wait()
        if Settings.Fly then
            if not flyBodyGyro or not flyBodyVelocity then startFly() end
            local root = getRoot(LocalPlayer)
            if root and flyBodyVelocity then
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
                flyBodyVelocity.velocity = moveDir * 50
            end
        else stopFly() end
        if Settings.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if Settings.InfiniteJump and LocalPlayer.Character then
            local humanoid = getHumanoid(LocalPlayer)
            if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        local humanoid = getHumanoid(LocalPlayer)
        if humanoid then
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
        if Settings.AntiVoid and LocalPlayer.Character then
            local root = getRoot(LocalPlayer)
            if root and root.Position.Y < -200 then root.CFrame = CFrame.new(0,20,0) end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.ClickTP then
        local mouse = LocalPlayer:GetMouse()
        local ray = mouse.UnitRay
        local targetPos = ray.Origin + ray.Direction * 100
        local root = getRoot(LocalPlayer)
        if root then root.CFrame = CFrame.new(targetPos) end
    end
end)

-- Visual
task.spawn(function()
    while true do
        task.wait()
        if Settings.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
        end
        if Settings.RemoveFog then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
        if Settings.XRay then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                    v.LocalTransparencyModifier = 0.7
                end
            end
        end
        if Settings.RemoveDoors then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("door") then v:Destroy() end
            end
        end
        if Settings.RemoveMapObjects then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("wall") or v.Name:lower():find("obstacle")) then
                    v.Transparency = 1
                    v.CanCollide = false
                end
            end
        end
        Camera.FieldOfView = Settings.CustomFOV
        if Settings.NightVision then
            Lighting.ColorCorrectionEffect = Color3.new(0,1,0)
        else
            Lighting.ColorCorrectionEffect = Color3.new(0,0,0)
        end
    end
end)

-- Player loops
local playerDropdown2 = nil
task.spawn(function()
    while true do
        task.wait()
        if Settings.Spectate and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            if target and target.Character then Camera.CameraSubject = target.Character end
        else
            if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character end
        end
        if Settings.Follow and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            local targetRoot = getRoot(target)
            local localRoot = getRoot(LocalPlayer)
            if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,3) end
        end
        if Settings.Orbit and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            local targetRoot = getRoot(target)
            local localRoot = getRoot(LocalPlayer)
            if targetRoot and localRoot then
                local angle = tick() % (2 * math.pi)
                local radius = 5
                local newPos = targetRoot.Position + Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
                localRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
            end
        end
    end
end)

-- Farm
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoFarmCoins or Settings.AutoCollectCoins or Settings.CoinTP then
            local coin = findCoin()
            local root = getRoot(LocalPlayer)
            if coin and root then root.CFrame = coin.CFrame end
        end
    end
end)

-- Gun/Knife
task.spawn(function()
    while true do
        task.wait()
        if Settings.AutoGrabGun then
            local gun = findGunDrop()
            local root = getRoot(LocalPlayer)
            if gun and root then
                root.CFrame = gun.CFrame
                task.wait(0.2)
                firetouchinterest(root, gun, 0)
                firetouchinterest(root, gun, 1)
            end
        end
        if Settings.AutoThrow then throwKnife() end
        if Settings.GunAimAssist then
            local target = getNearestPlayer(100)
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

-- Mobile buttons
local mobileScreenGui = nil
local function createMobileButtons()
    if mobileScreenGui then mobileScreenGui:Destroy() end
    if not (Settings.ShootButton or Settings.ThrowKnifeButton or Settings.TPButton or Settings.AimButton) then return end
    mobileScreenGui = Instance.new("ScreenGui")
    mobileScreenGui.Name = "SouzaMobileButtons"
    mobileScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    mobileScreenGui.ResetOnSpawn = false

    if Settings.ShootButton then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80,80)
        btn.Position = UDim2.new(0.8,0,0.7,0)
        btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
        btn.Text = "ATIRAR"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = mobileScreenGui
        btn.MouseButton1Click:Connect(shootGun)
    end
    if Settings.ThrowKnifeButton then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80,80)
        btn.Position = UDim2.new(0.65,0,0.7,0)
        btn.BackgroundColor3 = Color3.fromRGB(0,0,255)
        btn.Text = "FACADA"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = mobileScreenGui
        btn.MouseButton1Click:Connect(throwKnife)
    end
    if Settings.TPButton then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80,40)
        btn.Position = UDim2.new(0.1,0,0.1,0)
        btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
        btn.Text = "TP Murderer"
        btn.TextColor3 = Color3.new(0,0,0)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.Parent = mobileScreenGui
        btn.MouseButton1Click:Connect(function()
            local m = getMurderer()
            local root = getRoot(m)
            local localRoot = getRoot(LocalPlayer)
            if root and localRoot then localRoot.CFrame = root.CFrame end
        end)
    end
    if Settings.AimButton then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80,40)
        btn.Position = UDim2.new(0.2,0,0.1,0)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,0)
        btn.Text = "MIRAR"
        btn.TextColor3 = Color3.new(0,0,0)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.Parent = mobileScreenGui
        btn.MouseButton1Click:Connect(function()
            local target = getNearestPlayer(200)
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    end
end

-- ================= ABAS =================
local MainTab = Window:CreateTab("Main", "home")
local MainSection = MainTab:CreateSection("Bem-vindo")
MainSection:CreateLabel("Souza Hub carregado com sucesso!")
MainSection:CreateButton("Iniciar", function() Notify("Souza Hub", "Script ativado!") end)

local CombatTab = Window:CreateTab("Combat", "swords")
local CombatAim = CombatTab:CreateSection("Aim")
CombatAim:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
CombatAim:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
CombatAim:CreateToggle({Name = "Aim Lock", CurrentValue = false, Callback = function(v) Settings.AimLock = v end})
CombatAim:CreateSlider({Name = "Aim FOV", Range = {0,360}, Increment = 1, CurrentValue = 90, Callback = function(v) Settings.AimFOV = v end})
CombatAim:CreateToggle({Name = "FOV Circle", CurrentValue = false, Callback = function(v) Settings.FOVCircle = v end})
local CombatAuto = CombatTab:CreateSection("Automação")
CombatAuto:CreateToggle({Name = "Auto Shoot", CurrentValue = false, Callback = function(v) Settings.AutoShoot = v end})
CombatAuto:CreateToggle({Name = "Auto Kill Murderer", CurrentValue = false, Callback = function(v) Settings.AutoKillMurderer = v end})
CombatAuto:CreateToggle({Name = "Auto Kill Sheriff", CurrentValue = false, Callback = function(v) Settings.AutoKillSheriff = v end})
CombatAuto:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) Settings.KillAura = v end})
CombatAuto:CreateToggle({Name = "Knife Aura", CurrentValue = false, Callback = function(v) Settings.KnifeAura = v end})
CombatAuto:CreateToggle({Name = "Throw Knife Assist", CurrentValue = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
CombatAuto:CreateSlider({Name = "Knife Reach", Range = {10,100}, Increment = 1, CurrentValue = 20, Callback = function(v) Settings.KnifeReach = v end})
CombatAuto:CreateSlider({Name = "Gun Accuracy", Range = {0,100}, Increment = 1, CurrentValue = 50, Callback = function(v) Settings.GunAccuracy = v end})
CombatAuto:CreateToggle({Name = "Gun Prediction", CurrentValue = false, Callback = function(v) Settings.GunPrediction = v end})
CombatAuto:CreateToggle({Name = "Auto Pickup Gun", CurrentValue = false, Callback = function(v) Settings.AutoPickupGun = v end})
CombatAuto:CreateToggle({Name = "Instant Gun Pickup", CurrentValue = false, Callback = function(v) Settings.InstantGunPickup = v end})

local ESPTab = Window:CreateTab("ESP", "eye")
local ESPMain = ESPTab:CreateSection("ESP Geral")
ESPMain:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v) Settings.PlayerESP = v; if not v then clearESP() end end})
ESPMain:CreateToggle({Name = "Name ESP", CurrentValue = false, Callback = function(v) Settings.NameESP = v end})
ESPMain:CreateToggle({Name = "Distance ESP", CurrentValue = false, Callback = function(v) Settings.DistanceESP = v end})
ESPMain:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) Settings.BoxESP = v end})
ESPMain:CreateToggle({Name = "Tracer ESP", CurrentValue = false, Callback = function(v) Settings.TracerESP = v end})
ESPMain:CreateToggle({Name = "Highlight ESP", CurrentValue = false, Callback = function(v) Settings.HighlightESP = v end})
local ESPRole = ESPTab:CreateSection("ESP por Papel")
ESPRole:CreateToggle({Name = "Murderer ESP (Vermelho)", CurrentValue = false, Callback = function(v) Settings.MurdererESP = v end})
ESPRole:CreateToggle({Name = "Sheriff ESP (Azul)", CurrentValue = false, Callback = function(v) Settings.SheriffESP = v end})
ESPRole:CreateToggle({Name = "Innocent ESP (Verde)", CurrentValue = false, Callback = function(v) Settings.InnocentESP = v end})
ESPRole:CreateToggle({Name = "Hero ESP (Dourado)", CurrentValue = false, Callback = function(v) Settings.HeroESP = v end})
ESPRole:CreateToggle({Name = "Gun ESP", CurrentValue = false, Callback = function(v) Settings.GunESP = v end})
ESPRole:CreateToggle({Name = "Role Colors", CurrentValue = false, Callback = function(v) Settings.RoleColors = v end})
ESPRole:CreateToggle({Name = "Role Chams", CurrentValue = false, Callback = function(v) Settings.RoleChams = v end})

local RoleDetTab = Window:CreateTab("Role/Detecção", "user-secret")
local RoleDetSec = RoleDetTab:CreateSection("Detecção")
RoleDetSec:CreateToggle({Name = "Detect Murderer", CurrentValue = false, Callback = function(v) Settings.DetectMurderer = v end})
RoleDetSec:CreateToggle({Name = "Detect Sheriff", CurrentValue = false, Callback = function(v) Settings.DetectSheriff = v end})
RoleDetSec:CreateToggle({Name = "Detect Hero", CurrentValue = false, Callback = function(v) Settings.DetectHero = v end})
local RoleAlertSec = RoleDetTab:CreateSection("Alertas")
RoleAlertSec:CreateToggle({Name = "Role Notifications", CurrentValue = false, Callback = function(v) Settings.RoleNotifications = v end})
RoleAlertSec:CreateToggle({Name = "Murderer Alert", CurrentValue = false, Callback = function(v) Settings.MurdererAlert = v end})
RoleAlertSec:CreateToggle({Name = "Sheriff Alert", CurrentValue = false, Callback = function(v) Settings.SheriffAlert = v end})
RoleAlertSec:CreateToggle({Name = "Mostrar quem pegou a arma", CurrentValue = false, Callback = function(v) Settings.ShowGunPickup = v end})

local TeleportTab = Window:CreateTab("Teleport", "location-arrow")
local TeleportSec = TeleportTab:CreateSection("Teleportes")
TeleportSec:CreateButton("Teleport to Murderer", function()
    local m = getMurderer()
    local targetRoot = getRoot(m)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame; Notify("Teleport", "Teleportado ao Murderer") else Notify("Teleport", "Murderer não encontrado") end
end)
TeleportSec:CreateButton("Teleport to Sheriff", function()
    local s = getSheriff()
    local targetRoot = getRoot(s)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame; Notify("Teleport", "Teleportado ao Sheriff") else Notify("Teleport", "Sheriff não encontrado") end
end)
TeleportSec:CreateButton("Teleport to Gun Drop", function()
    local gun = findGunDrop()
    local localRoot = getRoot(LocalPlayer)
    if gun and localRoot then localRoot.CFrame = gun.CFrame end
end)
TeleportSec:CreateButton("Teleport to Lobby", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0,30,0) end
end)
TeleportSec:CreateButton("Teleport to Map", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0,30,0) end
end)
TeleportSec:CreateButton("Teleport to Spawn", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0,30,0) end
end)
local TeleportPlayerSec = TeleportTab:CreateSection("Teleportar para Jogador")
local playerDropdown = TeleportPlayerSec:CreateDropdown({Name = "Selecionar Jogador", Options = getPlayerNames(), CurrentOption = "", Callback = function(v) end})
TeleportPlayerSec:CreateButton("Teleport to Player", function()
    if playerDropdown.Value ~= "" then
        local plr = getPlayerByName(playerDropdown.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame end
    end
end)
TeleportPlayerSec:CreateButton("Teleport Behind Player", function()
    if playerDropdown.Value ~= "" then
        local plr = getPlayerByName(playerDropdown.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3) end
    end
end)

local MovementTab = Window:CreateTab("Movement", "person-running")
local MovementSec = MovementTab:CreateSection("Velocidade e Pulo")
MovementSec:CreateSlider({Name = "WalkSpeed", Range = {16,200}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})
MovementSec:CreateSlider({Name = "JumpPower", Range = {50,300}, Increment = 1, CurrentValue = 50, Callback = function(v) Settings.JumpPower = v end})
local MovementSpecial = MovementTab:CreateSection("Movimentação Especial")
MovementSpecial:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Settings.InfiniteJump = v end})
MovementSpecial:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(v) Settings.Fly = v end})
MovementSpecial:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.Noclip = v end})
MovementSpecial:CreateToggle({Name = "Click TP", CurrentValue = false, Callback = function(v) Settings.ClickTP = v end})
MovementSpecial:CreateToggle({Name = "Dash", CurrentValue = false, Callback = function(v) Settings.Dash = v end})
MovementSpecial:CreateToggle({Name = "Spin", CurrentValue = false, Callback = function(v) Settings.Spin = v end})
MovementSpecial:CreateToggle({Name = "Bunny Hop", CurrentValue = false, Callback = function(v) Settings.BunnyHop = v end})
MovementSpecial:CreateToggle({Name = "Anti-Void", CurrentValue = false, Callback = function(v) Settings.AntiVoid = v end})

local FarmTab = Window:CreateTab("Farm", "coins")
local FarmSec = FarmTab:CreateSection("Farm Automático")
FarmSec:CreateToggle({Name = "Auto Farm Coins", CurrentValue = false, Callback = function(v) Settings.AutoFarmCoins = v end})
FarmSec:CreateToggle({Name = "Auto Collect Coins", CurrentValue = false, Callback = function(v) Settings.AutoCollectCoins = v end})
FarmSec:CreateToggle({Name = "Auto Farm Candy/Eventos", CurrentValue = false, Callback = function(v) Settings.AutoFarmCandy = v end})
FarmSec:CreateToggle({Name = "Coin TP", CurrentValue = false, Callback = function(v) Settings.CoinTP = v end})
FarmSec:CreateToggle({Name = "Auto Farm XP", CurrentValue = false, Callback = function(v) Settings.AutoFarmXP = v end})
FarmSec:CreateToggle({Name = "Auto Farm Wins", CurrentValue = false, Callback = function(v) Settings.AutoFarmWins = v end})
FarmSec:CreateToggle({Name = "Auto Rejoin", CurrentValue = false, Callback = function(v) Settings.AutoRejoin = v end})
FarmSec:CreateToggle({Name = "Server Hop", CurrentValue = false, Callback = function(v) Settings.ServerHop = v end})

local SurvivalTab = Window:CreateTab("Survival", "shield-halved")
local SurvivalSec = SurvivalTab:CreateSection("Defesa")
SurvivalSec:CreateToggle({Name = "Auto Dodge", CurrentValue = false, Callback = function(v) Settings.AutoDodge = v end})
SurvivalSec:CreateToggle({Name = "Auto Escape Murderer", CurrentValue = false, Callback = function(v) Settings.AutoEscapeMurderer = v end})
SurvivalSec:CreateToggle({Name = "Anti-Knife", CurrentValue = false, Callback = function(v) Settings.AntiKnife = v end})
SurvivalSec:CreateToggle({Name = "Anti-Gun", CurrentValue = false, Callback = function(v) Settings.AntiGun = v end})
SurvivalSec:CreateToggle({Name = "Anti-Fling", CurrentValue = false, Callback = function(v) Settings.AntiFling = v end})
SurvivalSec:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function(v) Settings.AntiAFK = v end})
SurvivalSec:CreateToggle({Name = "Auto Reset", CurrentValue = false, Callback = function(v) Settings.AutoReset = v end})
SurvivalSec:CreateToggle({Name = "Safe Spot", CurrentValue = false, Callback = function(v) Settings.SafeSpot = v end})

local VisualTab = Window:CreateTab("Visual", "eye-slash")
local VisualWorld = VisualTab:CreateSection("Mundo")
VisualWorld:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) Settings.Fullbright = v end})
VisualWorld:CreateToggle({Name = "Remove Fog", CurrentValue = false, Callback = function(v) Settings.RemoveFog = v end})
VisualWorld:CreateToggle({Name = "X-Ray", CurrentValue = false, Callback = function(v) Settings.XRay = v end})
VisualWorld:CreateToggle({Name = "Remove Doors", CurrentValue = false, Callback = function(v) Settings.RemoveDoors = v end})
VisualWorld:CreateToggle({Name = "Remove Map Objects", CurrentValue = false, Callback = function(v) Settings.RemoveMapObjects = v end})
local VisualPlayer = VisualTab:CreateSection("Jogador e Câmera")
VisualPlayer:CreateToggle({Name = "Player Chams", CurrentValue = false, Callback = function(v) Settings.PlayerChams = v end})
VisualPlayer:CreateToggle({Name = "Crosshair", CurrentValue = false, Callback = function(v) Settings.Crosshair = v end})
VisualPlayer:CreateSlider({Name = "Custom FOV", Range = {30,120}, Increment = 1, CurrentValue = 70, Callback = function(v) Settings.CustomFOV = v end})
VisualPlayer:CreateToggle({Name = "Night Vision", CurrentValue = false, Callback = function(v) Settings.NightVision = v end})

local PlayerTab = Window:CreateTab("Player", "user")
local PlayerSelect = PlayerTab:CreateSection("Selecionar Jogador")
playerDropdown2 = PlayerSelect:CreateDropdown({Name = "Jogador Alvo", Options = getPlayerNames(), CurrentOption = "", Callback = function(v) end})
local PlayerActions = PlayerTab:CreateSection("Interações")
PlayerActions:CreateToggle({Name = "Spectate Player", CurrentValue = false, Callback = function(v) Settings.Spectate = v end})
PlayerActions:CreateToggle({Name = "View Player", CurrentValue = false, Callback = function(v) Settings.View = v end})
PlayerActions:CreateToggle({Name = "Follow Player", CurrentValue = false, Callback = function(v) Settings.Follow = v end})
PlayerActions:CreateToggle({Name = "Orbit Player", CurrentValue = false, Callback = function(v) Settings.Orbit = v end})
PlayerActions:CreateButton("Fling", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local root = getRoot(plr)
        if root then root.Velocity = Vector3.new(0,5000,0); root.RotVelocity = Vector3.new(100,100,100) end
    end
end)
PlayerActions:CreateButton("Bring Player", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then targetRoot.CFrame = localRoot.CFrame end
    end
end)
PlayerActions:CreateToggle({Name = "Freeze Local", CurrentValue = false, Callback = function(v) Settings.FreezeLocal = v end})
PlayerActions:CreateToggle({Name = "Freeze Visual", CurrentValue = false, Callback = function(v) Settings.FreezeVisual = v end})
PlayerActions:CreateButton("Copy Avatar", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local targetHumanoid = getHumanoid(plr)
        local localHumanoid = getHumanoid(LocalPlayer)
        if targetHumanoid and localHumanoid and targetHumanoid.HumanoidDescription then
            localHumanoid:ApplyDescription(targetHumanoid.HumanoidDescription)
        end
    end
end)

local GunTab = Window:CreateTab("Gun", "gun")
local GunSec = GunTab:CreateSection("Arma")
GunSec:CreateToggle({Name = "Gun Drop ESP", CurrentValue = false, Callback = function(v) Settings.GunDropESP = v end})
GunSec:CreateButton("Teleport Gun", function()
    local gun = findGunDrop()
    local root = getRoot(LocalPlayer)
    if gun and root then root.CFrame = gun.CFrame end
end)
GunSec:CreateToggle({Name = "Auto Grab Gun", CurrentValue = false, Callback = function(v) Settings.AutoGrabGun = v end})
GunSec:CreateToggle({Name = "Gun Aim Assist", CurrentValue = false, Callback = function(v) Settings.GunAimAssist = v end})
GunSec:CreateToggle({Name = "Gun Prediction", CurrentValue = false, Callback = function(v) Settings.GunPrediction2 = v end})
GunSec:CreateButton("Shoot Murderer", function()
    local m = getMurderer()
    if m and m.Character and m.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, m.Character.Head.Position)
        task.wait(0.2)
        shootGun()
    end
end)
GunSec:CreateToggle({Name = "Botão de Atirar (Mobile)", CurrentValue = false, Callback = function(v) Settings.ShootButton = v; createMobileButtons() end})

local KnifeTab = Window:CreateTab("Knife", "dagger")
local KnifeSec = KnifeTab:CreateSection("Faca")
KnifeSec:CreateToggle({Name = "Knife Throw Assist", CurrentValue = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
KnifeSec:CreateToggle({Name = "Throw Prediction", CurrentValue = false, Callback = function(v) Settings.ThrowPrediction = v end})
KnifeSec:CreateSlider({Name = "Knife Range/Reach", Range = {10,100}, Increment = 1, CurrentValue = 20, Callback = function(v) Settings.KnifeReach = v end})
KnifeSec:CreateToggle({Name = "Auto Throw", CurrentValue = false, Callback = function(v) Settings.AutoThrow = v end})
KnifeSec:CreateToggle({Name = "Knife Aura", CurrentValue = false, Callback = function(v) Settings.KnifeAura = v end})
KnifeSec:CreateToggle({Name = "Fake Knife", CurrentValue = false, Callback = function(v) Settings.FakeKnife = v end})
local KnifeTargetSec = KnifeTab:CreateSection("Alvo da Faca")
KnifeTargetSec:CreateDropdown({Name = "Knife Target", Options = getPlayerNames(), CurrentOption = "", Callback = function(v) Settings.KnifeTarget = v end})
KnifeTargetSec:CreateToggle({Name = "Botão de Facada (Mobile)", CurrentValue = false, Callback = function(v) Settings.ThrowKnifeButton = v; createMobileButtons() end})

local MobileTab = Window:CreateTab("Mobile", "mobile-screen")
local MobileSec = MobileTab:CreateSection("Botões Mobile")
MobileSec:CreateToggle({Name = "Aim Button", CurrentValue = false, Callback = function(v) Settings.AimButton = v; createMobileButtons() end})
MobileSec:CreateToggle({Name = "Shoot Button", CurrentValue = false, Callback = function(v) Settings.ShootButton = v; createMobileButtons() end})
MobileSec:CreateToggle({Name = "Throw Knife Button", CurrentValue = false, Callback = function(v) Settings.ThrowKnifeButton = v; createMobileButtons() end})
MobileSec:CreateToggle({Name = "Fly Controls", CurrentValue = false, Callback = function(v) Settings.FlyControls = v end})
MobileSec:CreateToggle({Name = "TP Button", CurrentValue = false, Callback = function(v) Settings.TPButton = v; createMobileButtons() end})
MobileSec:CreateToggle({Name = "Ligar/Desligar ESP", CurrentValue = false, Callback = function(v) Settings.PlayerESP = v end})

local InterfaceTab = Window:CreateTab("Interface", "sliders")
local InterfaceSec = InterfaceTab:CreateSection("Configurações da UI")
InterfaceSec:CreateDropdown({Name = "Tema", Options = {"Dark","Light","Blue","Purple","Red"}, CurrentOption = "Dark", Callback = function(v) end})
InterfaceSec:CreateSlider({Name = "Escala da UI", Range = {50,150}, Increment = 1, CurrentValue = 100, Callback = function(v) end})
InterfaceSec:CreateToggle({Name = "Notificações", CurrentValue = true, Callback = function(v) end})
InterfaceSec:CreateButton("Minimizar UI", function() Rayfield:ToggleUI() end)
InterfaceSec:CreateButton("Esconder UI", function() Rayfield:ToggleUI() end)
InterfaceSec:CreateButton("Salvar Configurações", function() Rayfield:SaveConfiguration() end)

local ServerTab = Window:CreateTab("Server", "server")
local ServerSec = ServerTab:CreateSection("Servidor")
ServerSec:CreateButton("Server Hop", function()
    local HttpService = game:GetService("HttpService")
    local jobId = HttpService:GenerateGUID(false)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end)
ServerSec:CreateButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
ServerSec:CreateButton("Join Small Server", function()
    Notify("Server", "Procurando servidor pequeno...")
end)
ServerSec:CreateButton("Join New Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
ServerSec:CreateButton("Copiar JobId", function()
    setclipboard(game.JobId)
    Notify("Server", "JobId copiado: "..game.JobId)
end)
ServerSec:CreateLabel("Player Count: ".. #Players:GetPlayers())

local MiscTab = Window:CreateTab("Misc", "gear")
local MiscSec = MiscTab:CreateSection("Extras")
MiscSec:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function(v) Settings.AntiAFK2 = v end})
MiscSec:CreateToggle({Name = "FPS Boost", CurrentValue = false, Callback = function(v) Settings.FPSBoost = v end})
MiscSec:CreateToggle({Name = "Remove Textures", CurrentValue = false, Callback = function(v) Settings.RemoveTextures = v end})
MiscSec:CreateToggle({Name = "Low Graphics", CurrentValue = false, Callback = function(v) Settings.LowGraphics = v end})
MiscSec:CreateToggle({Name = "Chat Spy", CurrentValue = false, Callback = function(v) Settings.ChatSpy = v end})
MiscSec:CreateToggle({Name = "Spinbot", CurrentValue = false, Callback = function(v) Settings.Spinbot = v end})
MiscSec:CreateToggle({Name = "Fake Lag Visual", CurrentValue = false, Callback = function(v) Settings.FakeLagVisual = v end})
local MiscFun = MiscTab:CreateSection("Diversão")
MiscFun:CreateDropdown({Name = "Emotes", Options = {"Dança 1","Dança 2","Aceno","Rir"}, CurrentOption = "Dança 1", Callback = function(v) end})
MiscFun:CreateButton("Dançar", function()
    local humanoid = getHumanoid(LocalPlayer)
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388"
        local track = humanoid:LoadAnimation(anim)
        track:Play()
    end
end)
local MiscInfo = MiscTab:CreateSection("Informações da Partida")
MiscInfo:CreateLabel("Modo: Murder Mystery 2")
MiscInfo:CreateLabel("Jogadores: ".. #Players:GetPlayers())

-- Monitoramento de papéis
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.RoleNotifications then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local role = getRole(p)
                    if role then print(p.Name.." é "..role) end
                end
            end
        end
        if Settings.MurdererAlert then
            local m = getMurderer()
            if m then Notify("Alerta", m.Name.." é o Assassino!") end
        end
        if Settings.SheriffAlert then
            local s = getSheriff()
            if s then Notify("Alerta", s.Name.." é o Xerife!") end
        end
        if Settings.DetectMurderer then
            local m = getMurderer()
            if m then print("Murderer detectado:", m.Name) end
        end
        if Settings.DetectSheriff then
            local s = getSheriff()
            if s then print("Sheriff detectado:", s.Name) end
        end
        if Settings.DetectHero then
            local h = getHero()
            if h then print("Hero detectado:", h.Name) end
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(60)
        if Settings.AntiAFK or Settings.AntiAFK2 then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, nil)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, nil)
        end
    end
end)

-- FPS Boost / Low Graphics
task.spawn(function()
    while true do
        task.wait(5)
        if Settings.FPSBoost or Settings.LowGraphics then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.TextureID = ""
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        end
        if Settings.RemoveTextures then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.TextureID = "" end
            end
        end
    end
end)

-- Spinbot
task.spawn(function()
    while true do
        task.wait()
        if Settings.Spinbot and LocalPlayer.Character then
            local root = getRoot(LocalPlayer)
            if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0) end
        end
    end
end)

-- Fake Lag Visual
task.spawn(function()
    while true do
        if Settings.FakeLagVisual then task.wait(0.1) else task.wait() end
    end
end)

Notify("Souza Hub", "Script carregado com sucesso!")
