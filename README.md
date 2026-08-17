--//========================================================
--// VEHICLE GRABBER
--// SOMENTE LOCAL SCRIPT
--//
--// PC:
--// Y = PEGAR / TACAR
--//
--// MOBILE:
--// GRAB / THROW
--//========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--//========================================================
--// CONFIG
--//========================================================

local GrabDistance = 40
local ThrowPower = 170
local ThrowUpPower = 35

local HeldVehicle = nil
local HoldConnection = nil
local ThrowConnection = nil

local SavedParts = {}

--//========================================================
--// CHARACTER
--//========================================================

local function GetCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRoot()
	local Character = GetCharacter()
	return Character:FindFirstChild("HumanoidRootPart")
end

--//========================================================
--// VEHICLE DETECTION
--//========================================================

local function GetVehicleFromSeat(Seat)

	local Model = Seat:FindFirstAncestorOfClass("Model")

	if not Model then
		return nil
	end

	-- sobe alguns níveis caso o carro tenha:
	-- Car > Chassis > VehicleSeat

	local Current = Model

	for _ = 1, 3 do

		local Parent = Current.Parent

		if not Parent or not Parent:IsA("Model") then
			break
		end

		local Success, Size = pcall(function()
			return Parent:GetExtentsSize()
		end)

		if not Success then
			break
		end

		-- evita pegar modelos gigantes do mapa
		if math.max(Size.X, Size.Y, Size.Z) > 80 then
			break
		end

		Current = Parent
	end

	return Current
end

local function GetVehiclePosition(Vehicle)

	local Success, Pivot = pcall(function()
		return Vehicle:GetPivot()
	end)

	if Success then
		return Pivot.Position
	end

	local Part = Vehicle:FindFirstChildWhichIsA("BasePart", true)

	if Part then
		return Part.Position
	end

	return nil
end

local function FindNearestVehicle()

	local Root = GetRoot()

	if not Root then
		return nil
	end

	local BestVehicle = nil
	local BestDistance = GrabDistance

	local Checked = {}

	for _, Object in ipairs(workspace:GetDescendants()) do

		if Object:IsA("VehicleSeat") then

			local Vehicle = GetVehicleFromSeat(Object)

			if Vehicle
				and not Checked[Vehicle]
				and not Vehicle:IsDescendantOf(GetCharacter())
			then

				Checked[Vehicle] = true

				local Position = GetVehiclePosition(Vehicle)

				if Position then

					local Distance =
						(Root.Position - Position).Magnitude

					if Distance < BestDistance then

						BestDistance = Distance
						BestVehicle = Vehicle

					end
				end
			end
		end
	end

	return BestVehicle
end

--//========================================================
--// VEHICLE PARTS
--//========================================================

local function SaveVehicle(Vehicle)

	SavedParts = {}

	for _, Object in ipairs(Vehicle:GetDescendants()) do

		if Object:IsA("BasePart") then

			SavedParts[Object] = {
				Anchored = Object.Anchored,
				CanCollide = Object.CanCollide,
				Massless = Object.Massless
			}

			Object.Anchored = true
			Object.CanCollide = false
			Object.Massless = true

			Object.AssemblyLinearVelocity = Vector3.zero
			Object.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function RestoreVehicle()

	for Part, Data in pairs(SavedParts) do

		if Part and Part.Parent then

			Part.Anchored = Data.Anchored
			Part.CanCollide = Data.CanCollide
			Part.Massless = Data.Massless

		end
	end

	SavedParts = {}
end

--//========================================================
--// GUI
--//========================================================

local OldGui = PlayerGui:FindFirstChild("VehicleGrabberV2")

if OldGui then
	OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "VehicleGrabberV2"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--// COLORS

local BG = Color3.fromRGB(14, 14, 19)
local PANEL = Color3.fromRGB(20, 20, 27)
local ITEM = Color3.fromRGB(29, 29, 39)
local ITEM2 = Color3.fromRGB(35, 35, 47)

local ACCENT = Color3.fromRGB(124, 82, 255)
local ACCENT2 = Color3.fromRGB(165, 92, 255)

local WHITE = Color3.fromRGB(245, 245, 250)
local GRAY = Color3.fromRGB(155, 155, 170)
local GREEN = Color3.fromRGB(85, 220, 130)
local RED = Color3.fromRGB(255, 90, 105)

