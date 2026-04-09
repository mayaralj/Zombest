local BulletEffects = {}

-- SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")
local Events = ReplicatedStorage:WaitForChild("Events")
local BulletEvents = Events:WaitForChild("BulletEvents")

-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))
local ZombieData = require(Data:WaitForChild("ZombieData"))

-- EVENTS
local WallRicochetEvent = BulletEvents:WaitForChild("WallRicochetEvent")
local ZombieRicochetEvent = BulletEvents:WaitForChild("ZombieRicochetEvent")
local ChainVFXEvent = BulletEvents:WaitForChild("ChainVFXEvent")
local AOEFX = BulletEvents:WaitForChild("AOEFX")
local BurnEffect = BulletEvents:WaitForChild("BurnEffect")

-- TABLES

-- HANDLE EFFECTS ON BULLET HIT
function BulletEffects.OnBulletHitEffect(ResultData, BulletData, IsZombie)
	if not BulletData.Effect then
		return
	end
	for EffectIndex, EffectData in pairs(BulletData.Effect) do
		local EffectFunction = EffectData.Type
		if typeof(EffectFunction) == "function" then
			local Player = BulletData.Player
			EffectFunction(ResultData, BulletData, Player, IsZombie, EffectIndex)
		end
	end
end

-- AOE EFFECT
function BulletEffects.AoeEffect(ResultData, BulletData, PlayerShooting, IsZombie, EffectIndex)
	-- GET HITPART DATA
	local Position = ResultData.Position
	if not Position then
		return
	end
	local HitPart = ResultData.Instance
	if not HitPart then
		return
	end

	-- EXCLUDE LIST FOR OVERLAP PARAMS
	local ExcludeList = {}
	local ZombiePart
	if HitPart:HasTag("ServerZombieTag") then
		ZombiePart = HitPart
	end

	-- DATA
	local CurrentPlayerData = PlayerData:Get(PlayerShooting)
	if not CurrentPlayerData then
		return
	end
	local EffectData = BulletData.Effect[EffectIndex]
	if not EffectData then
		return
	end

	-- COOLDOWN FOR AOE EFFECT
	if tick() - EffectData.CurrentCooldown < EffectData.MaxCooldown then
		return
	end
	EffectData.CurrentCooldown = tick()

	-- WHO TO EXCLUDE
	if not EffectData.DamageOrigZombie and ZombiePart and IsZombie then
		table.insert(ExcludeList, ZombiePart)
	end

	if not EffectData.DamagePlayer then
		if PlayerShooting.Character then
			table.insert(ExcludeList, PlayerShooting.Character)
		end
	end

	if not EffectData.DamageOtherPlayers then
		for _, Player in ipairs(Players:GetPlayers()) do
			if Player.Character and PlayerShooting ~= Player then
				table.insert(ExcludeList, Player.Character)
			end
		end
	end

	-- FIRE TO CLIENT
	local EquippedGun = PlayerShooting:GetAttribute("EquippedGun")
	AOEFX:FireAllClients(PlayerShooting, EquippedGun, Position, EffectData.Radius)

	-- OVERLAP PARAMS
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterDescendantsInstances = ExcludeList
	OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	OverlapParams.CollisionGroup = "Default"

	-- GET PARTS IN AOE
	local PartsInRadius = workspace:GetPartBoundsInRadius(Position, EffectData.Radius, OverlapParams)

	-- DEBUG PART
	--local DebugSphere = Instance.new("Part")
	--DebugSphere.Name = "hi"
	--DebugSphere.Shape = Enum.PartType.Ball
	--DebugSphere.Size = Vector3.new(EffectData.Radius * 2, EffectData.Radius * 2, EffectData.Radius * 2)
	--DebugSphere.Position = Position
	--DebugSphere.Anchored = true
	--DebugSphere.CanCollide = false
	--DebugSphere.Transparency = 0.7
	--DebugSphere.Material = Enum.Material.Neon
	--DebugSphere.BrickColor = BrickColor.Red()
	--DebugSphere.Parent = workspace:WaitForChild("BulletsFolder"):WaitForChild("BulletEffects")

	--Debris:AddItem(DebugSphere, 0.5)

	-- APPLY DAMAGE
	local Hits = 0
	for _, Part in ipairs(PartsInRadius) do
		if Hits > EffectData.MaxHits then
			return
		end
		if not Part:HasTag("ServerZombieTag") then
			continue
		end
		local ZombiePartData = ZombieData:Get(Part)
		if not ZombiePartData then
			continue
		end

		-- DAMAGE CHECK FOR THE AOE EFFECT WITH FALLOFF
		local Distance = (Part.Position - Position).Magnitude
		local FallOff = 1 - math.clamp(Distance / EffectData.Radius, 0.25, 1)
		FallOff *= EffectData.FallOffMultiplier
		FallOff = math.clamp(FallOff, 0.25, 1)
		local Damage = EffectData.Damage * FallOff

		-- APPLY DAMAGE
		ZombiePartData.Health.CurrentHealth -= Damage
		-- ENSURE ATTRIBUTES ARE SET FOR CLIENT RAGDOLL AND IMPULSE
		if ZombiePartData.Health.CurrentHealth <= 0 then
			Part:SetAttribute("DeadByWeapon", BulletData.EquippedGun)
			Part:SetAttribute("DirectionDead", BulletData.Direction)
		end

		-- UPDATE CURRENT PLAYER POINTS
		if CurrentPlayerData then
			-- RANDOMIZED AMOUNT OF POINTS
			CurrentPlayerData.Points.CurrentPoints += math.random(3, 6)
			-- EXTRA ON ZOMBIE KILL
			if ZombiePartData.Health.CurrentHealth <= 0 and HitPart ~= Part then
				CurrentPlayerData.Points.CurrentPoints += math.random(40, 60)
				CurrentPlayerData.RoundStats.Kills += 1
				PlayerShooting:SetAttribute("Kills", CurrentPlayerData.RoundStats.Kills)
			end
			PlayerShooting:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
		end

		-- HIT COUNT
		Hits += 1
	end
