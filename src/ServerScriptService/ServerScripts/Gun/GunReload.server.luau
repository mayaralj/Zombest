-- SERVICES
local UIS = game:GetService("UserInputService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunEvents = Events:WaitForChild("GunEvents")
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")

-- EVENTS
local StartReloading = GunEvents:WaitForChild("StartReloading")

-- MODULE
local GunData = require(Data:WaitForChild("GunData"))
local PlayerData = require(Data:WaitForChild("PlayerData"))
local ChargeEffectsFW = require(
	ServerScriptService:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("Gun")
		:WaitForChild("ChargeEffectsFW")
)

-- REGULAR BULLET RELOAD
local function BulletReload(Player, CurrentGunData, WantsToReload)
	if WantsToReload then
		Player:SetAttribute("WantsToReload", true)
	else
		Player:SetAttribute("WantsToReload", false)
	end
end

-- STREAM RELOAD
local function StreamReload(Player, CurrentGunData, WantsToCharge)
	if WantsToCharge then
		Player:SetAttribute("WantsToCharge", true)
	else
		Player:SetAttribute("WantsToCharge", false)
	end
end

-- WHICH RELOAD TYPE
local function DetermineReloadType(Player, WantsToReload)
	local PlayerGun = Player:GetAttribute("EquippedGun")
	if not PlayerGun then
		return
	end

	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then
		return
	end

	if CurrentGunData.About.BulletType == "Stream" then
		StreamReload(Player, CurrentGunData, WantsToReload)
	else
		BulletReload(Player, CurrentGunData, WantsToReload)
	end
end

-- TRIGGER RELOAD
StartReloading.OnServerEvent:Connect(function(Player, WantsToReload)
	DetermineReloadType(Player, WantsToReload)
end)

-- SHOTGUN RELOAD
local TimeSinceReloaded = {}
local function ProcessShotgunReload(Player, CurrentGunData, DT)
	-- END IF AMMO IS MAXED OR NO TOTAL AMMO REMANINING
	if CurrentGunData.Ammo.CurrentAmmo == CurrentGunData.Ammo.MaxAmmo then
		Player:SetAttribute("IsReloading", false)
		return
	end
	if CurrentGunData.Ammo.TotalAmmo <= 0 then
		Player:SetAttribute("IsReloading", false)
		return
	end

	-- AVOID DOUBLE RELOAD
	if Player:GetAttribute("ShotgunReload") then
		return
	end

	-- WANTED TO SHOOT
	local WantedToShoot = Player:GetAttribute("WantsToShoot")

	-- PROCESS SHOTGUN RELOAD
	Player:SetAttribute("IsReloading", true)
	Player:SetAttribute("ShotgunReload", true)

	local WantedToSprint = Player:GetAttribute("WantsToSprint")
	local SprintTask
	SprintTask = task.spawn(function()
		while not Player:GetAttribute("WantsToSprint") or (WantedToSprint and Player:GetAttribute("WantsToSprint")) do
			if WantedToSprint and not Player:GetAttribute("WantsToSprint") then
				WantedToSprint = false
			end
			if Player:GetAttribute("IsDashing") then
				break
			end
			task.wait(0.1)
		end
		Player:SetAttribute("IsReloading", false)
	end)

	local ForceEnd = false

	-- ADJUST MOVE WEIGHT WHEN RELOADING
	Player:SetAttribute("ReloadTime", CurrentGunData.Ammo.ReloadTime)
	CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ReloadMoveWeight
	while CurrentGunData.Ammo.CurrentAmmo < CurrentGunData.Ammo.MaxAmmo and CurrentGunData.Ammo.TotalAmmo > 0 do
		-- IF CANCELLED FROM ELSE WHERE
		if not Player:GetAttribute("ShotgunReload") or not Player:GetAttribute("IsReloading") then
			break
		end

		-- SOME SHOOTING CHECKS FOR AUTO RELOAD AND RELOAD CANCEL WITH CLICK
		if Player:GetAttribute("WantsToShoot") and not Player:GetAttribute("AutoReload") then
			break
		end
		if not Player:GetAttribute("WantsToShoot") then
			WantedToShoot = false
		end
		if Player:GetAttribute("WantsToShoot") and not WantedToShoot and Player:GetAttribute("AutoReload") then
			break
		end

		-- RELOAD AMMO
		Player:SetAttribute("BulletReloaded", true)
		CurrentGunData.Ammo.CurrentAmmo += CurrentGunData.Ammo.AmmoPerReload
		CurrentGunData.Ammo.TotalAmmo -= CurrentGunData.Ammo.AmmoPerReload

		-- WAIT TO UPDATE ATTRIBUTE
		task.wait(0.02)
		Player:SetAttribute("BulletReloaded", false)
		if not Player:GetAttribute("AutoReload") then
			TimeSinceReloaded[Player] = tick()
		end

		-- CLAMP
		if CurrentGunData.Ammo.CurrentAmmo > CurrentGunData.Ammo.MaxAmmo then
			CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo
		end
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / CurrentGunData.Ammo.AmmoPerReload)
		Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo / CurrentGunData.Ammo.AmmoPerReload)

		-- WAIT TIME
		local ReloadTime = CurrentGunData.Ammo.ReloadTime
		local StartTime = tick()
		local EndTime = StartTime + ReloadTime

		-- SPLIT INTO STEPS SO CANCELLING IS AS RESPONSIVE AS POSSIBLE
		while tick() < EndTime do
			task.wait()

			-- SOME SHOOTING CHECKS FOR AUTO RELOAD AND RELOAD CANCEL WITH CLICK
			if Player:GetAttribute("WantsToShoot") and not Player:GetAttribute("AutoReload") then
				ForceEnd = true
				break
			end
			if not Player:GetAttribute("WantsToShoot") then
				WantedToShoot = false
			end
			if Player:GetAttribute("WantsToShoot") and not WantedToShoot and Player:GetAttribute("AutoReload") then
				ForceEnd = true
				break
			end
		end

		-- BREAK IF FORCE END
		if ForceEnd then
			break
		end
	end

	-- CLAMP AMMO TO MAX AMMO IF REACHED GREATER
	if CurrentGunData.Ammo.CurrentAmmo > CurrentGunData.Ammo.MaxAmmo then
		CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / CurrentGunData.Ammo.AmmoPerReload)
		Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo / CurrentGunData.Ammo.AmmoPerReload)
	end
	-- SET ATTRIBUTES
	if SprintTask then
		task.cancel(SprintTask)
		SprintTask = nil
	end
	Player:SetAttribute("IsReloading", false)
	Player:SetAttribute("ShotgunReload", false)
	-- TO STILL PREVENT SPAM
	TimeSinceReloaded[Player] = tick()
