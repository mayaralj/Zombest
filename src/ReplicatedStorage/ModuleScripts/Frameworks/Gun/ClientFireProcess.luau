local ClientFireProcess = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local GunVFX = ReplicatedStorage:WaitForChild("GunVFX")

-- EVENTS
local FireVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("FireVisualBullet")
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")

-- MODULES
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local ObjectPoolFW =
	require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("ObjectPool"):WaitForChild("ObjectPoolFW"))
local ClientBulletCleanup = require(Frameworks:WaitForChild("Gun"):WaitForChild("ClientBulletCleanup"))
local ClientBulletProcess = require(Frameworks:WaitForChild("Gun"):WaitForChild("ClientBulletProcess"))
local DetermineAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("DetermineAssets"))

-- OTHER
local BulletTypes = ReplicatedStorage:WaitForChild("BulletTypes")
local BulletCasings = ReplicatedStorage:WaitForChild("BulletCasings")
local BulletsFolder = workspace:WaitForChild("BulletsFolder")

-- CREATE POOL FOR EACH BULLET TYPE
for _, BulletType in BulletTypes:GetChildren() do
	-- REGULAR NEEDS THE MOST
	if BulletType.Name == "Regular" then
		ObjectPoolFW.Create(BulletType, 1500)
	else
		ObjectPoolFW.Create(BulletType, 500)
	end
end

-- CREATE POOL FOR EACH CASING TYPE
for _, BulletCasing in BulletCasings:GetChildren() do
	if BulletCasing.Name == "RayCasing" then
		continue
	end -- handled by assets

	-- REGULAR NEEDS THE MOST
	if BulletCasing.Name == "Regular" then
		ObjectPoolFW.Create(BulletCasing, 1500)
	else
		ObjectPoolFW.Create(BulletCasing, 500)
	end
end

-- START BULLET SYSTEM
local function StartBulletSystem()
	if ClientGunData.BulletConnection then
		return
	end

	ClientGunData.BulletConnection = RunService.Heartbeat:Connect(function(DT)
		if #ClientGunData.ClientBulletData == 0 then
			ClientGunData.BulletConnection:Disconnect()
			ClientGunData.BulletConnection = nil
			return
		end

		for i = 1, #ClientGunData.ClientBulletData do
			local BulletData = ClientGunData.ClientBulletData[i]
			if not BulletData then
				continue
			end

			ClientBulletProcess.ProcessBulletType(BulletData, DT)
		end
	end)
end

