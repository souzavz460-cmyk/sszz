--========================================================
-- VEHICLE THROW UI
-- 100% LOCAL SCRIPT
-- PC: Y = Grab / Throw
-- Mobile: GRAB + THROW
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local GrabDistance = 25
local ThrowPower = 150
local ThrowUpPower = 30

local HeldVehicle = nil
local HoldWeld = nil

local SavedVehicleParts = {}

--========================================================
-- CHARACTER
--========================================================

local function GetCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRoot()
	local Character = GetCharacter()
	return Character:FindFirstChild("HumanoidRootPart")
end

local function GetHand()
	local Character = GetCharacter()

	return Character:FindFirstChild("RightHand")
		or Character:FindFirstChild("Right Arm")
		or Character:FindFirstChild("HumanoidRootPart")
end

--========================================================
-- VEHICLE SYSTEM
--========================================================

local function GetVehicleRoot(Vehicle)

	if not Vehicle then
		return nil
	end

	if Vehicle.PrimaryPart then
		return Vehicle.PrimaryPart
	end

	local VehicleSeat =
		Vehicle:FindFirstChildWhichIsA("VehicleSeat", true)

	if VehicleSeat then
		return VehicleSeat
	end

	return Vehicle:FindFirstChildWhichIsA("BasePart", true)
end

local function IsVehicle(Model)

	if not Model:IsA("Model") then
		return false
	end

	return Model:FindFirstChildWhichIsA(
		"VehicleSeat",
		true
	) ~= nil
end

local function FindNearestVehicle()

	local Root = GetRoot()

	if not Root then
		return nil
	end

	local NearestVehicle = nil
	local NearestDistance = GrabDistance

	for _, Object in ipairs(workspace:GetChildren()) do

		if IsVehicle(Object) then

			local VehicleRoot = GetVehicleRoot(Object)

			if VehicleRoot and not VehicleRoot.Anchored then

				local Distance =
					(Root.Position - VehicleRoot.Position).Magnitude

				if Distance < NearestDistance then

					NearestDistance = Distance
					NearestVehicle = Object

				end
			end
		end
	end

	return NearestVehicle
end

--========================================================
-- PREPARE VEHICLE
--========================================================

local function PrepareVehicle(Vehicle)

	SavedVehicleParts = {}

	for _, Object in ipairs(Vehicle:GetDescendants()) do

		if Object:IsA("BasePart") then

			SavedVehicleParts[Object] = {
				CanCollide = Object.CanCollide,
				Massless = Object.Massless
			}

			Object.CanCollide = false
			Object.Massless = true
		end
	end
end

local function RestoreVehicle()

	for Part, Data in pairs(SavedVehicleParts) do

		if Part and Part.Parent then

			Part.CanCollide = Data.CanCollide
			Part.Massless = Data.Massless

		end
	end

	SavedVehicleParts = {}
end

--========================================================
-- GRAB
--========================================================

local function GrabVehicle()

	if HeldVehicle then
		return
	end

	local Vehicle = FindNearestVehicle()

	if not Vehicle then
		warn("Nenhum veículo próximo.")
		return
	end

	local VehicleRoot = GetVehicleRoot(Vehicle)
	local Hand = GetHand()

	if not VehicleRoot or not Hand then
		return
	end

	PrepareVehicle(Vehicle)

	VehicleRoot.AssemblyLinearVelocity = Vector3.zero
	VehicleRoot.AssemblyAngularVelocity = Vector3.zero

	-- posição na frente/do lado da mão
	local HoldPosition =
		Hand.CFrame
		* CFrame.new(0, -1, -5)
		* CFrame.Angles(
			0,
			math.rad(90),
			0
		)

	Vehicle:PivotTo(HoldPosition)

	HoldWeld = Instance.new("WeldConstraint")

	HoldWeld.Name = "VehicleGrabWeld"

	HoldWeld.Part0 = Hand
	HoldWeld.Part1 = VehicleRoot

	HoldWeld.Parent = VehicleRoot

	HeldVehicle = Vehicle
end

--========================================================
-- THROW
--========================================================