local function AddCorner(Object, Radius)

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Radius or 10)
	Corner.Parent = Object

	return Corner
end

local function AddStroke(Object, Color, Transparency)

	local Stroke = Instance.new("UIStroke")

	Stroke.Color = Color or Color3.fromRGB(70, 70, 90)
	Stroke.Transparency = Transparency or 0.5
	Stroke.Thickness = 1

	Stroke.Parent = Object

	return Stroke
end

--//========================================================
--// MAIN WINDOW
--//========================================================

local Main = Instance.new("Frame")

Main.Name = "Main"
Main.Size = UDim2.fromOffset(470, 340)
Main.Position = UDim2.new(0.5, -235, 0.5, -170)

Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0

Main.ClipsDescendants = true

Main.Parent = Gui

AddCorner(Main, 14)
AddStroke(Main, Color3.fromRGB(75, 65, 110), 0.25)

local MainGradient = Instance.new("UIGradient")

MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(
		0,
		Color3.fromRGB(23, 19, 35)
	),

	ColorSequenceKeypoint.new(
		1,
		Color3.fromRGB(13, 13, 18)
	)
})

MainGradient.Rotation = 35
MainGradient.Parent = Main

--//========================================================
--// TOP BAR
--//========================================================

local Top = Instance.new("Frame")

Top.Size = UDim2.new(1, 0, 0, 64)

Top.BackgroundColor3 =
	Color3.fromRGB(23, 22, 31)

Top.BorderSizePixel = 0
Top.Parent = Main

local AccentLine = Instance.new("Frame")

AccentLine.Size = UDim2.new(0, 4, 0, 34)
AccentLine.Position = UDim2.fromOffset(16, 15)

AccentLine.BackgroundColor3 = ACCENT
AccentLine.BorderSizePixel = 0

AccentLine.Parent = Top

AddCorner(AccentLine, 4)

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, -130, 0, 27)
Title.Position = UDim2.fromOffset(32, 10)

Title.BackgroundTransparency = 1

Title.Text = "Vehicle Grabber"
Title.TextColor3 = WHITE
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent = Top

local Subtitle = Instance.new("TextLabel")

Subtitle.Size = UDim2.new(1, -130, 0, 20)
Subtitle.Position = UDim2.fromOffset(32, 36)

Subtitle.BackgroundTransparency = 1

Subtitle.Text = "Grab • Carry • Throw"
Subtitle.TextColor3 = GRAY
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.GothamMedium

Subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

Subtitle.Parent = Top

--// MINIMIZE

local Minimize = Instance.new("TextButton")

Minimize.Size = UDim2.fromOffset(40, 40)
Minimize.Position = UDim2.new(1, -52, 0, 12)

Minimize.BackgroundColor3 = ITEM
Minimize.BorderSizePixel = 0

Minimize.Text = "—"
Minimize.TextColor3 = WHITE
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold

Minimize.AutoButtonColor = false

Minimize.Parent = Top

AddCorner(Minimize, 10)

--//========================================================
--// CONTENT
--//========================================================

local Content = Instance.new("Frame")

Content.Size = UDim2.new(1, -28, 1, -80)
Content.Position = UDim2.fromOffset(14, 72)

Content.BackgroundTransparency = 1

Content.Parent = Main

--//========================================================
--// STATUS CARD
--//========================================================

local StatusCard = Instance.new("Frame")

StatusCard.Size = UDim2.new(1, 0, 0, 62)

StatusCard.BackgroundColor3 = PANEL
StatusCard.BorderSizePixel = 0

StatusCard.Parent = Content

AddCorner(StatusCard, 11)
AddStroke(StatusCard, Color3.fromRGB(65,65,85), 0.55)

local StatusTitle = Instance.new("TextLabel")

StatusTitle.Size = UDim2.new(1, -120, 0, 25)
StatusTitle.Position = UDim2.fromOffset(15, 9)

StatusTitle.BackgroundTransparency = 1

StatusTitle.Text = "Vehicle Throw"
StatusTitle.TextColor3 = WHITE
StatusTitle.TextSize = 14
StatusTitle.Font = Enum.Font.GothamSemibold

StatusTitle.TextXAlignment =
	Enum.TextXAlignment.Left

StatusTitle.Parent = StatusCard