-- HANDLE STREAM BULLET
local function HandleStreamBullet(PlayerFired, PlayerFiredClientGunData, ServerData)
	if PlayerFired:GetAttribute("IsEquipping") then
		return
	end
	-- ENSURE DATA IS ALL HERE
	if not PlayerFired or not PlayerFiredClientGunData or not ServerData then
		return
	end

	-- MODEL STUFF
	local PlayerFiredGunModel = PlayerFired.Character:WaitForChild("EquippedGun")
	if not PlayerFiredGunModel then
		return
	end
	local Muzzle = PlayerFiredGunModel:WaitForChild("Muzzle")
	if not Muzzle then
		return
	end

	local PlayerGunAttribute = PlayerFired:GetAttribute("IsEquippingGun")
	if not PlayerGunAttribute then
		return
	end

	-- GET OLD ID
	local OldData = ClientGunData.StreamBullet[PlayerFired]

	-- CHECK IF NO STREAM BULLET OR CHARACTER DIED
	local AssetsToUse = DetermineAssets.DetermineAssets(PlayerGunAttribute)
	if not AssetsToUse then
		return
	end

	-- GET STREAM BULLET
	local StreamBulletModel = AssetsToUse.StreamBullet
		and AssetsToUse.StreamBullet(PlayerFired, PlayerFiredClientGunData)
	if not StreamBulletModel then
		return
	end

	-- REMOVE OLD DATA
	if OldData then
		ClientBulletCleanup.RemoveBulletFromArrays(OldData.BulletID)
	end

	-- STORE NEW DATA IN STREAM BULLETS
	ClientGunData.StreamBullet[PlayerFired] = {
		PlayerFired = PlayerFired,
		PlayerFiredGun = PlayerGunAttribute,
		CharacterFired = PlayerFired.Character,
		BulletRadius = PlayerFiredClientGunData.BulletStats.BulletSize,
		BulletID = ServerData.BulletID,
		BulletClone = StreamBulletModel,
		BulletType = PlayerFiredClientGunData.About.BulletType,
		Direction = ServerData.Direction.Unit,
		StartPos = ServerData.StartPos,
		Age = 0,
		MaxAge = math.huge,
	}

	-- ADD OR REPLACE DATA
	ClientBulletCleanup.AddBulletToArrays(ClientGunData.StreamBullet[PlayerFired])
	StartBulletSystem()

	-- CLEANUP OLD CONNECTIONS
	local Connections = ClientGunData.Connections
	if not Connections then
		return
	end
	if Connections[PlayerFired]["KnockedStreamBullet"] then
		Connections[PlayerFired]["KnockedStreamBullet"]:Disconnect()
		Connections[PlayerFired]["KnockedStreamBullet"] = nil
	end

	if Connections[PlayerFired]["RemovingStreamBullet"] then
		Connections[PlayerFired]["RemovingStreamBullet"]:Disconnect()
		Connections[PlayerFired]["RemovingStreamBullet"] = nil
	end

	if Connections[PlayerFired]["ChangedWeapon_Stream"] then
		Connections[PlayerFired]["ChangedWeapon_Stream"]:Disconnect()
		Connections[PlayerFired]["ChangedWeapon_Stream"] = nil
	end

	-- CLEANUP IF KNOCKED
	Connections[PlayerFired]["KnockedStreamBullet"] = PlayerFired:GetAttributeChangedSignal("IsKnocked")
		:Connect(function()
			if not ClientGunData.StreamBullet[PlayerFired] then
				return
			end
			if PlayerFired:GetAttribute("IsKnocked") then
				ClientBulletCleanup.RemoveBulletFromArrays(ClientGunData.StreamBullet[PlayerFired].BulletID)
				StreamBulletModel:Destroy()
				ClientGunData.StreamBullet[PlayerFired] = nil
			end
		end)

	-- CLEANUP BULLET IF SWAPPED WEAPON
	Connections[PlayerFired]["ChangedWeapon_Stream"] = PlayerFired:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if not ClientGunData.StreamBullet[PlayerFired] then
				return
			end
			if PlayerFired:GetAttribute("IsEquippingGun") ~= PlayerGunAttribute then
				ClientBulletCleanup.RemoveBulletFromArrays(ClientGunData.StreamBullet[PlayerFired].BulletID)
				StreamBulletModel:Destroy()
				ClientGunData.StreamBullet[PlayerFired] = nil
			end
		end)

	-- CLEANUP IF DEAD
	Connections[PlayerFired]["RemovingStreamBullet"] = PlayerFired.CharacterRemoving:Connect(function()
		if not ClientGunData.StreamBullet[PlayerFired] then
			return
		end
		ClientBulletCleanup.RemoveBulletFromArrays(ClientGunData.StreamBullet[PlayerFired].BulletID)
		StreamBulletModel:Destroy()
		ClientGunData.StreamBullet[PlayerFired] = nil

		if Connections[PlayerFired]["KnockedStreamBullet"] then
			Connections[PlayerFired]["KnockedStreamBullet"]:Disconnect()
			Connections[PlayerFired]["KnockedStreamBullet"] = nil
		end

		if Connections[PlayerFired]["RemovingStreamBullet"] then
			Connections[PlayerFired]["RemovingStreamBullet"]:Disconnect()
			Connections[PlayerFired]["RemovingStreamBullet"] = nil
		end

		if Connections[PlayerFired]["ChangedWeapon_Stream"] then
			Connections[PlayerFired]["ChangedWeapon_Stream"]:Disconnect()
			Connections[PlayerFired]["ChangedWeapon_Stream"] = nil
		end
	end)
end

-- BULLET CASING HELPER
local function RegularBulletCasing(PlayerFiredCharacter, CasingType, CasingSFX)
	local RootPart = PlayerFiredCharacter:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end
	local CharEquippedGun = PlayerFiredCharacter:FindFirstChild("EquippedGun")
	if not CharEquippedGun then
		return
	end

	-- CREATE BULLET CASING FALLING ON THE GROUND
	local BulletCase = ReplicatedStorage:FindFirstChild("BulletCasings"):FindFirstChild(CasingType)
	BulletCase = ObjectPoolFW.Get(BulletCase)
	BulletCase.Anchored = false
	BulletCase.CanCollide = true
	BulletCase.CanTouch = false
	BulletCase.CanQuery = false
	BulletCase.Transparency = 0
	BulletCase.CollisionGroup = "Rocks"

	-- ADJUST POSITION
	BulletCase.Position = CharEquippedGun.PrimaryPart.Position

	-- BODY VELOCITY FOR REALISM
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Velocity = RootPart.CFrame.RightVector * math.random(10, 20)
		+ RootPart.CFrame.UpVector * math.random(10, 20)
	BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	BodyVelocity.Parent = BulletCase

	-- ADD ROTATION
	local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
	BodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
	BodyAngularVelocity.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	BodyAngularVelocity.Parent = BulletCase

	-- ADD DEBRIS
	task.delay(1, function()
		BulletCase.Anchored = true
		BulletCase.CanCollide = false
		BulletCase.Transparency = 1
		task.wait(1)
		ObjectPoolFW.Return(BulletCase)
	end)
	game.Debris:AddItem(BodyVelocity, 0.1)
	game.Debris:AddItem(BodyAngularVelocity, 0.1)

	-- SFX
	local CasingSoundFX = Instance.new("Sound")
	CasingSoundFX.SoundId = CasingSFX
	CasingSoundFX.Parent = BulletCase
	CasingSoundFX.Volume = 0.35

	task.delay(0.1, function()
		CasingSoundFX:Play()
	end)
