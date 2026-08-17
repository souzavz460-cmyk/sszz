-- Souza Hub - MM2 Atualizado
-- Feito por Souza | Suporte: discord.gg/souza

--[[
    INSTRUÇÕES:
    1. Execute em qualquer exploit compatível (Synapse X, Script-Ware, Krnl, Fluxus, etc.)
    2. Aguarde o carregamento.
    3. Use a interface para ativar as funções.

    OBS: Algumas funções dependem da estrutura do jogo. Se algo não funcionar,
    verifique o console (F9) e ajuste os nomes das pastas/objetos conforme necessário.
]]

-- Serviços
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

-- Configurações
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

-- Funções auxiliares
local function Notify(title, message)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 5
    })
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

    -- 1. Pastas no personagem
    if char:FindFirstChild("Murderer") or char:FindFirstChild("murderer") then
        return "Murderer"
    elseif char:FindFirstChild("Sheriff") or char:FindFirstChild("sheriff") then
        return "Sheriff"
    elseif char:FindFirstChild("Hero") or char:FindFirstChild("hero") then
        return "Hero"
    end

    -- 2. Pastas no Player
    if player:FindFirstChild("Murderer") or player:FindFirstChild("murderer") then
        return "Murderer"
    elseif player:FindFirstChild("Sheriff") or player:FindFirstChild("sheriff") then
        return "Sheriff"
    elseif player:FindFirstChild("Hero") or player:FindFirstChild("hero") then
        return "Hero"
    end

    -- 3. Ferramentas (faca = murderer, arma = sheriff/hero)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local name = tool.Name:lower()
        if name:find("knife") or name:find("faca") then
            return "Murderer"
        elseif name:find("gun") or name:find("pistol") or name:find("revolver") then
            -- Pode ser sheriff ou hero; tentar distinguir
            if char:FindFirstChild("Hero") or player:FindFirstChild("Hero") then
                return "Hero"
            else
                return "Sheriff"
            end
        end
    end

    -- 4. Valores no Player
    local roleVal = player:FindFirstChild("Role") or player:FindFirstChild("role")
    if roleVal and roleVal:IsA("StringValue") then
        local val = roleVal.Value:lower()
        if val:find("murderer") then return "Murderer"
        elseif val:find("sheriff") then return "Sheriff"
        elseif val:find("hero") then return "Hero"
        end
    end

    -- 5. Se nada detectado, é Inocente
    return "Innocent"
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then
            return p
        end
    end
    return nil
end

local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Sheriff" then
            return p
        end
    end
    return nil
end

local function getHero()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Hero" then
            return p
        end
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
            if mag < dist then
                dist = mag
                nearest = p
            end
        end
    end
    return nearest
end

local function findGunDrop()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("revolver")) then
            return v
        end
    end
    return nil
end

local function findKnife()
    if LocalPlayer.Character then
        local knife = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if knife and (knife.Name:lower():find("knife") or knife.Name:lower():find("faca")) then
            return knife
        end
    end
    if LocalPlayer.Backpack then
        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("faca")) then
            return tool
        end
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
            if dist < minDist then
                minDist = dist
                closest = v
            end
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
    if knife then
        knife:Activate()
        fireClick()
    end
end

-- ================= ESP SYSTEM =================
local ESPObjects = {}
local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Remove then obj:Remove() elseif obj.Destroy then obj:Destroy() end
    end
    table.clear(ESPObjects)
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then return Color3.fromRGB(0, 100, 255)
    elseif role == "Hero" then return Color3.fromRGB(255, 215, 0)
    elseif role == "Innocent" then return Color3.fromRGB(0, 255, 0)
    else return Color3.fromRGB(255, 255, 255) end
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
                else
                    box.Visible = false
                end
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
                if onScreen then
                    name.Position = Vector2.new(pos.X, pos.Y)
                    name.Visible = true
                else
                    name.Visible = false
                end
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
                if onScreen then
                    distText.Position = Vector2.new(pos.X, pos.Y)
                    distText.Visible = true
                else
                    distText.Visible = false
                end
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
                else
                    tracer.Visible = false
                end
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
                if player ~= LocalPlayer then
                    createESP(player)
                end
            end
        else
            clearESP()
        end
    end
end)

-- ================= COMBAT LOOPS =================
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

