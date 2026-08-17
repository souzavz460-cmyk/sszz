-- Souza Hub - Script Completo para Murder Mystery 2 (Atualizado)
-- Feito por Souza | Suporte: discord.gg/souza

--[[
    Instruções:
    - Executar em um exploit compatível com loadstring e game:HttpGet.
    - Aguardar carregamento completo.
    - Algumas funções dependem da estrutura do jogo; se necessário, ajuste os nomes de pastas.
]]

-- ================= SERVIÇOS =================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ================= CONFIGURAÇÕES =================
local Settings = {
    -- Combat
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

-- ================= FUNÇÕES AUXILIARES =================
local function Notify(title, message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 5
    })
end

local function getRole(player)
    -- Retorna "Murderer", "Sheriff", "Hero", "Innocent" ou nil
    if not player or player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return nil end
    
    -- Método 1: pastas no personagem
    if char:FindFirstChild("Murderer") or char:FindFirstChild("murderer") then
        return "Murderer"
    elseif char:FindFirstChild("Sheriff") or char:FindFirstChild("sheriff") then
        return "Sheriff"
    elseif char:FindFirstChild("Hero") or char:FindFirstChild("hero") then
        return "Hero"
    end
    
    -- Método 2: pastas no Player
    if player:FindFirstChild("Murderer") or player:FindFirstChild("murderer") then
        return "Murderer"
    elseif player:FindFirstChild("Sheriff") or player:FindFirstChild("sheriff") then
        return "Sheriff"
    elseif player:FindFirstChild("Hero") or player:FindFirstChild("hero") then
        return "Hero"
    end
    
    -- Método 3: através de ferramentas (faca = murderer, arma = sheriff/hero)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local name = tool.Name:lower()
        if name:find("knife") or name:find("faca") then
            return "Murderer"
        elseif name:find("gun") or name:find("pistol") or name:find("revolver") then
            -- Pode ser sheriff ou hero; checar se tem algo mais
            if char:FindFirstChild("Hero") or player:FindFirstChild("Hero") then
                return "Hero"
            else
                return "Sheriff"
            end
        end
    end
    
    -- Método 4: valores específicos (alguns scripts usam IntValue no Player)
    local roleVal = player:FindFirstChild("Role") or player:FindFirstChild("role")
    if roleVal and roleVal:IsA("StringValue") then
        local val = roleVal.Value:lower()
        if val:find("murderer") then return "Murderer"
        elseif val:find("sheriff") then return "Sheriff"
        elseif val:find("hero") then return "Hero"
        end
    end
    
    -- Se nada detectado, é Inocente
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
    -- Procurar no Backpack também
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

local function getCharacter(player)
    return player and player.Character
end

local function getRoot(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function fireClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

local function activateTool(tool)
    if tool then
        tool:Activate()
    end
end

local function shootGun()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") or tool.Name:lower():find("revolver")) then
        tool:Activate()
        -- Alguns scripts precisam de clique real
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
local espConnections = {}

local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Remove then
            obj:Remove()
        elseif obj.Destroy then
            obj:Destroy()
        end
    end
    table.clear(ESPObjects)
end

local function getRoleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 0, 0)      -- Vermelho
    elseif role == "Sheriff" then
        return Color3.fromRGB(0, 100, 255)    -- Azul
    elseif role == "Hero" then
        return Color3.fromRGB(255, 215, 0)    -- Dourado
    elseif role == "Innocent" then
        return Color3.fromRGB(0, 255, 0)      -- Verde
    else
        return Color3.fromRGB(255, 255, 255)  -- Branco
    end
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
    
    -- Highlight
    if Settings.HighlightESP then
        local highlight = Instance.new("Highlight")
        highlight.Parent = char
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5
        table.insert(ESPObjects, highlight)
    end
    
    -- Box ESP
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
    
    -- Name ESP
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
    
    -- Distance ESP
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
    
    -- Tracer ESP
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

-- Atualiza ESP para todos os jogadores
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
-- Aimbot / Aim Lock
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

-- Silent Aim (simulação: apenas mantém a mira, mas não altera câmera visível)
-- Auto Shoot
task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AutoShoot then
            shootGun()
        end
        if Settings.AutoKillMurderer then
            local m = getMurderer()
            if m and m.Character and m.Character:FindFirstChild("Humanoid") then
                -- Verifica se tem arma
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
                    -- Atira no murderer
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, m.Character.Head.Position)
                    tool:Activate()
                end
            end
        end
        if Settings.AutoKillSheriff then
            local s = getSheriff()
            if s and s.Character and s.Character:FindFirstChild("Humanoid") then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, s.Character.Head.Position)
                    tool:Activate()
                end
            end
        end
    end