end

-- BURN EFFECT
local TimeSinceBurnt = {}
function BulletEffects.BurnEffect(ResultData, BulletData, PlayerShooting, IsZombie, EffectIndex)
	-- ONLY FOR ZOMBIES
	if not IsZombie then
		return
	end

	-- EFFECT DATA
	local EffectData = BulletData.Effect[EffectIndex]
	if not EffectData then
		return
	end

	-- GET POSITION AND HIT PART
	local Position = ResultData.Position
	if not Position then
		return
	end
	local HitPart = ResultData.Instance
	if not HitPart then
		return
	end
	local HitNormal = ResultData.Normal
	if not HitNormal then
		return
	end

	-- ZOMBIE AND BURN DATA
	local CurrentZomData = ZombieData:Get(HitPart)
	if not CurrentZomData then
		return
	end
	local BurnData = CurrentZomData.Status.Burn
	if not BurnData then
		return
	end
	local ZombieID = CurrentZomData.About.ID
	if not ZombieID then
		return
	end

	-- PER ZOMBIE CD
	if TimeSinceBurnt[HitPart] then
		if tick() - TimeSinceBurnt[HitPart] < EffectData.PerZombieCD then
			return
		end
	end
	TimeSinceBurnt[HitPart] = tick()

	-- GLOBAL CD
	if tick() - EffectData.CurrentCD < EffectData.GlobalCD then
		return
	end
	EffectData.CurrentCD = tick()

	-- ALLOW EXTRA BURN
	if BurnData.BurnTime > 0 then
		BurnData.BurnDamage += EffectData.Damage / 10
	else
		BurnData.BurnTime = EffectData.Duration
		BurnData.TickTime = 0
		BurnData.BurnDamage += EffectData.Damage
	end

	-- FIRE TO CLIENT IF NOT ALREADY BURNING
	BurnEffect:FireAllClients(ZombieID, BurnData.BurnTime, BurnData.BurnDamage)

	-- SET THE PLAYER WHO STARTED BURN
	BurnData.Player = PlayerShooting
