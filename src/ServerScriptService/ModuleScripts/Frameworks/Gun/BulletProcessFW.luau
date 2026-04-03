local BulletProcessFW = {}


-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
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
local ZombieRagPulse = Events:WaitForChild("ZombieEvents"):WaitForChild("ZombieRagPulse")


-- MODULES
local BulletFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletFW"))
local PlayerData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local BulletCleanupFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletCleanupFW"))
local GunMiscFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunMiscFW"))
local ZombieForceFW = require(Frameworks:WaitForChild("Zombie"):WaitForChild("ZombieForceFW"))



-- GUN ASSETS FOLDER AND EVENTS
local GunAssetsEvents = Events:WaitForChild("GunAssetsEvents")
local ZombieHitVFX = GunAssetsEvents:WaitForChild("ZombieHitVFX")
local WallFX = GunAssetsEvents:WaitForChild("WallFX")


-- TABLES
local ShotHitZombieTask = {}



-- PROCESS RAY RESULT
local function ProcessBulletRayResult(ResultData, BulletData, IsOverlapParams)
	-- HIT PROPERTIES
	local HitPart = ResultData.Instance
	local HitPosition = ResultData.Position
	
	-- BODY FORCE
	local BodyForce = BulletData.BodyForce
	
	-- PLAYER THAT FIRED AND THE DATA
	local PlayerFired = BulletData.Player
	local CurrentPlayerData = PlayerData:Get(PlayerFired)


	-- EQUIPPED GUN
	local EquippedGun = BulletData.EquippedGun

	
	-- HIT ZOMBIE PART
	if HitPart:HasTag("ServerZombieTag") and not BulletData.HitCharacters[HitPart] then
		local ZombiePartData = ZombieData:Get(HitPart)
		if not ZombiePartData then return false end
		if ZombiePartData.Health.CurrentHealth <= 0 then return false end
		
		-- FIRE ALL CLIENT FOR VFX
		-- ZOMBIE ID
		local ZombieID = ZombiePartData.About.ID
		local NewResultData = {
			Position = HitPosition,
			ID = ZombieID
		}
		ZombieHitVFX:FireAllClients(PlayerFired, NewResultData)
		
		
		-- DAMAGE ZOMBIE
		ZombiePartData.Health.CurrentHealth -= BulletData.Damage
		
		-- IF A REFLECTED BULLET HITS ZOMBIE
		if BulletData.CurrentReflections > 0 then
			BulletData.ReflectedHits += 1
		end
	
		
		-- IMPULSE VECTOR
		if ZombiePartData.Health.CurrentHealth <= 0 then
			ZombieRagPulse:FireAllClients(ZombieID, BulletData.EquippedGun, BulletData.Direction)
		end

		
		-- BODY FORCE
		if ResultData.Normal then
			ZombieForceFW.ApplyBodyForceToZombie(HitPart, BodyForce, BulletData.Direction)
		end
		BulletData.HitCharacters[HitPart] = true
		-- NO NEED FOR OVERLAP PARAMS CHECK FOR BULLET EFFECTS AS ITS A ZOMBIE
		BulletData.PhaseAmount -= 1
		if BulletData.PhaseType and BulletData.PhaseType == "Wall" then
			BulletData.PhaseAmount = 0
		end
		BulletFW.OnBulletHitEffect(ResultData, BulletData, true)
		
		
		-- SET SHOTHITZOMBIE ATTRIBUTE
		PlayerFired:SetAttribute("ShotHitZombie", true)
		if ShotHitZombieTask[PlayerFired] then
			task.cancel(ShotHitZombieTask[PlayerFired])
		end
		ShotHitZombieTask[PlayerFired] = task.delay(0.5, function()
			PlayerFired:SetAttribute("ShotHitZombie", false)
		end)

		-- UPDATE CURRENT PLAYER POINTS
		if CurrentPlayerData then
			-- RANDOMIZED AMOUNT OF POINTS
			CurrentPlayerData.Points.CurrentPoints += math.random(
				8, 12
			)						
			-- EXTRA ON ZOMBIE KILL
			if ZombiePartData.Health.CurrentHealth <= 0 then
				CurrentPlayerData.Points.CurrentPoints += math.random(40,60)
			end
			PlayerFired:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
		end


		-- HIT ANY OTHER PART
	elseif CollectionService:HasTag(HitPart, "PhaseTag") and
		(not BulletData.HitParts[HitPart] or BulletData.CurrentReflections > 0) then

		BulletData.HitParts[HitPart] = true
		BulletData.PhaseAmount -= 1
		if BulletData.PhaseType and BulletData.PhaseType == "Zombie" then
			BulletData.PhaseAmount = 0
		end
		if not IsOverlapParams then
			BulletFW.OnBulletHitEffect(ResultData, BulletData, false)

			-- FIRE WALL FX
			WallFX:FireAllClients(PlayerFired, ResultData)
		end
	end
	
	-- PHASE AMOUNT CHECK
	if BulletData.PhaseAmount <= 0 then
		return true
	end
	
	
	return false
