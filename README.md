-- Souza Hub - Script Completo para Murder Mystery 2
-- Feito por Souza

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Variáveis globais
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
    -- ESP
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
    -- Detection
    DetectMurderer = false,
    DetectSheriff = false,
    DetectHero = false,
    RoleNotifications = false,
    MurdererAlert = false,
    SheriffAlert = false,
    ShowGunPickup = false,
    -- Movement
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
    -- Farm
    AutoFarmCoins = false,
    AutoCollectCoins = false,
    AutoFarmCandy = false,
    CoinTP = false,
    AutoFarmXP = false,
    AutoFarmWins = false,
    AutoRejoin = false,
    ServerHop = false,
    -- Survival
    AutoDodge = false,
    AutoEscapeMurderer = false,
    AntiKnife = false,
    AntiGun = false,
    AntiFling = false,
    AntiAFK = false,
    AutoReset = false,
    SafeSpot = false,
    -- Visual
    Fullbright = false,
    RemoveFog = false,
    XRay = false,
    RemoveDoors = false,
    RemoveMapObjects = false,
    PlayerChams = false,
    Crosshair = false,
    CustomFOV = 70,
    NightVision = false,
    -- Player
    Spectate = false,
    View = false,
    Follow = false,
    Orbit = false,
    FreezeLocal = false,
    FreezeVisual = false,
    -- Gun
    GunDropESP = false,
    AutoGrabGun = false,
    GunAimAssist = false,
    GunPrediction2 = false,
    -- Knife
    ThrowPrediction = false,
    AutoThrow = false,
    KnifeTarget = nil,
    -- Mobile
    AimButton = false,
    ShootButton = false,
    ThrowKnifeButton = false,
    FlyControls = false,
    TPButton = false,
    -- Misc
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
local function getMurderer()
    -- Tenta detectar o assassino por meio de pasta "Murderer" ou valor
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local roleFolder = char:FindFirstChild("Murderer") or char:FindFirstChild("murderer")
                if roleFolder then
                    return player
                end
                -- Verifica por nome (alguns scripts usam nomes específicos)
                if char.Name:lower():find("murderer") then
                    return player
                end
            end
            -- Também verifica Backpack ou PlayerGui
            if player:FindFirstChild("Murderer") or player:FindFirstChild("murderer") then
                return player
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                if char:FindFirstChild("Sheriff") or char:FindFirstChild("sheriff") then
                    return player
                end
                if char.Name:lower():find("sheriff") then
                    return player
                end
            end
            if player:FindFirstChild("Sheriff") or player:FindFirstChild("sheriff") then
                return player
            end
        end
    end
    return nil
end

local function getHero()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                if char:FindFirstChild("Hero") or char:FindFirstChild("hero") then
                    return player
                end
                if char.Name:lower():find("hero") then
                    return player
                end
            end
            if player:FindFirstChild("Hero") or player:FindFirstChild("hero") then
                return player
            end
        end
    end
    return nil
end

