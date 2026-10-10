-- ============================================================
-- UNIVERSAL SILENT AIM + RAYFIELD + ADONIS NEUTRALIZER
-- Versão única, sem duplicação, sem lag, sem loop infinito
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
if not syn or not protectgui then getgenv().protectgui = function() end end

-- ============================================================
-- FASE 0: EXECUTOR CHECK
-- ============================================================
local REQUIRED = {"hookmetamethod", "newcclosure", "checkcaller", "hookfunction", "getgc", "Drawing", "writefile"}
for _, fn in ipairs(REQUIRED) do
    if not getgenv()[fn] and not (fn == "Drawing" and Drawing) then
        return warn("[USA] Executor incompatível: falta " .. fn)
    end
end

-- ============================================================
-- FASE 1: ADONIS NEUTRALIZER (VERSÃO LEVE - RODA 2X SÓ)
-- ============================================================
local hookedFuncs = {}
local function safeHook(fn)
    if hookedFuncs[fn] then return false end
    hookedFuncs[fn] = true
    pcall(hookfunction, fn, function() return false end)
    return true
end

local function neutralizeAdonis()
    local killed = 0

    -- A) getgc: mata Detected/indexInstance/namecallInstance
    local ok, gc = pcall(getgc, true)
    if ok and gc then
        for _, v in next, gc do
            if type(v) == "table" then
                local d = rawget(v, "Detected")
                if type(d) == "function" and safeHook(d) then killed = killed + 1 end

                local ii = rawget(v, "indexInstance")
                if type(ii) == "table" and #ii >= 2 and type(ii[2]) == "function" and safeHook(ii[2]) then
                    killed = killed + 1
                end

                local ni = rawget(v, "namecallInstance")
                if type(ni) == "table" and #ni >= 2 and type(ni[2]) == "function" and safeHook(ni[2]) then
                    killed = killed + 1
                end
            end
        end
    end

    -- B) Desabilita scripts de anti-cheat
    local roots = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts"),
        game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
    }
    for _, root in ipairs(roots) do
        if not root then continue end
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script") then
                local n = d.Name:lower()
                if n:find("adonis") or n:find("anticheat") or n:find("detector")
                or n:find("indexinstance") or n:find("namecallinstance") then
                    pcall(function()
                        if d:IsA("LocalScript") then d.Disabled = true else d:Destroy() end
                    end)
                    killed = killed + 1
                end
            end
        end
    end

    return killed
end

-- Roda 1x agora + 1x depois de 5s. SEM LOOP.
local totalKilled = neutralizeAdonis()
task.delay(5, function()
    totalKilled = totalKilled + neutralizeAdonis()
    warn("[USA] Re-scan total: " .. totalKilled)
end)
warn("[USA] Adonis neutralizado: " .. totalKilled)

-- ============================================================
-- FASE 2: SETTINGS DO SILENT AIM
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
}
getgenv().SilentAimSettings = SilentAimSettings

local MainFileName = "UniversalSilentAim"
local SelectedFile, FileToSave = "", ""

-- Serviços
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInput      = game:GetService("UserInputService")
local HttpService    = game:GetService("HttpService")
local LocalPlayer    = Players.LocalPlayer

-- Camera dinâmica (evita erro ao respawnar)
local Camera = workspace.CurrentCamera
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    Camera = workspace.CurrentCamera
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
end)

local Mouse = LocalPlayer:GetMouse()

local GetPlayers       = Players.GetPlayers
local WorldToScreen    = function(cam, pos) return cam:WorldToScreenPoint(pos) end
local WorldToViewport  = function(cam, pos) return cam:WorldToViewportPoint(pos) end
local FindFirstChild   = game.FindFirstChild
local RenderStepped    = RunService.RenderStepped
local GetMouseLocation = UserInput.GetMouseLocation

local resume = coroutine.resume
local create = coroutine.create

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0.165
local rng = Random.new()

-- Drawings
local mouse_box = Drawing.new("Square")
mouse_box.Visible = false
mouse_box.ZIndex = 999
mouse_box.Color = SilentAimSettings.MouseVisualizeColor
mouse_box.Thickness = 1
mouse_box.Size = Vector2.new(20, 20)
mouse_box.Filled = false

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
    FindPartOnRay              = { ArgCountRequired = 2, Args = {"Instance", "Ray", "Instance", "boolean", "boolean"} },
    Raycast                    = { ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"} }
}

function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    return rng:NextNumber(0, 1) <= Percentage / 100
end

-- File handling
do
    if not isfolder(MainFileName) then makefolder(MainFileName) end
    if not isfolder(MainFileName .. "/" .. tostring(game.PlaceId)) then
        makefolder(MainFileName .. "/" .. tostring(game.PlaceId))
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
    return GetMouseLocation(UserInput)
end