local StatusDescription = Instance.new("TextLabel")

StatusDescription.Size = UDim2.new(1, -120, 0, 20)
StatusDescription.Position = UDim2.fromOffset(15, 32)

StatusDescription.BackgroundTransparency = 1

StatusDescription.Text =
	"Press Y or use the controls"

StatusDescription.TextColor3 = GRAY
StatusDescription.TextSize = 11
StatusDescription.Font = Enum.Font.Gotham

StatusDescription.TextXAlignment =
	Enum.TextXAlignment.Left

StatusDescription.Parent = StatusCard

local StatusBadge = Instance.new("TextLabel")

StatusBadge.Size = UDim2.fromOffset(88, 30)

StatusBadge.Position =
	UDim2.new(
		1,
		-103,
		0.5,
		-15
	)

StatusBadge.BackgroundColor3 =
	Color3.fromRGB(33, 55, 43)

StatusBadge.BorderSizePixel = 0

StatusBadge.Text = "READY"

StatusBadge.TextColor3 = GREEN

StatusBadge.TextSize = 11
StatusBadge.Font = Enum.Font.GothamBold

StatusBadge.Parent = StatusCard

AddCorner(StatusBadge, 8)

--//========================================================
--// MAIN ACTION
--//========================================================

local Action = Instance.new("TextButton")

Action.Size = UDim2.new(1, 0, 0, 52)
Action.Position = UDim2.fromOffset(0, 74)

Action.BackgroundColor3 = ACCENT
Action.BorderSizePixel = 0

Action.Text = "GRAB VEHICLE   [ Y ]"

Action.TextColor3 = WHITE
Action.TextSize = 14
Action.Font = Enum.Font.GothamBold

Action.AutoButtonColor = false

Action.Parent = Content

AddCorner(Action, 11)

local ActionGradient = Instance.new("UIGradient")

ActionGradient.Color = ColorSequence.new(
	ACCENT,
	ACCENT2
)

ActionGradient.Rotation = 15

ActionGradient.Parent = Action

--//========================================================
--// MOBILE TOGGLE CARD
--//========================================================

local MobileCard = Instance.new("Frame")

MobileCard.Size = UDim2.new(1, 0, 0, 52)
MobileCard.Position = UDim2.fromOffset(0, 138)

MobileCard.BackgroundColor3 = PANEL
MobileCard.BorderSizePixel = 0

MobileCard.Parent = Content

AddCorner(MobileCard, 10)

local MobileText = Instance.new("TextLabel")

MobileText.Size = UDim2.new(1, -100, 1, 0)
MobileText.Position = UDim2.fromOffset(15, 0)

MobileText.BackgroundTransparency = 1

MobileText.Text = "Mobile Controls"

MobileText.TextColor3 = WHITE
MobileText.TextSize = 13
MobileText.Font = Enum.Font.GothamMedium

MobileText.TextXAlignment =
	Enum.TextXAlignment.Left

MobileText.Parent = MobileCard

local Toggle = Instance.new("TextButton")

Toggle.Size = UDim2.fromOffset(48, 26)

Toggle.Position =
	UDim2.new(
		1,
		-63,
		0.5,
		-13
	)

Toggle.BackgroundColor3 = ITEM2
Toggle.BorderSizePixel = 0

Toggle.Text = ""

Toggle.AutoButtonColor = false

Toggle.Parent = MobileCard

AddCorner(Toggle, 20)

local ToggleDot = Instance.new("Frame")

ToggleDot.Size = UDim2.fromOffset(20,20)
ToggleDot.Position = UDim2.fromOffset(3,3)

ToggleDot.BackgroundColor3 = WHITE
ToggleDot.BorderSizePixel = 0

ToggleDot.Parent = Toggle

AddCorner(ToggleDot, 20)

--//========================================================
--// THROW POWER
--//========================================================

local PowerCard = Instance.new("Frame")

PowerCard.Size = UDim2.new(1, 0, 0, 70)
PowerCard.Position = UDim2.fromOffset(0, 202)

PowerCard.BackgroundColor3 = PANEL
PowerCard.BorderSizePixel = 0

PowerCard.Parent = Content

AddCorner(PowerCard, 10)

local PowerTitle = Instance.new("TextLabel")

PowerTitle.Size = UDim2.new(1, -100, 0, 30)
PowerTitle.Position = UDim2.fromOffset(15, 4)

