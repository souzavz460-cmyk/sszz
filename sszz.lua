-- ============================================================
-- UNIVERSAL SILENT AIM + CAMERA AIM + ADONIS NEUTRALIZER
-- Silent aim intacto + técnicas hook-free adicionadas
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
if not syn or not protectgui then getgenv().protectgui = function() end end

-- ============================================================
-- FASE 0 — EXECUTOR CHECK
-- ============================================================
local REQUIRED = {"hookmetamethod", "newcclosure", "checkcaller", "Drawing", "writefile", "listfiles"}
for _, fn in ipairs(REQUIRED) do
    if not getgenv()[fn] and not (fn == "Drawing" and Drawing) then
        return warn("[USA] Executor incompatível: falta " .. fn)
    end
end

-- ============================================================
-- FASE 1 — ADONIS NEUTRALIZER (RODA ANTES DE TUDO)
-- Isso precisa vir primeiro pra tentar matar o detector
-- antes dos hooks serem instalados.
-- ============================================================
local function killAdonis()
    local killed = 0
    local roots = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("ServerScriptService"),
    }
    local plrScripts = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts")
    local plrGui     = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if plrScripts then table.insert(roots, plrScripts) end
    if plrGui then table.insert(roots, plrGui) end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then table.insert(roots, core) end

    local namesToKill = {
        "Adonis", "Adonis_Loader", "Adonis_Client", "Adonis_Server",
        "AntiCheat", "Anti_Exploit", "AC_Client", "Detector",
        "Adonis_Detector", "indexInstance"
    }

    for _, root in ipairs(roots) do
        if not root then continue end
        for _, name in ipairs(namesToKill) do
            local target = root:FindFirstChild(name)
            if target then
                pcall(function() target:Destroy() end)
                killed = killed + 1
            end
        end
        -- varre descendentes buscando por palavra-chave
        for _, desc in ipairs(root:GetDescendants()) do
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                local n = desc.Name:lower()
                if n:find("adonis") or n:find("anticheat") or n:find("detector")
                or n:find("indexinstance") or n:find("namecallinstance") then
                    pcall(function()
                        if desc:IsA("LocalScript") then
                            desc.Disabled = true
                        else
                            desc:Destroy()
                        end
                    end)
                    killed = killed + 1
                end
            end
        end
    end
    return killed
end

-- Roda IMEDIATAMENTE e depois a cada 3s (Adonis pode recarregar módulos)
local adonisKilledTotal = killAdonis()
task.spawn(function()
    while task.wait(3) do
        adonisKilledTotal = adonisKilledTotal + killAdonis()
    end
end)
warn("[USA] Adonis neutralizado inicialmente: " .. adonisKilledTotal)

-- ============================================================
-- FASE 2 — SETTINGS ORIGINAIS DO SILENT AIM (INTACTOS)
-- ============================================================
local SilentAimSettings = {
    Enabled = false,
    ClassName = "Universal Silent Aim - Averiias, Stefanuk12, xaxa",
    ToggleKey = "RightAlt",
    TeamCheck = false,
    VisibleCheck = false,
    TargetPart = "HumanoidRootPart",
    SilentAimMethod = "Raycast",
    FOVRadius = 130,
    FOVVisible = false,
    ShowSilentAimTarget = false,
    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.165,
    HitChance = 100,
    FOVColor = Color3.fromRGB(54, 57, 241),
    MouseVisualizeColor = Color3.fromRGB(54, 57, 241),

    -- NOVAS configs (técnicas adicionais)
    CamAimEnabled = false,
    CamAimKey = "RightAlt",
    CamAimSmoothing = 0.25,
    CamAimFOV = 130,
    CamAimPart = "Head",
    CamAimTeamCheck = false,
    CamAimVisible = false,
    CamAimPrediction = false,
    CamAimPredAmount = 0.165,
}

-- FIX do bug original (getgenv().SilentAimSettings = Settings → Settings indefinido)
getgenv().SilentAimSettings = SilentAimSettings