end

-- FUNCTION TO HANDLE REGULAR BULLET
local function HandleRegularBullet(PlayerFired, PlayerFiredClientGunData, ServerData)
	if PlayerFired:GetAttribute("IsEquipping") then
		return
	end
	-- ENSURE DATA IS ALL HERE
	if not PlayerFired or not PlayerFiredClientGunData or not ServerData then
		return
	end

	-- REGULAR BULLETS
	local PlayerFiredCharacter = PlayerFired.Character
	if not PlayerFiredCharacter then
		return
	end
	local EquippedGun = PlayerFiredCharacter:FindFirstChild("EquippedGun")
	if not EquippedGun then
		return
	end
	local Muzzle = EquippedGun:FindFirstChild("Muzzle")
	if not Muzzle then
		return
	end

	-- CREATE BULLET
	local BulletClone = BulletTypes:FindFirstChild(PlayerFiredClientGunData.About.BulletType)
	if not BulletClone then
		return
	end
	-- GET FROM POOL
	BulletClone = ObjectPoolFW.Get(BulletClone)
	if not BulletClone then
		return
	end

	-- BULLET CASING (reduce casing if too many consecutive shots)
	task.spawn(function()
		if PlayerFiredClientGunData.About.CasingDelay then
			task.wait(PlayerFiredClientGunData.About.CasingDelay)
		end

		local ConsecutiveShots = math.min(PlayerFired:GetAttribute("ConsecutiveShots") or 10, 10)
		local RandomNumber = math.random(1, ConsecutiveShots or 10)
		if RandomNumber < 5 then
			local CasingSFX = PlayerFiredClientGunData.About.CasingSFX
			local CasingType = PlayerFiredClientGunData.About.Casing
			if CasingSFX and CasingType then
				RegularBulletCasing(PlayerFiredCharacter, CasingType, CasingSFX)
			end
		end
	end)

	-- BULLET DATA
	local BulletData = {
		PlayerFired = PlayerFired,
		BulletID = ServerData.BulletID,
		BulletClone = BulletClone,
		BulletType = PlayerFiredClientGunData.About.BulletType,
		Direction = ServerData.Direction,
		StartPos = ServerData.StartPos,
		CurrentPos = ServerData.StartPos,
		BulletSpeed = ServerData.BulletSpeed,
		Velocity = ServerData.BulletSpeed * ServerData.Direction,
		Age = 0,
		MaxAge = PlayerFiredClientGunData.BulletStats.MaxAge,
	}

	-- MAKE BULLET VISIBLE
	BulletData.BulletClone.Transparency = 0
	for _, Descendant in pairs(BulletData.BulletClone:GetDescendants()) do
		if Descendant:IsA("BasePart") then
			Descendant.Transparency = 0
		end
		if Descendant:IsA("ParticleEmitter") then
			Descendant.Enabled = true
		end
		if Descendant:IsA("Trail") then
			Descendant:Clear()
			Descendant.Lifetime = 1
			Descendant.Transparency = NumberSequence.new(0.5)
			Descendant.Enabled = true
		end
	end

	-- ADD BULLET TO ARRAY AND START SYSTEM
	ClientBulletCleanup.AddBulletToArrays(BulletData)

	StartBulletSystem()
end

-- WHICH FIRE TO PROCESS
function ClientFireProcess.FireToProcess(PlayerFired, PlayerFiredClientGunData, PlayerFiredData)
	-- BULLET CLONING
	if PlayerFiredClientGunData.About.BulletType == "Stream" then
		HandleStreamBullet(PlayerFired, PlayerFiredClientGunData, PlayerFiredData)
	else
		HandleRegularBullet(PlayerFired, PlayerFiredClientGunData, PlayerFiredData)
	end
end

return ClientFireProcess