end

-- PROCESS BULLET RELOAD
local OutOfAmmoTask = {}
local function ProcessBulletReload(Player, CurrentGunData, DT)
	-- EARLY CHECK
	if not Player or not CurrentGunData then
		return
	end

	-- DONT ALLOW IF NOT WANTING TO RELOAD AND ITS NOT AUTO RELOAD TIME
	if CurrentGunData.Ammo.CurrentAmmo > 0 then
		if not Player:GetAttribute("WantsToReload") then
			return
		end
		Player:SetAttribute("AutoReload", false)
	else
		-- CAP AMMO TO 0
		CurrentGunData.Ammo.CurrentAmmo = 0
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / (CurrentGunData.Ammo.AmmoPerReload or 1))

		-- ALLOW RELOAD IF WANT TO SHOOT OR RELOAD
		if not Player:GetAttribute("WantsToShoot") and not Player:GetAttribute("WantsToReload") then
			return
		end
		Player:SetAttribute("AutoReload", true)
	end

	-- OUT OF AMMO
	if CurrentGunData.Ammo.TotalAmmo <= 0 then
		Player:SetAttribute("IsReloading", false)
		Player:SetAttribute("AutoReload", false)

		-- PLAY OUT OF AMMO SFX
		if Player:GetAttribute("OutOfAmmoSFX") then
			return
		end
		Player:SetAttribute("OutOfAmmoSFX", true)

		OutOfAmmoTask[Player] = task.delay(1, function()
			Player:SetAttribute("OutOfAmmoSFX", false)
			OutOfAmmoTask[Player] = nil
		end)
		return
	end

	-- DONT ALLOW IF SHOOTING OR RELOADING OR NOT WANTING TO RELOAD
	if Player:GetAttribute("IsShooting") then
		Player:SetAttribute("IsReloading", false)
		return
	end
	if Player:GetAttribute("IsReloading") then
		return
	end
	if CurrentGunData.Ammo.ReloadTime < 0 then
		return
	end -- disable reload if negative

	-- PREVENT SPAMMING RELOADS
	if TimeSinceReloaded[Player] and not Player:GetAttribute("AutoReload") then
		if (tick() - TimeSinceReloaded[Player]) < 0.5 then
			return
		end
	end

	-- PROCESS SHOTGUN RELOAD
	if CurrentGunData.Ammo.ReloadType and CurrentGunData.Ammo.ReloadType == "Shotgun" then
		ProcessShotgunReload(Player, CurrentGunData, DT)
		return
	end

	-- PROCESS REGULAR RELOAD
	if not Player:GetAttribute("IsReloading") then
		Player:SetAttribute("IsReloading", true)
	end

	-- END IF AMMO IS MAXED OR NO TOTAL AMMO REMANINING
	if CurrentGunData.Ammo.CurrentAmmo >= CurrentGunData.Ammo.MaxAmmo then
		CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo
		Player:SetAttribute("IsReloading", false)
		return
	end

	-- CHECK IF WANTS TO SPRINT
	local WantedToSprint = Player:GetAttribute("WantsToSprint")

	-- CHECK IF WAS KNOCKED
	local WasKnocked = Player:GetAttribute("IsKnocked")

	-- TIME SINCE STARTED RELOADING
	Player:SetAttribute("TimeSinceStartedReloading", tick())

	-- ADJUST MOVE WEIGHT WHEN RELOADING
	CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ReloadMoveWeight
	local ReloadTask
	ReloadTask = task.delay(CurrentGunData.Ammo.ReloadTime, function()
		-- IF RELOADING GOT FORCE CANCELLED
		if not Player:GetAttribute("IsReloading") then
			return
		end

		-- KNOCKED CHECKS
		if not WasKnocked and Player:GetAttribute("IsKnocked") then
			Player:SetAttribute("IsReloading", false)
			return
		end

		-- END RELOADING
		TimeSinceReloaded[Player] = tick()
		Player:SetAttribute("IsReloading", false)

		-- DO SOME AMMO CALCULATIONS
		local AmmoDifference = CurrentGunData.Ammo.MaxAmmo - CurrentGunData.Ammo.CurrentAmmo
		if CurrentGunData.Ammo.TotalAmmo - AmmoDifference < AmmoDifference then
			CurrentGunData.Ammo.CurrentAmmo += CurrentGunData.Ammo.TotalAmmo -- - AmmoDifference)
			CurrentGunData.Ammo.TotalAmmo = 0
		else
			CurrentGunData.Ammo.CurrentAmmo += AmmoDifference
			CurrentGunData.Ammo.TotalAmmo -= AmmoDifference
		end

		-- UPDATE ATTRIBUTES
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / (CurrentGunData.Ammo.AmmoPerReload or 1))
		Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo / (CurrentGunData.Ammo.AmmoPerReload or 1))
	end)
	Player:SetAttribute("ReloadTime", CurrentGunData.Ammo.ReloadTime)

	-- CANCEL RELOAD IF SPRINTED OR DASHING
	while (not Player:GetAttribute("WantsToSprint")) or (WantedToSprint and Player:GetAttribute("WantsToSprint")) do
		if WantedToSprint and not Player:GetAttribute("WantsToSprint") then
			WantedToSprint = false
		end
		if Player:GetAttribute("IsDashing") then
			break
		end
		if not Player:GetAttribute("IsReloading") then
			break
		end
		task.wait(0.1)
	end
	-- ADD A BIT OF ASSIST FOR FAIRNESS
	if (tick() - Player:GetAttribute("TimeSinceStartedReloading")) / CurrentGunData.Ammo.ReloadTime > 0.75 then
		return
	end

	-- CANCEL RELOADING IF SPRINTED
	task.cancel(ReloadTask)
	Player:SetAttribute("IsReloading", false)
	-- TO STILL PREVENT SPAM
	TimeSinceReloaded[Player] = tick()
