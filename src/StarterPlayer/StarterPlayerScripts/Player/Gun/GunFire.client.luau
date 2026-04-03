-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

-- PLAYER
local Player = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunModels = ReplicatedStorage:WaitForChild("GunModels")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ModuleScripts:WaitForChild("Client")

-- EVENTS
local StartShooting = Events:WaitForChild("GunEvents"):WaitForChild("StartShooting")
local StopShooting = Events:WaitForChild("GunEvents"):WaitForChild("StopShooting")
local GunCameraShakeEvent = Events:WaitForChild("GunEvents"):WaitForChild("GunCameraShakeEvent")

-- MODULES
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))
local GunCameraShake =
	require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Screenshake"):WaitForChild("GunCameraShake"))

-- GET ALL KINDS OF DATA
local function GetPlayerGunData()
	local EquippedGun = Player:GetAttribute("EquippedGun")
	local PlayerGunData = ClientGunData:Get(Player)
	local CurrentGunData = (PlayerGunData and PlayerGunData[EquippedGun]) or ClientGunData.DefaultData["Pistol"]
	local CurrentGunModel = GunModels:FindFirstChild(CurrentGunData and CurrentGunData.Model or "Pistol")
	local PlayerData = ClientPlayerData:Get(Player)

	return EquippedGun, PlayerGunData, PlayerGunData, CurrentGunModel, PlayerData
end

-- GET EXACT CURSOR POSITION ON GROUND PLANE
local Camera = workspace.CurrentCamera
local function GetMouseGroundPosition()
	local MouseLocation = UIS:GetMouseLocation()
	local Ray = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

	local Origin = Ray.Origin
	local Direction = Ray.Direction
	local RootY = Player.Character
			and Player.Character:FindFirstChild("HumanoidRootPart")
			and Player.Character.HumanoidRootPart.Position.Y
		or 0

	if Direction.Y == 0 then
		return
	end

	local PosMultiplier = (RootY - Origin.Y) / Direction.Y
	if PosMultiplier < 0 then
		return
	end

	return Origin + Direction * PosMultiplier
end

-- GET ANGLE BETWEEN 2 VECTORS
local function GetAngleBetween(v1, v2)
	local Dot = v1:Dot(v2)
	Dot = math.clamp(Dot, -1, 1)
	return math.acos(Dot)
end