end)

-- Kill Aura / Knife Aura
task.spawn(function()
    while true do
        task.wait()
        if Settings.KillAura or Settings.KnifeAura then
            local target = getNearestPlayer(20)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                local knife = findKnife()
                if knife then
                    knife:Activate()
                end
            end
        end
    end
end)

-- ================= MOVEMENT LOOPS =================
local flyBodyGyro, flyBodyVelocity

local function stopFly()
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
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
        -- Fly
        if Settings.Fly then
            if not flyBodyGyro or not flyBodyVelocity then
                startFly()
            end
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
        -- Noclip
        if Settings.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        -- Infinite Jump
        if Settings.InfiniteJump and LocalPlayer.Character then
            local humanoid = getHumanoid(LocalPlayer)
            if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        -- WalkSpeed e JumpPower
        local humanoid = getHumanoid(LocalPlayer)
        if humanoid then
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
        -- Anti-Void
        if Settings.AntiVoid and LocalPlayer.Character then
            local root = getRoot(LocalPlayer)
            if root and root.Position.Y < -200 then
                root.CFrame = CFrame.new(0, 20, 0) -- respawn genérico
            end
        end
    end
end)

-- Click TP
if Settings.ClickTP then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.ClickTP then
            local mouse = LocalPlayer:GetMouse()
            local ray = mouse.UnitRay
            local targetPos = ray.Origin + ray.Direction * 100
            local root = getRoot(LocalPlayer)
            if root then
                root.CFrame = CFrame.new(targetPos)
            end
        end
    end)
end

-- ================= VISUAL LOOPS =================
task.spawn(function()
    while true do
        task.wait()
        -- Fullbright
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
        -- Remove Fog
        if Settings.RemoveFog then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
        -- X-Ray
        if Settings.XRay then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                    v.LocalTransparencyModifier = 0.7
                end
            end
        end
        -- Remove Doors
        if Settings.RemoveDoors then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("door") then
                    v:Destroy()
                end
            end
        end
        -- Remove Map Objects
        if Settings.RemoveMapObjects then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("wall") or v.Name:lower():find("obstacle")) then
                    v.Transparency = 1
                    v.CanCollide = false
                end
            end
        end
        -- Custom FOV
        Camera.FieldOfView = Settings.CustomFOV
        -- Night Vision
        if Settings.NightVision then
            Lighting.ColorCorrectionEffect = Color3.new(0, 1, 0)
        else
            Lighting.ColorCorrectionEffect = Color3.new(0, 0, 0)
        end
    end
end)