end



-- PROCESS INDIVIDUAL BULLET (DATA ONLY)
local WallParams = RaycastParams.new()
WallParams.FilterType = Enum.RaycastFilterType.Include
WallParams.FilterDescendantsInstances = {workspace:FindFirstChild("PhaseParts")}

local ZombieParams = RaycastParams.new()
ZombieParams.FilterType = Enum.RaycastFilterType.Include
ZombieParams.FilterDescendantsInstances = {workspace:FindFirstChild("ServerZombies")}

local ZombieOverlap = OverlapParams.new()
ZombieParams.FilterType = Enum.RaycastFilterType.Include
ZombieParams.FilterDescendantsInstances = {workspace:FindFirstChild("ServerZombies")}

local function ProcessBullet(BulletData, DT)
	if not BulletData or not DT then return end
	
	-- LIFETIME CHECK
	BulletData.Age += DT
	if BulletData.Age >= BulletData.MaxAge then
		return true
	end


	-- CALCULATE NEW POSITION
	local LastPos = BulletData.CurrentPos
	local IntendedMovement = BulletData.Velocity * DT * 1 -- buff the range slightly but dont update
	
	local UpdatedMovement = BulletData.Velocity * DT
	BulletData.CurrentPos = LastPos + UpdatedMovement -- no buff update here



	-- RANGE CHECK
	local StepDistance = BulletData.BulletSpeed * DT
	BulletData.TravelDistance += StepDistance
	if BulletData.TravelDistance >= BulletData.Range then
		return true
	end
	
	
	-- PHASE CHECK
	if BulletData.PhaseAmount <= 0 then
		return true
	end
	
	
	-- DAMAGE FALLOFF
	if BulletData.DamageFalloff and BulletData.DamageFalloff > 0 then
		local DamageFalloff = BulletData.DamageFalloff * BulletData.TravelDistance
		DamageFalloff *= 0.1
		DamageFalloff = math.max(DamageFalloff, 1)
		BulletData.Damage = BulletData.MaxDamage/DamageFalloff
		BulletData.Damage = math.max(0, BulletData.Damage)
	end

	local PlayerFired = BulletData.Player
	if not PlayerFired then return true end
	local CharacterFired = BulletData.Character
	if not CharacterFired then return true end
	local RootPart = CharacterFired:FindFirstChild("HumanoidRootPart")
	if not RootPart then return true end
	local EquippedGun = CharacterFired:FindFirstChild("EquippedGun")
	if not EquippedGun then return true end
	
	
	-- PLAYER PING
	local PlayerPing = PlayerFired:GetNetworkPing()
	local PingOffset = BulletData.Velocity.Unit * (BulletData.BulletSpeed * PlayerPing * 0.5)
	local LagCompensatedStart = LastPos - PingOffset
	
	-- CHECK IF PLAYER IS MOVING
	local RootVelocity = RootPart.Velocity
	local IsMoving = RootVelocity.Magnitude > 0
	if not IsMoving or PlayerPing * 1000 < 50 then
		LagCompensatedStart = LastPos
	end



	-- COLLISION DETECTION 
	local RayResult
	
	
	-- EARLY CHECK FOR NEW BULLETS
	if not BulletData.IsPhaseBullet and not BulletData.AgeChecked then
		BulletData.AgeChecked = true
		-- WALL CHECK
		RayResult = workspace:Raycast(
			BulletData.HandlePos - IntendedMovement * 4,
			IntendedMovement * 6,
			WallParams
		)
		if RayResult then
			-- IF WALL IS BEHIND PLAYER THEN IGNORE
			local ToWallFromRoot = (RayResult.Position - RootPart.Position)
			
			-- CHECK IF FACING WALL
			if (BulletData.Direction:Dot(RayResult.Normal) < -0.25) and (RootPart.CFrame.LookVector:Dot(ToWallFromRoot) >= 0) then 
				local ResultData = { 
					Instance = RayResult.Instance,
					Position = RayResult.Position,
					Normal = RayResult.Normal
				}
				-- ONLY DELETE FOR THIS CHECK IF CLOSE
				local Distance = (ResultData.Position - BulletData.HandlePos).Magnitude
				--if Distance < 10 then
					local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
					return ProcessedResult
				--end
			end
		end
		
		
		-- EXTRA RAYCAST CHECK
		RayResult = workspace:Raycast(
			BulletData.HandlePos - IntendedMovement,
			IntendedMovement * 2,
			ZombieParams
		)
		if RayResult then
			local ResultData = {
				Instance = RayResult.Instance,
				Position = RayResult.Position,
				Normal = RayResult.Normal
			}
			local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
			return ProcessedResult
		end
		
		
		
		-- HANDLE OVERLAP CHECK
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.HandlePos,
			1,
			ZombieOverlap
		)
		if #Overlap > 0 then
			-- DO A REGULAR SPHERE CAST CHECK FIRST
			RayResult = workspace:Raycast(
				BulletData.HandlePos - IntendedMovement,
				IntendedMovement * 2,
				ZombieParams
			)
			if RayResult then
				local ResultData = {
					Instance = RayResult.Instance,
					Position = RayResult.Position,
					Normal = RayResult.Normal
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
				return ProcessedResult
			end
		end
		

	
		-- MUZZLE OVERLAP CHECK
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.StartPos,
			1,
			ZombieOverlap
		)
		if #Overlap > 0 then
			-- DO A REGULAR SPHERE CAST CHECK FIRST
			RayResult = workspace:Raycast(
				BulletData.HandlePos - IntendedMovement,
				IntendedMovement * 2,
				ZombieParams
			)
			if RayResult then
				local ResultData = {
					Instance = RayResult.Instance,
					Position = RayResult.Position,
					Normal = RayResult.Normal
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
				return ProcessedResult
			end
		end
		
		


		-- OVERLAP CHECK 1
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.StartPos,
			0.1,
			BulletData.OverlapParams
		)
		if #Overlap > 0 then
			for _, Part in ipairs(Overlap) do
				if Part.Name == "Base" then continue end
				local ResultData = {
					Instance = Part,
					Position = Part.Position,
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, true)
				return true
			end
		end
		

		-- OVERLAP CHECK 2
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.CurrentPos,
			0.01,
			BulletData.OverlapParams
		)
		
		if #Overlap > 0 then
			for _, Part in ipairs(Overlap) do
				if Part.Name == "Base" then continue end
				local ResultData = {
					Instance = Part,
					Position = Part.Position,
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, true)
				return true
			end
		end
		
		
		-- WALL CHECK
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.HandlePos,
			0.1,
			BulletData.OverlapParams
		)
		if #Overlap > 0 then
			for _, Part in ipairs(Overlap) do
				if Part.Name == "Base" then continue end
				local ResultData = {
					Instance = Part,
					Position = Part.Position,
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, true)
				return true
			end
		end
	end
	
	
	-- SPHERECAST
	-- AGE CHECK FOR PHASE BULLETS TO INCLUDE A LONGER RANGE
	if not BulletData.AgeChecked and BulletData.IsPhaseBullet then
		RayResult = workspace:Spherecast(
			BulletData.HandlePos - IntendedMovement * 5,
			BulletData.BulletRadius,
			IntendedMovement * 5,
			BulletData.RayParams
		)
		BulletData.AgeChecked = true
	else
		RayResult = workspace:Spherecast(
			LagCompensatedStart,
			BulletData.BulletRadius,
			IntendedMovement,
			ZombieParams
		)
		-- NO PING COMPENSATION FOR WALLS
		if not RayResult then
			RayResult = workspace:Spherecast(
				LastPos,
				BulletData.BulletRadius,
				IntendedMovement,
				WallParams
			)
		end
	end

	-- CHECK FOR RAY HITS
	if RayResult then
		BulletData.CurrentPos = RayResult.Position
		local ResultData = {
			Instance = RayResult.Instance,
			Position = RayResult.Position,
			Normal = RayResult.Normal
		}
		local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
		if not BulletData.IsPhaseBullet then return ProcessedResult end
	end

	
	
	-- DOUBLE CHECK FOR OTHER PARTS NEAR BULLET (ONLY FOR BULLETS THAT CAN PHASE)
	if BulletData.IsPhaseBullet then
		local Overlap = workspace:GetPartBoundsInRadius(
			BulletData.CurrentPos,
			BulletData.BulletRadius,
			BulletData.OverlapParams
		)
		if #Overlap > 0 then
			local ShouldReturn = false
			for _, Part in ipairs(Overlap) do
				local ResultData = {
					Instance = Part,
					Position = Part.Position,
				}
				local ProcessedResult = ProcessBulletRayResult(ResultData, BulletData, false)
				if ProcessedResult == true then ShouldReturn = true end 
			end
			return ShouldReturn
		end
	end
	return false