end

-- RICOCHET EFFECT
function BulletEffects.WallRicochetEffect(ResultData, BulletData, PlayerShooting, IsZombie, EffectIndex)
	-- GET POSITION AND HIT PART
	local Position = ResultData.Position
	if not Position then
		return
	end
	local HitPart = ResultData.Instance
	if not HitPart then
		return
	end
	local HitNormal = ResultData.Normal
	if not HitNormal then
		return
	end

	-- EFFECT DATA
	local EffectData = BulletData.Effect[EffectIndex]
	if not EffectData then
		return
	end

	-- CHECK FOR OBSTACLE
	if IsZombie then
		-- IF HIT TOO MANY ZOMBIES WHEN BULLET HAS BEEN REFLECTED
		if BulletData.ReflectedHits >= EffectData.MaxReflectedHits then
			BulletData.PhaseAmount = 0
		end
		return
	end
	if not CollectionService:HasTag(HitPart, "PhaseTag") then
		return
	end

	-- DECREASE RANGE TRAVELLED TO ALLOW BULLET TO LAST LONGER
	BulletData.TravelDistance -= 75
	BulletData.TravelDistance = math.max(0, BulletData.TravelDistance)

	-- BULLET REFLECTIONS
	BulletData.CurrentReflections += 1
	if BulletData.CurrentReflections >= EffectData.MaxReflections then
		BulletData.PhaseAmount = 0 -- ensure bullet gets deleted
		return
	else
		BulletData.PhaseAmount = 99 -- cannot be deleted
	end

	local OldDirection = BulletData.Direction

	-- REFLECTION FORMULA
	local DotProduct = OldDirection:Dot(HitNormal)
	local NewDirection = OldDirection - (2 * DotProduct * HitNormal)
	NewDirection = Vector3.new(NewDirection.X, 0, NewDirection.Z).Unit

	-- UPDATE BULLET STATE
	BulletData.Direction = NewDirection
	BulletData.Velocity = NewDirection * BulletData.BulletSpeed

	WallRicochetEvent:FireAllClients(BulletData.BulletID, NewDirection, BulletData.CurrentPos)
end

