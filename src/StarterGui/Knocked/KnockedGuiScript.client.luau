-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- PLAYER
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))

-- UI
local PlayerGui = LocalPlayer.PlayerGui
local KnockedGui = ReplicatedStorage:WaitForChild("Gui"):WaitForChild("KnockedGui")

-- HEARTBEAT TO CONTINUOUSLY UPDATE KNOCKED GUI IF PLAYERS ARE KNOCKED
local KnockedGuiTable = {}

-- HUMANOID DIED
local Connection
Humanoid.Died:Connect(function()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
	for _, Player in Players:GetChildren() do
		if KnockedGuiTable[Player] then
			KnockedGuiTable[Player].Enabled = false
			KnockedGuiTable[Player]:Destroy()
			KnockedGuiTable[Player] = nil
		end
	end
end)

-- HEARTBEAT
Connection = RunService.Heartbeat:Connect(function()
	-- CHECK FOR INVALID
	for Player, _ in pairs(KnockedGuiTable) do
		if not Player or not Player.Parent then
			if KnockedGuiTable[Player] then
				KnockedGuiTable[Player].Enabled = false
				KnockedGuiTable[Player]:Destroy()
				KnockedGuiTable[Player] = nil
			end
		end
	end

	-- CHECK FOR KNOCKED PLAYERS AND UPDATE
	for _, Player in Players:GetChildren() do
		if Player == LocalPlayer then
			continue
		end

		-- IF KNOCKED
		if Player:GetAttribute("IsKnocked") then
			-- GET CHARACTER STUFF
			local PlayerCharacter = Player.Character
			if not PlayerCharacter then
				continue
			end
			local PlayerHumanoid = PlayerCharacter:FindFirstChild("Humanoid")
			if not PlayerHumanoid then
				continue
			end
			local PlayerRoot = PlayerCharacter:FindFirstChild("HumanoidRootPart")
			if not PlayerRoot then
				continue
			end

			-- DIRECTION TO KNOCKED PLAYER
			local DirectionToKnocked = (PlayerRoot.Position - RootPart.Position).Unit
			if not DirectionToKnocked then
				continue
			end

			-- CONVERT 3D POSITION TO SCREEN SPACE
			local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(PlayerRoot.Position)

			-- DETERMINE IF WITHIN SCREEN
			local IsOnScreen = ScreenPoint.X >= 0
				and ScreenPoint.X <= Camera.ViewportSize.X
				and ScreenPoint.Y >= 0
				and ScreenPoint.Y <= Camera.ViewportSize.Y

			-- IF NOT WITHIN SCREEEN THEN SHOW UI
			if not IsOnScreen then
				if KnockedGuiTable[Player] then
					KnockedGuiTable[Player].Enabled = true
				end
			else
				if KnockedGuiTable[Player] then
					KnockedGuiTable[Player].Enabled = false
				end
				continue
			end

			-- IF KNOCKED GUI ALREADY EXISTS
			if not KnockedGuiTable[Player] then
				KnockedGuiTable[Player] = KnockedGui:Clone()
				local Frame = KnockedGuiTable[Player].MainFrame.Frame
				local CharacterImage = Frame.CharacterImage
				CharacterImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=180&h=180"

				-- SET PARENT AND ENABLE
				KnockedGuiTable[Player].Parent = PlayerGui
				KnockedGuiTable[Player].Enabled = true
			end

			-- FRAME AND ARROW
			local MainFrame = KnockedGuiTable[Player].MainFrame
			local Arrow = MainFrame.Frame.Arrow

			-- VIEWPORT INFO
			local ViewportSize = Camera.ViewportSize
			local ScreenCenter = Vector2.new(ViewportSize.X * 0.5, ViewportSize.Y * 0.5)

			-- CONVERT WORLD POSITION TO SCREEN SPACE
			local ScreenPosition = Vector2.new(ScreenPoint.X, ScreenPoint.Y)

			-- IF BEHIND CAMERA
			if ScreenPoint.Z < 0 then
				ScreenPosition = ScreenCenter - (ScreenPosition - ScreenCenter)
			end

			-- DIRECTION FROM CENTER TO KNOCKED PLAYER
			local DirectionFromCenter = ScreenPosition - ScreenCenter

			-- SCREEN EDGE PADDING
			local EdgePadding = 60

			-- MIN AND MAX X AND Y
			local MinX = EdgePadding
			local MaxX = ViewportSize.X - EdgePadding
			local MinY = EdgePadding
			local MaxY = ViewportSize.Y - EdgePadding

			-- HALF SIZES FOR EDGE SELECTION
			local HalfWidth = (ViewportSize.X * 0.5) - EdgePadding
			local HalfHeight = (ViewportSize.Y * 0.5) - EdgePadding

			-- DETERMINE WHICH MAIN EDGE TO USE
			local NormalizedX = math.abs(DirectionFromCenter.X) / math.max(HalfWidth, 1)
			local NormalizedY = math.abs(DirectionFromCenter.Y) / math.max(HalfHeight, 1)

			local EdgePosition
			-- LEFT OR RIGHT
			if NormalizedX > NormalizedY then
				local X = (DirectionFromCenter.X >= 0) and MaxX or MinX
				local Y = ScreenCenter.Y + DirectionFromCenter.Y * ((X - ScreenCenter.X) / DirectionFromCenter.X)

				EdgePosition = Vector2.new(X, math.clamp(Y, MinY, MaxY))
			else
				-- TOP OR BOTTOM
				local Y = (DirectionFromCenter.Y >= 0) and MaxY or MinY
				local X = ScreenCenter.X + DirectionFromCenter.X * ((Y - ScreenCenter.Y) / DirectionFromCenter.Y)

				EdgePosition = Vector2.new(math.clamp(X, MinX, MaxX), Y)
			end

			-- APPLY POSITION
			MainFrame.Position = UDim2.fromOffset(EdgePosition.X, EdgePosition.Y)

			-- ROTATE TO ALWAYS POINT TOWARDS MAIN EDGE
			local AngleRadians = math.atan2(DirectionFromCenter.Y, DirectionFromCenter.X)
			local AngleDegrees = math.deg(AngleRadians)
			MainFrame.Rotation = AngleDegrees

			-- CHANGE COLOR OF STROKE AND ARROW
			local SecondFrameUIStroke = MainFrame.Frame.UIStroke

			-- CHECK HEALTH RATIO AND DETERMINE COLOR
			local HealthRatio = (PlayerHumanoid.Health / 30)

			-- MOVE COLOR TO RED SLOWLY BUT SURELY (based on hp)
			local NewColor = Color3.new(1, math.clamp(HealthRatio, 0, 1), math.clamp(HealthRatio, 0, 1))
			SecondFrameUIStroke.Color = NewColor
			Arrow.ImageColor3 = NewColor

			-- SCALE GUI SIZE DEPENDING ON DISTANCE BETWEEN PLAYERS
			local UIScale = MainFrame:FindFirstChildOfClass("UIScale")
			if not UIScale then
				return
			end
			local Distance = (PlayerRoot.Position - RootPart.Position).Magnitude
			Distance = math.clamp(Distance, 100, 500)

			-- SCALE
			local Scale = math.clamp(1 - (Distance - 100) / 300, 0.4, 1)
			-- UPDATE UI SCALE
			UIScale.Scale = Scale
		else
			-- CLEANUP
			if KnockedGuiTable[Player] then
				KnockedGuiTable[Player]:Destroy()
				KnockedGuiTable[Player] = nil
			end
		end
	end
end)