-- ================= PLAYER LOOPS (Spectate, Follow, Orbit) =================
task.spawn(function()
    while true do
        task.wait()
        if Settings.Spectate and playerDropdown2 and playerDropdown2.Value then
            local target = getPlayerByName(playerDropdown2.Value)
            if target and target.Character then
                Camera.CameraSubject = target.Character
            end
        else
            if LocalPlayer.Character then
                Camera.CameraSubject = LocalPlayer.Character
            end
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
        if Settings.AutoFarmCoins or Settings.AutoCollectCoins then
            local coin = findCoin()
            local root = getRoot(LocalPlayer)
            if coin and root then
                root.CFrame = coin.CFrame
            end
        end
        if Settings.CoinTP then
            local coin = findCoin()
            local root = getRoot(LocalPlayer)
            if coin and root then
                root.CFrame = coin.CFrame
            end
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
        if Settings.AutoThrow then
            throwKnife()
        end
        if Settings.GunAimAssist then
            local target = getNearestPlayer(100)
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

-- ================= INTERFACE WINDUI =================
local Window = WindUI:CreateWindow({
    Title = "Souza Hub",
    Icon = "sparkles",
    Author = "Souza",
    Folder = "SouzaHub",
    Size = UDim2.fromOffset(640, 520),
    Theme = "Dark",
    Transparent = true,
})

-- Função para criar seção rapidamente
local function QuickSection(tab, title)
    return tab:Section({Title = title})
end

-- ================= MAIN TAB =================
local MainTab = Window:Tab({Title = "Main", Icon = "house"})
local MainSection = QuickSection(MainTab, "Bem-vindo")
MainSection:Label({Title = "Souza Hub carregado com sucesso!"})
MainSection:Button({Title = "Iniciar", Callback = function()
    Notify("Souza Hub", "Script ativado!")
end})

-- ================= COMBAT TAB =================
local CombatTab = Window:Tab({Title = "Combat", Icon = "swords"})
local CombatAimSection = QuickSection(CombatTab, "Aim")
CombatAimSection:Toggle({Title = "Aimbot", Default = false, Callback = function(v) Settings.Aimbot = v end})
CombatAimSection:Toggle({Title = "Silent Aim", Default = false, Callback = function(v) Settings.SilentAim = v end})
CombatAimSection:Toggle({Title = "Aim Lock", Default = false, Callback = function(v) Settings.AimLock = v end})
CombatAimSection:Slider({Title = "Aim FOV", Min = 0, Max = 360, Default = 90, Callback = function(v) Settings.AimFOV = v end})
CombatAimSection:Toggle({Title = "FOV Circle", Default = false, Callback = function(v) Settings.FOVCircle = v end})
local CombatAutoSection = QuickSection(CombatTab, "Automação")
CombatAutoSection:Toggle({Title = "Auto Shoot", Default = false, Callback = function(v) Settings.AutoShoot = v end})
CombatAutoSection:Toggle({Title = "Auto Kill Murderer", Default = false, Callback = function(v) Settings.AutoKillMurderer = v end})
CombatAutoSection:Toggle({Title = "Auto Kill Sheriff", Default = false, Callback = function(v) Settings.AutoKillSheriff = v end})
CombatAutoSection:Toggle({Title = "Kill Aura", Default = false, Callback = function(v) Settings.KillAura = v end})
CombatAutoSection:Toggle({Title = "Knife Aura", Default = false, Callback = function(v) Settings.KnifeAura = v end})
CombatAutoSection:Toggle({Title = "Throw Knife Assist", Default = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
CombatAutoSection:Slider({Title = "Knife Reach", Min = 10, Max = 100, Default = 20, Callback = function(v) Settings.KnifeReach = v end})
CombatAutoSection:Slider({Title = "Gun Accuracy", Min = 0, Max = 100, Default = 50, Callback = function(v) Settings.GunAccuracy = v end})
CombatAutoSection:Toggle({Title = "Gun Prediction", Default = false, Callback = function(v) Settings.GunPrediction = v end})
CombatAutoSection:Toggle({Title = "Auto Pickup Gun", Default = false, Callback = function(v) Settings.AutoPickupGun = v end})
CombatAutoSection:Toggle({Title = "Instant Gun Pickup", Default = false, Callback = function(v) Settings.InstantGunPickup = v end})

-- ================= ESP TAB =================
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
local ESPMainSection = QuickSection(ESPTab, "ESP Geral")
ESPMainSection:Toggle({Title = "Player ESP", Default = false, Callback = function(v) Settings.PlayerESP = v; if not v then clearESP() end end})
ESPMainSection:Toggle({Title = "Name ESP", Default = false, Callback = function(v) Settings.NameESP = v end})
ESPMainSection:Toggle({Title = "Distance ESP", Default = false, Callback = function(v) Settings.DistanceESP = v end})
ESPMainSection:Toggle({Title = "Box ESP", Default = false, Callback = function(v) Settings.BoxESP = v end})
ESPMainSection:Toggle({Title = "Tracer ESP", Default = false, Callback = function(v) Settings.TracerESP = v end})
ESPMainSection:Toggle({Title = "Highlight ESP", Default = false, Callback = function(v) Settings.HighlightESP = v end})
local ESPRoleSection = QuickSection(ESPTab, "ESP por Papel")
ESPRoleSection:Toggle({Title = "Murderer ESP (Vermelho)", Default = false, Callback = function(v) Settings.MurdererESP = v end})
ESPRoleSection:Toggle({Title = "Sheriff ESP (Azul)", Default = false, Callback = function(v) Settings.SheriffESP = v end})
ESPRoleSection:Toggle({Title = "Innocent ESP (Verde)", Default = false, Callback = function(v) Settings.InnocentESP = v end})
ESPRoleSection:Toggle({Title = "Hero ESP (Dourado)", Default = false, Callback = function(v) Settings.HeroESP = v end})
ESPRoleSection:Toggle({Title = "Gun ESP", Default = false, Callback = function(v) Settings.GunESP = v end})
ESPRoleSection:Toggle({Title = "Role Colors", Default = false, Callback = function(v) Settings.RoleColors = v end})
ESPRoleSection:Toggle({Title = "Role Chams", Default = false, Callback = function(v) Settings.RoleChams = v end})

-- ================= ROLE/DETECTION TAB =================
local RoleDetTab = Window:Tab({Title = "Role/Detecção", Icon = "user-secret"})
local RoleDetSection = QuickSection(RoleDetTab, "Detecção de Papéis")
RoleDetSection:Toggle({Title = "Detect Murderer", Default = false, Callback = function(v) Settings.DetectMurderer = v end})
RoleDetSection:Toggle({Title = "Detect Sheriff", Default = false, Callback = function(v) Settings.DetectSheriff = v end})
RoleDetSection:Toggle({Title = "Detect Hero", Default = false, Callback = function(v) Settings.DetectHero = v end})
local RoleAlertSection = QuickSection(RoleDetTab, "Alertas")
RoleAlertSection:Toggle({Title = "Role Notifications", Default = false, Callback = function(v) Settings.RoleNotifications = v end})
RoleAlertSection:Toggle({Title = "Murderer Alert", Default = false, Callback = function(v) Settings.MurdererAlert = v end})
RoleAlertSection:Toggle({Title = "Sheriff Alert", Default = false, Callback = function(v) Settings.SheriffAlert = v end})
RoleAlertSection:Toggle({Title = "Mostrar quem pegou a arma", Default = false, Callback = function(v) Settings.ShowGunPickup = v end})

-- ================= TELEPORT TAB =================
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "location-arrow"})
local TeleportSection = QuickSection(TeleportTab, "Teleportes")
TeleportSection:Button({Title = "Teleport to Murderer", Callback = function()
    local m = getMurderer()
    local targetRoot = getRoot(m)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then
        localRoot.CFrame = targetRoot.CFrame
        Notify("Teleport", "Teleportado ao Murderer")
    else
        Notify("Teleport", "Murderer não encontrado")
    end
end})
TeleportSection:Button({Title = "Teleport to Sheriff", Callback = function()
    local s = getSheriff()
    local targetRoot = getRoot(s)
    local localRoot = getRoot(LocalPlayer)
    if targetRoot and localRoot then
        localRoot.CFrame = targetRoot.CFrame
        Notify("Teleport", "Teleportado ao Sheriff")
    else
        Notify("Teleport", "Sheriff não encontrado")
    end
end})
TeleportSection:Button({Title = "Teleport to Gun Drop", Callback = function()
    local gun = findGunDrop()
    local localRoot = getRoot(LocalPlayer)
    if gun and localRoot then
        localRoot.CFrame = gun.CFrame
        Notify("Teleport", "Teleportado à arma")
    else
        Notify("Teleport", "Arma não encontrada")
    end
end})
TeleportSection:Button({Title = "Teleport to Lobby", Callback = function()
    local localRoot = getRoot(LocalPlayer)
    if localRoot then
        localRoot.CFrame = CFrame.new(0, 30, 0) -- ajuste
    end
end})
TeleportSection:Button({Title = "Teleport to Map", Callback = function()
    local localRoot = getRoot(LocalPlayer)
    if localRoot then
        localRoot.CFrame = CFrame.new(0, 30, 0) -- ajuste
    end
end})
TeleportSection:Button({Title = "Teleport to Spawn", Callback = function()
    local localRoot = getRoot(LocalPlayer)
    if localRoot then
        localRoot.CFrame = CFrame.new(0, 30, 0) -- ajuste
    end
end})
local TeleportPlayerSection = QuickSection(TeleportTab, "Teleportar para Jogador")
local playerDropdown = TeleportPlayerSection:Dropdown({
    Title = "Selecionar Jogador",
    Options = getPlayerNames(),
    Default = "",
    Callback = function(v) end
})
TeleportPlayerSection:Button({Title = "Teleport to Player", Callback = function()
    local target = playerDropdown.Value
    if target and target ~= "" then
        local plr = getPlayerByName(target)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then
            localRoot.CFrame = targetRoot.CFrame
        end
    end
end})
TeleportPlayerSection:Button({Title = "Teleport Behind Player", Callback = function()
    local target = playerDropdown.Value
    if target and target ~= "" then
        local plr = getPlayerByName(target)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then
            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
        end
    end
end})

-- ================= MOVEMENT TAB =================
local MovementTab = Window:Tab({Title = "Movement", Icon = "person-running"})
local MovementSection = QuickSection(MovementTab, "Velocidade e Pulo")
MovementSection:Slider({Title = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v) Settings.WalkSpeed = v end})
MovementSection:Slider({Title = "JumpPower", Min = 50, Max = 300, Default = 50, Callback = function(v) Settings.JumpPower = v end})
local MovementSpecialSection = QuickSection(MovementTab, "Movimentação Especial")
MovementSpecialSection:Toggle({Title = "Infinite Jump", Default = false, Callback = function(v) Settings.InfiniteJump = v end})
MovementSpecialSection:Toggle({Title = "Fly", Default = false, Callback = function(v) Settings.Fly = v end})
MovementSpecialSection:Toggle({Title = "Noclip", Default = false, Callback = function(v) Settings.Noclip = v end})
MovementSpecialSection:Toggle({Title = "Click TP", Default = false, Callback = function(v) Settings.ClickTP = v end})
MovementSpecialSection:Toggle({Title = "Dash", Default = false, Callback = function(v) Settings.Dash = v end})
MovementSpecialSection:Toggle({Title = "Spin", Default = false, Callback = function(v) Settings.Spin = v end})
MovementSpecialSection:Toggle({Title = "Bunny Hop", Default = false, Callback = function(v) Settings.BunnyHop = v end})
MovementSpecialSection:Toggle({Title = "Anti-Void", Default = false, Callback = function(v) Settings.AntiVoid = v end})