local MainFileName = "UniversalSilentAim"
local SelectedFile, FileToSave = "", ""

-- variables (originais)
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local resume = coroutine.resume
local create = coroutine.create

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0.165
local rng = Random.new() -- otimização: não recriar a cada tiro

-- draws (originais, com ajustes discretos)
local mouse_box = Drawing.new("Square")
mouse_box.Visible = false
mouse_box.ZIndex = 999
mouse_box.Color = SilentAimSettings.MouseVisualizeColor
mouse_box.Thickness = 1       -- ⚠️ era 20, chamava atenção
mouse_box.Size = Vector2.new(20, 20)
mouse_box.Filled = false      -- ⚠️ era true

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 130
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = SilentAimSettings.FOVColor

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean", "boolean"} },
    FindPartOnRayWithWhitelist = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean"} },
    FindPartOnRay = { ArgCountRequired = 2, Args = {"Instance", "Ray", "Instance", "boolean", "boolean"} },
    Raycast = { ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"} }
}

-- função original (com fix do Random.new)
function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    return rng:NextNumber(0, 1) <= Percentage / 100
end

-- file handling (original)
do
    if not isfolder(MainFileName) then makefolder(MainFileName) end
    if not isfolder(string.format("%s/%s", MainFileName, tostring(game.PlaceId))) then
        makefolder(string.format("%s/%s", MainFileName, tostring(game.PlaceId)))
    end
end

local function GetFiles()
    local out = {}
    local ok, files = pcall(listfiles, MainFileName .. "/" .. tostring(game.PlaceId))
    if not ok or not files then return out end
    for i = 1, #files do
        local file = files[i]
        if file:sub(-4) == '.lua' then
            local pos = file:find('.lua', 1, true)
            local start = pos
            local char = file:sub(pos, pos)
            while char ~= '/' and char ~= '\\' and char ~= '' do
                pos = pos - 1
                char = file:sub(pos, pos)
            end
            if char == '/' or char == '\\' then
                table.insert(out, file:sub(pos + 1, start - 1))
            end
        end
    end
    return out
end

local function UpdateFile(FileName)
    pcall(writefile, MainFileName .. "/" .. tostring(game.PlaceId) .. "/" .. FileName .. ".lua",
        HttpService:JSONEncode(SilentAimSettings))
end

local function LoadFile(FileName)
    local ok, data = pcall(readfile, MainFileName .. "/" .. tostring(game.PlaceId) .. "/" .. FileName .. ".lua")
    if not ok then return end
    local ok2, ConfigData = pcall(HttpService.JSONDecode, HttpService, data)
    if not ok2 or type(ConfigData) ~= "table" then return end
    for k, v in next, ConfigData do SilentAimSettings[k] = v end
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then return false end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then Matches = Matches + 1 end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end
    local PlayerRoot = FindFirstChild(PlayerCharacter, SilentAimSettings.TargetPart)
                       or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end
    local CastPoints = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}
    local IgnoreList = {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    return ObscuringObjects == 0
end

-- cache de alvo (otimização — não recalcula 3x por frame)
local cachedTarget, cachedFrame = nil, 0
local function getClosestPlayer()
    if not SilentAimSettings.TargetPart then return end
    if cachedFrame == os.clock() then return cachedTarget end
    cachedFrame = os.clock()

    local Closest, DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character
        if not Character then continue end
        if SilentAimSettings.VisibleCheck and not IsPlayerVisible(Player) then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or SilentAimSettings.FOVRadius or 2000) then
            Closest = ((SilentAimSettings.TargetPart == "Random"
                and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]])
                or Character[SilentAimSettings.TargetPart])
            DistanceToMouse = Distance
        end
    end
    cachedTarget = Closest
    return Closest
end