local function ThrowVehicle()

	if not HeldVehicle then
		return
	end

	local Vehicle = HeldVehicle
	local VehicleRoot = GetVehicleRoot(Vehicle)

	if HoldWeld then

		HoldWeld:Destroy()
		HoldWeld = nil

	end

	RestoreVehicle()

	if VehicleRoot then

		local Camera = workspace.CurrentCamera

		local Direction = Camera.CFrame.LookVector

		VehicleRoot.AssemblyLinearVelocity =
			Direction * ThrowPower
			+ Vector3.new(
				0,
				ThrowUpPower,
				0
			)

		VehicleRoot.AssemblyAngularVelocity =
			Vector3.new(
				math.random(-6, 6),
				math.random(-8, 8),
				math.random(-6, 6)
			)

	end

	HeldVehicle = nil
end

local function GrabOrThrow()

	if HeldVehicle then
		ThrowVehicle()
	else
		GrabVehicle()
	end
end

--========================================================
-- PC KEY
--========================================================

UserInputService.InputBegan:Connect(function(Input, Processed)

	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.Y then

		GrabOrThrow()

	end
end)

--========================================================
-- MAIN GUI
--========================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "VehicleThrowUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false

Gui.Parent = PlayerGui

--========================================================
-- WINDOW
--========================================================

local Main = Instance.new("Frame")

Main.Size = UDim2.fromOffset(430, 310)

Main.Position =
	UDim2.new(
		0.5,
		-215,
		0.5,
		-155
	)

Main.BackgroundColor3 =
	Color3.fromRGB(18, 18, 24)

Main.BorderSizePixel = 0

Main.Parent = Gui

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0, 12)

MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")

MainStroke.Color =
	Color3.fromRGB(80, 80, 100)

MainStroke.Transparency = 0.5
MainStroke.Thickness = 1

MainStroke.Parent = Main

--========================================================
-- TOP BAR
--========================================================

local TopBar = Instance.new("Frame")

TopBar.Size =
	UDim2.new(
		1,
		0,
		0,
		55
	)

TopBar.BackgroundColor3 =
	Color3.fromRGB(23, 23, 31)

TopBar.BorderSizePixel = 0

TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")

TopCorner.CornerRadius =
	UDim.new(0, 12)

TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(
		1,
		-70,
		1,
		0
	)

Title.Position =
	UDim2.fromOffset(
		20,
		0
	)

Title.BackgroundTransparency = 1

Title.Text = "Vehicle Throw"

Title.TextColor3 =
	Color3.fromRGB(
		240,
		240,
		245
	)

Title.TextSize = 20

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent = TopBar

--========================================================
-- MINIMIZE
--========================================================

local Minimize = Instance.new("TextButton")

Minimize.Size =
	UDim2.fromOffset(
		38,
		38
	)

Minimize.Position =
	UDim2.new(
		1,
		-48,
		0,
		8
	)

Minimize.BackgroundColor3 =
	Color3.fromRGB(
		33,
		33,
		44
	)

Minimize.Text = "—"

Minimize.TextColor3 = Color3.new(1,1,1)

Minimize.TextSize = 20

Minimize.Font =
	Enum.Font.GothamBold

Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")

MinCorner.CornerRadius =
	UDim.new(
		0,
		8
	)

MinCorner.Parent = Minimize

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

	Minimized = not Minimized

	if Minimized then

		TweenService:Create(
			Main,
			TweenInfo.new(0.25),
			{
				Size = UDim2.fromOffset(
					430,
					55
				)
			}
		):Play()

	else

		TweenService:Create(
			Main,
			TweenInfo.new(0.25),
			{
				Size = UDim2.fromOffset(
					430,
					310
				)
			}
		):Play()

	end
end)

--========================================================
-- DRAGGING
--========================================================

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
		Enum.UserInputType.Touch
	then

		Dragging = true

		DragStart = Input.Position
		StartPosition = Main.Position

	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or
		Input.UserInputType ==
		Enum.UserInputType.Touch
	then

		local Delta =
			Input.Position - DragStart

		Main.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,

				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)
	end
end)

UserInputService.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
		Enum.UserInputType.Touch
	then

		Dragging = false
	end
end)

--========================================================
-- CONTENT
--========================================================

local Content = Instance.new("Frame")

Content.Position =
	UDim2.fromOffset(
		15,
		65
	)

Content.Size =
	UDim2.new(
		1,
		-30,
		1,
		-75
	)

Content.BackgroundTransparency = 1

Content.Parent = Main

--========================================================
-- MAIN BUTTON
--========================================================