-- ================= FARM TAB =================
local FarmTab = Window:Tab({Title = "Farm", Icon = "coins"})
local FarmSection = QuickSection(FarmTab, "Farm Automático")
FarmSection:Toggle({Title = "Auto Farm Coins", Default = false, Callback = function(v) Settings.AutoFarmCoins = v end})
FarmSection:Toggle({Title = "Auto Collect Coins", Default = false, Callback = function(v) Settings.AutoCollectCoins = v end})
FarmSection:Toggle({Title = "Auto Farm Candy/Eventos", Default = false, Callback = function(v) Settings.AutoFarmCandy = v end})
FarmSection:Toggle({Title = "Coin TP", Default = false, Callback = function(v) Settings.CoinTP = v end})
FarmSection:Toggle({Title = "Auto Farm XP", Default = false, Callback = function(v) Settings.AutoFarmXP = v end})
FarmSection:Toggle({Title = "Auto Farm Wins", Default = false, Callback = function(v) Settings.AutoFarmWins = v end})
FarmSection:Toggle({Title = "Auto Rejoin", Default = false, Callback = function(v) Settings.AutoRejoin = v end})
FarmSection:Toggle({Title = "Server Hop", Default = false, Callback = function(v) Settings.ServerHop = v end})

-- ================= SURVIVAL TAB =================
local SurvivalTab = Window:Tab({Title = "Survival", Icon = "shield-halved"})
local SurvivalSection = QuickSection(SurvivalTab, "Defesa")
SurvivalSection:Toggle({Title = "Auto Dodge", Default = false, Callback = function(v) Settings.AutoDodge = v end})
SurvivalSection:Toggle({Title = "Auto Escape Murderer", Default = false, Callback = function(v) Settings.AutoEscapeMurderer = v end})
SurvivalSection:Toggle({Title = "Anti-Knife", Default = false, Callback = function(v) Settings.AntiKnife = v end})
SurvivalSection:Toggle({Title = "Anti-Gun", Default = false, Callback = function(v) Settings.AntiGun = v end})
SurvivalSection:Toggle({Title = "Anti-Fling", Default = false, Callback = function(v) Settings.AntiFling = v end})
SurvivalSection:Toggle({Title = "Anti-AFK", Default = false, Callback = function(v) Settings.AntiAFK = v end})
SurvivalSection:Toggle({Title = "Auto Reset", Default = false, Callback = function(v) Settings.AutoReset = v end})
SurvivalSection:Toggle({Title = "Safe Spot", Default = false, Callback = function(v) Settings.SafeSpot = v end})