-- ============================================================
-- FASE 3 — CAMERA AIM (nova técnica, hook-free)
-- ============================================================
local function getCamTargetPart(character)
    if not character then return nil end
    if SilentAimSettings.CamAimPart == "Random" then
        return character[ValidTargetParts[rng:NextInteger(1, #ValidTargetParts)]]
    end
    return FindFirstChild(character, SilentAimSettings.CamAimPart)
        or FindFirstChild(character, "Head")
        or FindFirstChild(character, "HumanoidRootPart")
end

local function getCamClosestToCenter()
    local center = getMousePosition()
    local best, bestDist = nil, SilentAimSettings.CamAimFOV

    for _, player in ipairs(GetPlayers(Players)) do
        if player == LocalPlayer then continue end
        if SilentAimSettings.CamAimTeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end
        local hum = FindFirstChild(char, "Humanoid")
        if hum and hum.Health <= 0 then continue end

        local part = getCamTargetPart(char)
        if not part then continue end

        if SilentAimSettings.CamAimVisible and not IsPlayerVisible(player) then continue end

        local screen, onScreen = WorldToScreen(Camera, part.Position)
        if not onScreen then continue end

        local dist = (center - Vector2.new(screen.X, screen.Y)).Magnitude
        if dist < bestDist then
            best, bestDist = part, dist
        end
    end
    return best
end

local function applyCameraAim()
    if not SilentAimSettings.CamAimEnabled then return end
    local keyEnum = Enum.KeyCode[SilentAimSettings.CamAimKey]
    if not keyEnum or not UserInputService:IsKeyDown(keyEnum) then return end

    local part = getCamClosestToCenter()
    if not part then return end

    local targetPos = part.Position
    if SilentAimSettings.CamAimPrediction then
        targetPos = targetPos + part.AssemblyLinearVelocity * SilentAimSettings.CamAimPredAmount
    end

    local camPos = Camera.CFrame.Position
    local desired = CFrame.new(camPos, targetPos)
    local smooth = math.clamp(SilentAimSettings.CamAimSmoothing, 0, 0.99)
    Camera.CFrame = Camera.CFrame:Lerp(desired, 1 - smooth)
end

-- ============================================================
-- FASE 4 — REMOTE SCANNER (nova técnica)
-- ============================================================
local function scanRemotes()
    local list = {}
    local root = game:GetService("ReplicatedStorage")
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")
        or desc:IsA("UnreliableRemoteEvent") then
            table.insert(list, desc:GetFullName())
        end
    end
    return list
end

-- ============================================================
-- FASE 5 — UI RAYFIELD
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Universal Silent Aim",
    LoadingTitle = "Universal Silent Aim",
    LoadingSubtitle = "by Averiias, Stefanuk12, xaxa",
    ShowText = "USA",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local GeneralTab = Window:CreateTab("General", nil)
local VisualsTab = Window:CreateTab("Visuals", nil)
local CameraTab  = Window:CreateTab("Camera Aim", nil)
local ExtrasTab  = Window:CreateTab("Extras", nil)
local ConfigTab  = Window:CreateTab("Config", nil)

-- ===== GENERAL (silent aim original) =====
GeneralTab:CreateSection("Aim")

local ToggleEnabled
ToggleEnabled = GeneralTab:CreateToggle({
    Name = "Enabled",
    CurrentValue = false,
    Flag = "aim_Enabled",
    Callback = function(Value)
        SilentAimSettings.Enabled = Value
        if not Value then mouse_box.Visible = false end
    end
})

GeneralTab:CreateKeybind({
    Name = "Toggle Key",
    CurrentKeybind = "RightAlt",
    HoldToInteract = false,
    Flag = "aim_ToggleKey",
    Callback = function()
        local newState = not SilentAimSettings.Enabled
        SilentAimSettings.Enabled = newState
        if ToggleEnabled and ToggleEnabled.Set then ToggleEnabled:Set(newState) end
        mouse_box.Visible = newState and SilentAimSettings.ShowSilentAimTarget
    end
})

GeneralTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Flag = "aim_TeamCheck",
    Callback = function(v) SilentAimSettings.TeamCheck = v end })

GeneralTab:CreateToggle({ Name = "Visible Check", CurrentValue = false, Flag = "aim_VisibleCheck",
    Callback = function(v) SilentAimSettings.VisibleCheck = v end })

GeneralTab:CreateSection("Target")

GeneralTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Random"},
    CurrentOption = SilentAimSettings.TargetPart,
    Flag = "aim_TargetPart",
    Callback = function(o) SilentAimSettings.TargetPart = o end
})