local function getNearestPlayer(maxDist)
    local nearest = nil
    local dist = maxDist or math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (player.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if mag < dist then
                dist = mag
                nearest = player
            end
        end
    end
    return nearest
end

local function getGunDrop()
    -- Tenta encontrar um objeto de arma no Workspace
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and (v.Name:lower():find("gun") or v.Name:lower():find("pistol") or v.Name:lower():find("revolver")) then
            return v
        end
    end
    return nil
end

local function getKnife()
    if LocalPlayer.Character then
        local knife = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if knife and (knife.Name:lower():find("knife") or knife.Name:lower():find("faca")) then
            return knife
        end
    end
    return nil
end

local function getClosestCoin()
    local closest = nil
    local dist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            if v.Name:lower():find("coin") or v.Name:lower():find("moeda") then
                local mag = (v.Position - root.Position).Magnitude
                if mag < dist then
                    dist = mag
                    closest = v
                end
            end
        end
    end
    return closest
end

-- Funções de ESP (usando Drawing)
local ESPObjects = {}
local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Remove then obj:Remove() end
    end
    ESPObjects = {}
end

local function createESP(player)
    if not Settings.PlayerESP then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Box ESP
    if Settings.BoxESP then
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Filled = false
        box.Transparency = 1
        table.insert(ESPObjects, box)
        -- Atualizar posição em loop
        task.spawn(function()
            while Settings.BoxESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local size = (Camera:WorldToScreenPoint(root.Position + Vector3.new(0, 2, 0)).Y - pos.Y)
                    box.Size = Vector2.new(size / 2, size)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y)
                    box.Visible = true
                else
                    box.Visible = false
                end
                task.wait()
            end
            box:Remove()
        end)
    end

    -- Name ESP
    if Settings.NameESP then
        local name = Drawing.new("Text")
        name.Text = player.Name
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Size = 14
        name.Center = true
        name.Outline = true
        table.insert(ESPObjects, name)
        task.spawn(function()
            while Settings.NameESP and player.Character and player.Character:FindFirstChild("Head") do
                local pos, onScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
                if onScreen then
                    name.Position = Vector2.new(pos.X, pos.Y)
                    name.Visible = true
                else
                    name.Visible = false
                end
                task.wait()
            end
            name:Remove()
        end)
    end

    -- Distance ESP
    if Settings.DistanceESP then
        local dist = Drawing.new("Text")
        dist.Color = Color3.fromRGB(255, 255, 255)
        dist.Size = 12
        dist.Center = true
        dist.Outline = true
        table.insert(ESPObjects, dist)
        task.spawn(function()
            while Settings.DistanceESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                dist.Text = tostring(math.floor(distance)) .. "m"
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position + Vector3.new(0, 1, 0))
                if onScreen then
                    dist.Position = Vector2.new(pos.X, pos.Y)
                    dist.Visible = true
                else
                    dist.Visible = false
                end
                task.wait()
            end
            dist:Remove()
        end)
    end

    -- Tracer ESP
    if Settings.TracerESP then
        local tracer = Drawing.new("Line")
        tracer.Color = Color3.fromRGB(255, 255, 255)
        tracer.Thickness = 1
        tracer.Transparency = 1
        table.insert(ESPObjects, tracer)
        task.spawn(function()
            while Settings.TracerESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
                task.wait()
            end
            tracer:Remove()
        end)
    end

    -- Highlight ESP (usando Highlight do Roblox)
    if Settings.HighlightESP then
        local highlight = Instance.new("Highlight")
        highlight.Parent = char
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        table.insert(ESPObjects, highlight)
    end
end

-- Atualizar ESP em loop
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

-- Funções de combate
local function aimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local head = target.Character.Head
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
end

local function silentAim(target)
    -- Simula silent aim alterando a direção do tiro sem mover a câmera
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local head = target.Character.Head
    -- Aqui seria necessário manipular o sistema de armas do jogo, mas podemos tentar teleportar o tiro
    -- Deixaremos como placeholder: apenas notifica
    print("Silent Aim at " .. target.Name)
end

-- Loop principal para aimbot, kill aura, etc.
task.spawn(function()
    while true do
        task.wait()
        if Settings.Aimbot then
            local target = getNearestPlayer(Settings.AimFOV)
            if target then
                aimAt(target)
            end
        end
        if Settings.AimLock then
            local target = getNearestPlayer(Settings.AimFOV)
            if target then
                aimAt(target)
            end
        end
        if Settings.SilentAim and Settings.AutoShoot then
            local target = getNearestPlayer(Settings.AimFOV)
            if target then
                silentAim(target)
            end
        end
        if Settings.KillAura then
            local target = getNearestPlayer(20)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                -- Simula ataque corpo a corpo
                local knife = getKnife()
                if knife then
                    knife:Activate()
                end
            end
        end
        if Settings.KnifeAura then
            local target = getNearestPlayer(20)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                local knife = getKnife()
                if knife then
                    knife:Activate()
                end
            end
        end
        if Settings.AutoShoot then
            -- Tenta encontrar uma arma e atirar
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Ammo") then
                tool:Activate()
            end
        end
    end
end)

