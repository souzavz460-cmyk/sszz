--// Vehicle Grab & Throw - LocalScript
--// Coloque em: StarterPlayer > StarterPlayerScripts
--// Requer: ReplicatedStorage > Rayfield (ModuleScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// CONFIG
local GRAB_DISTANCE = 22
local THROW_POWER = 150
local THROW_UP_POWER = 35

--// RAYFIELD
local Rayfield = require(ReplicatedStorage:WaitForChild("Rayfield"))

local Window = Rayfield:CreateWindow({
	Name = "Vehicle Throw",
	LoadingTitle = "Vehicle System",
	LoadingSubtitle = "Rayfield",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

local VehicleTab = Window:CreateTab("Vehicle", 4483362458)

VehicleTab:CreateSection("Vehicle Throw")

--// VARIABLES
local HeldVehicle = nil
local HoldWeld = nil
local SavedParts = {}

local MobileGui
local GrabButton
local ThrowButton

--// CHARACTER
local function getCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function getRoot()
	local Character = getCharacter()
	return Character:FindFirstChild("HumanoidRootPart")
end

local function getHand()
	local Character = getCharacter()

	return Character:FindFirstChild("RightHand")
		or Character:FindFirstChild("Right Arm")
		or Character:FindFirstChild("HumanoidRootPart")
end

--// NOTIFICATION
local function notify(title, content)
	pcall(function()
		Rayfield:Notify({
			Title = title,
			Content = content,
			Duration = 3
		})
	end)
end

--// VEHICLE ROOT
local function getVehicleRoot(Model)
	if not Model then
		return nil
	end

	if Model.PrimaryPart then
		return Model.PrimaryPart
	end

	local Seat = Model:FindFirstChildWhichIsA("VehicleSeat", true)

	if Seat then
		return Seat
	end

	return Model:FindFirstChildWhichIsA("BasePart", true)
end

--// CHECK IF MODEL IS VEHICLE
local function isVehicle(Model)
	if not Model:IsA("Model") then
		return false
	end

	if CollectionService:HasTag(Model, "ThrowableVehicle") then
		return true
	end

	if Model:FindFirstChildWhichIsA("VehicleSeat", true) then
		return true
	end

	return false
end

--// FIND NEAREST VEHICLE
local function findNearestVehicle()
	local Root = getRoot()

	if not Root then
		return nil
	end

	local Nearest = nil
	local NearestDistance = GRAB_DISTANCE

	for _, Object in ipairs(workspace:GetDescendants()) do
		if Object:IsA("Model") and isVehicle(Object) then

			-- Não selecionar modelos dentro de outro veículo
			local ParentVehicle = false

			local Parent = Object.Parent

			while Parent and Parent ~= workspace do
				if Parent:IsA("Model") and isVehicle(Parent) then
					ParentVehicle = true
					break
				end

				Parent = Parent.Parent
			end

			if not ParentVehicle then
				local VehicleRoot = getVehicleRoot(Object)

				if VehicleRoot then
					local Distance = (Root.Position - VehicleRoot.Position).Magnitude

					if Distance < NearestDistance then
						NearestDistance = Distance
						Nearest = Object
					end
				end
			end
		end
	end

	return Nearest
end

--// PREPARE VEHICLE
local function prepareVehicle(Vehicle)
	SavedParts = {}

	for _, Object in ipairs(Vehicle:GetDescendants()) do
		if Object:IsA("BasePart") then

			SavedParts[Object] = {
				CanCollide = Object.CanCollide,
				Massless = Object.Massless
			}

			Object.CanCollide = false
			Object.Massless = true
		end
	end
end

--// RESTORE VEHICLE
local function restoreVehicle()
	for Part, Properties in pairs(SavedParts) do
		if Part and Part.Parent then
			Part.CanCollide = Properties.CanCollide
			Part.Massless = Properties.Massless
		end
	end

	SavedParts = {}
end

--// GRAB
local function grabVehicle()
	if HeldVehicle then
		notify("Vehicle Throw", "Você já está segurando um veículo.")
		return
	end

	local Vehicle = findNearestVehicle()

	if not Vehicle then
		notify(
			"Nenhum veículo",
			"Chegue mais perto de um veículo."
		)

		return
	end

	local VehicleRoot = getVehicleRoot(Vehicle)
	local Hand = getHand()

	if not VehicleRoot or not Hand then
		return
	end

	if VehicleRoot.Anchored then
		notify(
			"Vehicle Throw",
			"Esse veículo está Anchored."
		)

		return
	end

	prepareVehicle(Vehicle)

	HeldVehicle = Vehicle

	--// Posiciona o veículo na mão
	local HoldCFrame =
		Hand.CFrame
		* CFrame.new(0, -1.5, -4)
		* CFrame.Angles(0, math.rad(90), 0)

	Vehicle:PivotTo(HoldCFrame)

	--// Prende na mão
	HoldWeld = Instance.new("WeldConstraint")
	HoldWeld.Name = "VehicleHoldWeld"
	HoldWeld.Part0 = Hand
	HoldWeld.Part1 = VehicleRoot
	HoldWeld.Parent = VehicleRoot

	VehicleRoot.AssemblyLinearVelocity = Vector3.zero
	VehicleRoot.AssemblyAngularVelocity = Vector3.zero

	notify(
		"Vehicle Grabbed",
		"Pressione Y novamente para arremessar."
	)
end

--// THROW
local function throwVehicle()
	if not HeldVehicle then
		notify(
			"Vehicle Throw",
			"Você não está segurando nenhum veículo."
		)

		return
	end

	local Vehicle = HeldVehicle
	local VehicleRoot = getVehicleRoot(Vehicle)

	if HoldWeld then
		HoldWeld:Destroy()
		HoldWeld = nil
	end

	restoreVehicle()

	if VehicleRoot then

		local Camera = workspace.CurrentCamera

		local Direction = Camera.CFrame.LookVector

		VehicleRoot.AssemblyLinearVelocity =
			(Direction * THROW_POWER)
			+ Vector3.new(0, THROW_UP_POWER, 0)

		-- rotação durante o arremesso
		VehicleRoot.AssemblyAngularVelocity =
			Vector3.new(
				math.random(-8, 8),
				math.random(-10, 10),
				math.random(-8, 8)
			)
	end

	HeldVehicle = nil

	notify(
		"Vehicle Throw",
		"Veículo arremessado!"
	)
end

--// MAIN ACTION
local function grabOrThrow()
	if HeldVehicle then
		throwVehicle()
	else
		grabVehicle()
	end
end

--==================================================
-- PC CONTROL
--==================================================

UserInputService.InputBegan:Connect(function(Input, Processed)

	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.Y then
		grabOrThrow()
	end

end)

--==================================================
-- MOBILE GUI
--==================================================

MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "VehicleThrowMobile"
MobileGui.ResetOnSpawn = false
MobileGui.IgnoreGuiInset = true
MobileGui.Parent = PlayerGui

--// GRAB BUTTON
GrabButton = Instance.new("TextButton")
GrabButton.Name = "GrabButton"
GrabButton.Size = UDim2.fromOffset(125, 52)
GrabButton.Position = UDim2.new(
	1,
	-285,
	1,
	-120
)

GrabButton.AnchorPoint = Vector2.new(0, 0)
GrabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
GrabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GrabButton.Text = "GRAB"
GrabButton.TextSize = 19
GrabButton.Font = Enum.Font.GothamBold
GrabButton.Parent = MobileGui

local GrabCorner = Instance.new("UICorner")
GrabCorner.CornerRadius = UDim.new(0, 13)
GrabCorner.Parent = GrabButton

local GrabStroke = Instance.new("UIStroke")
GrabStroke.Thickness = 2
GrabStroke.Transparency = 0.25
GrabStroke.Parent = GrabButton

--// THROW BUTTON
ThrowButton = Instance.new("TextButton")
ThrowButton.Name = "ThrowButton"
ThrowButton.Size = UDim2.fromOffset(125, 52)
ThrowButton.Position = UDim2.new(
	1,
	-150,
	1,
	-120
)

ThrowButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ThrowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ThrowButton.Text = "THROW"
ThrowButton.TextSize = 19
ThrowButton.Font = Enum.Font.GothamBold
ThrowButton.Parent = MobileGui

local ThrowCorner = Instance.new("UICorner")
ThrowCorner.CornerRadius = UDim.new(0, 13)
ThrowCorner.Parent = ThrowButton

local ThrowStroke = Instance.new("UIStroke")
ThrowStroke.Thickness = 2
ThrowStroke.Transparency = 0.25
ThrowStroke.Parent = ThrowButton

--// MOBILE ACTIONS
GrabButton.MouseButton1Click:Connect(function()
	grabVehicle()
end)

ThrowButton.MouseButton1Click:Connect(function()
	throwVehicle()
end)

-- padrão
MobileGui.Enabled = UserInputService.TouchEnabled

--==================================================
-- RAYFIELD OPTIONS
--==================================================

VehicleTab:CreateButton({
	Name = "Grab / Throw Vehicle [Y]",

	Callback = function()
		grabOrThrow()
	end
})

VehicleTab:CreateToggle({
	Name = "Show Mobile Buttons",

	CurrentValue = UserInputService.TouchEnabled,

	Flag = "MobileVehicleButtons",

	Callback = function(Value)
		MobileGui.Enabled = Value
	end
})

VehicleTab:CreateSection("Throw Settings")

VehicleTab:CreateSlider({
	Name = "Throw Power",

	Range = {
		50,
		300
	},

	Increment = 10,

	Suffix = " Power",

	CurrentValue = THROW_POWER,

	Flag = "VehicleThrowPower",

	Callback = function(Value)
		THROW_POWER = Value
	end
})

--// RESET IF CHARACTER DIES
Player.CharacterAdded:Connect(function()

	if HoldWeld then
		HoldWeld:Destroy()
	end

	HoldWeld = nil
	HeldVehicle = nil
	SavedParts = {}

end)