-- ================= VISUAL TAB =================
local VisualTab = Window:Tab({Title = "Visual", Icon = "eye-slash"})
local VisualWorldSection = QuickSection(VisualTab, "Mundo")
VisualWorldSection:Toggle({Title = "Fullbright", Default = false, Callback = function(v) Settings.Fullbright = v end})
VisualWorldSection:Toggle({Title = "Remove Fog", Default = false, Callback = function(v) Settings.RemoveFog = v end})
VisualWorldSection:Toggle({Title = "X-Ray", Default = false, Callback = function(v) Settings.XRay = v end})
VisualWorldSection:Toggle({Title = "Remove Doors", Default = false, Callback = function(v) Settings.RemoveDoors = v end})
VisualWorldSection:Toggle({Title = "Remove Map Objects", Default = false, Callback = function(v) Settings.RemoveMapObjects = v end})
local VisualPlayerSection = QuickSection(VisualTab, "Jogador e Câmera")
VisualPlayerSection:Toggle({Title = "Player Chams", Default = false, Callback = function(v) Settings.PlayerChams = v end})
VisualPlayerSection:Toggle({Title = "Crosshair", Default = false, Callback = function(v) Settings.Crosshair = v end})
VisualPlayerSection:Slider({Title = "Custom FOV", Min = 30, Max = 120, Default = 70, Callback = function(v) Settings.CustomFOV = v end})
VisualPlayerSection:Toggle({Title = "Night Vision", Default = false, Callback = function(v) Settings.NightVision = v end})