GeneralTab:CreateDropdown({
    Name = "Silent Aim Method",
    Options = {"Raycast", "FindPartOnRay", "FindPartOnRayWithWhitelist",
               "FindPartOnRayWithIgnoreList", "Mouse.Hit/Target"},
    CurrentOption = SilentAimSettings.SilentAimMethod,
    Flag = "aim_Method",
    Callback = function(o) SilentAimSettings.SilentAimMethod = o end
})

GeneralTab:CreateSlider({
    Name = "Hit Chance", Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = 100, Flag = "aim_HitChance",
    Callback = function(v) SilentAimSettings.HitChance = v end
})

-- ===== VISUALS =====
VisualsTab:CreateSection("FOV Circle")

VisualsTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Flag = "fov_Visible",
    Callback = function(v)
        SilentAimSettings.FOVVisible = v
        fov_circle.Visible = v
    end })

VisualsTab:CreateColorPicker({ Name = "FOV Color", Color = SilentAimSettings.FOVColor, Flag = "fov_Color",
    Callback = function(v) SilentAimSettings.FOVColor = v; fov_circle.Color = v end })

VisualsTab:CreateSlider({ Name = "FOV Circle Radius", Range = {0, 360}, Increment = 1, Suffix = "px",
    CurrentValue = 130, Flag = "fov_Radius",
    Callback = function(v)
        SilentAimSettings.FOVRadius = v
        fov_circle.Radius = v
        SilentAimSettings.CamAimFOV = v
    end })

VisualsTab:CreateSection("Target Visualizer")

VisualsTab:CreateToggle({ Name = "Show Silent Aim Target", CurrentValue = false, Flag = "aim_ShowTarget",
    Callback = function(v)
        SilentAimSettings.ShowSilentAimTarget = v
        if not v then mouse_box.Visible = false end
    end })

VisualsTab:CreateColorPicker({ Name = "Target Color", Color = SilentAimSettings.MouseVisualizeColor, Flag = "aim_TargetColor",
    Callback = function(v) SilentAimSettings.MouseVisualizeColor = v; mouse_box.Color = v end })

VisualsTab:CreateSection("Prediction")

VisualsTab:CreateToggle({ Name = "Mouse.Hit Prediction", CurrentValue = false, Flag = "aim_Prediction",
    Callback = function(v) SilentAimSettings.MouseHitPrediction = v end })

VisualsTab:CreateSlider({ Name = "Prediction Amount", Range = {0.165, 1}, Increment = 0.001, Suffix = "s",
    CurrentValue = 0.165, Flag = "aim_PredictionAmount",
    Callback = function(v)
        PredictionAmount = v
        SilentAimSettings.MouseHitPredictionAmount = v
    end })

-- ===== CAMERA AIM (técnica nova) =====
CameraTab:CreateSection("Camera Aim (Hook-Free)")

CameraTab:CreateToggle({
    Name = "Enable Camera Aim",
    CurrentValue = false,
    Flag = "cam_Enabled",
    Callback = function(v) SilentAimSettings.CamAimEnabled = v end
})

CameraTab:CreateKeybind({
    Name = "Activation Key (hold)",
    CurrentKeybind = "RightAlt",
    HoldToInteract = true,
    Flag = "cam_Key",
    Callback = function(k) SilentAimSettings.CamAimKey = k end
})

CameraTab:CreateSlider({
    Name = "Smoothing", Range = {0, 99}, Increment = 1, Suffix = "%",
    CurrentValue = 25, Flag = "cam_Smooth",
    Callback = function(v) SilentAimSettings.CamAimSmoothing = v / 100 end
})