PowerTitle.BackgroundTransparency = 1

PowerTitle.Text = "Throw Power"

PowerTitle.TextColor3 = WHITE
PowerTitle.TextSize = 13
PowerTitle.Font = Enum.Font.GothamMedium

PowerTitle.TextXAlignment =
	Enum.TextXAlignment.Left

PowerTitle.Parent = PowerCard

local PowerValue = Instance.new("TextLabel")

PowerValue.Size = UDim2.fromOffset(65, 30)

PowerValue.Position =
	UDim2.new(
		1,
		-80,
		0,
		4
	)

PowerValue.BackgroundTransparency = 1

PowerValue.Text = tostring(ThrowPower)

PowerValue.TextColor3 = ACCENT2

PowerValue.TextSize = 13
PowerValue.Font = Enum.Font.GothamBold

PowerValue.TextXAlignment =
	Enum.TextXAlignment.Right

PowerValue.Parent = PowerCard

local Slider = Instance.new("Frame")

Slider.Size = UDim2.new(1, -30, 0, 6)
Slider.Position = UDim2.fromOffset(15, 47)

Slider.BackgroundColor3 = ITEM2
Slider.BorderSizePixel = 0

Slider.Parent = PowerCard

AddCorner(Slider, 10)

local SliderFill = Instance.new("Frame")

SliderFill.Size =
	UDim2.new(
		(ThrowPower - 50) / 300,
		0,
		1,
		0
	)

SliderFill.BackgroundColor3 = ACCENT
SliderFill.BorderSizePixel = 0

SliderFill.Parent = Slider

AddCorner(SliderFill, 10)

local SliderDot = Instance.new("Frame")

SliderDot.Size = UDim2.fromOffset(16,16)

SliderDot.AnchorPoint =
	Vector2.new(0.5,0.5)

SliderDot.Position =
	UDim2.new(
		1,
		0,
		0.5,
		0
	)

SliderDot.BackgroundColor3 = WHITE
SliderDot.BorderSizePixel = 0

SliderDot.Parent = SliderFill

AddCorner(SliderDot, 20)

--//========================================================
--// MOBILE BUTTONS
--//========================================================

local MobileControls = Instance.new("Frame")

MobileControls.Size = UDim2.fromOffset(260, 72)

MobileControls.Position =
	UDim2.new(
		1,
		-280,
		1,
		-110
	)

MobileControls.BackgroundTransparency = 1

MobileControls.Parent = Gui

local GrabMobile = Instance.new("TextButton")

GrabMobile.Size = UDim2.fromOffset(120,58)
GrabMobile.Position = UDim2.fromOffset(0,0)

GrabMobile.BackgroundColor3 =
	Color3.fromRGB(24,24,32)

GrabMobile.BorderSizePixel = 0

GrabMobile.Text = "GRAB"
GrabMobile.TextColor3 = WHITE

GrabMobile.TextSize = 14
GrabMobile.Font = Enum.Font.GothamBold

GrabMobile.AutoButtonColor = false

GrabMobile.Parent = MobileControls

AddCorner(GrabMobile, 14)
AddStroke(GrabMobile, ACCENT, 0.25)

local ThrowMobile = Instance.new("TextButton")

ThrowMobile.Size = UDim2.fromOffset(120,58)
ThrowMobile.Position = UDim2.fromOffset(140,0)

ThrowMobile.BackgroundColor3 = ACCENT
ThrowMobile.BorderSizePixel = 0

ThrowMobile.Text = "THROW"
ThrowMobile.TextColor3 = WHITE

ThrowMobile.TextSize = 14
ThrowMobile.Font = Enum.Font.GothamBold

ThrowMobile.AutoButtonColor = false

ThrowMobile.Parent = MobileControls

AddCorner(ThrowMobile, 14)

--//========================================================
--// TOAST
--//========================================================

local Toast = Instance.new("TextLabel")

Toast.Size = UDim2.fromOffset(330, 42)

Toast.Position =
	UDim2.new(
		0.5,
		-165,
		0,
		-60
	)

Toast.BackgroundColor3 =
	Color3.fromRGB(23,23,30)

Toast.BorderSizePixel = 0

Toast.TextColor3 = WHITE
Toast.TextSize = 12
Toast.Font = Enum.Font.GothamMedium

