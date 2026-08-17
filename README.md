--============================================================
-- VEHICLE YEET
-- 100% LOCAL SCRIPT
--
-- ENTRE NO CARRO
-- MIRE COM A CAMERA
-- Y = JOGAR
--
-- MOBILE = BOTAO THROW
--============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character
local Humanoid
local HRP

local ThrowSpeed = 170
local UpSpeed = 32

local Throwing = false
local MobileButtons = UIS.TouchEnabled

--============================================================
-- CHARACTER
--============================================================

local function SetupCharacter(char)

	Character = char

	Humanoid = char:WaitForChild("Humanoid")
	HRP = char:WaitForChild("HumanoidRootPart")

end

SetupCharacter(
	Player.Character
	or Player.CharacterAdded:Wait()
)

Player.CharacterAdded:Connect(SetupCharacter)

--============================================================
-- REMOVE GUI ANTIGA
--============================================================

local Old = PlayerGui:FindFirstChild("VehicleYeet")

if Old then
	Old:Destroy()
end

--============================================================
-- GUI
--============================================================

local GUI = Instance.new("ScreenGui")

GUI.Name = "VehicleYeet"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = false
GUI.Parent = PlayerGui

--============================================================
-- COLORS
--============================================================

local BG = Color3.fromRGB(13, 13, 17)
local CARD = Color3.fromRGB(22, 22, 28)
local ELEMENT = Color3.fromRGB(31, 31, 40)

local PURPLE = Color3.fromRGB(128, 78, 255)
local PURPLE2 = Color3.fromRGB(174, 92, 255)

local WHITE = Color3.fromRGB(245, 245, 250)
local GRAY = Color3.fromRGB(145, 145, 160)

local GREEN = Color3.fromRGB(95, 235, 145)
local RED = Color3.fromRGB(255, 95, 110)

local function Corner(object, radius)

	local corner = Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			radius or 10
		)

	corner.Parent = object

	return corner

end

--============================================================
-- MAIN WINDOW
--============================================================

local Main = Instance.new("Frame")

Main.Size = UDim2.fromOffset(330, 205)

Main.Position =
	UDim2.new(
		0.5,
		-165,
		0.5,
		-102
	)

Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0

Main.Parent = GUI

Corner(Main, 14)

local MainStroke = Instance.new("UIStroke")

MainStroke.Color =
	Color3.fromRGB(
		62,
		55,
		82
	)

MainStroke.Transparency = 0.2
MainStroke.Thickness = 1

MainStroke.Parent = Main

--============================================================
-- TOP BAR
--============================================================

local Top = Instance.new("Frame")

Top.Size =
	UDim2.new(
		1,
		0,
		0,
		52
	)

Top.BackgroundColor3 =
	Color3.fromRGB(
		18,
		18,
		24
	)

Top.BorderSizePixel = 0

Top.Parent = Main

Corner(Top, 14)

local Accent = Instance.new("Frame")

Accent.Size =
	UDim2.fromOffset(
		4,
		27
	)

Accent.Position =
	UDim2.fromOffset(
		14,
		12
	)

Accent.BackgroundColor3 = PURPLE
Accent.BorderSizePixel = 0

Accent.Parent = Top

Corner(Accent, 4)

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
		29,
		0
	)

Title.BackgroundTransparency = 1

Title.Text = "Vehicle Throw"

Title.TextColor3 = WHITE

Title.TextSize = 16

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.Parent = Top

--============================================================
-- MINIMIZE
--============================================================

local Minimize = Instance.new("TextButton")

Minimize.Size =
	UDim2.fromOffset(
		32,
		32
	)

Minimize.Position =
	UDim2.new(
		1,
		-42,
		0,
		10
	)

Minimize.BackgroundColor3 = ELEMENT
Minimize.BorderSizePixel = 0

Minimize.Text = "−"
Minimize.TextColor3 = WHITE

Minimize.TextSize = 17
Minimize.Font = Enum.Font.GothamBold

Minimize.AutoButtonColor = false

Minimize.Parent = Top

Corner(Minimize, 8)

--============================================================
-- STATUS
--============================================================

local Status = Instance.new("TextLabel")

Status.Size =
	UDim2.new(
		1,
		-30,
		0,
		25
	)

Status.Position =
	UDim2.fromOffset(
		15,
		63
	)

Status.BackgroundTransparency = 1

Status.Text = "ENTER A VEHICLE"

Status.TextColor3 = GRAY

Status.TextSize = 11
Status.Font = Enum.Font.GothamBold

Status.TextXAlignment =
	Enum.TextXAlignment.Left

Status.Parent = Main

--============================================================
-- THROW BUTTON
--============================================================

local ThrowButton = Instance.new("TextButton")