CameraTab:CreateSlider({
    Name = "FOV (px)", Range = {10, 500}, Increment = 5, Suffix = "px",
    CurrentValue = 130, Flag = "cam_FOV",
    Callback = function(v)
        SilentAimSettings.CamAimFOV = v
        SilentAimSettings.FOVRadius = v
        fov_circle.Radius = v
    end
})

CameraTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "Random"},
    CurrentOption = "Head",
    Flag = "cam_Part",
    Callback = function(o) SilentAimSettings.CamAimPart = o end
})

CameraTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Flag = "cam_Team",
    Callback = function(v) SilentAimSettings.CamAimTeamCheck = v end })

CameraTab:CreateToggle({ Name = "Visible Check", CurrentValue = false, Flag = "cam_Vis",
    Callback = function(v) SilentAimSettings.CamAimVisible = v end })

CameraTab:CreateToggle({ Name = "Prediction", CurrentValue = false, Flag = "cam_Pred",
    Callback = function(v) SilentAimSettings.CamAimPrediction = v end })

CameraTab:CreateSlider({
    Name = "Prediction Amount", Range = {165, 1000}, Increment = 1,
    Suffix = "/1000", CurrentValue = 165, Flag = "cam_PredAmt",
    Callback = function(v) SilentAimSettings.CamAimPredAmount = v / 1000 end
})

-- ===== EXTRAS =====
ExtrasTab:CreateSection("Adonis Neutralizer")

ExtrasTab:CreateLabel("Roda automaticamente a cada 3s. Não precisa ativar.")

ExtrasTab:CreateButton({
    Name = "Force Re-scan Adonis",
    Callback = function()
        local n = killAdonis()
        adonisKilledTotal = adonisKilledTotal + n
        Rayfield:Notify({
            Title = "Adonis",
            Content = n .. " objeto(s) neutralizado(s) | total: " .. adonisKilledTotal,
            Duration = 5,
            Image = 4483362458
        })
    end
})

ExtrasTab:CreateSection("Remote Scanner")