-- CALCULATE SHOT DIRECTION AND AIMING LOGIC
local function CalculateShotDirection()
	-- CHARACTER AND DATA
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart or not Character then
		return
	end

	-- CHECK FOR GUN STUFF
	if Player:GetAttribute("IsEquipping") then
		return
	end
	if not Player:GetAttribute("EquippedGun") then
		return
	end
	if not Player:GetAttribute("IsEquippingGun") then
		return
	end
	if Player:GetAttribute("IsReviving") then
		return
	end

	-- EQUIPPED GUN
	local GunClone = Character:FindFirstChild("EquippedGun")
	if not GunClone then
		return
	end
	local GunMuzzle = GunClone:FindFirstChild("Muzzle")
	if not GunMuzzle then
		return
	end
	local Handle = GunClone:FindFirstChild("Handle")
	if not Handle then
		return
	end
	local HandlePos = Vector3.new(Handle.Position.X, GunMuzzle.Position.Y, Handle.Position.Z)
	if not HandlePos then
		return
	end

	-- DATA
	local _, _, CurrentGunData, _, _ = GetPlayerGunData()
	if not CurrentGunData then
		return
	end

	-- ORIGIN DIRECTION AND MOUSE POSITION RELATIVE TO GROUND
	local Origin = GunMuzzle.Position
	if Origin.Y > RootPart.Position.Y + 1 then
		-- CAP THE Y INCASE ITS TOO HIGH
		Origin = Vector3.new(Origin.X, RootPart.Position.Y + 1, Origin.Z)
	end
	--Origin = Vector3.new(Origin.X, RootPart.Position.Y, Origin.Z)
	local Direction = RootPart.CFrame.LookVector
	local MouseWorldPos = GetMouseGroundPosition()
	if not MouseWorldPos then
		return nil
	end

	-- VECTORS
	local ToMouse = (MouseWorldPos - Origin)
	local Distance = ToMouse.Magnitude

	-- ONLY ACCEPT Y IF STREAM BULLET
	local ToMouseDir
	local ForwardDir
	if CurrentGunData.About and CurrentGunData.About.BulletType == "Stream" then
		ToMouseDir = Vector3.new(ToMouse.X, ToMouse.Y, ToMouse.Z).Unit
		ForwardDir = Vector3.new(Direction.X, Direction.Y, Direction.Z).Unit
	else
		ToMouseDir = Vector3.new(ToMouse.X, 0, ToMouse.Z).Unit
		ForwardDir = Vector3.new(Direction.X, 0, Direction.Z).Unit
	end

	-- DEBUG PART
	--local NewPart = Instance.new("Part")
	--NewPart.Anchored = true
	--NewPart.Transparency = 0
	--NewPart.Size = Vector3.new(0.1, 0.1, Distance)
	--NewPart.CanCollide = false
	--NewPart.CFrame = CFrame.lookAt(Origin, Origin + ForwardDir)
	--NewPart.Parent = workspace
	--game.Debris:AddItem(NewPart, 0.1)

	-- SETTINGS
	local MaxDistance = 120
	local MinCone = CurrentGunData.Rotation.MinRotationAngle
	local MaxCone = CurrentGunData.Rotation.MaxRotationAngle

	-- LERP MATH
	local LerpAlpha = math.clamp(Distance / MaxDistance, 0, 1)
	local AllowedCone = math.lerp(MaxCone, MinCone, LerpAlpha)

	-- GET ANGLE BETWEEN DIRECTION AND MOUSE DIRECTION
	local Angle = GetAngleBetween(ForwardDir, ToMouseDir)

	-- DETERMINE FINAL DIRECTION
	local FinalDirection
	if Angle <= AllowedCone then
		FinalDirection = ToMouseDir
	else
		FinalDirection = ForwardDir:Lerp(ToMouseDir, AllowedCone / Angle)
	end

	return Origin, FinalDirection, HandlePos
end

-- PROCESS SHOT REQUEST
local function ProcessShotRequest()
	local Origin, FinalDirection, HandlePos = CalculateShotDirection()
	if not Origin or not FinalDirection or not HandlePos then
		return
	end

	StartShooting:FireServer(Origin, FinalDirection, HandlePos)
end

-- KEEP SHOOTING WHILE CLICK HELD
local function StartShootingFunc()
	local _, _, CurrentGunData, _, PlayerData = GetPlayerGunData()
	if PlayerData.Shooting.ShootingConnection then
		PlayerData.Shooting.ShootingConnection:Disconnect()
		PlayerData.Shooting.ShootingConnection = nil
	end

	PlayerData.Shooting.ShootingConnection = RunService.Heartbeat:Connect(function(DT)
		-- PROCESS SHOT DATA IF SHOOTING
		if PlayerData.Shooting.IsShooting then
			ProcessShotRequest()
		end
	end)
end

-- DISCONNECT HEARTBEAT
local function StopShots()
	local _, _, _, _, PlayerData = GetPlayerGunData()
	PlayerData.Shooting.IsShooting = false
	if PlayerData.Shooting.ShootingConnection then
		PlayerData.Shooting.ShootingConnection:Disconnect()
		PlayerData.Shooting.ShootingConnection = nil
	end
	StopShooting:FireServer()
end

-- INPUT FOR GUN FIRE START
UIS.InputBegan:Connect(function(Input, GameProcessed)
	local _, _, _, _, PlayerData = GetPlayerGunData()
	if not GameProcessed and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- THEN CONTINUE AUTOMATIC FIRE
		PlayerData.Shooting.IsShooting = true
		StartShootingFunc()
	end
end)

-- INPUT FOR GUN FIRE STOP
UIS.InputEnded:Connect(function(Input)
	local _, _, _, _, PlayerData = GetPlayerGunData()
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		StopShots()
	end
end)

-- CAMERA SHAKE EVENT FOR EACH BULLET
GunCameraShakeEvent.OnClientEvent:Connect(function()
	GunCameraShake.ScreenShake(Player)
end)

-- DISCONNECT WHEN DEAD
Player.CharacterRemoving:Connect(function()
	StopShots()
end)