local ActionButton = Instance.new("TextButton")

ActionButton.Size =
	UDim2.new(
		1,
		0,
		0,
		50
	)

ActionButton.BackgroundColor3 =
	Color3.fromRGB(
		35,
		35,
		47
	)

ActionButton.Text =
	"Grab / Throw Vehicle  [Y]"

ActionButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

ActionButton.TextSize = 15

ActionButton.Font =
	Enum.Font.GothamSemibold

ActionButton.Parent = Content

local ActionCorner =
	Instance.new("UICorner")

ActionCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

ActionCorner.Parent =
	ActionButton

ActionButton.MouseButton1Click:Connect(function()

	GrabOrThrow()

end)

--========================================================
-- MOBILE TOGGLE
--========================================================

local ToggleFrame = Instance.new("Frame")

ToggleFrame.Position =
	UDim2.fromOffset(
		0,
		65
	)

ToggleFrame.Size =
	UDim2.new(
		1,
		0,
		0,
		50
	)

ToggleFrame.BackgroundColor3 =
	Color3.fromRGB(
		28,
		28,
		38
	)

ToggleFrame.Parent = Content

local ToggleCorner =
	Instance.new("UICorner")

ToggleCorner.CornerRadius =
	UDim.new(
		0,
		9
	)

ToggleCorner.Parent =
	ToggleFrame

local ToggleText =
	Instance.new("TextLabel")

ToggleText.Size =
	UDim2.new(
		1,
		-80,
		1,
		0
	)

ToggleText.Position =
	UDim2.fromOffset(
		15,
		0
	)

ToggleText.BackgroundTransparency = 1

ToggleText.Text =
	"Show Mobile Buttons"

ToggleText.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

ToggleText.Font =
	Enum.Font.Gotham

ToggleText.TextSize = 14

ToggleText.TextXAlignment =
	Enum.TextXAlignment.Left

ToggleText.Parent =
	ToggleFrame

local Toggle =
	Instance.new("TextButton")

Toggle.Size =
	UDim2.fromOffset(
		48,
		26
	)

Toggle.Position =
	UDim2.new(
		1,
		-60,
		0.5,
		-13
	)

Toggle.Text = ""

Toggle.Parent =
	ToggleFrame

local ToggleCorner2 =
	Instance.new("UICorner")

ToggleCorner2.CornerRadius =
	UDim.new(
		1,
		0
	)

ToggleCorner2.Parent =
	Toggle

local ToggleDot =
	Instance.new("Frame")

ToggleDot.Size =
	UDim2.fromOffset(
		20,
		20
	)

ToggleDot.Position =
	UDim2.fromOffset(
		3,
		3
	)

ToggleDot.BackgroundColor3 =
	Color3.new(
		1,
		1,
		1
	)

ToggleDot.Parent = Toggle

local DotCorner =
	Instance.new("UICorner")

DotCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

DotCorner.Parent =
	ToggleDot

--========================================================
-- MOBILE BUTTON GUI
--========================================================

local MobileFrame =
	Instance.new("Frame")

MobileFrame.Size =
	UDim2.fromOffset(
		280,
		65
	)

MobileFrame.Position =
	UDim2.new(
		0.5,
		-140,
		1,
		-100
	)

MobileFrame.BackgroundTransparency = 1

MobileFrame.Parent = Gui

local GrabButton =
	Instance.new("TextButton")

GrabButton.Size =
	UDim2.fromOffset(
		130,
		55
	)

GrabButton.BackgroundColor3 =
	Color3.fromRGB(
		25,
		25,
		35
	)

GrabButton.Text = "GRAB"

GrabButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

GrabButton.TextSize = 16

GrabButton.Font =
	Enum.Font.GothamBold

GrabButton.Parent =
	MobileFrame

local GrabCorner =
	Instance.new("UICorner")

GrabCorner.CornerRadius =
	UDim.new(
		0,
		12
	)

GrabCorner.Parent =
	GrabButton

local ThrowButton =
	Instance.new("TextButton")

ThrowButton.Size =
	UDim2.fromOffset(
		130,
		55
	)

ThrowButton.Position =
	UDim2.fromOffset(
		150,
		0
	)

ThrowButton.BackgroundColor3 =
	Color3.fromRGB(
		25,
		25,
		35
	)

ThrowButton.Text = "THROW"

ThrowButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