Toast.Visible = true

Toast.Parent = Gui

AddCorner(Toast, 10)
AddStroke(Toast, Color3.fromRGB(80,70,110),0.35)

local ToastBusy = false

local function Notify(Text)

	Toast.Text = Text

	TweenService:Create(
		Toast,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		{
			Position =
				UDim2.new(
					0.5,
					-165,
					0,
					20
				)
		}
	):Play()

	task.delay(2.2, function()

		TweenService:Create(
			Toast,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.In
			),
			{
				Position =
					UDim2.new(
						0.5,
						-165,
						0,
						-60
					)
			}
		):Play()

	end)
end

--//========================================================
--// STATUS
--//========================================================

local function UpdateStatus()

	if HeldVehicle then

		StatusBadge.Text = "HOLDING"

		StatusBadge.TextColor3 =
			Color3.fromRGB(220,190,255)

		StatusBadge.BackgroundColor3 =
			Color3.fromRGB(54,39,75)

		Action.Text = "THROW VEHICLE   [ Y ]"

	else

		StatusBadge.Text = "READY"
		StatusBadge.TextColor3 = GREEN

		StatusBadge.BackgroundColor3 =
			Color3.fromRGB(33,55,43)

		Action.Text = "GRAB VEHICLE   [ Y ]"

	end
end

--//========================================================
--// GRAB
--//========================================================

local function GrabVehicle()

	if HeldVehicle then
		return
	end

	if ThrowConnection then

		ThrowConnection:Disconnect()
		ThrowConnection = nil

		RestoreVehicle()
	end

	local Vehicle = FindNearestVehicle()

	if not Vehicle then

		Notify("No vehicle found nearby.")

		StatusBadge.Text = "NO VEHICLE"
		StatusBadge.TextColor3 = RED

		StatusBadge.BackgroundColor3 =
			Color3.fromRGB(65,32,38)

		task.delay(1.5, UpdateStatus)

		return
	end

	SaveVehicle(Vehicle)

	HeldVehicle = Vehicle

	if HoldConnection then
		HoldConnection:Disconnect()
	end

	HoldConnection =
		RunService.RenderStepped:Connect(function()

			if not HeldVehicle
				or not HeldVehicle.Parent
			then
				return
			end

			local Root = GetRoot()

			if not Root then
				return
			end

			-- posição do carro "na mão"
			-- fica na frente/direita do personagem

			local Target =
				Root.CFrame
				* CFrame.new(
					3.8,
					3.2,
					-3.5
				)
				* CFrame.Angles(
					0,
					math.rad(90),
					math.rad(-8)
				)

			pcall(function()

				HeldVehicle:PivotTo(Target)

			end)
		end)

	UpdateStatus()

	Notify("Vehicle grabbed!")
end

--//========================================================
--// THROW
--//========================================================

local function ThrowVehicle()

	if not HeldVehicle then

		Notify("Grab a vehicle first.")
		return

	end

	local Vehicle = HeldVehicle

	HeldVehicle = nil

	if HoldConnection then

		HoldConnection:Disconnect()
		HoldConnection = nil

	end

	UpdateStatus()

	Camera = workspace.CurrentCamera

	local Velocity =
		Camera.CFrame.LookVector * ThrowPower
		+
		Vector3.new(
			0,
			ThrowUpPower,
			0
		)

	local Spin =
		Vector3.new(
			math.rad(140),
			math.rad(210),
			math.rad(100)
		)

	local Time = 0
	local MaxTime = 2

	local Params = RaycastParams.new()

	Params.FilterType =
		Enum.RaycastFilterType.Exclude

	Params.FilterDescendantsInstances = {
		Vehicle,
		GetCharacter()
	}

	if ThrowConnection then
		ThrowConnection:Disconnect()
	end

	ThrowConnection =
		RunService.Heartbeat:Connect(function(Delta)

			if not Vehicle
				or not Vehicle.Parent
			then

				ThrowConnection:Disconnect()
				ThrowConnection = nil

				RestoreVehicle()

				return
			end

			Time += Delta

			local Current = Vehicle:GetPivot()

			Velocity +=
				Vector3.new(
					0,
					-workspace.Gravity * Delta,
					0
				)

			local Movement =
				Velocity * Delta

			local Result =
				workspace:Raycast(
					Current.Position,
					Movement,
					Params
				)

			local Rotation =
				Current.Rotation
				*
				CFrame.Angles(
					Spin.X * Delta,
					Spin.Y * Delta,
					Spin.Z * Delta
				)

			if Result then

				pcall(function()

					Vehicle:PivotTo(
						CFrame.new(
							Result.Position
							+
							Result.Normal * 2
						)
						*
						Rotation
					)

				end)

				ThrowConnection:Disconnect()
				ThrowConnection = nil

				RestoreVehicle()

				return
			end

			pcall(function()

				Vehicle:PivotTo(
					CFrame.new(
						Current.Position
						+
						Movement
					)
					*
					Rotation
				)

			end)

			if Time >= MaxTime then

				ThrowConnection:Disconnect()
				ThrowConnection = nil

				RestoreVehicle()
			end
		end)

	Notify("Vehicle thrown!")