ExtrasTab:CreateButton({
    Name = "Listar Remotes no Console (F9)",
    Callback = function()
        local list = scanRemotes()
        print("=== REMOTES (" .. #list .. ") ===")
        for i, v in ipairs(list) do print(i .. ". " .. v) end
        Rayfield:Notify({
            Title = "Remotes",
            Content = #list .. " encontrados (ver console F9)",
            Duration = 5,
            Image = 4483362458
        })
    end
})

ExtrasTab:CreateSection("Info")

ExtrasTab:CreateParagraph({
    Title = "Status de detecção",
    Content = "Silent aim usa hooks de metatabela → pode ser pego pelo indexInstance do Adonis se ele já carregou antes. Camera Aim NÃO usa hooks. Use Camera Aim se quiser 0% de erro 267."
})

-- ===== CONFIG =====
ConfigTab:CreateSection("Create Configuration")

ConfigTab:CreateInput({ Name = "File Name", CurrentValue = "", PlaceholderText = "nome...",
    RemoveTextAfterFocusLost = false, Flag = "cfg_FileName",
    Callback = function(t) if t and #t > 0 then FileToSave = t end end })

ConfigTab:CreateButton({ Name = "Create Config File",
    Callback = function()
        if FileToSave ~= "" then
            UpdateFile(FileToSave)
            Rayfield:Notify({ Title = "Config", Content = "Criado: " .. FileToSave, Duration = 4, Image = 4483362458 })
        end
    end })

ConfigTab:CreateSection("Load / Save")

ConfigTab:CreateDropdown({ Name = "Config File", Options = GetFiles(), CurrentOption = nil, Flag = "cfg_Selected",
    Callback = function(o) SelectedFile = o end })

ConfigTab:CreateButton({ Name = "Save Configuration",
    Callback = function()
        if SelectedFile ~= "" then
            UpdateFile(SelectedFile)
            Rayfield:Notify({ Title = "Config", Content = "Salvo: " .. SelectedFile, Duration = 4, Image = 4483362458 })
        end
    end })

ConfigTab:CreateButton({ Name = "Load Configuration",
    Callback = function()
        if SelectedFile ~= "" and table.find(GetFiles(), SelectedFile) then
            LoadFile(SelectedFile)
            fov_circle.Color = SilentAimSettings.FOVColor or fov_circle.Color
            fov_circle.Radius = SilentAimSettings.FOVRadius or fov_circle.Radius
            fov_circle.Visible = SilentAimSettings.FOVVisible or false
            mouse_box.Color = SilentAimSettings.MouseVisualizeColor or mouse_box.Color
            PredictionAmount = SilentAimSettings.MouseHitPredictionAmount or 0.165
            Rayfield:Notify({ Title = "Config", Content = "Carregado: " .. SelectedFile, Duration = 4, Image = 4483362458 })
        end
    end })

-- ============================================================
-- FASE 6 — RENDER LOOP (silent aim visuals + camera aim)
-- ============================================================
resume(create(function()
    RenderStepped:Connect(function()
        -- Camera aim (técnica nova, roda sempre que ativa + tecla)
        applyCameraAim()

        -- Visual do silent aim (original)
        if SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled then
            local Target = getClosestPlayer()
            if Target then
                local Root = Target.Parent.PrimaryPart or Target
                local RootToViewportPoint, IsOnScreen = WorldToViewportPoint(Camera, Root.Position)
                mouse_box.Visible = IsOnScreen
                mouse_box.Position = Vector2.new(RootToViewportPoint.X, RootToViewportPoint.Y)
            else
                mouse_box.Visible = false
                mouse_box.Position = Vector2.new()
            end
        else
            mouse_box.Visible = false
        end

        -- FOV circle (original)
        if SilentAimSettings.FOVVisible then
            fov_circle.Visible = true
            fov_circle.Color = SilentAimSettings.FOVColor
            fov_circle.Position = getMousePosition()
        else
            fov_circle.Visible = false
        end
    end)
end))

-- ============================================================
-- FASE 7 — HOOKS DO SILENT AIM (ORIGINAIS, INTACTOS)
-- ============================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    local chance = CalculateChance(SilentAimSettings.HitChance)
    if SilentAimSettings.Enabled and self == workspace and not checkcaller() and chance == true then
        if Method == "FindPartOnRayWithIgnoreList" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                local A_Ray = Arguments[2]
                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)
                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif Method == "FindPartOnRayWithWhitelist" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                local A_Ray = Arguments[2]
                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)
                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and SilentAimSettings.SilentAimMethod:lower() == Method:lower() then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                local A_Ray = Arguments[2]
                local HitPart = getClosestPlayer()
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)
                    return oldNamecall(unpack(Arguments))
                end
            end
        elseif Method == "Raycast" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                local A_Origin = Arguments[2]
                local HitPart = getClosestPlayer()
                if HitPart then
                    Arguments[3] = getDirection(A_Origin, HitPart.Position)
                    return oldNamecall(unpack(Arguments))
                end
            end
        end
    end
    return oldNamecall(...)
end))

local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and SilentAimSettings.Enabled and SilentAimSettings.SilentAimMethod == "Mouse.Hit/Target" and getClosestPlayer() then
        local HitPart = getClosestPlayer()
        if Index == "Target" or Index == "target" then
            return HitPart
        elseif Index == "Hit" or Index == "hit" then
            return ((SilentAimSettings.MouseHitPrediction and (HitPart.CFrame + (HitPart.Velocity * PredictionAmount))) or (not SilentAimSettings.MouseHitPrediction and HitPart.CFrame))
        elseif Index == "X" or Index == "x" then
            return self.X
        elseif Index == "Y" or Index == "y" then
            return self.Y
        elseif Index == "UnitRay" then
            return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
        end
    end
    return oldIndex(self, Index)
end))

-- Notificação final
Rayfield:Notify({
    Title = "Carregado",
    Content = "Silent Aim + Camera Aim + Adonis Killer ativos",
    Duration = 6,
    Image = 4483362458
})