end

-- PROCESS STREAM RELOAD
local function ProcessStreamReload(Player, CurrentGunData, DT)
	if CurrentGunData.Charge.CurrentCharge >= 100 then
		CurrentGunData.Charge.CurrentCharge = 100
	end

	-- UPDATE CHARGE ATTRIBUTE (ROUNDED)
	Player:SetAttribute("CurrentCharge", math.round(CurrentGunData.Charge.CurrentCharge * 10) / 10)

	-- NO CHARGE IF SHOOTING OR KNOCKED
	if Player:GetAttribute("IsShooting") or Player:GetAttribute("IsKnocked") then
		Player:SetAttribute("VisuallyCharging", false)
		Player:SetAttribute("IsCharging", false)
		return
	end

	-- DONT ALLOW CHARGINGIF KNOCKED
	if Player:GetAttribute("IsKnocked") then
		Player:SetAttribute("VisuallyCharging", false)
		Player:SetAttribute("IsCharging", false)
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight
		return
	end

	if not Player:GetAttribute("IsCharging") then
		CurrentGunData.Charge.ManualChargeTimer += DT
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight
	else
		CurrentGunData.Charge.ManualChargeTimer = 0
	end
	CurrentGunData.Charge.TimeToWait += DT

	-- CURRENT CHARGE CHECKS
	if CurrentGunData.Charge.CurrentCharge <= 0 then
		-- CHANGE WEIGHT BACK TO NORMAL
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight
		-- CAP CHARGE
		CurrentGunData.Charge.CurrentCharge = 0

		-- OUT OF CHARGE ATTRIBUTE
		if not Player:GetAttribute("OutOfCharge") then
			Player:SetAttribute("OutOfCharge", true)
			task.delay(0.1, function()
				Player:SetAttribute("OutOfCharge", false)
			end)
		end
	elseif CurrentGunData.Charge.CurrentCharge >= CurrentGunData.Charge.MaxCharge then
		Player:SetAttribute("WantsToCharge", false)
		Player:SetAttribute("VisuallyCharging", false)
		Player:SetAttribute("IsCharging", false)

		-- CHANGE WEIGHT BACK TO NORMAL
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight
		-- CAP CHARGE
		CurrentGunData.Charge.CurrentCharge = CurrentGunData.Charge.MaxCharge

		-- END SINCE MAX CHARGE
		return
	else
		if not Player:GetAttribute("WantsToCharge") and not Player:GetAttribute("IsShooting") then
			CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight
		end
	end

	-- DONT LET ANY AUTO CHARGE IF WANT TO SHOOT
	--if Player:GetAttribute("WantsToShoot") and not Player:GetAttribute("WantsToCharge") then return end

	-- WANTSTOCHARGE CHECKS
	local WantsToCharge = Player:GetAttribute("WantsToCharge")
	if not WantsToCharge then
		CurrentGunData.Charge.TimeBeforeChargeTimer = 0
		-- SET ATTRIBUTES
		Player:SetAttribute("VisuallyCharging", false)
		Player:SetAttribute("IsCharging", false)
		-- CHANGE WEIGHT BACK TO NORMAL
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RegularMoveWeight

		if CurrentGunData.Charge.TimeToWait <= 1 then
			return
		end
		CurrentGunData.Charge.CurrentCharge += CurrentGunData.Charge.ChargeRegenRate / 4 * DT
	else
		--CurrentGunData.Charge.TimeToWait = 0
		-- VISUAL CHARGE FOR ASSETS AND WEIGHT
		if not Player:GetAttribute("IsCharging") then
			CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ReloadMoveWeight
			CurrentGunData.Charge.TimeBeforeChargeTimer += DT
			Player:SetAttribute("VisuallyCharging", true)
			if CurrentGunData.Charge.TimeBeforeChargeTimer < CurrentGunData.Charge.TimeBeforeCharge then
				return
			end
		end
		CurrentGunData.Charge.TimeBeforeChargeTimer = 0

		-- ONLY SEND IF NEARING MAX CHARGE
		if CurrentGunData.Charge.CurrentCharge >= 95 then
			ChargeEffectsFW.OnCharge(Player, CurrentGunData, CurrentGunData.Charge.CurrentCharge)
		end
		if Player:GetAttribute("IsCharging") then
			CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ReloadMoveWeight
			CurrentGunData.Charge.CurrentCharge += CurrentGunData.Charge.ChargeRegenRate * DT
		end
		if CurrentGunData.Charge.ManualChargeTimer <= CurrentGunData.Charge.ManualChargeCD then
			return
		end
		CurrentGunData.Charge.ManualChargeTimer = 0
		Player:SetAttribute("IsCharging", true)

		CurrentGunData.Charge.CurrentCharge += CurrentGunData.Charge.ChargeRegenRate * DT
		-- CHANGE WEIGHT
		CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ReloadMoveWeight
	end
end

-- ALL RELOAD HEARTBEAT
RunService.Heartbeat:Connect(function(DT)
	for _, Player in ipairs(game.Players:GetPlayers()) do
		-- DATA
		local PlayerGun = Player:GetAttribute("EquippedGun")
		if not PlayerGun then
			continue
		end
		local CurrentGunData = GunData:Get(Player)
		if not CurrentGunData then
			continue
		end

		if Player:GetAttribute("IsReviving") then
			if Player:GetAttribute("WantsToCharge") then
				Player:SetAttribute("WantsToCharge", false)
			end
			if Player:GetAttribute("WantsToReload") then
				Player:SetAttribute("WantsToReload", false)
			end
			if Player:GetAttribute("IsReloading") then
				Player:SetAttribute("IsReloading", false)
			end
			if Player:GetAttribute("IsCharging") then
				Player:SetAttribute("IsCharging", false)
			end
			continue
		end

		if CurrentGunData.About.BulletType == "Stream" then
			ProcessStreamReload(Player, CurrentGunData, DT)
		elseif CurrentGunData.About.BulletType == "Regular" then
			ProcessBulletReload(Player, CurrentGunData, DT)
		end
	end
end)
