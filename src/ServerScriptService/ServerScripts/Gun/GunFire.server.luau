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
local FireToProcessFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("FireToProcessFW"))
local GunRecoilFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunRecoilFW"))



-- AMMO CHECKS
local OutOfAmmoReady = {}
local OutOfAmmoTask = {}
local AmmoLastChecked = {}
local function AmmoChecks(Player, CurrentGunData, FirstShot)
	if CurrentGunData.Ammo and CurrentGunData.Ammo.CurrentAmmo <= 0 then
		-- PREVENT SPAM
		if AmmoLastChecked[Player] and (tick() - AmmoLastChecked[Player]) < 0.25 then return true end
		AmmoLastChecked[Player] = tick()
		
		-- SET ATTRIBUTE
		task.delay(0.25, function()
			-- ADD DELAY IF NEEDED
			if CurrentGunData.GunStats.DelayIsShooting then
				task.wait(CurrentGunData.GunStats.DelayIsShooting)
			end
			
			-- SET ATTRIBUTE
			Player:SetAttribute("IsShooting", false)
		end)

		-- ALLOW OUT OF AMMO SFX RIGHT WHEN PLAYER ENDS SHOOTING AND NO AMMO (MUST HAVE NO AMMO LEFT)
		if Player:GetAttribute("TotalAmmo") <= 0 then
			if Player:GetAttribute("NoAmmo") then
				OutOfAmmoReady[Player] = false
			else
				OutOfAmmoReady[Player] = true
			end
			Player:SetAttribute("NoAmmo", true)

			-- OUT OF AMMO SFX
			if (FirstShot or OutOfAmmoReady[Player]) and not Player:GetAttribute("OutOfAmmoSFX") then
				Player:SetAttribute("OutOfAmmoSFX", true)

				OutOfAmmoTask[Player] = task.delay(1, function()
					Player:SetAttribute("OutOfAmmoSFX", false)
					OutOfAmmoTask[Player] = nil
				end)
			end
		end
	
		return true 
	else
		Player:SetAttribute("NoAmmo", false)
		return false
	end
end



-- FIRERATE CHECK
local FirstShotActivated = {}
local function ReadyToShoot(Player, CurrentGunData, PlayerDataTable)
	-- CHECK IF THERE IS AMMO FIRST
	local AmmoChecksFailed = AmmoChecks(Player, CurrentGunData, true)
	if AmmoChecksFailed then return false end
	
	-- LET WINDUP HANDLE THE FIRST SHOT
	if not FirstShotActivated[Player] then return true end
	
	-- FIRERATE
	local Now = tick()
	local TimeSinceShot = PlayerDataTable.Shooting.TimeSincePlayerShot or 0
	local FireRate = 1/CurrentGunData.GunStats.FireRate
	if Now - TimeSinceShot < FireRate then
		return false	
	end
	return true
end



-- HELPER TO COUNT CONDITIONS AS FIRST SHOT
local function CountAsFirstShot(Player, CurrentGunData)
	if Player:GetAttribute("IsDashing") or (Player:GetAttribute("IsReloading") and not Player:GetAttribute("ShotgunReload")) or Player:GetAttribute("IsEquipping") then
		FirstShotActivated[Player] = nil
		return true
	end
	return false
end



-- STREAM BULLET CHECKS
local function StreamChecks(Player, CurrentGunData)
	-- STREAM BULLET CHECKS
	if CurrentGunData.About.BulletType == "Stream" then
		if (Player:GetAttribute("IsCharging") or Player:GetAttribute("VisuallyCharging")) and Player:GetAttribute("WantsToCharge") then
			Player:SetAttribute("IsShooting", false) 
			return true
		end

		if CurrentGunData.Charge.CurrentCharge <= 0 then
			Player:SetAttribute("IsShooting", false) 
			CurrentGunData.Charge.CurrentCharge = 0
			return true
		end
	end
end