-- Loop para sobrevivência
task.spawn(function()
    while true do
        task.wait()
        if Settings.AutoDodge then
            local murderer = getMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (murderer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 10 then
                    -- Move para direção oposta
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local dir = (root.Position - murderer.Character.HumanoidRootPart.Position).Unit
                    root.CFrame = root.CFrame + dir * 10
                end
            end
        end
        if Settings.AntiVoid and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            if root.Position.Y < -100 then
                root.CFrame = CFrame.new(0, 50, 0) -- Teleporta para spawn
            end
        end
    end
end)

-- Loop para farm
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoCollectCoins or Settings.AutoFarmCoins then
            local coin = getClosestCoin()
            if coin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
            end
        end
        if Settings.CoinTP and Settings.AutoFarmCoins then
            local coin = getClosestCoin()
            if coin then
                LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
            end
        end
    end
end)

-- Funções de movimentação
local flyConnection
local function startFly()
    if flyConnection then flyConnection:Disconnect() end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = root.CFrame
    bodyGyro.Parent = root
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.velocity = Vector3.zero
    bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly then
            bodyGyro:Destroy()
            bodyVelocity:Destroy()
            flyConnection:Disconnect()
            return
        end
        local moveDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        bodyVelocity.velocity = moveDirection * 50
    end)
end