-- ZOMBIE RICOCHET EFFECT
local ZombieRicocheted = {}
function BulletEffects.ZombieRicochetEffect(ResultData, BulletData, PlayerShooting, IsZombie, EffectIndex)
	-- GET POSITION AND HIT PART
	local Position = ResultData.Position
	if not Position then
		return
	end
	local HitPart = ResultData.Instance
	if not HitPart then
		return
	end

	-- ENSURE DESTROY IF RICOCHETS AND HITS WALL
	if not IsZombie or not CollectionService:HasTag(HitPart, "ServerZombieTag") then
		-- ENSURE BULLET DESTROY
		if BulletData.ZombieReflections > 0 then
			BulletData.PhaseAmount = 0
		end
		return
	end

	-- ENSURE EFFECT ACTUALLY EXISTS
	local EffectData = BulletData.Effect[EffectIndex]
	if not EffectData then
		return
	end

	if ZombieRicocheted[HitPart] then
		return
	end

	-- ADD A GLOBAL COOLDOWN
	local TimeSinceLastUse = tick() - (EffectData.CurrentCooldown or 0)
	if TimeSinceLastUse < EffectData.GlobalCooldown and BulletData.ZombieReflections == 0 then
		return
	end
	EffectData.CurrentCooldown = tick()

	-- DECREASE RANGE TRAVELLED TO ALLOW BULLET TO LAST LONGER
	BulletData.TravelDistance -= 75
	BulletData.TravelDistance = math.max(0, BulletData.TravelDistance)

	-- BULLET REFLECTIONS
	BulletData.ZombieReflections += 1
	local CurrentReflections = BulletData.ZombieReflections
	if BulletData.ZombieReflections > EffectData.MaxReflections then
		BulletData.PhaseAmount = 0
		return
	else
		BulletData.PhaseAmount = 99
	end
	-- RESET COOLDOWN ONLY IF ALL CHECKS PASS
	EffectData.CurrentCooldown = tick()
	BulletData.HitCharacters[HitPart] = true -- turn false for repeated hit per zombie if not turn true

	--task.delay(0.025, function()
	--	if BulletData.ZombieReflections == CurrentReflections then
	--		BulletData.PhaseAmount = 1
	--	end
	--end)

	-- OVERLAP PARAMS
	local IncludeList = { workspace.ServerZombies }
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterDescendantsInstances = IncludeList
	OverlapParams.FilterType = Enum.RaycastFilterType.Include

	local OverlapResult = workspace:GetPartBoundsInRadius(Position, EffectData.Radius, OverlapParams)

	if #OverlapResult > 0 then
		local ClosestPart = nil
		local ClosestPosition = nil
		for _, Part in ipairs(OverlapResult) do
			-- ENSURE ZOMBIE
			if Part == HitPart then
				continue
			end
			if BulletData.HitCharacters[Part] then
				continue
			end
			if not CollectionService:HasTag(Part, "ServerZombieTag") then
				continue
			end
			local CurrentZombieData = ZombieData:Get(Part)
			if not CurrentZombieData then
				continue
			end

			if CurrentZombieData.Health.CurrentHealth <= 0 then
				continue
			end

			-- GET CLOSEST PART
			local Distance = (Part.Position - Position).Magnitude
			if not ClosestPosition or Distance < (ClosestPosition - HitPart.Position).Magnitude then
				ClosestPart = Part
				ClosestPosition = Part.Position
			end
		end
		if not ClosestPart then
			BulletData.PhaseAmount = 0
			return
		end
		-- CALCULATE DIRECTION TO CLOSEST PART
		local Direction = (ClosestPart.Position - Position).Unit
		-- GROUND DIRECTION
		Direction = Vector3.new(Direction.X, 0, Direction.Z).Unit
		BulletData.Direction = Direction
		BulletData.Velocity = Direction * BulletData.BulletSpeed

		-- SEND TO ALL CLIENTS
		ZombieRicochetEvent:FireAllClients(BulletData.BulletID, Direction, BulletData.CurrentPos)

		-- ADD DAMAGEFALLOFF
		if EffectData.DamageFalloff > 0 then
			local FallOff = BulletData.Damage * (EffectData.DamageFalloff / 100)
			BulletData.Damage -= FallOff
		end

		-- UPDATE COOLDOWN
		if EffectData.ZombieCooldown > 0 then
			ZombieRicocheted[ClosestPart] = true
			task.delay(EffectData.ZombieCooldown, function()
				ZombieRicocheted[ClosestPart] = nil
			end)
		end
	else
		BulletData.PhaseAmount = 0
	end
end