local function IsPlayerVisible(Player)
    local PC, LPC = Player.Character, LocalPlayer.Character
    if not (PC and LPC) then return false end
    local Root = FindFirstChild(PC, SilentAimSettings.TargetPart)
                 or FindFirstChild(PC, "HumanoidRootPart")
    if not Root then return false end
    local ok, objs = pcall(function()
        return Camera:GetPartsObscuringTarget({Root.Position, LPC, PC}, {LPC, PC})
    end)
    return ok and #objs == 0
end

-- Cache de alvo
local cachedTarget, cachedFrame = nil, 0
local function getClosestPlayer()
    if not SilentAimSettings.TargetPart then return nil end
    local now = os.clock()
    if cachedFrame == now then return cachedTarget end
    cachedFrame = now

    local Closest, DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        local Character = Player.Character
        if not Character then continue end
        if SilentAimSettings.VisibleCheck and not IsPlayerVisible(Player) then continue end

        local HRP = FindFirstChild(Character, "HumanoidRootPart")
        local Hum = FindFirstChild(Character, "Humanoid")
        if not HRP or not Hum or Hum.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HRP.Position)
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
-- FASE 3: RAYFIELD UI
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
local ConfigTab  = Window:CreateTab("Config", nil)

-- ===== GENERAL =====
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
-- FASE 4: RENDER LOOP (só roda visual quando ativo)
-- ============================================================
resume(create(function()
    RenderStepped:Connect(function()
        -- Só processa target visualizer se estiver ativo
        if SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled then
            local Target = getClosestPlayer()
            if Target then
                local Root = Target.Parent and Target.Parent.PrimaryPart or Target
                local ScreenPos, OnScreen = WorldToViewport(Camera, Root.Position)
                mouse_box.Visible = OnScreen
                mouse_box.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
            else
                mouse_box.Visible = false
            end
        elseif mouse_box.Visible then
            mouse_box.Visible = false
        end

        -- Só atualiza FOV se estiver ativo
        if SilentAimSettings.FOVVisible then
            fov_circle.Visible = true
            fov_circle.Color = SilentAimSettings.FOVColor
            fov_circle.Position = getMousePosition()
        elseif fov_circle.Visible then
            fov_circle.Visible = false
        end
    end)
end))

-- ============================================================
-- FASE 5: HOOKS DO SILENT AIM
-- ============================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]

    if SilentAimSettings.Enabled and self == workspace and not checkcaller() then
        if not CalculateChance(SilentAimSettings.HitChance) then
            return oldNamecall(...)
        end

        if Method == "FindPartOnRayWithIgnoreList" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                local HitPart = getClosestPlayer()
                if HitPart then
                    local A_Ray = Arguments[2]
                    Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                    return oldNamecall(unpack(Arguments))
                end
            end

        elseif Method == "FindPartOnRayWithWhitelist" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                local HitPart = getClosestPlayer()
                if HitPart then
                    local A_Ray = Arguments[2]
                    Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                    return oldNamecall(unpack(Arguments))
                end
            end

        elseif (Method == "FindPartOnRay" or Method == "findPartOnRay")
            and SilentAimSettings.SilentAimMethod:lower() == Method:lower() then
            if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                local HitPart = getClosestPlayer()
                if HitPart then
                    local A_Ray = Arguments[2]
                    Arguments[2] = Ray.new(A_Ray.Origin, getDirection(A_Ray.Origin, HitPart.Position))
                    return oldNamecall(unpack(Arguments))
                end
            end

        elseif Method == "Raycast" and SilentAimSettings.SilentAimMethod == Method then
            if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                local HitPart = getClosestPlayer()
                if HitPart then
                    Arguments[3] = getDirection(Arguments[2], HitPart.Position)
                    return oldNamecall(unpack(Arguments))
                end
            end
        end
    end
    return oldNamecall(...)
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if self == Mouse and not checkcaller() and SilentAimSettings.Enabled
       and SilentAimSettings.SilentAimMethod == "Mouse.Hit/Target" then
        local HitPart = getClosestPlayer()
        if HitPart then
            if Index == "Target" or Index == "target" then
                return HitPart
            elseif Index == "Hit" or Index == "hit" then
                return SilentAimSettings.MouseHitPrediction
                    and (HitPart.CFrame + (HitPart.Velocity * PredictionAmount))
                    or HitPart.CFrame
            elseif Index == "X" or Index == "x" then
                return self.X
            elseif Index == "Y" or Index == "y" then
                return self.Y
            elseif Index == "UnitRay" then
                return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
            end
        end
    end
    return oldIndex(self, Index)
end))

-- ============================================================
-- NOTIFICAÇÃO FINAL
-- ============================================================
Rayfield:Notify({
    Title = "Carregado",
    Content = "Adonis neutralizado: " .. totalKilled .. " | Silent Aim pronto",
    Duration = 6,
    Image = 4483362458
})