-- ================= MOVEMENT LOOPS =================
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
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = root.CFrame
    flyBodyGyro.Parent = root
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.zero
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
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
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
                flyBodyVelocity.velocity = moveDir * 50
            end
        else
            stopFly()
        end
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
            if root and root.Position.Y < -200 then
                root.CFrame = CFrame.new(0, 20, 0)
            end
        end
    end
end)

-- Click TP
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

-- ================= VISUAL LOOPS =================
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
            Lighting.ColorCorrectionEffect = Color3.new(0, 1, 0)
        else
            Lighting.ColorCorrectionEffect = Color3.new(0, 0, 0)
        end
    end
end)

-- ================= PLAYER LOOPS (Spectate, Follow, Orbit) =================
local playerDropdown2 = nil -- será definido depois

task.spawn(function()
    while true do
        task.wait()
        if Settings.Spectate and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            if target and target.Character then
                Camera.CameraSubject = target.Character
            end
        else
            if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character end
        end
        if Settings.Follow and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            local targetRoot = getRoot(target)
            local localRoot = getRoot(LocalPlayer)
            if targetRoot and localRoot then
                localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end
        if Settings.Orbit and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            local targetRoot = getRoot(target)
            local localRoot = getRoot(LocalPlayer)
            if targetRoot and localRoot then
                local angle = tick() % (2 * math.pi)
                local radius = 5
                local newPos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                localRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
            end
        end
    end
end)

-- ================= FARM LOOPS =================
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

-- ================= GUN/KNIFE LOOPS =================
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

-- ================= INTERFACE (ORION) =================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Souza Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "SouzaHub"})

-- Função para criar toggle com Settings
local function addToggle(tab, name, default, callback)
    tab:AddToggle({
        Name = name,
        Default = default,
        Callback = function(Value)
            callback(Value)
        end
    })
end

local function addButton(tab, name, callback)
    tab:AddButton({
        Name = name,
        Callback = callback
    })
end

local function addSlider(tab, name, min, max, default, callback)
    tab:AddSlider({
        Name = name,
        Min = min,
        Max = max,
        Default = default,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 1,
        ValueName = "",
        Callback = callback
    })
end

local function addDropdown(tab, name, options, default, callback)
    local dropdown = tab:AddDropdown({
        Name = name,
        Default = default or "",
        Options = options,
        Callback = callback
    })
    return dropdown
end