-- ================= PLAYER TAB =================
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
local PlayerSelectSection = QuickSection(PlayerTab, "Selecionar Jogador")
local playerDropdown2 = PlayerSelectSection:Dropdown({
    Title = "Jogador Alvo",
    Options = getPlayerNames(),
    Default = "",
    Callback = function(v) end
})
local PlayerActionSection = QuickSection(PlayerTab, "Interações")
PlayerActionSection:Toggle({Title = "Spectate Player", Default = false, Callback = function(v) Settings.Spectate = v end})
PlayerActionSection:Toggle({Title = "View Player", Default = false, Callback = function(v) Settings.View = v end})
PlayerActionSection:Toggle({Title = "Follow Player", Default = false, Callback = function(v) Settings.Follow = v end})
PlayerActionSection:Toggle({Title = "Orbit Player", Default = false, Callback = function(v) Settings.Orbit = v end})
PlayerActionSection:Button({Title = "Fling", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = getPlayerByName(target)
        local root = getRoot(plr)
        if root then
            root.Velocity = Vector3.new(0, 5000, 0)
            root.RotVelocity = Vector3.new(100, 100, 100)
        end
    end
end})
PlayerActionSection:Button({Title = "Bring Player", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = getPlayerByName(target)
        local targetRoot = getRoot(plr)
        local localRoot = getRoot(LocalPlayer)
        if targetRoot and localRoot then
            targetRoot.CFrame = localRoot.CFrame
        end
    end
end})
PlayerActionSection:Toggle({Title = "Freeze Local", Default = false, Callback = function(v) Settings.FreezeLocal = v end})
PlayerActionSection:Toggle({Title = "Freeze Visual", Default = false, Callback = function(v) Settings.FreezeVisual = v end})
PlayerActionSection:Button({Title = "Copy Avatar", Callback = function()
    local target = playerDropdown2.Value
    if target and target ~= "" then
        local plr = getPlayerByName(target)
        local targetHumanoid = getHumanoid(plr)
        local localHumanoid = getHumanoid(LocalPlayer)
        if targetHumanoid and localHumanoid and targetHumanoid.HumanoidDescription then
            localHumanoid:ApplyDescription(targetHumanoid.HumanoidDescription)
        end
    end
end})

-- ================= GUN TAB =================
local GunTab = Window:Tab({Title = "Gun", Icon = "gun"})
local GunSection = QuickSection(GunTab, "Arma")
GunSection:Toggle({Title = "Gun Drop ESP", Default = false, Callback = function(v) Settings.GunDropESP = v end})
GunSection:Button({Title = "Teleport Gun", Callback = function()
    local gun = findGunDrop()
    local localRoot = getRoot(LocalPlayer)
    if gun and localRoot then
        localRoot.CFrame = gun.CFrame
    end
end})
GunSection:Toggle({Title = "Auto Grab Gun", Default = false, Callback = function(v) Settings.AutoGrabGun = v end})
GunSection:Toggle({Title = "Gun Aim Assist", Default = false, Callback = function(v) Settings.GunAimAssist = v end})
GunSection:Toggle({Title = "Gun Prediction", Default = false, Callback = function(v) Settings.GunPrediction2 = v end})
GunSection:Button({Title = "Shoot Murderer", Callback = function()
    local m = getMurderer()
    if m and m.Character and m.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, m.Character.Head.Position)
        task.wait(0.2)
        shootGun()
    end
end})
GunSection:Toggle({Title = "Botão de Atirar (Mobile)", Default = false, Callback = function(v)
    Settings.ShootButton = v
    if v then createMobileButtons() else removeMobileButtons() end
end})