-- STREAM CHAIN EFFECT
local CurrentlyChained = {}
function BulletEffects.ChainEffect(ResultData, BulletData, PlayerShooting, IsZombie, EffectIndex)
	local Position = ResultData.Position
	if not Position then
		return
	end
	local HitPart = ResultData.Instance
	if not HitPart then
		return
	end

	local EffectData = BulletData.Effect[EffectIndex]
	if not EffectData then
		return
	end

	-- ENSURE ZOMBIE IS HIT
	if not IsZombie or not HitPart:HasTag("ServerZombieTag") then
		return
	end
	local CurrentZombieData = ZombieData:Get(HitPart)
	if not CurrentZombieData then
		return
	end

	-- END IF ZOMBIE IS DEAD
	if CurrentZombieData.Health.CurrentHealth <= 0 then
		return
	end

	-- CURRENT PLAYER DATA
	local CurrentPlayerData = PlayerData:Get(PlayerShooting)
	if not CurrentPlayerData then
		return
	end

	-- ADD A GLOBAL COOLDOWN
	local TimeSinceLastUse = tick() - (EffectData.CurrentCooldown or 0)
	if TimeSinceLastUse < EffectData.GlobalCooldown and BulletData.CurrentChain == 0 then
		return
	end
	EffectData.CurrentCooldown = tick()

	-- ADD A COOLDOWN PER ZOMBIE
	if CurrentlyChained[HitPart] then
		return
	end

	-- FIRE TO CLIENTS FOR VISUALS
	local ZombieID = CurrentZombieData.About.ID
	local LastZombieID = nil
	if ResultData.LastPart then
		-- LAST PART DATA
		local LastZombieData = ZombieData:Get(ResultData.LastPart)
		if not LastZombieData then
			return
		end

		LastZombieID = LastZombieData.About.ID
		if not LastZombieID then
			return
		end
	end
	ChainVFXEvent:FireAllClients(PlayerShooting, ZombieID, EffectData.StunTime, LastZombieID)

	-- STUN
	local StunData = CurrentZombieData.Status.Stun
	StunData.CurrentStun += EffectData.StunTime

	-- DAMAGE
	CurrentZombieData.Health.CurrentHealth -= EffectData.Damage

	-- UPDATE CURRENT PLAYER POINTS
	if CurrentPlayerData then
		-- RANDOMIZED AMOUNT OF POINTS
		CurrentPlayerData.Points.CurrentPoints += math.random(5, 10)
		-- EXTRA ON ZOMBIE KILL
		if CurrentZombieData.Health.CurrentHealth <= 0 then
			CurrentPlayerData.Points.CurrentPoints += math.random(40, 60)
			CurrentPlayerData.RoundStats.Kills += 1
			PlayerShooting:SetAttribute("Kills", CurrentPlayerData.RoundStats.Kills)
		end
		PlayerShooting:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
	end

	-- CHAIN CHECK
	BulletData.CurrentChain += 1
	if BulletData.CurrentChain > EffectData.MaxChains then
		return
	end

	-- FORMAT EXCLUDE LIST
	BulletData.ChainedHit[HitPart] = true
	local LastPart = ResultData.LastPart or HitPart
	local ExcludeList = { LastPart, HitPart }
	for ChainedPart, Bool in pairs(BulletData.ChainedHit) do
		if not Bool then
			continue
		end
		table.insert(ExcludeList, ChainedPart)
	end

	-- OVERLAP PARAMS
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterDescendantsInstances = ExcludeList
	OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	OverlapParams.CollisionGroup = "Default"
	local OverlapSize = Vector3.new(EffectData.ChainRadius, EffectData.ChainRadius, EffectData.ChainRadius)
	local OverlapResult = workspace:GetPartBoundsInBox(HitPart.CFrame, OverlapSize, OverlapParams)

	-- GET ZOMBIE PARTS
	local ClosestPart = nil
	local ClosestData = nil
	if #OverlapResult > 0 then
		-- CHECK ALL PARTS WITHIN RADIUS
		for i, Part in pairs(OverlapResult) do
			-- CHECKS
			if Part == HitPart then
				continue
			end
			if not Part:IsA("BasePart") or not Part:HasTag("ServerZombieTag") then
				continue
			end

			local ThisZombieData = ZombieData:Get(Part)
			if not ThisZombieData then
				continue
			end

			-- FIND IF CLOSEST PART
			local Distance = (Part.Position - HitPart.Position).Magnitude
			if not ClosestPart or Distance < (ClosestPart.Position - HitPart.Position).Magnitude then
				ClosestPart = Part
				-- FORMAT NEW DATA
				ClosestData = {
					LastPart = HitPart,
					Position = Part.Position,
					Instance = Part,
				}
			end
		end

		-- RECURSIVE CALL
		if ClosestData and ClosestPart ~= HitPart then
			BulletData.ChainedHit[ClosestPart] = true
			BulletEffects.ChainEffect(ClosestData, BulletData, PlayerShooting, true, EffectIndex)
		end
	end
	-- SET TO CURRENTLY CHAINED TO AVOID CHAINING AGAIN
	CurrentlyChained[HitPart] = true
	task.delay(EffectData.StunTime, function()
		CurrentlyChained[HitPart] = false
	end)
end

-- RETURN
return BulletEffects
