local FireToProcessFW = {}


-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")


-- FOLDERS 
local Events = ReplicatedStorage:WaitForChild("Events")
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local PhaseParts = workspace:WaitForChild("PhaseParts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")


-- EVENTS
local StartShooting = Events:WaitForChild("GunEvents"):WaitForChild("StartShooting")
local StopShooting = Events:WaitForChild("GunEvents"):WaitForChild("StopShooting")
local FireVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("FireVisualBullet")
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")
local GunCameraShakeEvent = Events:WaitForChild("GunEvents"):WaitForChild("GunCameraShakeEvent")


-- MODULES
local BulletFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletFW"))
local PlayerData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local BulletCleanupFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletCleanupFW"))
local GunMiscFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunMiscFW"))
local BulletProcessFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletProcessFW"))



-- RAYPARAMS FOR PLAYER
local ListToInclude = {workspace.ServerZombies, workspace.PhaseParts}
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Include
RayParams.FilterDescendantsInstances = ListToInclude


-- OVERLAP PARAMS
local OverLapParams = OverlapParams.new()
OverLapParams.FilterType = Enum.RaycastFilterType.Include
OverLapParams.FilterDescendantsInstances = ListToInclude



-- START BULLET SYSTEM
local function StartBulletSystem()
	if GunData.BulletConnection then return end

	GunData.BulletConnection = RunService.Heartbeat:Connect(function(DT)
		-- CHECK IF ANY ACTIVE BULLETS
		if #GunData.BulletData == 0 then
			GunData.BulletConnection:Disconnect()
			GunData.BulletConnection = nil
			return
		end
		
		-- LOOP THROUGH ALL BULLETS
		for i = 1, #GunData.BulletData do
			local BulletData = GunData.BulletData[i]
			if not BulletData then continue end
			local ShouldRemove = BulletProcessFW.BulletToProcess(BulletData, DT)
			
			if ShouldRemove then
				BulletCleanupFW.ScheduleBulletCleanup(BulletData)
				BulletCleanupFW.RemoveBulletFromArrays(BulletData.BulletID)
			end
		end
	end)
end



-- FIRE STREAM BULLET AND SEND DATA TO ACTIVE BULLETS AND CLIENT
local function FireStream(Player, StartPos, Direction, HandlePos)
	if Player:GetAttribute("IsEquipping") then return end
	local EquippedGun = Player:GetAttribute("EquippedGun")
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return end

	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then return end


	-- GENERATE BULLET ID
	local BulletID = HttpService:GenerateGUID(false)
	-- FIRE NECESSARY DATA
	local NecessaryData = {
		StartPos = StartPos,
		Direction = Direction,
		BulletID = BulletID,
	}
	FireVisualBullet:FireAllClients(Player, NecessaryData)
	


	-- CREATE BULLET DATA
	local BulletData = {
		BulletID = BulletID,
		BulletType = CurrentGunData.About.BulletType,
		Player = Player,
		EquippedGun = EquippedGun,
		
		Effect = CurrentGunData.Effect,
		
		RayParams = RayParams,
		OverlapParams = OverLapParams,
		
		Damage = CurrentGunData.GunStats.Damage,
		BulletRadius = CurrentGunData.BulletStats.BulletSize * 0.5,
		
		Age = CurrentGunData.BulletStats.BulletAge,
		AgeChecked = false,
		MaxAge = CurrentGunData.BulletStats.BulletMaxAge,
		
		BodyForce = CurrentGunData.BodyForce.BodyForce,
		
		Direction = Direction,
		StartPos = StartPos,
		HandlePos = HandlePos,
		
		AccumulatedTime = 0,
		CurrentChain = 0,
		
		HitCharacters = {},
		HitParts = {},
		
		ChainedHit = {},
	}

	-- ADD TO ACTIVE BULLETS
	BulletCleanupFW.AddBulletToArrays(BulletData)

	-- CHARGE
	CurrentGunData.Charge.TimeToWait = 0
	CurrentGunData.Charge.CurrentCharge -= CurrentGunData.Charge.ChargeDecreaseRate
	-- UPDATE CHARGE ATTRIBUTE
	Player:SetAttribute("CurrentCharge", CurrentGunData.Charge.CurrentCharge)


	-- CAMERA SHAKE
	GunCameraShakeEvent:FireClient(Player)

	StartBulletSystem()