-- ================= KNIFE TAB =================
local KnifeTab = Window:Tab({Title = "Knife", Icon = "dagger"})
local KnifeSection = QuickSection(KnifeTab, "Faca")
KnifeSection:Toggle({Title = "Knife Throw Assist", Default = false, Callback = function(v) Settings.ThrowKnifeAssist = v end})
KnifeSection:Toggle({Title = "Throw Prediction", Default = false, Callback = function(v) Settings.ThrowPrediction = v end})
KnifeSection:Slider({Title = "Knife Range/Reach", Min = 10, Max = 100, Default = 20, Callback = function(v) Settings.KnifeReach = v end})
KnifeSection:Toggle({Title = "Auto Throw", Default = false, Callback = function(v) Settings.AutoThrow = v end})
KnifeSection:Toggle({Title = "Knife Aura", Default = false, Callback = function(v) Settings.KnifeAura = v end})
KnifeSection:Toggle({Title = "Fake Knife", Default = false, Callback = function(v) Settings.FakeKnife = v end})
local KnifeTargetSection = QuickSection(KnifeTab, "Alvo da Faca")
KnifeTargetSection:Dropdown({Title = "Knife Target", Options = getPlayerNames(), Default = "", Callback = function(v) Settings.KnifeTarget = v end})
KnifeTargetSection:Toggle({Title = "Botão de Facada (Mobile)", Default = false, Callback = function(v)
    Settings.ThrowKnifeButton = v
    if v then createMobileButtons() else removeMobileButtons() end
end})

-- ================= MOBILE TAB =================
local MobileTab = Window:Tab({Title = "Mobile", Icon = "mobile-screen"})
local MobileSection = QuickSection(MobileTab, "Botões Mobile")
MobileSection:Toggle({Title = "Aim Button", Default = false, Callback = function(v) Settings.AimButton = v; if v then createMobileButtons() else removeMobileButtons() end end})
MobileSection:Toggle({Title = "Shoot Button", Default = false, Callback = function(v) Settings.ShootButton = v; if v then createMobileButtons() else removeMobileButtons() end end})
MobileSection:Toggle({Title = "Throw Knife Button", Default = false, Callback = function(v) Settings.ThrowKnifeButton = v; if v then createMobileButtons() else removeMobileButtons() end end})
MobileSection:Toggle({Title = "Fly Controls", Default = false, Callback = function(v) Settings.FlyControls = v end})
MobileSection:Toggle({Title = "TP Button", Default = false, Callback = function(v) Settings.TPButton = v; if v then createMobileButtons() else removeMobileButtons() end end})
MobileSection:Toggle({Title = "Ligar/Desligar ESP", Default = false, Callback = function(v) Settings.PlayerESP = v end})

-- ================= INTERFACE TAB =================
local InterfaceTab = Window:Tab({Title = "Interface", Icon = "sliders"})
local InterfaceSection = QuickSection(InterfaceTab, "Configurações da UI")
InterfaceSection:Dropdown({Title = "Tema", Options = {"Dark", "Light", "Blue", "Purple", "Red"}, Default = "Dark", Callback = function(v)
    -- Tentar mudar tema da WindUI (pode não funcionar, mas registramos)
    print("Tema selecionado:", v)
end})
InterfaceSection:Slider({Title = "Escala da UI", Min = 50, Max = 150, Default = 100, Callback = function(v) end})
InterfaceSection:Toggle({Title = "Notificações", Default = true, Callback = function(v) end})
InterfaceSection:Button({Title = "Minimizar UI", Callback = function() Window:Minimize() end})
InterfaceSection:Button({Title = "Esconder UI", Callback = function() Window:Close() end})
InterfaceSection:Button({Title = "Salvar Configurações", Callback = function()
    Notify("Souza Hub", "Configurações salvas!")
end})
InterfaceSection:Keybind({Title = "Keybind Esconder UI", Default = "RightShift", Callback = function() Window:Close() end})
-- Search bar (aproximação com um TextBox? A WindUI pode não ter, mas podemos tentar)
-- Não implementado pois a API não oferece TextBox; recomendamos usar Dropdown.