-- GENERAL CHECKS
local function GeneralChecks(Player)
	if Player:GetAttribute("IsEquipping") then 	FirstShotActivated[Player] = nil return false end
	if not Player:GetAttribute("EquippedGun") then  FirstShotActivated[Player] = nil return false end
	if not Player:GetAttribute("IsEquippingGun") then FirstShotActivated[Player] = nil return false end
	if Player:GetAttribute("IsReviving") then FirstShotActivated[Player] = nil return false end
	return true
end



-- RELOAD CHECKS
local function ReloadChecks(Player)
	if Player:GetAttribute("IsReloading") then
		-- IF REGULAR RELOADING
		Player:SetAttribute("IsShooting", false)
		return true 
	end
end



-- CLEANUP HELPER
local CleanupTasks = {}
local function ScheduleCleanup(Player)
	if CleanupTasks[Player] then
		task.cancel(CleanupTasks[Player])
	end

	CleanupTasks[Player] = task.delay(0.02, function()
		if Player:GetAttribute("WantsToShoot") then 
			CleanupTasks[Player] = nil
			return 
		end
		FirstShotActivated[Player] = nil
		Player:SetAttribute("ShotFired", false)
		Player:SetAttribute("InWindup", false)
		Player:SetAttribute("IsShooting", false)
		CleanupTasks[Player] = nil
	end)
end



-- PLAYER STARTS SHOOTING
local WindupTable = {}
local NewestDirection = {}
local NewestOrigin = {}
local InBurst = {}
StartShooting.OnServerEvent:Connect(function(Player, Origin, Direction, HandlePos)
	-- SET WANTS TO SHOOT ATTRIBUTE TO TRUE
	Player:SetAttribute("WantsToShoot", true)
	
	-- SOME GENERAL CHECKS
	if not GeneralChecks(Player) then return end
	
	
	-- ALWAYS STORE THE NEWEST DATA
	NewestOrigin[Player] = Origin
	NewestDirection[Player] = Direction

	
	-- ALL DATA
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return end
	local PlayerDataTable = PlayerData:Get(Player)
	if not PlayerDataTable then return end
	
	
	-- RELOAD CHECKS
	if ReloadChecks(Player) then return end

	-- FIRERATE CHECKS
	local ReadyToShoot = ReadyToShoot(Player, CurrentGunData, PlayerDataTable)
	if not ReadyToShoot then return end


	-- ENSURE FIRST SHOT IF:
	local CountAsFirstShot = CountAsFirstShot(Player, CurrentGunData)
	if CountAsFirstShot then return end


	-- DETERMINE IF FIRST SHOT (UPDATE TABLE)
	local FirstShot = false
	if not FirstShotActivated[Player] then
		FirstShotActivated[Player] = true 
		FirstShot = true
	end
	
	
	-- STREAM CHECKS
	local EndDueToStream = StreamChecks(Player, CurrentGunData)
	if EndDueToStream then return end


	-- DONT ALLOW SHOOTING IF:
	if Player:GetAttribute("IsEquipping") then return end
	if Player:GetAttribute("IsDashing") then return end
	if Player:GetAttribute("IsRevived") then return end
	

	-- WINDUP
	if FirstShot then 
		Player:SetAttribute("InWindup", true)
		Player:SetAttribute("IsShooting", true)
		
		if WindupTable[Player] then
			task.cancel(WindupTable[Player])
			WindupTable[Player] = nil
		end
		WindupTable[Player] = task.delay(CurrentGunData.GunStats.Windup, function()
			Player:SetAttribute("InWindup", false)
		end)
	end
	if Player:GetAttribute("InWindup") then return end


	-- TO TRACK WHEN SHOT FIRED ATTRIBUTE ALLOWED TO REPLICATE
	local AllowedShotFiredAttribute = true


	-- LOOP THROUGH BULLETS PER SHOT
	if InBurst[Player] then return end
	InBurst[Player] = true
	local BulletsPerShot = CurrentGunData.Burst and CurrentGunData.Burst.BulletsPerShot or 1
	for i = 1, BulletsPerShot do	
		-- END MIDWAY IF REQUESTED (NOT ALLOWED IF MEANT TO BE INSTANT BURST (ShOTGUN))
		if CurrentGunData.Burst and CurrentGunData.Burst.BurstDuration and CurrentGunData.Burst.BurstDuration > 0 then
			if i >= 1 and not Player:GetAttribute("WantsToShoot") then break end
		end
		
		-- STREAM CHECKS
		local EndDueToStream = StreamChecks(Player, CurrentGunData)
		if EndDueToStream then break end

		-- BULLET CHECKS
		local AmmoChecksFailed = AmmoChecks(Player, CurrentGunData, FirstShot)
		if AmmoChecksFailed then break end
		
		-- ADD TO TIME SINCE SHOT
		PlayerDataTable.Shooting.TimeSincePlayerShot = tick()


		-- SET SHOOTING ATTRIBUTE
		Player:SetAttribute("IsShooting", true)


		-- DIRECTION AND RECOIL
		local RecoilDirection = GunRecoilFW.GetRecoilSpread(Player, CurrentGunData, NewestDirection[Player])
		FireToProcessFW.FireToProcess(Player, NewestOrigin[Player], RecoilDirection, HandlePos)


		-- APPLY TIME SINCE SHOT FIRED ATTRIBUTE ONLY IF NEEDED (for rifles, etc)
		if CurrentGunData.GunStats.DelayIsShooting then
			Player:SetAttribute("TimeSinceShotFired", tick())
		end


		-- APPLY SHOT FIRED ATTRIBUTE
		local BurstDuration = CurrentGunData.Burst and CurrentGunData.Burst.BurstDuration or 0.05
		if AllowedShotFiredAttribute then
			Player:SetAttribute("ShotFired", true)
			task.delay(0.02, function()
				Player:SetAttribute("ShotFired", false)
			end)
			
			if BurstDuration <= 0 then
				AllowedShotFiredAttribute = false
			end
		end

		
		
		-- BURST DURATION
		if i < BulletsPerShot then
			if BurstDuration > 0 then
				task.wait(BurstDuration)
			end
		end
	end
	
	-- RESET INBURST
	InBurst[Player] = false
	
	-- RESET ATTRIBUTES IF NOT WANT TO SHOOT
	if not Player:GetAttribute("WantsToShoot") then
		ScheduleCleanup(Player)
	end
end)