end



-- FIRE BULLET (DATA ONLY - NO VISUAL OBJECT)
local AvailableBulletID = 0
local function FireBullet(Player, StartPos, Direction, HandlePos)
	if Player:GetAttribute("IsEquipping") then return end
	local Character = Player.Character
	if not Character then return end
	local EquippedGun = Player:GetAttribute("EquippedGun")
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return end
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then return end


	-- GENERATE BULLET ID
	local BulletID = AvailableBulletID
	AvailableBulletID += 1
	AvailableBulletID %= 10000
	

	-- FIRE VISUAL BULLET
	local NecessaryData = {
		StartPos = StartPos,
		Direction = Direction,
		BulletID = BulletID,
		BulletSpeed = CurrentGunData.BulletStats.BulletSpeed,
	}
	FireVisualBullet:FireAllClients(Player, NecessaryData)
	


	-- CREATE BULLET DATA
	local BulletData = {
		BulletID = BulletID,
		BulletType = CurrentGunData.About.BulletType,
		Player = Player,
		Character = Character,
		EquippedGun = EquippedGun,
		
		Effect = CurrentGunData.Effect,
		
		RayParams = RayParams,
		OverlapParams = OverLapParams,

		BulletSpeed = CurrentGunData.BulletStats.BulletSpeed,
		Range = CurrentGunData.GunStats.Range,
		
		MaxDamage = CurrentGunData.GunStats.Damage,
		Damage = CurrentGunData.GunStats.Damage,
		DamageFalloff = CurrentGunData.GunStats.DamageFalloff or 0,
		
		BulletRadius = CurrentGunData.BulletStats.BulletSize * 0.5,
		PhaseAmount = CurrentGunData.BulletStats.BulletPhase,
		PhaseType = CurrentGunData.BulletStats.BulletPhaseType,
		IsPhaseBullet = CurrentGunData.BulletStats.BulletPhase > 1 and CurrentGunData.BulletStats.BulletPhaseType ~= "Zombie",
		
		Age = CurrentGunData.BulletStats.BulletAge,
		AgeChecked = false,
		MaxAge = CurrentGunData.BulletStats.BulletMaxAge,
		
		FireRate = CurrentGunData.GunStats.FireRate,
		BodyForce = CurrentGunData.BodyForce.BodyForce,

		Direction = Direction,
		Velocity = Direction * CurrentGunData.BulletStats.BulletSpeed,
		StartPos = StartPos,
		HandlePos = HandlePos,
		CurrentPos = StartPos,
		TravelDistance = 0,

		AccumulatedTime = 0,

		HitCharacters = {},
		HitParts = {},
	
		-- WALL REFLECTIONS
		CurrentReflections = 0,
		ReflectedHits = 0,
		
		-- ZOM REFLECTIONS
		ZombieReflections = 0,
	}

	-- AMMO
	if CurrentGunData.Ammo  then
		CurrentGunData.Ammo.CurrentAmmo -= 1
		if CurrentGunData.Ammo.AmmoPerReload then
			Player:SetAttribute("CurrentAmmo", math.round(CurrentGunData.Ammo.CurrentAmmo/CurrentGunData.Ammo.AmmoPerReload))
		else
			Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo)
		end
	end


	-- SCREENSHAKE
	GunCameraShakeEvent:FireClient(Player)

	-- ADD TO BULLETS WITH PROPER HASHING
	BulletCleanupFW.AddBulletToArrays(BulletData)

	
	StartBulletSystem()
end



-- WHICH FIRE TO PROCESS
function FireToProcessFW.FireToProcess(Player, StartPos, Direction, HandlePos)
	local EquippedGun = Player:GetAttribute("EquippedGun")
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return end

	if CurrentGunData.About.BulletType == "Stream" then
		FireStream(Player, StartPos, Direction, HandlePos)
	else
		FireBullet(Player, StartPos, Direction, HandlePos)
	end
end



return FireToProcessFW