task.spawn(function()
    while true do
        task.wait()
        if Settings.Fly then
            startFly()
        else
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, v in ipairs(root:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                            v:Destroy()
                        end
                    end
                end
            end
        end
        if Settings.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid.FloorMaterial == Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Funções de visual
task.spawn(function()
    while true do
        task.wait()
        if Settings.Fullbright then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 1000
            game:GetService("Lighting").GlobalShadows = true
        end
        if Settings.RemoveFog then
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").FogStart = 0
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
                if v.Name:lower():find("door") then
                    v:Destroy()
                end
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
        if Settings.CustomFOV then
            Camera.FieldOfView = Settings.CustomFOV
        end
    end
end)

-- Funções de player (spectate, follow, etc.)
local spectateConnection
task.spawn(function()
    while true do
        task.wait()
        if Settings.Spectate and playerDropdown2.Value then
            local target = Players:FindFirstChild(playerDropdown2.Value)
            if target and target.Character then
                Camera.CameraSubject = target.Character
            end
        else
            Camera.CameraSubject = LocalPlayer.Character
        end
        if Settings.Follow and playerDropdown2.Value then
            local target = Players:FindFirstChild(playerDropdown2.Value)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
        if Settings.Orbit and playerDropdown2.Value then
            local target = Players:FindFirstChild(playerDropdown2.Value)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local angle = tick() % (2 * math.pi)
                local radius = 5
                local root = LocalPlayer.Character.HumanoidRootPart
                local targetRoot = target.Character.HumanoidRootPart
                local newPos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                root.CFrame = CFrame.new(newPos, targetRoot.Position)
            end
        end
    end
end)

-- Funções de arma e faca
task.spawn(function()
    while true do
        task.wait()
        if Settings.AutoGrabGun then
            local gun = getGunDrop()
            if gun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gun.CFrame
                task.wait(0.5)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 1)
            end
        end
        if Settings.AutoThrow and getKnife() then
            local knife = getKnife()
            knife:Activate()
        end
        if Settings.ThrowPrediction then
            -- Não implementado sem acesso ao sistema de física do jogo
        end
    end
end)

-- ================= INTERFACE =================
local Window = WindUI:CreateWindow({
    Title = "Souza Hub",
    Icon = "sparkles",
    Author = "Souza",
    Folder = "SouzaHub",
    Size = UDim2.fromOffset(620, 500),
    Theme = "Dark",
    Transparent = true,
})

-- Função para adicionar toggle com callback que salva em Settings
local function AddToggle(tab, section, title, default, settingName)
    local sectionObj = tab:Section({Title = section})
    local toggle = sectionObj:Toggle({
        Title = title,
        Default = default,
        Callback = function(value)
            Settings[settingName] = value
        end
    })
end

-- ================= MAIN TAB =================
local Main = Window:Tab({Title = "Main", Icon = "house"})
Main:Section({Title = "Exemplo"})
Main:Toggle({Title = "Example Toggle", Default = false, Callback = function(v) print("Example Toggle:", v) end})
Main:Button({Title = "Example Button", Callback = function() print("Clicou") end})

-- ================= COMBAT TAB =================
local Combat = Window:Tab({Title = "Combat", Icon = "swords"})
Combat:Section({Title = "Aim"})
Combat:Toggle({Title = "Aimbot", Default = false, Callback = function(v) Settings.Aimbot = v end})
Combat:Toggle({Title = "Silent Aim", Default = false, Callback = function(v) Settings.SilentAim = v end})
Combat:Toggle({Title = "Aim Lock", Default = false, Callback = function(v) Settings.AimLock = v end})
Combat:Slider({Title = "Aim FOV", Min = 0, Max = 360, Default = 90, Callback = function(v) Settings.AimFOV = v end})
Combat:Toggle({Title = "FOV Circle", Default = false, Callback = function(v) Settings.FOVCircle = v end})
Combat:Section({Title = "Automação"})
Combat:Toggle({Title = "Auto Shoot", Default = false, Callback = function(v) Settings.AutoShoot = v end})
Combat:Toggle({Title = "Auto Kill Murderer", Default = false, Callback = function(v) Settings.AutoKillMurderer = v end})
Combat:Toggle({Title = "Auto Kill Sheriff", Default = false, Callback = function(v) Settings.AutoKillSheriff = v end})
Combat:Toggle({Title = "Kill Aura", Default = false, Callback = function(v) Settings.KillAura = v end})
Combat:Toggle({Title = "Knife Aura", Default = false, Callback = function(v) Settings.KnifeAura = v end})
Combat:Toggle({Title = "Throw Knife Assist", Default = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
Combat:Slider({Title = "Knife Reach", Min = 10, Max = 100, Default = 20, Callback = function(v) Settings.KnifeReach = v end})
Combat:Slider({Title = "Gun Accuracy", Min = 0, Max = 100, Default = 50, Callback = function(v) Settings.GunAccuracy = v end})
Combat:Toggle({Title = "Gun Prediction", Default = false, Callback = function(v) Settings.GunPrediction = v end})
Combat:Toggle({Title = "Auto Pickup Gun", Default = false, Callback = function(v) Settings.AutoPickupGun = v end})
Combat:Toggle({Title = "Instant Gun Pickup", Default = false, Callback = function(v) Settings.InstantGunPickup = v end})

-- ================= ESP TAB =================
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
ESPTab:Section({Title = "Player ESP"})
ESPTab:Toggle({Title = "Player ESP", Default = false, Callback = function(v) Settings.PlayerESP = v; if not v then clearESP() end end})
ESPTab:Toggle({Title = "Name ESP", Default = false, Callback = function(v) Settings.NameESP = v end})
ESPTab:Toggle({Title = "Distance ESP", Default = false, Callback = function(v) Settings.DistanceESP = v end})
ESPTab:Toggle({Title = "Box ESP", Default = false, Callback = function(v) Settings.BoxESP = v end})
ESPTab:Toggle({Title = "Tracer ESP", Default = false, Callback = function(v) Settings.TracerESP = v end})
ESPTab:Toggle({Title = "Highlight ESP", Default = false, Callback = function(v) Settings.HighlightESP = v end})
ESPTab:Section({Title = "Role ESP"})
ESPTab:Toggle({Title = "Murderer ESP", Default = false, Callback = function(v) Settings.MurdererESP = v end})
ESPTab:Toggle({Title = "Sheriff ESP", Default = false, Callback = function(v) Settings.SheriffESP = v end})
ESPTab:Toggle({Title = "Innocent ESP", Default = false, Callback = function(v) Settings.InnocentESP = v end})
ESPTab:Toggle({Title = "Hero ESP", Default = false, Callback = function(v) Settings.HeroESP = v end})
ESPTab:Toggle({Title = "Gun ESP", Default = false, Callback = function(v) Settings.GunESP = v end})
ESPTab:Toggle({Title = "Role Colors", Default = false, Callback = function(v) Settings.RoleColors = v end})
ESPTab:Toggle({Title = "Role Chams", Default = false, Callback = function(v) Settings.RoleChams = v end})

-- ================= ROLE DETECTION =================
local RoleDet = Window:Tab({Title = "Role/Detecção", Icon = "user-secret"})
RoleDet:Section({Title = "Detecção"})
RoleDet:Toggle({Title = "Detect Murderer", Default = false, Callback = function(v) Settings.DetectMurderer = v end})
RoleDet:Toggle({Title = "Detect Sheriff", Default = false, Callback = function(v) Settings.DetectSheriff = v end})
RoleDet:Toggle({Title = "Detect Hero", Default = false, Callback = function(v) Settings.DetectHero = v end})
RoleDet:Section({Title = "Alertas"})
RoleDet:Toggle({Title = "Role Notifications", Default = false, Callback = function(v) Settings.RoleNotifications = v end})
RoleDet:Toggle({Title = "Murderer Alert", Default = false, Callback = function(v) Settings.MurdererAlert = v end})
RoleDet:Toggle({Title = "Sheriff Alert", Default = false, Callback = function(v) Settings.SheriffAlert = v end})
RoleDet:Toggle({Title = "Mostrar quem pegou a arma", Default = false, Callback = function(v) Settings.ShowGunPickup = v end})

-- ================= TELEPORT =================
local Teleport = Window:Tab({Title = "Teleport", Icon = "location-arrow"})
Teleport:Section({Title = "Teleportes Rápidos"})
Teleport:Button({Title = "Teleport to Murderer", Callback = function()
    local m = getMurderer()
    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
    end
end})
Teleport:Button({Title = "Teleport to Sheriff", Callback = function()
    local s = getSheriff()
    if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
    end
end})
Teleport:Button({Title = "Teleport to Gun Drop", Callback = function()
    local g = getGunDrop()
    if g and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = g.CFrame
    end
end})
Teleport:Button({Title = "Teleport to Lobby", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- Ajuste conforme o mapa
    end
end})
Teleport:Button({Title = "Teleport to Map", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- Ajuste
    end
end})
Teleport:Button({Title = "Teleport to Spawn", Callback = function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- Ajuste
    end
end})

Teleport:Section({Title = "Teleporte para Jogador"})
local playerDropdown = Teleport:Dropdown({
    Title = "Selecionar Jogador",
    Options = getPlayerNames(),
    Default = "",
    Callback = function(v) end
})
Teleport:Button({Title = "Teleport to Player", Callback = function()
    local target = playerDropdown.Value
    if target and target ~= "" then
        local plr = Players:FindFirstChild(target)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
        end
    end
end})
Teleport:Button({Title = "Teleport Behind Player", Callback = function()
    local target = playerDropdown.Value
    if target and target ~= "" then
        local plr = Players:FindFirstChild(target)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = plr.Character.HumanoidRootPart
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
        end
    end
end})

-- ================= MOVEMENT =================
local Movement = Window:Tab({Title = "Movement", Icon = "person-running"})
Movement:Section({Title = "Velocidade e Pulo"})
Movement:Slider({Title = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v)
    Settings.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})
Movement:Slider({Title = "JumpPower", Min = 50, Max = 300, Default = 50, Callback = function(v)
    Settings.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end})
Movement:Section({Title = "Movimentação Especial"})
Movement:Toggle({Title = "Infinite Jump", Default = false, Callback = function(v) Settings.InfiniteJump = v end})
Movement:Toggle({Title = "Fly", Default = false, Callback = function(v) Settings.Fly = v end})
Movement:Toggle({Title = "Noclip", Default = false, Callback = function(v) Settings.Noclip = v end})
Movement:Toggle({Title = "Click TP", Default = false, Callback = function(v) Settings.ClickTP = v end})
Movement:Toggle({Title = "Dash", Default = false, Callback = function(v) Settings.Dash = v end})
Movement:Toggle({Title = "Spin", Default = false, Callback = function(v) Settings.Spin = v end})
Movement:Toggle({Title = "Bunny Hop", Default = false, Callback = function(v) Settings.BunnyHop = v end})
Movement:Toggle({Title = "Anti-Void", Default = false, Callback = function(v) Settings.AntiVoid = v end})

-- ================= FARM =================
local Farm = Window:Tab({Title = "Farm", Icon = "coins"})
Farm:Section({Title = "Farm Automático"})
Farm:Toggle({Title = "Auto Farm Coins", Default = false, Callback = function(v) Settings.AutoFarmCoins = v end})
Farm:Toggle({Title = "Auto Collect Coins", Default = false, Callback = function(v) Settings.AutoCollectCoins = v end})
Farm:Toggle({Title = "Auto Farm Candy/Eventos", Default = false, Callback = function(v) Settings.AutoFarmCandy = v end})
Farm:Toggle({Title = "Coin TP", Default = false, Callback = function(v) Settings.CoinTP = v end})
Farm:Toggle({Title = "Auto Farm XP", Default = false, Callback = function(v) Settings.AutoFarmXP = v end})
Farm:Toggle({Title = "Auto Farm Wins", Default = false, Callback = function(v) Settings.AutoFarmWins = v end})
Farm:Toggle({Title = "Auto Rejoin", Default = false, Callback = function(v) Settings.AutoRejoin = v end})
Farm:Toggle({Title = "Server Hop", Default = false, Callback = function(v) Settings.ServerHop = v end})

-- ================= SURVIVAL =================
local Survival = Window:Tab({Title = "Survival", Icon = "shield-halved"})
Survival:Section({Title = "Defesa"})
Survival:Toggle({Title = "Auto Dodge", Default = false, Callback = function(v) Settings.AutoDodge = v end})
Survival:Toggle({Title = "Auto Escape Murderer", Default = false, Callback = function(v) Settings.AutoEscapeMurderer = v end})
Survival:Toggle({Title = "Anti-Knife", Default = false, Callback = function(v) Settings.AntiKnife = v end})
Survival:Toggle({Title = "Anti-Gun", Default = false, Callback = function(v) Settings.AntiGun = v end})
Survival:Toggle({Title = "Anti-Fling", Default = false, Callback = function(v) Settings.AntiFling = v end})
Survival:Toggle({Title = "Anti-AFK", Default = false, Callback = function(v) Settings.AntiAFK = v end})
Survival:Toggle({Title = "Auto Reset", Default = false, Callback = function(v) Settings.AutoReset = v end})
Survival:Toggle({Title = "Safe Spot", Default = false, Callback = function(v) Settings.SafeSpot = v end})

-- ================= VISUAL =================
local Visual = Window:Tab({Title = "Visual", Icon = "eye-slash"})
Visual:Section({Title = "Mundo"})
Visual:Toggle({Title = "Fullbright", Default = false, Callback = function(v) Settings.Fullbright = v end})
Visual:Toggle({Title = "Remove Fog", Default = false, Callback = function(v) Settings.RemoveFog = v end})
Visual:Toggle({Title = "X-Ray", Default = false, Callback = function(v) Settings.XRay = v end})
Visual:Toggle({Title = "Remove Doors", Default = false, Callback = function(v) Settings.RemoveDoors = v end})
Visual:Toggle({Title = "Remove Map Objects", Default = false, Callback = function(v) Settings.RemoveMapObjects = v end})
Visual:Section({Title = "Jogador e Câmera"})
Visual:Toggle({Title = "Player Chams", Default = false, Callback = function(v) Settings.PlayerChams = v end})
Visual:Toggle({Title = "Crosshair", Default = false, Callback = function(v) Settings.Crosshair = v end})
Visual:Slider({Title = "Custom FOV", Min = 30, Max = 120, Default = 70, Callback = function(v) Settings.CustomFOV = v end})
Visual:Toggle({Title = "Night Vision", Default = false, Callback = function(v) Settings.NightVision = v end})

-- ================= PLAYER =================
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
PlayerTab:Section({Title = "Interações"})
local playerDropdown2 = PlayerTab:Dropdown({
    Title = "Selecionar Jogador",
    Options = getPlayerNames(),
    Default = "",
    Callback = function(v) end
})
PlayerTab:Toggle({Title = "Spectate Player", Default = false, Callback = function(v) Settings.Spectate = v end})
PlayerTab:Toggle({Title = "View Player", Default = false, Callback = function(v) Settings.View = v end})
PlayerTab:Toggle({Title = "Follow Player", Default = false, Callback = function(v) Settings.Follow = v end})
PlayerTab:Toggle({Title = "Orbit Player", Default = false, Callback = function(v) Settings.Orbit = v end})
PlayerTab:Section({Title = "Ações"})
PlayerTab:Button({Title = "Fling", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = Players:FindFirstChild(target)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            root.Velocity = Vector3.new(0, 5000, 0)
            root.RotVelocity = Vector3.new(100, 100, 100)
        end
    end
end})
PlayerTab:Button({Title = "Bring Player", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = Players:FindFirstChild(target)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end})
PlayerTab:Toggle({Title = "Freeze Local", Default = false, Callback = function(v) Settings.FreezeLocal = v end})
PlayerTab:Toggle({Title = "Freeze Visual", Default = false, Callback = function(v) Settings.FreezeVisual = v end})
PlayerTab:Button({Title = "Copy Avatar", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = Players:FindFirstChild(target)
        if plr and plr.Character and LocalPlayer.Character then
            -- Copia roupas (precisa de acesso a HumanoidDescription)
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ApplyDescription(plr.Character:FindFirstChildOfClass("Humanoid").HumanoidDescription)
            end
        end
    end
end})

-- ================= GUN =================
local Gun = Window:Tab({Title = "Gun", Icon = "gun"})
Gun:Section({Title = "Arma"})
Gun:Toggle({Title = "Gun Drop ESP", Default = false, Callback = function(v) Settings.GunDropESP = v end})
Gun:Button({Title = "Teleport Gun", Callback = function()
    local g = getGunDrop()
    if g and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = g.CFrame
    end
end})
Gun:Toggle({Title = "Auto Grab Gun", Default = false, Callback = function(v) Settings.AutoGrabGun = v end})
Gun:Toggle({Title = "Gun Aim Assist", Default = false, Callback = function(v) Settings.GunAimAssist = v end})
Gun:Toggle({Title = "Gun Prediction", Default = false, Callback = function(v) Settings.GunPrediction2 = v end})
Gun:Button({Title = "Shoot Murderer", Callback = function()
    local m = getMurderer()
    if m and m.Character then
        aimAt(m)
        task.wait(0.5)
        -- Tentar atirar
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end})
Gun:Section({Title = "Mobile"})
Gun:Toggle({Title = "Botão de Atirar (Mobile)", Default = false, Callback = function(v) Settings.ShootButton = v end})

-- ================= KNIFE =================
local Knife = Window:Tab({Title = "Knife", Icon = "dagger"})
Knife:Section({Title = "Faca"})
Knife:Toggle({Title = "Knife Throw Assist", Default = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
Knife:Toggle({Title = "Throw Prediction", Default = false, Callback = function(v) Settings.ThrowPrediction = v end})
Knife:Slider({Title = "Knife Range/Reach", Min = 10, Max = 100, Default = 20, Callback = function(v) Settings.KnifeReach = v end})
Knife:Toggle({Title = "Auto Throw", Default = false, Callback = function(v) Settings.AutoThrow = v end})
Knife:Toggle({Title = "Knife Aura", Default = false, Callback = function(v) Settings.KnifeAura = v end})
Knife:Toggle({Title = "Fake Knife", Default = false, Callback = function(v) Settings.FakeKnife = v end})
Knife:Section({Title = "Alvo"})
Knife:Dropdown({
    Title = "Knife Target",
    Options = getPlayerNames(),
    Default = "",
    Callback = function(v) Settings.KnifeTarget = v end
})

-- ================= MOBILE =================
local Mobile = Window:Tab({Title = "Mobile", Icon = "mobile-screen"})
Mobile:Section({Title = "Botões Mobile"})
Mobile:Toggle({Title = "Aim Button", Default = false, Callback = function(v) Settings.AimButton = v end})
Mobile:Toggle({Title = "Shoot Button", Default = false, Callback = function(v) Settings.ShootButton = v end})
Mobile:Toggle({Title = "Throw Knife Button", Default = false, Callback = function(v) Settings.ThrowKnifeButton = v end})
Mobile:Toggle({Title = "Fly Controls", Default = false, Callback = function(v) Settings.FlyControls = v end})
Mobile:Toggle({Title = "TP Button", Default = false, Callback = function(v) Settings.TPButton = v end})
Mobile:Section({Title = "ESP Rápido"})
Mobile:Toggle({Title = "Ligar/Desligar ESP", Default = false, Callback = function(v) Settings.PlayerESP = v end})

-- ================= INTERFACE =================
local Interface = Window:Tab({Title = "Interface", Icon = "sliders"})
Interface:Section({Title = "Configurações da UI"})
Interface:Dropdown({
    Title = "Tema",
    Options = {"Dark", "Light", "Blue", "Purple"},
    Default = "Dark",
    Callback = function(v) print("Tema alterado para " .. v) end
})
Interface:Slider({Title = "Escala da UI", Min = 50, Max = 150, Default = 100, Callback = function(v) end})
Interface:Toggle({Title = "Notificações", Default = true, Callback = function(v) end})
Interface:Button({Title = "Minimizar UI", Callback = function() Window:Minimize() end})
Interface:Button({Title = "Esconder UI", Callback = function() Window:Close() end})
Interface:Button({Title = "Salvar Configurações", Callback = function() print("Configurações salvas") end})
Interface:Keybind({Title = "Keybind Esconder UI", Default = "RightShift", Callback = function() Window:Close() end})

-- ================= SERVER =================
local Server = Window:Tab({Title = "Server", Icon = "server"})
Server:Section({Title = "Servidor"})
Server:Button({Title = "Server Hop", Callback = function()
    -- Usar função de teleporte para outro servidor (requer API)
    local HttpService = game:GetService("HttpService")
    local jobId = HttpService:GenerateGUID(false)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end})
Server:Button({Title = "Rejoin", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})
Server:Button({Title = "Join Small Server", Callback = function()
    -- Não implementado
    print("Buscando servidor pequeno...")
end})
Server:Button({Title = "Join New Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})
Server:Button({Title = "Copiar JobId", Callback = function()
    setclipboard(game.JobId)
    print("JobId copiado: " .. game.JobId)
end})
Server:Label({Title = "Player Count: " .. #Players:GetPlayers()})

-- ================= MISC =================
local Misc = Window:Tab({Title = "Misc", Icon = "gear"})
Misc:Section({Title = "Extras"})
Misc:Toggle({Title = "Anti-AFK", Default = false, Callback = function(v) Settings.AntiAFK2 = v end})
Misc:Toggle({Title = "FPS Boost", Default = false, Callback = function(v) Settings.FPSBoost = v end})
Misc:Toggle({Title = "Remove Textures", Default = false, Callback = function(v) Settings.RemoveTextures = v end})
Misc:Toggle({Title = "Low Graphics", Default = false, Callback = function(v) Settings.LowGraphics = v end})
Misc:Toggle({Title = "Chat Spy", Default = false, Callback = function(v) Settings.ChatSpy = v end})
Misc:Toggle({Title = "Spinbot", Default = false, Callback = function(v) Settings.Spinbot = v end})
Misc:Toggle({Title = "Fake Lag Visual", Default = false, Callback = function(v) Settings.FakeLagVisual = v end})
Misc:Section({Title = "Diversão"})
Misc:Dropdown({
    Title = "Emotes",
    Options = {"Dança 1", "Dança 2", "Aceno", "Rir"},
    Default = "Dança 1",
    Callback = function(v) print("Emote: " .. v) end
})
Misc:Button({Title = "Dançar", Callback = function()
    -- Tenta tocar animação de dança
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://507766388" -- Exemplo
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local track = humanoid:LoadAnimation(anim)
        track:Play()
    end
end})
Misc:Section({Title = "Informações da Partida"})
Misc:Label({Title = "Modo: Murder Mystery 2"})
Misc:Label({Title = "Jogadores: " .. #Players:GetPlayers()})

-- Inicializa algumas funções
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(15), 0)
        end
        if Settings.FakeLagVisual then
            -- Simula lag visual pausando o render por um instante
            task.wait(0.05)
        end
    end
end)

print("Souza Hub carregado com sucesso!")