-- Abas
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ESPTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local RoleDetTab = Window:MakeTab({Name = "Role/Detecção", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MovementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FarmTab = Window:MakeTab({Name = "Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SurvivalTab = Window:MakeTab({Name = "Survival", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualTab = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local GunTab = Window:MakeTab({Name = "Gun", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local KnifeTab = Window:MakeTab({Name = "Knife", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MobileTab = Window:MakeTab({Name = "Mobile", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local InterfaceTab = Window:MakeTab({Name = "Interface", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ServerTab = Window:MakeTab({Name = "Server", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Main
local MainSection = MainTab:AddSection({Name = "Bem-vindo"})
MainSection:AddLabel("Souza Hub carregado com sucesso!")
MainSection:AddButton({Name = "Iniciar", Callback = function() Notify("Souza Hub", "Script ativado!") end})

-- Combat
local CombatAim = CombatTab:AddSection({Name = "Aim"})
addToggle(CombatTab, "Aimbot", false, function(v) Settings.Aimbot = v end)
addToggle(CombatTab, "Silent Aim", false, function(v) Settings.SilentAim = v end)
addToggle(CombatTab, "Aim Lock", false, function(v) Settings.AimLock = v end)
addSlider(CombatTab, "Aim FOV", 0, 360, 90, function(v) Settings.AimFOV = v end)
addToggle(CombatTab, "FOV Circle", false, function(v) Settings.FOVCircle = v end)
local CombatAuto = CombatTab:AddSection({Name = "Automação"})
addToggle(CombatTab, "Auto Shoot", false, function(v) Settings.AutoShoot = v end)
addToggle(CombatTab, "Auto Kill Murderer", false, function(v) Settings.AutoKillMurderer = v end)
addToggle(CombatTab, "Auto Kill Sheriff", false, function(v) Settings.AutoKillSheriff = v end)
addToggle(CombatTab, "Kill Aura", false, function(v) Settings.KillAura = v end)
addToggle(CombatTab, "Knife Aura", false, function(v) Settings.KnifeAura = v end)
addToggle(CombatTab, "Throw Knife Assist", false, function(v) Settings.ThrowKnifeAssist = v end)
addSlider(CombatTab, "Knife Reach", 10, 100, 20, function(v) Settings.KnifeReach = v end)
addSlider(CombatTab, "Gun Accuracy", 0, 100, 50, function(v) Settings.GunAccuracy = v end)
addToggle(CombatTab, "Gun Prediction", false, function(v) Settings.GunPrediction = v end)
addToggle(CombatTab, "Auto Pickup Gun", false, function(v) Settings.AutoPickupGun = v end)
addToggle(CombatTab, "Instant Gun Pickup", false, function(v) Settings.InstantGunPickup = v end)

-- ESP
local ESPMain = ESPTab:AddSection({Name = "ESP Geral"})
addToggle(ESPTab, "Player ESP", false, function(v) Settings.PlayerESP = v; if not v then clearESP() end end)
addToggle(ESPTab, "Name ESP", false, function(v) Settings.NameESP = v end)
addToggle(ESPTab, "Distance ESP", false, function(v) Settings.DistanceESP = v end)
addToggle(ESPTab, "Box ESP", false, function(v) Settings.BoxESP = v end)
addToggle(ESPTab, "Tracer ESP", false, function(v) Settings.TracerESP = v end)
addToggle(ESPTab, "Highlight ESP", false, function(v) Settings.HighlightESP = v end)
local ESPRole = ESPTab:AddSection({Name = "ESP por Papel"})
addToggle(ESPTab, "Murderer ESP (Vermelho)", false, function(v) Settings.MurdererESP = v end)
addToggle(ESPTab, "Sheriff ESP (Azul)", false, function(v) Settings.SheriffESP = v end)
addToggle(ESPTab, "Innocent ESP (Verde)", false, function(v) Settings.InnocentESP = v end)
addToggle(ESPTab, "Hero ESP (Dourado)", false, function(v) Settings.HeroESP = v end)
addToggle(ESPTab, "Gun ESP", false, function(v) Settings.GunESP = v end)
addToggle(ESPTab, "Role Colors", false, function(v) Settings.RoleColors = v end)
addToggle(ESPTab, "Role Chams", false, function(v) Settings.RoleChams = v end)

-- Role/Detection
local RoleDetSec = RoleDetTab:AddSection({Name = "Detecção"})
addToggle(RoleDetTab, "Detect Murderer", false, function(v) Settings.DetectMurderer = v end)
addToggle(RoleDetTab, "Detect Sheriff", false, function(v) Settings.DetectSheriff = v end)
addToggle(RoleDetTab, "Detect Hero", false, function(v) Settings.DetectHero = v end)
local RoleAlertSec = RoleDetTab:AddSection({Name = "Alertas"})
addToggle(RoleDetTab, "Role Notifications", false, function(v) Settings.RoleNotifications = v end)
addToggle(RoleDetTab, "Murderer Alert", false, function(v) Settings.MurdererAlert = v end)
addToggle(RoleDetTab, "Sheriff Alert", false, function(v) Settings.SheriffAlert = v end)
addToggle(RoleDetTab, "Mostrar quem pegou a arma", false, function(v) Settings.ShowGunPickup = v end)

-- Teleport
local TeleportSec = TeleportTab:AddSection({Name = "Teleportes"})
addButton(TeleportTab, "Teleport to Murderer", function()
    local m = getMurderer()
    local targetRoot = getRoot(m)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame; Notify("Teleport", "Teleportado ao Murderer") else Notify("Teleport", "Murderer não encontrado") end
end)
addButton(TeleportTab, "Teleport to Sheriff", function()
    local s = getSheriff()
    local targetRoot = getRoot(s)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame; Notify("Teleport", "Teleportado ao Sheriff") else Notify("Teleport", "Sheriff não encontrado") end
end)
addButton(TeleportTab, "Teleport to Gun Drop", function()
    local gun = findGunDrop()
    local localRoot = getRoot(LocalPlayer)
    if gun and localRoot then localRoot.CFrame = gun.CFrame end
end)
addButton(TeleportTab, "Teleport to Lobby", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0, 30, 0) end
end)
addButton(TeleportTab, "Teleport to Map", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0, 30, 0) end
end)
addButton(TeleportTab, "Teleport to Spawn", function()
    local root = getRoot(LocalPlayer)
    if root then root.CFrame = CFrame.new(0, 30, 0) end
end)
local TeleportPlayerSec = TeleportTab:AddSection({Name = "Teleportar para Jogador"})
local playerDropdown = addDropdown(TeleportTab, "Selecionar Jogador", getPlayerNames(), "", function(v) end)
addButton(TeleportTab, "Teleport to Player", function()
    if playerDropdown.Value ~= "" then
        local plr = getPlayerByName(playerDropdown.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame end
    end
end)
addButton(TeleportTab, "Teleport Behind Player", function()
    if playerDropdown.Value ~= "" then
        local plr = getPlayerByName(playerDropdown.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then localRoot.CFrame = targetRoot.CFrame * CFrame.new(0,0,-3) end
    end
end)

-- Movement
local MovementSec = MovementTab:AddSection({Name = "Velocidade e Pulo"})
addSlider(MovementTab, "WalkSpeed", 16, 200, 16, function(v) Settings.WalkSpeed = v end)
addSlider(MovementTab, "JumpPower", 50, 300, 50, function(v) Settings.JumpPower = v end)
local MovementSpecial = MovementTab:AddSection({Name = "Movimentação Especial"})
addToggle(MovementTab, "Infinite Jump", false, function(v) Settings.InfiniteJump = v end)
addToggle(MovementTab, "Fly", false, function(v) Settings.Fly = v end)
addToggle(MovementTab, "Noclip", false, function(v) Settings.Noclip = v end)
addToggle(MovementTab, "Click TP", false, function(v) Settings.ClickTP = v end)
addToggle(MovementTab, "Dash", false, function(v) Settings.Dash = v end)
addToggle(MovementTab, "Spin", false, function(v) Settings.Spin = v end)
addToggle(MovementTab, "Bunny Hop", false, function(v) Settings.BunnyHop = v end)
addToggle(MovementTab, "Anti-Void", false, function(v) Settings.AntiVoid = v end)

-- Farm
local FarmSec = FarmTab:AddSection({Name = "Farm Automático"})
addToggle(FarmTab, "Auto Farm Coins", false, function(v) Settings.AutoFarmCoins = v end)
addToggle(FarmTab, "Auto Collect Coins", false, function(v) Settings.AutoCollectCoins = v end)
addToggle(FarmTab, "Auto Farm Candy/Eventos", false, function(v) Settings.AutoFarmCandy = v end)
addToggle(FarmTab, "Coin TP", false, function(v) Settings.CoinTP = v end)
addToggle(FarmTab, "Auto Farm XP", false, function(v) Settings.AutoFarmXP = v end)
addToggle(FarmTab, "Auto Farm Wins", false, function(v) Settings.AutoFarmWins = v end)
addToggle(FarmTab, "Auto Rejoin", false, function(v) Settings.AutoRejoin = v end)
addToggle(FarmTab, "Server Hop", false, function(v) Settings.ServerHop = v end)

-- Survival
local SurvivalSec = SurvivalTab:AddSection({Name = "Defesa"})
addToggle(SurvivalTab, "Auto Dodge", false, function(v) Settings.AutoDodge = v end)
addToggle(SurvivalTab, "Auto Escape Murderer", false, function(v) Settings.AutoEscapeMurderer = v end)
addToggle(SurvivalTab, "Anti-Knife", false, function(v) Settings.AntiKnife = v end)
addToggle(SurvivalTab, "Anti-Gun", false, function(v) Settings.AntiGun = v end)
addToggle(SurvivalTab, "Anti-Fling", false, function(v) Settings.AntiFling = v end)
addToggle(SurvivalTab, "Anti-AFK", false, function(v) Settings.AntiAFK = v end)
addToggle(SurvivalTab, "Auto Reset", false, function(v) Settings.AutoReset = v end)
addToggle(SurvivalTab, "Safe Spot", false, function(v) Settings.SafeSpot = v end)

-- Visual
local VisualWorld = VisualTab:AddSection({Name = "Mundo"})
addToggle(VisualTab, "Fullbright", false, function(v) Settings.Fullbright = v end)
addToggle(VisualTab, "Remove Fog", false, function(v) Settings.RemoveFog = v end)
addToggle(VisualTab, "X-Ray", false, function(v) Settings.XRay = v end)
addToggle(VisualTab, "Remove Doors", false, function(v) Settings.RemoveDoors = v end)
addToggle(VisualTab, "Remove Map Objects", false, function(v) Settings.RemoveMapObjects = v end)
local VisualPlayer = VisualTab:AddSection({Name = "Jogador e Câmera"})
addToggle(VisualTab, "Player Chams", false, function(v) Settings.PlayerChams = v end)
addToggle(VisualTab, "Crosshair", false, function(v) Settings.Crosshair = v end)
addSlider(VisualTab, "Custom FOV", 30, 120, 70, function(v) Settings.CustomFOV = v end)
addToggle(VisualTab, "Night Vision", false, function(v) Settings.NightVision = v end)

-- Player
local PlayerSelect = PlayerTab:AddSection({Name = "Selecionar Jogador"})
playerDropdown2 = addDropdown(PlayerTab, "Jogador Alvo", getPlayerNames(), "", function(v) end)
local PlayerActions = PlayerTab:AddSection({Name = "Interações"})
addToggle(PlayerTab, "Spectate Player", false, function(v) Settings.Spectate = v end)
addToggle(PlayerTab, "View Player", false, function(v) Settings.View = v end)
addToggle(PlayerTab, "Follow Player", false, function(v) Settings.Follow = v end)
addToggle(PlayerTab, "Orbit Player", false, function(v) Settings.Orbit = v end)
addButton(PlayerTab, "Fling", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local root = getRoot(plr)
        if root then root.Velocity = Vector3.new(0,5000,0); root.RotVelocity = Vector3.new(100,100,100) end
    end
end)
addButton(PlayerTab, "Bring Player", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then targetRoot.CFrame = localRoot.CFrame end
    end
end)
addToggle(PlayerTab, "Freeze Local", false, function(v) Settings.FreezeLocal = v end)
addToggle(PlayerTab, "Freeze Visual", false, function(v) Settings.FreezeVisual = v end)
addButton(PlayerTab, "Copy Avatar", function()
    if playerDropdown2.Value ~= "" then
        local plr = getPlayerByName(playerDropdown2.Value)
        local targetHumanoid = getHumanoid(plr)
        local localHumanoid = getHumanoid(LocalPlayer)
        if targetHumanoid and localHumanoid and targetHumanoid.HumanoidDescription then
            localHumanoid:ApplyDescription(targetHumanoid.HumanoidDescription)
        end
    end
end)

-- Gun
local GunSec = GunTab:AddSection({Name = "Arma"})
addToggle(GunTab, "Gun Drop ESP", false, function(v) Settings.GunDropESP = v end)
addButton(GunTab, "Teleport Gun", function()
    local gun = findGunDrop()
    local root = getRoot(LocalPlayer)
    if gun and root then root.CFrame = gun.CFrame end
end)
addToggle(GunTab, "Auto Grab Gun", false, function(v) Settings.AutoGrabGun = v end)
addToggle(GunTab, "Gun Aim Assist", false, function(v) Settings.GunAimAssist = v end)
addToggle(GunTab, "Gun Prediction", false, function(v) Settings.GunPrediction2 = v end)
addButton(GunTab, "Shoot Murderer", function()
    local m = getMurderer()
    if m and m.Character and m.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, m.Character.Head.Position)
        task.wait(0.2)
        shootGun()
    end
end)
addToggle(GunTab, "Botão de Atirar (Mobile)", false, function(v) Settings.ShootButton = v; if v then createMobileButtons() else removeMobileButtons() end end)

-- Knife
local KnifeSec = KnifeTab:AddSection({Name = "Faca"})
addToggle(KnifeTab, "Knife Throw Assist", false, function(v) Settings.ThrowKnifeAssist = v end)
addToggle(KnifeTab, "Throw Prediction", false, function(v) Settings.ThrowPrediction = v end)
addSlider(KnifeTab, "Knife Range/Reach", 10, 100, 20, function(v) Settings.KnifeReach = v end)
addToggle(KnifeTab, "Auto Throw", false, function(v) Settings.AutoThrow = v end)
addToggle(KnifeTab, "Knife Aura", false, function(v) Settings.KnifeAura = v end)
addToggle(KnifeTab, "Fake Knife", false, function(v) Settings.FakeKnife = v end)
local KnifeTargetSec = KnifeTab:AddSection({Name = "Alvo da Faca"})
addDropdown(KnifeTab, "Knife Target", getPlayerNames(), "", function(v) Settings.KnifeTarget = v end)
addToggle(KnifeTab, "Botão de Facada (Mobile)", false, function(v) Settings.ThrowKnifeButton = v; if v then createMobileButtons() else removeMobileButtons() end end)

-- Mobile
local MobileSec = MobileTab:AddSection({Name = "Botões Mobile"})
addToggle(MobileTab, "Aim Button", false, function(v) Settings.AimButton = v; if v then createMobileButtons() else removeMobileButtons() end end)
addToggle(MobileTab, "Shoot Button", false, function(v) Settings.ShootButton = v; if v then createMobileButtons() else removeMobileButtons() end end)
addToggle(MobileTab, "Throw Knife Button", false, function(v) Settings.ThrowKnifeButton = v; if v then createMobileButtons() else removeMobileButtons() end end)
addToggle(MobileTab, "Fly Controls", false, function(v) Settings.FlyControls = v end)
addToggle(MobileTab, "TP Button", false, function(v) Settings.TPButton = v; if v then createMobileButtons() else removeMobileButtons() end end)
addToggle(MobileTab, "Ligar/Desligar ESP", false, function(v) Settings.PlayerESP = v end)

-- Interface
local InterfaceSec = InterfaceTab:AddSection({Name = "Configurações da UI"})
addDropdown(InterfaceTab, "Tema", {"Dark", "Light", "Blue", "Purple", "Red"}, "Dark", function(v) print("Tema:", v) end)
addSlider(InterfaceTab, "Escala da UI", 50, 150, 100, function(v) end)
addToggle(InterfaceTab, "Notificações", true, function(v) end)
addButton(InterfaceTab, "Minimizar UI", function() OrionLib:MakeNotification({Name = "Souza Hub", Content = "UI minimizada", Time = 2}) end)
addButton(InterfaceTab, "Esconder UI", function() OrionLib:MakeNotification({Name = "Souza Hub", Content = "UI escondida", Time = 2}) end)
addButton(InterfaceTab, "Salvar Configurações", function() OrionLib:SaveConfig() end)
addToggle(InterfaceTab, "Keybind Esconder UI", false, function(v) end) -- Apenas placeholder

-- Server
local ServerSec = ServerTab:AddSection({Name = "Servidor"})
addButton(ServerTab, "Server Hop", function()
    local HttpService = game:GetService("HttpService")
    local jobId = HttpService:GenerateGUID(false)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end)
addButton(ServerTab, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
addButton(ServerTab, "Join Small Server", function()
    Notify("Server", "Procurando servidor pequeno...")
end)
addButton(ServerTab, "Join New Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
addButton(ServerTab, "Copiar JobId", function()
    setclipboard(game.JobId)
    Notify("Server", "JobId copiado: "..game.JobId)
end)
ServerSec:AddLabel("Player Count: ".. #Players:GetPlayers())

-- Misc
local MiscSec = MiscTab:AddSection({Name = "Extras"})
addToggle(MiscTab, "Anti-AFK", false, function(v) Settings.AntiAFK2 = v end)
addToggle(MiscTab, "FPS Boost", false, function(v) Settings.FPSBoost = v end)
addToggle(MiscTab, "Remove Textures", false, function(v) Settings.RemoveTextures = v end)
addToggle(MiscTab, "Low Graphics", false, function(v) Settings.LowGraphics = v end)
addToggle(MiscTab, "Chat Spy", false, function(v) Settings.ChatSpy = v end)
addToggle(MiscTab, "Spinbot", false, function(v) Settings.Spinbot = v end)
addToggle(MiscTab, "Fake Lag Visual", false, function(v) Settings.FakeLagVisual = v end)
local MiscFun = MiscTab:AddSection({Name = "Diversão"})
addDropdown(MiscTab, "Emotes", {"Dança 1", "Dança 2", "Aceno", "Rir"}, "Dança 1", function(v) end)
addButton(MiscTab, "Dançar", function()
    local humanoid = getHumanoid(LocalPlayer)
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388"
        local track = humanoid:LoadAnimation(anim)
        track:Play()
    end
end)
local MiscInfo = MiscTab:AddSection({Name = "Informações da Partida"})
MiscInfo:AddLabel("Modo: Murder Mystery 2")
MiscInfo:AddLabel("Jogadores: ".. #Players:GetPlayers())

-- ================= MOBILE BUTTONS =================
local mobileScreenGui = nil
local shootBtn, knifeBtn, tpBtn, aimBtn

function createMobileButtons()
    removeMobileButtons()
    if not (Settings.ShootButton or Settings.ThrowKnifeButton or Settings.TPButton or Settings.AimButton) then return end
    mobileScreenGui = Instance.new("ScreenGui")
    mobileScreenGui.Name = "SouzaMobileButtons"
    mobileScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    mobileScreenGui.ResetOnSpawn = false
    
    if Settings.ShootButton then
        shootBtn = Instance.new("TextButton")
        shootBtn.Size = UDim2.fromOffset(80, 80)
        shootBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
        shootBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        shootBtn.Text = "ATIRAR"
        shootBtn.TextColor3 = Color3.new(1,1,1)
        shootBtn.Font = Enum.Font.SourceSansBold
        shootBtn.TextSize = 16
        shootBtn.Parent = mobileScreenGui
        shootBtn.MouseButton1Click:Connect(function() shootGun() end)
    end
    if Settings.ThrowKnifeButton then
        knifeBtn = Instance.new("TextButton")
        knifeBtn.Size = UDim2.fromOffset(80, 80)
        knifeBtn.Position = UDim2.new(0.65, 0, 0.7, 0)
        knifeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
        knifeBtn.Text = "FACADA"
        knifeBtn.TextColor3 = Color3.new(1,1,1)
        knifeBtn.Font = Enum.Font.SourceSansBold
        knifeBtn.TextSize = 16
        knifeBtn.Parent = mobileScreenGui
        knifeBtn.MouseButton1Click:Connect(function() throwKnife() end)
    end
    if Settings.TPButton then
        tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.fromOffset(80, 40)
        tpBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        tpBtn.Text = "TP Murderer"
        tpBtn.TextColor3 = Color3.new(0,0,0)
        tpBtn.Font = Enum.Font.SourceSansBold
        tpBtn.TextSize = 14
        tpBtn.Parent = mobileScreenGui
        tpBtn.MouseButton1Click:Connect(function()
            local m = getMurderer()
            local root = getRoot(m)
            local localRoot = getRoot(LocalPlayer)
            if root and localRoot then localRoot.CFrame = root.CFrame end
        end)
    end
    if Settings.AimButton then
        aimBtn = Instance.new("TextButton")
        aimBtn.Size = UDim2.fromOffset(80, 40)
        aimBtn.Position = UDim2.new(0.2, 0, 0.1, 0)
        aimBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        aimBtn.Text = "MIRAR"
        aimBtn.TextColor3 = Color3.new(0,0,0)
        aimBtn.Font = Enum.Font.SourceSansBold
        aimBtn.TextSize = 14
        aimBtn.Parent = mobileScreenGui
        aimBtn.MouseButton1Click:Connect(function()
            local target = getNearestPlayer(200)
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end)
    end
end

function removeMobileButtons()
    if mobileScreenGui then mobileScreenGui:Destroy() mobileScreenGui = nil end
end

-- ================= ATUALIZAR DROPDOWNS =================
Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    local names = getPlayerNames()
    if playerDropdown then playerDropdown:Refresh(names, true) end
    if playerDropdown2 then playerDropdown2:Refresh(names, true) end
end)
Players.PlayerRemoving:Connect(function(p)
    task.wait(0.5)
    local names = getPlayerNames()
    if playerDropdown then playerDropdown:Refresh(names, true) end
    if playerDropdown2 then playerDropdown2:Refresh(names, true) end
end)

-- ================= MONITORAMENTO DE PAPÉIS =================
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

-- ================= ANTI-AFK =================
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

-- ================= FPS BOOST / LOW GRAPHICS =================
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

-- ================= SPINBOT =================
task.spawn(function()
    while true do
        task.wait()
        if Settings.Spinbot and LocalPlayer.Character then
            local root = getRoot(LocalPlayer)
            if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0) end
        end
    end
end)

-- ================= FAKE LAG VISUAL =================
task.spawn(function()
    while true do
        if Settings.FakeLagVisual then task.wait(0.1) else task.wait() end
    end
end)

print("Souza Hub carregado com sucesso!")
Notify("Souza Hub", "Script carregado com sucesso!")