ThrowButton.Size =
	UDim2.new(
		1,
		-30,
		0,
		46
	)

ThrowButton.Position =
	UDim2.fromOffset(
		15,
		92
	)

ThrowButton.BackgroundColor3 = PURPLE
ThrowButton.BorderSizePixel = 0

ThrowButton.Text = "THROW VEHICLE   [ Y ]"

ThrowButton.TextColor3 = WHITE

ThrowButton.TextSize = 13
ThrowButton.Font = Enum.Font.GothamBold

ThrowButton.AutoButtonColor = false

ThrowButton.Parent = Main

Corner(ThrowButton, 10)

local Gradient = Instance.new("UIGradient")

Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(
		0,
		PURPLE
	),

	ColorSequenceKeypoint.new(
		1,
		PURPLE2
	)
})

Gradient.Rotation = 15
Gradient.Parent = ThrowButton

--============================================================
-- MOBILE TOGGLE
--============================================================

local MobileRow = Instance.new("Frame")

MobileRow.Size =
	UDim2.new(
		1,
		-30,
		0,
		42
	)

MobileRow.Position =
	UDim2.fromOffset(
		15,
		149
	)

MobileRow.BackgroundColor3 = CARD
MobileRow.BorderSizePixel = 0

MobileRow.Parent = Main

Corner(MobileRow, 9)

local MobileText = Instance.new("TextLabel")

MobileText.Size =
	UDim2.new(
		1,
		-75,
		1,
		0
	)

MobileText.Position =
	UDim2.fromOffset(
		12,
		0
	)

MobileText.BackgroundTransparency = 1

MobileText.Text = "Mobile Throw Button"

MobileText.TextColor3 = WHITE

MobileText.TextSize = 11
MobileText.Font = Enum.Font.GothamMedium

MobileText.TextXAlignment =
	Enum.TextXAlignment.Left

MobileText.Parent = MobileRow

local Toggle = Instance.new("TextButton")

Toggle.Size =
	UDim2.fromOffset(
		42,
		22
	)

Toggle.Position =
	UDim2.new(
		1,
		-52,
		0.5,
		-11
	)

Toggle.BackgroundColor3 = ELEMENT
Toggle.BorderSizePixel = 0
Toggle.Text = ""

Toggle.AutoButtonColor = false

Toggle.Parent = MobileRow

Corner(Toggle, 20)

local ToggleDot = Instance.new("Frame")

ToggleDot.Size =
	UDim2.fromOffset(
		16,
		16
	)

ToggleDot.Position =
	UDim2.fromOffset(
		3,
		3
	)

ToggleDot.BackgroundColor3 = WHITE
ToggleDot.BorderSizePixel = 0

ToggleDot.Parent = Toggle

Corner(ToggleDot, 20)

--============================================================
-- MOBILE THROW
--============================================================

local MobileThrow = Instance.new("TextButton")

MobileThrow.Size =
	UDim2.fromOffset(
		145,
		56
	)

MobileThrow.Position =
	UDim2.new(
		1,
		-165,
		1,
		-90
	)

MobileThrow.BackgroundColor3 = PURPLE
MobileThrow.BorderSizePixel = 0

MobileThrow.Text = "THROW"

MobileThrow.TextColor3 = WHITE

MobileThrow.TextSize = 14
MobileThrow.Font = Enum.Font.GothamBold

MobileThrow.AutoButtonColor = false

MobileThrow.Parent = GUI

Corner(MobileThrow, 14)

local MobileStroke = Instance.new("UIStroke")

MobileStroke.Color =
	Color3.fromRGB(
		180,
		140,
		255
	)

MobileStroke.Transparency = 0.4

MobileStroke.Parent = MobileThrow

--============================================================
-- UPDATE MOBILE
--============================================================

local function UpdateMobile()

	MobileThrow.Visible =
		MobileButtons

	if MobileButtons then

		Toggle.BackgroundColor3 =
			PURPLE

		TweenService:Create(
			ToggleDot,
			TweenInfo.new(0.15),
			{
				Position =
					UDim2.fromOffset(
						23,
						3
					)
			}
		):Play()

	else

		Toggle.BackgroundColor3 =
			ELEMENT

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

	MobileButtons =
		not MobileButtons

	UpdateMobile()

end)

UpdateMobile()

--============================================================
-- GET CURRENT VEHICLE
--============================================================

local function GetCurrentVehicle()

	if not Humanoid then
		return nil
	end

	local Seat =
		Humanoid.SeatPart

	if not Seat then
		return nil
	end

	if not Seat:IsA("VehicleSeat") then
		return nil
	end

	local Root =
		Seat.AssemblyRootPart
		or Seat

	if not Root then
		return nil
	end

	return Seat, Root

end

--============================================================
-- STATUS
--============================================================