end

local function MainAction()

	if HeldVehicle then
		ThrowVehicle()
	else
		GrabVehicle()
	end
end

--//========================================================
--// BUTTONS
--//========================================================

Action.MouseButton1Click:Connect(MainAction)

GrabMobile.MouseButton1Click:Connect(
	GrabVehicle
)

ThrowMobile.MouseButton1Click:Connect(
	ThrowVehicle
)

--//========================================================
--// KEY Y
--//========================================================

UserInputService.InputBegan:Connect(
	function(Input, Processed)

		if Processed then
			return
		end

		if Input.KeyCode ==
			Enum.KeyCode.Y
		then

			MainAction()

		end
	end
)

--//========================================================
--// MOBILE TOGGLE
--//========================================================

local MobileEnabled =
	UserInputService.TouchEnabled

local function UpdateMobile()

	MobileControls.Visible =
		MobileEnabled

	if MobileEnabled then

		Toggle.BackgroundColor3 =
			ACCENT

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
			ITEM2

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

	MobileEnabled = not MobileEnabled

	UpdateMobile()

end)

UpdateMobile()

--//========================================================
--// POWER SLIDER
--//========================================================

local SliderDragging = false

local function SetSlider(PositionX)

	local Percent =
		math.clamp(
			(
				PositionX
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
			Percent * 300
		)

	PowerValue.Text =
		tostring(ThrowPower)

	SliderFill.Size =
		UDim2.new(
			Percent,
			0,
			1,
			0
		)
end

Slider.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
			Enum.UserInputType.Touch
	then

		SliderDragging = true

		SetSlider(Input.Position.X)

	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if not SliderDragging then
		return
	end

	if Input.UserInputType ==
			Enum.UserInputType.MouseMovement
		or
		Input.UserInputType ==
			Enum.UserInputType.Touch
	then

		SetSlider(Input.Position.X)

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

--//========================================================
--// WINDOW DRAG
--//========================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)

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

--//========================================================
--// MINIMIZE
--//========================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

	Minimized = not Minimized

	if Minimized then

		Content.Visible = false

		TweenService:Create(
			Main,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint
			),
			{
				Size =
					UDim2.fromOffset(
						470,
						64
					)
			}
		):Play()

	else

		TweenService:Create(
			Main,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint
			),
			{
				Size =
					UDim2.fromOffset(
						470,
						340
					)
			}
		):Play()

		task.delay(0.15, function()
			Content.Visible = true
		end)
	end
end)

--//========================================================
--// HOVER
--//========================================================

Action.MouseEnter:Connect(function()

	TweenService:Create(
		Action,
		TweenInfo.new(0.12),
		{
			BackgroundColor3 =
				Color3.fromRGB(
					145,
					92,
					255
				)
		}
	):Play()

end)

Action.MouseLeave:Connect(function()

	TweenService:Create(
		Action,
		TweenInfo.new(0.12),
		{
			BackgroundColor3 =
				ACCENT
		}
	):Play()

end)

--//========================================================
--// RESPAWN
--//========================================================

Player.CharacterAdded:Connect(function()

	if HoldConnection then
		HoldConnection:Disconnect()
		HoldConnection = nil
	end

	if ThrowConnection then
		ThrowConnection:Disconnect()
		ThrowConnection = nil
	end

	RestoreVehicle()

	HeldVehicle = nil

	task.wait(1)

	UpdateStatus()

end)

UpdateStatus()