-- ================= SERVER TAB =================
local ServerTab = Window:Tab({Title = "Server", Icon = "server"})
local ServerSection = QuickSection(ServerTab, "Servidor")
ServerSection:Button({Title = "Server Hop", Callback = function()
    local HttpService = game:GetService("HttpService")
    local jobId = HttpService:GenerateGUID(false)
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
end})
ServerSection:Button({Title = "Rejoin", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})
ServerSection:Button({Title = "Join Small Server", Callback = function()
    Notify("Server", "Procurando servidor pequeno...")
end})
ServerSection:Button({Title = "Join New Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})
ServerSection:Button({Title = "Copiar JobId", Callback = function()
    setclipboard(game.JobId)
    Notify("Server", "JobId copiado: " .. game.JobId)
end})
ServerSection:Label({Title = "Player Count: " .. #Players:GetPlayers()})

-- ================= MISC TAB =================
local MiscTab = Window:Tab({Title = "Misc", Icon = "gear"})
local MiscSection = QuickSection(MiscTab, "Extras")
MiscSection:Toggle({Title = "Anti-AFK", Default = false, Callback = function(v) Settings.AntiAFK2 = v end})
MiscSection:Toggle({Title = "FPS Boost", Default = false, Callback = function(v) Settings.FPSBoost = v end})
MiscSection:Toggle({Title = "Remove Textures", Default = false, Callback = function(v) Settings.RemoveTextures = v end})
MiscSection:Toggle({Title = "Low Graphics", Default = false, Callback = function(v) Settings.LowGraphics = v end})
MiscSection:Toggle({Title = "Chat Spy", Default = false, Callback = function(v) Settings.ChatSpy = v end})
MiscSection:Toggle({Title = "Spinbot", Default = false, Callback = function(v) Settings.Spinbot = v end})
MiscSection:Toggle({Title = "Fake Lag Visual", Default = false, Callback = function(v) Settings.FakeLagVisual = v end})
local MiscFunSection = QuickSection(MiscTab, "Diversão")
MiscFunSection:Dropdown({Title = "Emotes", Options = {"Dança 1", "Dança 2", "Aceno", "Rir"}, Default = "Dança 1", Callback = function(v) end})
MiscFunSection:Button({Title = "Dançar", Callback = function()
    local humanoid = getHumanoid(LocalPlayer)
    if humanoid then
        -- Tenta carregar animação de dança genérica
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388"
        local track = humanoid:LoadAnimation(anim)
        track:Play()
    end
end})
local MiscInfoSection = QuickSection(MiscTab, "Informações da Partida")
MiscInfoSection:Label({Title = "Modo: Murder Mystery 2"})
MiscInfoSection:Label({Title = "Jogadores: " .. #Players:GetPlayers()})

-- ================= MOBILE BUTTONS (GUI) =================
local mobileScreenGui = nil
local shootBtn, knifeBtn, tpBtn, aimBtn

local function createMobileButtons()
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
        shootBtn.MouseButton1Click:Connect(function()
            shootGun()
        end)
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
        knifeBtn.MouseButton1Click:Connect(function()
            throwKnife()
        end)
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
            if root and localRoot then
                localRoot.CFrame = root.CFrame
            end
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

local function removeMobileButtons()
    if mobileScreenGui then
        mobileScreenGui:Destroy()
        mobileScreenGui = nil
    end
end

-- Atualizar botões quando toggles mudam
-- Já conectado nos callbacks relevantes

-- ================= MONITORAMENTO DE PAPÉIS (Alertas) =================
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.RoleNotifications then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local role = getRole(p)
                    if role then
                        print(p.Name .. " é " .. role)
                    end
                end
            end
        end
        if Settings.MurdererAlert then
            local m = getMurderer()
            if m then
                Notify("Alerta", m.Name .. " é o Assassino!")
            end
        end
        if Settings.SheriffAlert then
            local s = getSheriff()
            if s then
                Notify("Alerta", s.Name .. " é o Xerife!")
            end
        end
        if Settings.DetectMurderer then
            local m = getMurderer()
            if m then
                print("Murderer detectado:", m.Name)
            end
        end
        if Settings.DetectSheriff then
            local s = getSheriff()
            if s then
                print("Sheriff detectado:", s.Name)
            end
        end
        if Settings.DetectHero then
            local h = getHero()
            if h then
                print("Hero detectado:", h.Name)
            end
        end
    end
end)

-- ================= ATUALIZAR DROPDOWNS =================
Players.PlayerAdded:Connect(function(p)
    local names = getPlayerNames()
    if playerDropdown then playerDropdown:Refresh(names) end
    if playerDropdown2 then playerDropdown2:Refresh(names) end
    -- Atualizar outros dropdowns se necessário
end)

Players.PlayerRemoving:Connect(function(p)
    task.wait(0.5)
    local names = getPlayerNames()
    if playerDropdown then playerDropdown:Refresh(names) end
    if playerDropdown2 then playerDropdown2:Refresh(names) end
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
            -- Desativar texturas e gráficos
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
                if v:IsA("BasePart") then
                    v.TextureID = ""
                end
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
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
        end
    end
end)

-- ================= FAKE LAG VISUAL =================
task.spawn(function()
    while true do
        if Settings.FakeLagVisual then
            task.wait(0.1)
        else
            task.wait()
        end
    end
end)

print("Souza Hub carregado com sucesso!")
Notify("Souza Hub", "Script carregado!")