local function UpdateStatus()

	if Throwing then

		Status.Text =
			"THROWING..."

		Status.TextColor3 =
			PURPLE2

		return

	end

	local Seat =
		Humanoid
		and Humanoid.SeatPart

	if Seat
		and Seat:IsA("VehicleSeat")
	then

		Status.Text =
			"VEHICLE READY • AIM AND THROW"

		Status.TextColor3 =
			GREEN

		ThrowButton.Text =
			"THROW VEHICLE   [ Y ]"

	else

		Status.Text =
			"ENTER A VEHICLE"

		Status.TextColor3 =
			GRAY

		ThrowButton.Text =
			"NO VEHICLE   [ Y ]"

	end

end

RunService.Heartbeat:Connect(
	UpdateStatus
)

--============================================================
-- THROW
--============================================================

local function ThrowVehicle()

	if Throwing then
		return
	end

	local Seat, VehicleRoot =
		GetCurrentVehicle()

	if not Seat
		or not VehicleRoot
	then

		Status.Text =
			"ENTER A VEHICLE FIRST"

		Status.TextColor3 = RED

		return
	end

	if VehicleRoot.Anchored then

		Status.Text =
			"VEHICLE IS ANCHORED"

		Status.TextColor3 = RED

		return
	end

	Throwing = true

	-- pega direção ANTES de sair do carro

	local Camera =
		workspace.CurrentCamera

	local Direction =
		Camera.CFrame.LookVector.Unit

	local LaunchVelocity =
		Direction * ThrowSpeed
		+
		Vector3.new(
			0,
			UpSpeed,
			0
		)

	--====================================================
	-- SAIR DO CARRO
	--====================================================

	Humanoid.Sit = false

	-- remove imediatamente o weld do banco
	-- para o personagem não viajar junto

	local SeatWeld =
		Seat:FindFirstChild(
			"SeatWeld"
		)

	if SeatWeld then

		pcall(function()
			SeatWeld:Destroy()
		end)

	end

	-- afasta o personagem um pouco para não
	-- encostar novamente no banco imediatamente

	if HRP then

		local EscapeDirection =
			-Direction

		HRP.CFrame =
			HRP.CFrame
			+
			EscapeDirection * 3
			+
			Vector3.new(
				0,
				2,
				0
			)

	end

	-- espera a separação física acontecer

	RunService.Heartbeat:Wait()

	--====================================================
	-- JOGAR O CARRO
	--====================================================

	if VehicleRoot
		and VehicleRoot.Parent
	then

		-- NÃO TELEPORTA O CARRO
		-- NÃO ANCORA
		-- NÃO USA PIVOTTO
		--
		-- apenas aplica velocidade na assembly real

		VehicleRoot.AssemblyLinearVelocity =
			LaunchVelocity

		-- pequena rotação para parecer um arremesso

		VehicleRoot.AssemblyAngularVelocity =
			Vector3.new(
				math.random(-3, 3),
				math.random(-5, 5),
				math.random(-3, 3)
			)

	end

	task.delay(0.25, function()

		Throwing = false
		UpdateStatus()

	end)

end

--============================================================
-- BUTTONS
--============================================================

ThrowButton.MouseButton1Click:Connect(
	ThrowVehicle
)

MobileThrow.MouseButton1Click:Connect(
	ThrowVehicle
)

--============================================================
-- Y
--============================================================

UIS.InputBegan:Connect(function(
	Input,
	Processed
)

	if Processed then
		return
	end

	if Input.KeyCode ==
		Enum.KeyCode.Y
	then

		ThrowVehicle()

	end

end)

--============================================================
-- DRAG MENU
--============================================================

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

		DragStart =
			Input.Position

		StartPosition =
			Main.Position

	end

end)

UIS.InputChanged:Connect(function(Input)

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
			Input.Position
			-
			DragStart

		Main.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset
					+
					Delta.X,

				StartPosition.Y.Scale,
				StartPosition.Y.Offset
					+
					Delta.Y
			)

	end

end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
		or
		Input.UserInputType ==
			Enum.UserInputType.Touch
	then

		Dragging = false

	end

end)

--============================================================
-- MINIMIZE
--============================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

	Minimized =
		not Minimized

	if Minimized then

		MobileRow.Visible = false
		Status.Visible = false
		ThrowButton.Visible = false

		TweenService:Create(
			Main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quint
			),
			{
				Size =
					UDim2.fromOffset(
						330,
						52
					)
			}
		):Play()

	else

		TweenService:Create(
			Main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quint
			),
			{
				Size =
					UDim2.fromOffset(
						330,
						205
					)
			}
		):Play()

		task.delay(0.12, function()

			MobileRow.Visible = true
			Status.Visible = true
			ThrowButton.Visible = true

		end)

	end

end)