ThrowButton.TextSize = 16

ThrowButton.Font =
	Enum.Font.GothamBold

ThrowButton.Parent =
	MobileFrame

local ThrowCorner =
	Instance.new("UICorner")

ThrowCorner.CornerRadius =
	UDim.new(
		0,
		12
	)

ThrowCorner.Parent =
	ThrowButton

GrabButton.MouseButton1Click:Connect(
	function()

		GrabVehicle()

	end
)

ThrowButton.MouseButton1Click:Connect(
	function()

		ThrowVehicle()

	end
)

--========================================================
-- TOGGLE LOGIC
--========================================================

local MobileEnabled =
	UserInputService.TouchEnabled

local function UpdateToggle()

	MobileFrame.Visible =
		MobileEnabled

	if MobileEnabled then

		Toggle.BackgroundColor3 =
			Color3.fromRGB(
				80,
				100,
				255
			)

		TweenService:Create(
			ToggleDot,
			TweenInfo.new(0.15),
			{
				Position =
					UDim2.fromOffset(
						25,
						3
					)
			}
		):Play()

	else

		Toggle.BackgroundColor3 =
			Color3.fromRGB(
				55,
				55,
				65
			)

		TweenService:Create(
			ToggleDot,
			TweenInfo.new(0.15),
			{
				Position =
					UDim2.fromOffset(
						3,
						3
					)
			}
		):Play()

	end
end

Toggle.MouseButton1Click:Connect(function()

	MobileEnabled =
		not MobileEnabled

	UpdateToggle()

end)

UpdateToggle()

--========================================================
-- THROW POWER SLIDER
--========================================================

local SliderLabel =
	Instance.new("TextLabel")

SliderLabel.Position =
	UDim2.fromOffset(
		5,
		135
	)

SliderLabel.Size =
	UDim2.new(
		1,
		-10,
		0,
		30
	)

SliderLabel.BackgroundTransparency = 1

SliderLabel.Text =
	"Throw Power: "
	.. ThrowPower

SliderLabel.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

SliderLabel.TextSize = 14

SliderLabel.Font =
	Enum.Font.Gotham

SliderLabel.TextXAlignment =
	Enum.TextXAlignment.Left

SliderLabel.Parent =
	Content

local Slider =
	Instance.new("Frame")

Slider.Position =
	UDim2.fromOffset(
		5,
		175
	)

Slider.Size =
	UDim2.new(
		1,
		-10,
		0,
		8
	)

Slider.BackgroundColor3 =
	Color3.fromRGB(
		50,
		50,
		60
	)

Slider.Parent = Content

local SliderCorner =
	Instance.new("UICorner")

SliderCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

SliderCorner.Parent =
	Slider

local Fill =
	Instance.new("Frame")

Fill.Size =
	UDim2.new(
		0.4,
		0,
		1,
		0
	)

Fill.BackgroundColor3 =
	Color3.fromRGB(
		90,
		110,
		255
	)

Fill.Parent = Slider

local FillCorner =
	Instance.new("UICorner")

FillCorner.CornerRadius =
	UDim.new(
		1,
		0
	)

FillCorner.Parent = Fill

local SliderDragging = false

local function UpdateSlider(Input)

	local Percent =
		math.clamp(
			(
				Input.Position.X
				-
				Slider.AbsolutePosition.X
			)
			/
			Slider.AbsoluteSize.X,

			0,
			1
		)

	ThrowPower =
		math.floor(
			50
			+
			Percent * 250
		)

	Fill.Size =
		UDim2.new(
			Percent,
			0,
			1,
			0
		)

	SliderLabel.Text =
		"Throw Power: "
		.. ThrowPower
end

Slider.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
		Enum.UserInputType.Touch
	then

		SliderDragging = true
		UpdateSlider(Input)

	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if SliderDragging then

		if Input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or
			Input.UserInputType ==
			Enum.UserInputType.Touch
		then

			UpdateSlider(Input)

		end
	end
end)

UserInputService.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
		Enum.UserInputType.Touch
	then

		SliderDragging = false

	end
end)

--========================================================
-- RESPAWN
--========================================================

Player.CharacterAdded:Connect(function()

	if HoldWeld then

		HoldWeld:Destroy()
		HoldWeld = nil

	end

	RestoreVehicle()

	HeldVehicle = nil

end)