end




-- PROCESS RAYRESULT FROM STREAM BULLET
local function ProcessStreamRayResult(ResultData, BulletData, IsOverlapParams)
	-- HIT PART POSITION
	local HitPart = ResultData.Instance
	if not HitPart then return false end
	local HitPosition = ResultData.Position
	if not HitPosition then return false end
	
	-- BODY FORCE
	local BodyForce = BulletData.BodyForce

	-- PLAYER FIRED
	local Character = HitPart:FindFirstAncestorOfClass("Model")
	local PlayerFired = BulletData.Player
	local CurrentPlayerData = PlayerData:Get(PlayerFired)
	
	-- DEBUG PART
	--local NewPart = Instance.new("Part")
	--NewPart.Parent = workspace
	--NewPart.Anchored = true
	--NewPart.CanCollide = false
	--NewPart.CanTouch = false
	--NewPart.CanQuery = false
	--NewPart.Size = Vector3.new(0.1, 0.1, 14)
	--NewPart.Color = Color3.new(1, 0.784314, 0)
	--NewPart.Position = ResultData.Position
	--Debris:AddItem(NewPart, 0.1)


	if HitPart:HasTag("ServerZombieTag") and not BulletData.HitCharacters[HitPart] then
		local ZombiePartData = ZombieData:Get(HitPart)
		if not ZombiePartData then return false end
		if ZombiePartData.Health.CurrentHealth <= 0 then return false end
		
		-- DEAL DAMAGE
		ZombiePartData.Health.CurrentHealth -= BulletData.Damage
		-- BODY FORCE
		if ResultData.Normal then
			ZombieForceFW.ApplyBodyForceToZombie(HitPart, BodyForce, BulletData.Direction)
		end
		
		-- ZOMBIE ID
		local ZombieID = ZombiePartData.About.ID

		-- IMPULSE VECTOR
		if ZombiePartData.Health.CurrentHealth <= 0 then
			ZombieRagPulse:FireAllClients(ZombieID, BulletData.EquippedGun, BulletData.Direction)
		end
		
		
		-- MARK PART
		BulletData.HitCharacters[HitPart] = true
		
		-- NO NEED FOR OVERLAP PARAMS CHECK FOR BULLET EFFECTS AS ITS A ZOMBIE
		BulletFW.OnBulletHitEffect(ResultData, BulletData, true)
		
		
		-- SET SHOTHITZOMBIE ATTRIBUTE
		PlayerFired:SetAttribute("ShotHitZombie", true)
		if ShotHitZombieTask[PlayerFired] then
			task.cancel(ShotHitZombieTask[PlayerFired])
		end
		ShotHitZombieTask[PlayerFired] = task.delay(0.5, function()
			PlayerFired:SetAttribute("ShotHitZombie", false)
		end)
		

		-- UPDATE CURRENT PLAYER POINTS
		if CurrentPlayerData then
			-- RANDOMIZED AMOUNT OF POINTS
			CurrentPlayerData.Points.CurrentPoints += math.random(
				8, 12
			)			
			-- EXTRA ON ZOMBIE KILL
			if ZombiePartData.Health.CurrentHealth <= 0 then
				CurrentPlayerData.Points.CurrentPoints += math.random(40,60)
			end
			PlayerFired:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
		end


	elseif HitPart.Transparency <= 0.5 and HitPart.CanCollide 
		and CollectionService:HasTag(HitPart, "PhaseTag") and
		(not BulletData.HitParts[HitPart] or BulletData.CurrentReflections > 0) then

		BulletData.HitParts[HitPart] = true
		if not IsOverlapParams then
			BulletFW.OnBulletHitEffect(ResultData, BulletData, false)
		end
	end

	return false