-- PLAYER STOPS SHOOTING
StopShooting.OnServerEvent:Connect(function(Player)
	-- SET ATTRIBUTE
	Player:SetAttribute("WantsToShoot", nil)
	
	-- ALL DATA
	local EquippedGun = Player:GetAttribute("EquippedGun")
	if not EquippedGun then return end
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return end
	

	-- DELAY IF NEEDED (DONT DELAY IF FIRST SHOT, used for guns such as rifle etc to add delay for extra animations and syncing)
	if CurrentGunData.GunStats.DelayIsShooting and (Player:GetAttribute("TimeSinceShotFired") and tick() - Player:GetAttribute("TimeSinceShotFired") < CurrentGunData.GunStats.DelayIsShooting) then
		task.wait(CurrentGunData.GunStats.DelayIsShooting)
		if Player:GetAttribute("WantsToShoot") then return end
	end
	
	-- CANCEL WINDUP TASK
	if WindupTable[Player] then
		task.cancel(WindupTable[Player])
		WindupTable[Player]= nil
	end
	-- RESET ATTRIBUTES WITH A SLIGHT DELAY
	if not InBurst[Player] then
		ScheduleCleanup(Player)
	end
end)



-- PLAYER CLEANUP
Players.PlayerRemoving:Connect(function(Player)
	FirstShotActivated[Player] = nil
	WindupTable[Player] = nil
	NewestOrigin[Player] = nil
	NewestDirection[Player] = nil
	InBurst[Player] = nil
end)