end



-- PROCESS STREAM BULLETS
local function ProcessStream(BulletData, DT)
	local RayResult
	local Overlap
	local PlayerFiredRoot = BulletData.Player.Character:FindFirstChild("HumanoidRootPart")

	-- IF WEAPON WASNT FOUND DELETE BULLET
	local PlayerFiredMuzzle = BulletData and BulletData.Player.Character:FindFirstChild("EquippedGun") and BulletData.Player.Character:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle") or nil
	if not PlayerFiredMuzzle then 
		return true
	end
	
	-- CHECK IF PLAYER STOPPED SHOOTING
	if not BulletData.Player:GetAttribute("IsShooting") or BulletData.Player:GetAttribute("IsCharging") then
		return true 
	end
	
	BulletData.Age += DT
	if not BulletData.AgeChecked then
		Overlap = workspace:GetPartBoundsInRadius(
			BulletData.StartPos,
			2,
			BulletData.OverlapParams
		)
		BulletData.AgeChecked = true
	else
		RayResult = workspace:Raycast(
			BulletData.StartPos,  
			BulletData.Direction * 100, 
			BulletData.RayParams
		)
	end
	if not Overlap then Overlap = {} end

	if #Overlap > 0 then
		for _, Part in ipairs(Overlap) do
			local ResultData = {
				Instance = Part,
				Position = Part.Position,
			}
			ProcessStreamRayResult(ResultData, BulletData, true)
		end
		return true
	end

	if RayResult then
		local ResultData = {
			Instance = RayResult.Instance,
			Position = RayResult.Position,
			Normal = RayResult.Normal,
		}
		ProcessStreamRayResult(ResultData, BulletData, false)
		return true
	end

	
	-- IF NOTHING DETECTED WITHIN MAX AGE (SHORT TIME), REMOVE BULLET
	if not RayResult or #Overlap <= 0 then
		BulletData.Age += DT
		if BulletData.Age >= BulletData.MaxAge then
			return true
		end
	end
	
	return false
end



-- DETERMINE WHICH BULLET TO PROCESS
function BulletProcessFW.BulletToProcess(BulletData, DT)
	local BulletType = BulletData.BulletType
	if BulletType == "Stream" then
		return ProcessStream(BulletData, DT)
	else
		return ProcessBullet(BulletData, DT)
	end
end



return BulletProcessFW