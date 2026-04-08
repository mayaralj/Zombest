local ZombieSpawnerFW = {}

-- SERVICES
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local DebrisService = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local Misc = ModuleScripts:WaitForChild("Misc")
local ZombieModels = ReplicatedStorage:WaitForChild("ZombieModels")
local Events = ReplicatedStorage:WaitForChild("Events")
local ZombieEvents = Events:WaitForChild("ZombieEvents")

-- MODULES
local ZombieAIFW = require(Frameworks:WaitForChild("Zombie"):WaitForChild("ZombieAIFW"))
local RagdollFW = require(
	ReplicatedStorage:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("Ragdoll")
		:WaitForChild("RagdollFW")
)
local ZombieHealthFW = require(Frameworks:WaitForChild("Zombie"):WaitForChild("ZombieHealthFW"))
local ZombieData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("ZombieData"))
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))
local SpatialGridFW = require(Frameworks:WaitForChild("Grid"):WaitForChild("SpatialGridFW"))
local ZombieEffectFW = require(Frameworks:WaitForChild("Zombie"):WaitForChild("ZombieEffectFW"))

-- EVENTS
local ZombieSpawn = ZombieEvents:WaitForChild("ZombieSpawn")
local ZombieDelete = ZombieEvents:WaitForChild("ZombieDelete")
local UpdateClientZombie = ZombieEvents:WaitForChild("UpdateClientZombie")
local WaveEvents = Events:WaitForChild("WaveEvents")
local RoundResult = WaveEvents:WaitForChild("RoundResult")

-- VARIABLES
local ZombieID = 0
local AliveZombies = 0
local ZombiesCurrentSpawning = false
local ZombieIndex = {}
local ZombieArray = {}

-- SETTINGS
local VERY_CLOSE = 40
local CLOSE = 100
local MEDIUM = 200

-- HELPER TO GET ALIVE ZOMBIES
function ZombieSpawnerFW.GetAliveZombies()
	return AliveZombies
end

-- HELPER TO CHECK IF ZOMBIES CURRENTLY SPAWNING
function ZombieSpawnerFW.IsSpawningZombies()
	return ZombiesCurrentSpawning
end

-- REMOVE ZOMBIE FROM ARRAY AND CORRECT INDEXES
local function RemoveZombieFromArray(ZombieIDToRemove)
	local CurrentIndex = ZombieIndex[ZombieIDToRemove]
	if not CurrentIndex then
		return
	end

	ZombieIndex[ZombieIDToRemove] = nil

	local LastIndex = #ZombieArray

	if CurrentIndex == LastIndex then
		ZombieArray[LastIndex] = nil
		return
	end

	local LastZombie = ZombieArray[LastIndex]
	if LastZombie then
		ZombieArray[CurrentIndex] = LastZombie

		local LastData = ZombieData:Get(LastZombie)
		if LastData and LastData.About and LastData.About.ID then
			ZombieIndex[LastData.About.ID] = CurrentIndex
		end
	end

	ZombieArray[LastIndex] = nil
end

-- CREATE ZOMBIE MODEL IN WORKSPACE
local ServerZombiesFolder = workspace:WaitForChild("ServerZombies")
local function CreateZombieModel(SpawnPart)
	local ZombiePart = Instance.new("Part")
	if not ZombiePart then
		return
	end

	ZombieID += 1
	if ZombieID > 100000 then
		ZombieID = 0
	end

	-- DOUBLE CHECK IF A ZOMBIE OWNS THIS ID ALREADY
	while ZombieIndex[ZombieID] do
		ZombieID += 1
		task.wait()
	end

	-- SET PROPERTIES
	ZombiePart.Size = Vector3.new(4.5, 5, 4)
	ZombiePart.Anchored = true
	ZombiePart.CanCollide = false
	ZombiePart.Transparency = 1
	CollectionService:AddTag(ZombiePart, "ServerZombieTag")

	-- SET THE CFRAME TO SPAWN PART CFRAME
	ZombiePart.CFrame = SpawnPart.CFrame * CFrame.new(0, 2, 0)
	-- SET PARENT
	ZombiePart.Parent = ServerZombiesFolder

	-- ADD A TEST FACE TO PART
	--local function ColorFace(face, color)
	--	local surfaceGui = Instance.new("SurfaceGui")
	--	surfaceGui.Face = face
	--	surfaceGui.Parent = ZombiePart

	--	local frame = Instance.new("Frame")
	--	frame.Size = UDim2.new(1, 0, 1, 0)
	--	frame.BackgroundColor3 = color
	--	frame.BorderSizePixel = 0
	--	frame.Transparency = 1
	--	frame.Parent = surfaceGui

	--	return surfaceGui
	--end

	--ColorFace(Enum.NormalId.Front, Color3.new(0, 0, 0))

	-- CREATE AND GET DATA
	local ZombieCategory = ZombieData.DefaultData["Regular"]
	local ZombieTypes = {}
	for Type, _ in pairs(ZombieCategory) do
		table.insert(ZombieTypes, Type)
	end

	-- RANDOMIZE WHICH ZOMBIE DATA TYPE
	local RandomZombieType = ZombieTypes[math.random(1, #ZombieTypes)]
	ZombieData:CreateData(ZombiePart, "Regular", RandomZombieType)
	local ZombieDataGet = ZombieData:Get(ZombiePart)
	if not ZombieDataGet then
		return
	end

	-- FIRE TO CLIENTS TO SPAWN ZOMBIE
	ZombieSpawn:FireAllClients(ZombieID, "Regular", RandomZombieType, ZombiePart.CFrame)

	-- CHANGE NAME TO INCLUDE THE TYPE
	ZombiePart.Name = "ZombiePart" .. ZombieID
	ZombiePart:SetAttribute("ZombieID", ZombieID)

	-- UPDATE DATA (ID MUST BE ON THE DATA TABLE)
	ZombieDataGet.About.ID = ZombieID
	ZombieDataGet.About.ZombiePart = ZombiePart

	-- ARRAY SYSTEM
	local ArrayIndex = #ZombieArray + 1
	ZombieArray[ArrayIndex] = ZombiePart
	ZombieIndex[ZombieID] = ArrayIndex

	return ZombiePart, "Regular", RandomZombieType
end

-- SETUP ZOMBIE DEATH HANDLER
local StuckTogether = {}
local function SetupZombieDeathHandler(Zombie)
	-- SEND SIGNAL TO DELETE CLIENT ZOMBIE
	local Data = ZombieData:Get(Zombie)
	if not Data then
		return
	end

	local CurrentID = Data.About.ID
	if not CurrentID then
		return
	end

	-- GET THE TOTAL ZOMBIES AGROED TO THE TARGET AND REDUCE AS ZOMBIE IS DEAD
	if Data.Target.LastTarget then
		local TargetData = PlayerData:Get(Data.Target.LastTarget)
		if TargetData then
			TargetData.Agro.TotalZombiesAgroed -= 1
		end
		if Data.Target.LastTargetDiedConn then
			Data.Target.LastTargetDiedConn:Disconnect()
		end
	end

	-- ENSURE CLIENT ZOMBIE DOESNT GET REPLICATED
	if Data.Replication.ReplicatedTask then
		task.cancel(Data.Replication.ReplicatedTask)
	end
	if StuckTogether[Zombie] then
		StuckTogether[Zombie] = nil
	end

	-- FIRE TO DELETE CLIENT ZOMBIE
	ZombieDelete:FireAllClients(CurrentID)

	-- REMOVE FROM ARRAY, REMOVE DATA, AND REMOVE FROM GRID
	RemoveZombieFromArray(CurrentID)
	ZombieData:Remove(Zombie)
	SpatialGridFW.RemovePartFromGrid(Zombie)

	-- RESPAWN TIME
	Zombie.Parent = workspace:FindFirstChild("DeadCharacters")
	DebrisService:AddItem(Zombie, 0.25)

	-- DECREMENT ALIVE ZOMBIES
	AliveZombies -= 1
end

-- FUNCTiON TO SPAWN A ZOMBIE AND APPLY SETTINGS TO IT
function ZombieSpawnerFW.SpawnZombie(SpawnPart)
	-- GET THE PART AND TYPE
	local ZombiePart, ZombieType, ZombieSubType = CreateZombieModel(SpawnPart)
	if not ZombiePart or not ZombieType or not ZombieSubType then
		return
	end

	-- GET DATA
	local CurrentZombieData = ZombieData:Get(ZombiePart)
	if not CurrentZombieData then
		return
	end

	-- RANDOMIZE HP
	CurrentZombieData.Health.MaxHealth =
		math.random(CurrentZombieData.Health.MaxHealth - 10, CurrentZombieData.Health.MaxHealth + 40)

	-- RANDOMIZE SPEED
	CurrentZombieData.Stats.MaxSpeed =
		math.random(CurrentZombieData.Stats.MaxSpeed - 2.5, CurrentZombieData.Stats.MaxSpeed + 2.5)
	CurrentZombieData.Stats.WalkSpeed = CurrentZombieData.Stats.MaxSpeed

	-- RANDOMIZE DAMAGE
	CurrentZombieData.Damage.DamagePerHit =
		math.random(CurrentZombieData.Damage.DamagePerHit - 10, CurrentZombieData.Damage.DamagePerHit + 10)

	-- GROUND POS
	CurrentZombieData.Position.GroundPos = ZombiePart.Position.Y

	-- MAKE INVINCIBLE TILL REPLICATED
	CurrentZombieData.Health.CurrentHealth += 1000
	CurrentZombieData.Position.LastZomPos = ZombiePart.Position

	AliveZombies += 1
	local ReplicationTask = task.delay(0, function()
		-- TRACK REPLICATION
		CurrentZombieData.Health.CurrentHealth = CurrentZombieData.Health.MaxHealth
		CurrentZombieData.Replication.ReplicatedToAll = true
		CurrentZombieData.Replication.ReplicatedTask = nil
		CurrentZombieData.Replication.SpawnTime = tick()
	end)
	-- TRACK THE TASK TO CANCEL IF NEEDED
	CurrentZombieData.Replication.ReplicatedTask = ReplicationTask

	-- RETURN PART
	return ZombiePart
end

-- GROUND POSITION
local function GetGroundPosition(ZombiePart)
	local Position = ZombiePart.Position
	local RayOrigin = Vector3.new(Position.X, Position.Y + 20, Position.Z)
	local RayDirection = Vector3.new(0, -100, 0)

	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Include
	RayParams.FilterDescendantsInstances = { workspace.PhaseParts.TestMap.Base.Base }

	local RayResult = workspace:Raycast(RayOrigin, RayDirection, RayParams)

	if RayResult then
		return RayResult.Position.Y + 3.5
	else
		return Position.Y
	end
end

-- DETERMINE HOW OFTEN SERVER ZOMBIE SHOULD UPDATE
local function GetUpdateInterval(Data, TargetData, Distance, IsOnPath)
	-- UPDATE INTERVAL
	local UpdateInterval
	if Distance < VERY_CLOSE then
		UpdateInterval = 0.05
	elseif Distance < CLOSE then
		UpdateInterval = 0.05
	elseif Distance < MEDIUM then
		UpdateInterval = 0.15
	else
		UpdateInterval = 0.2
	end

	return UpdateInterval
end

-- ZOMBIE COLLISION LOGIC
local function HandleZombieCollisions(ZombiePart, TargetRoot, DT)
	local Data = ZombieData:Get(ZombiePart)
	if not Data then
		return
	end

	local TargetData = PlayerData:Get(Data.Target.LastTarget)
	if not TargetData then
		return
	end

	-- SKIP ZOMBIE COLLISIONS IF OBSTACLES ARE NEARBY
	if Data.Grid.ObstacleNearby then
		return
	end

	-- ALSO SKIP IF THIS ZOMBIE CAN'T COLLIDE (touching walls)
	if not Data.Collision.CanCollideOthers then
		return
	end

	local COLLISION_RADIUS = 5 + (TargetData.Agro.TotalZombiesAgroed / 40)
	COLLISION_RADIUS = math.clamp(COLLISION_RADIUS, 2, 10)

	-- UPDATE POSITION
	if not Data.Grid.NearbyParts then
		return
	end

	local ZombiePos = ZombiePart.Position
	local NewPos = ZombiePos
	local HasMoved = false

	local TotalOffset = Vector3.zero
	local CollisionCount = 0

	local function DoCollisionStuff(OtherPart, ClosestPoint, Distance, RepulsionForce)
		-- CHECK IF DISTANCE IS WITHIN COLLISION RADIUS
		if Distance > COLLISION_RADIUS then
			return
		end
		-- IF ALREADY TANGLED UP LET THE ONE WHO STARTED REPELLING HANDLE IT TO PREVENT INFINITE COLLISION
		if
			(StuckTogether[ZombiePart] and StuckTogether[ZombiePart][OtherPart])
			or (StuckTogether[OtherPart] and StuckTogether[OtherPart][ZombiePart])
		then
			return
		end

		-- GET STARTING WEIGHT AND DIRECTION
		local Weight = (COLLISION_RADIUS - Distance) / COLLISION_RADIUS
		local Direction = (ZombiePos - ClosestPoint)
		if Direction.Magnitude <= 0.1 then
			local DirectionToPlayer = (TargetRoot.Position - ZombiePos)
			if DirectionToPlayer.Magnitude >= 0.1 then
				Direction = -DirectionToPlayer.Unit + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
			end

			-- INCREASE REPULSION WEIGHT
			if TargetData.Agro.TotalZombiesAgroed > 0 then
				Weight *= 1.5 + (50 / TargetData.Agro.TotalZombiesAgroed)
				Weight = math.clamp(Weight, 1.5, 3.5)
			end

			-- STORE THAT THE 2 ZOMBIES ARE STUCK
			if not StuckTogether[ZombiePart] then
				StuckTogether[ZombiePart] = {}
			end
			StuckTogether[ZombiePart][OtherPart] = true
			-- CLEANUP AFTER SMALL DELAY
			task.delay(0.25, function()
				if StuckTogether[ZombiePart] then
					StuckTogether[ZombiePart][OtherPart] = nil
				end
				StuckTogether[ZombiePart] = nil
			end)
		end
		-- ENSURE DIRECTION IS IN UNIT
		if Direction.Magnitude > 0.1 then
			Direction = Direction.Unit
		end

		-- ADD REPULSION VECTOR TO AVERAGE THEM OUT LATER
		TotalOffset += Direction * Weight * COLLISION_RADIUS

		-- INCREMENT COLLISION COUNT
		CollisionCount += 1
	end

	for _, NearbyData in ipairs(Data.Grid.NearbyParts) do
		local OtherPart = NearbyData.OtherPart
		local ClosestPoint = NearbyData.ClosestPoint
		local Distance = NearbyData.Distance

		if not OtherPart:HasTag("ServerZombieTag") then
			continue
		end
		local OtherPartData = ZombieData:Get(OtherPart)
		if not OtherPartData then
			continue
		end

		-- Both zombies must be able to collide AND no obstacles nearby
		if OtherPartData.Collision.CanCollideOthers and not OtherPartData.Grid.ObstacleNearby then
			DoCollisionStuff(OtherPart, ClosestPoint, Distance, 1)
		end
	end

	-- GET NEW POS TO DETECT IF ITS MOVING CLOSER TO PLAYER
	if CollisionCount > 0 and TotalOffset ~= Vector3.zero then
		local AverageOffset = TotalOffset / CollisionCount
		NewPos = ZombiePos + AverageOffset
		NewPos = Vector3.new(NewPos.X, Data.Position.GroundPos, NewPos.Z)
	end

	-- RETURN IF MOVING CLOSER TO PLAYER
	if (NewPos - TargetRoot.Position).Magnitude < (ZombiePos - TargetRoot.Position).Magnitude then
		return
	end

	-- RETURN OFFSET
	if CollisionCount > 0 and TotalOffset ~= Vector3.zero then
		-- AVERAGE OFFSET AND GROUND THE Y
		local AverageOffset = TotalOffset / CollisionCount
		AverageOffset = Vector3.new(AverageOffset.X, 0, AverageOffset.Z)

		return AverageOffset
	end
end

-- START MOVEMENT LOOP FOR ZOMBIES
local function ZombieLoop()
	local FrameToPathfind = 0
	local PathFindCycle = 4 -- this determines how many pathfinds per frame rn its alivezombies/2

	RunService.Heartbeat:Connect(function(DT)
		-- CHECK IF ANY ZOMBIES EVEN EXIST FIRST
		if AliveZombies <= 0 then
			task.wait(0.5)
			return
		end

		-- BULK MOVE TO TABLES
		local BulkParts = {}
		local BulkCFrames = {}

		-- BULK CLIENT UPDATES
		local ClientZombieUpdates = {}
		for _, Player in Players:GetPlayers() do
			ClientZombieUpdates[Player] = {}
		end

		-- LOOP THROUGH ALL ZOMBIES AND UPDATE
		for i = 1, #ZombieArray do
			-- DATA AND ZOMBIE PART
			local ZombiePart = ZombieArray[i]
			if not ZombiePart then
				continue
			end
			local Data = ZombieData:Get(ZombiePart)
			if not Data then
				continue
			end

			-- CHECK IF PATHFINDING SHOULD BE ALLOWED
			local ZombieFrame = (i - 1) % PathFindCycle
			local CanPathFind = ZombieFrame == FrameToPathfind

			-- CHECK IF ZOMBIE STILL ALIVE/EXISTS
			if not (ZombiePart and ZombiePart.Parent and Data.Health.CurrentHealth > 0) then
				SetupZombieDeathHandler(ZombiePart)
				continue
			end

			-- IF ZOMBIE IS IN AN INVALID POSITION
			if ZombiePart.Position.Y < -1000 or ZombiePart.Position.Y > 1000 then
				warn("Invalid Zombie Position")
				SetupZombieDeathHandler(ZombiePart)
				continue
			end

			-- HP
			if Data.Health.CurrentHealth < Data.Health.LastHealth then
				Data.Health.LastHealth = Data.Health.CurrentHealth
			end

			-- BURN DAMAGE
			local BurnData = Data.Status.Burn
			if BurnData.BurnTime > 0 then
				ZombieEffectFW.ZombieBurn(Data, ZombiePart, DT)
			end

			-- HANDLE STUN
			local StunData = Data.Status.Stun
			if StunData.CurrentStun > 0 then
				StunData.CurrentStun -= DT
				continue
			elseif StunData.CurrentStun <= 0 then
				StunData.CurrentStun = 0
			end

			-- INCREMENT TIME SINCE MOVED
			Data.Position.TimeSinceMoved += DT
			-- CHECK POSITION
			local MovedDistance = (ZombiePart.Position - (Data.Position.LastZomPos or ZombiePart.Position)).Magnitude
			if MovedDistance >= 0.01 then
				Data.Position.TimeSinceMoved = 0
			end
			Data.Position.LastZomPos = ZombiePart.Position

			-- UPDATE DATA
			local CooldownData = Data.Cooldowns
			CooldownData.SendToClientCD += DT
			if CooldownData.SendToClientCD > 0.05 and Data.Position.TimeSinceMoved < 0.5 then
				-- RESET CD
				CooldownData.SendToClientCD = 0

				-- PREPARE DATA FOR BUFFER
				local Position = ZombiePart.Position
				local LookVector = ZombiePart.CFrame.LookVector
				local YLook = math.atan2(-LookVector.X, -LookVector.Z)

				-- UPDATE PLAYERS
				for _, Player in Players:GetPlayers() do
					-- ONLY CHECK FOR DISTANCE IF CHARACTER EXISTS
					local Character = Player.Character
					if Character then
						local RootPart = Character:FindFirstChild("HumanoidRootPart")
						if not RootPart then
							continue
						end
						local Humanoid = Character:FindFirstChild("Humanoid")
						if not Humanoid then
							continue
						end

						-- CALCULATE IF CLOSE ENOUGH (AS LONG AS NOT DEAD OR NOT KNOCKED)
						if Humanoid.Health > 0 and not Player:GetAttribute("IsKnocked") then
							if (ZombiePart.Position - RootPart.Position).Magnitude > 225 then
								continue
							end
						end
					end

					-- ADD RAW DATA TO TABLE
					table.insert(ClientZombieUpdates[Player], {
						ID = Data.About.ID,
						PX = math.floor(Position.X * 10),
						PY = math.floor(Position.Y * 10),
						PZ = math.floor(Position.Z * 10),
						RY = math.floor(YLook * 1000),
					})
				end
			end

			-- GET TARGET AND TARGET COMPONENTS
			local Target, ClosestDistance = ZombieAIFW.GetClosestPlayer(ZombiePart, false)
			if not Target then
				continue
			end

			-- UPDATE DISTANCE
			Data.Target.ClosestDistance = ClosestDistance

			local TargetRoot = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
			local TargetHumanoid = Target.Character and Target.Character:FindFirstChild("Humanoid")
			if not TargetRoot or not TargetHumanoid then
				continue
			end
			if TargetHumanoid.Health <= 0 then
				continue
			end

			-- TARGETDATA
			local TargetData = PlayerData:Get(Target)
			if not TargetData then
				continue
			end
			if TargetData.Knockdown.IsKnocked then
				continue
			end

			-- IF NO LAST TARGET
			if not Data.Target.LastTarget then
				TargetData.Agro.TotalZombiesAgroed += 1
				Data.Target.LastTarget = Target

				if TargetHumanoid then
					Data.Target.LastTargetDiedConn = TargetHumanoid.Died:Connect(function()
						TargetData.Cooldowns.PlayerHitCooldown = nil
						TargetData.Agro.TotalZombiesAgroed -= 1
						Data.Target.LastTarget = nil
					end)
				end
			end

			-- CHECK IF TARGET CHANGED OR DIED
			if Target ~= Data.Target.LastTarget then
				if Data.Target.LastTargetDiedConn then
					Data.Target.LastTargetDiedConn:Disconnect()
				end

				local LastTargetData = PlayerData:Get(Data.Target.LastTarget)
				if LastTargetData then
					LastTargetData.Agro.TotalZombiesAgroed -= 1
				end
				TargetData.Agro.TotalZombiesAgroed += 1
				Data.Target.LastTarget = Target

				if TargetHumanoid then
					Data.Target.LastTargetDiedConn = TargetHumanoid.Died:Connect(function()
						TargetData.Cooldowns.PlayerHitCooldown = nil
						TargetData.Agro.TotalZombiesAgroed -= 1
					end)
				end
			end

			-- SKIP FRAMES
			local UpdateInterval
			UpdateInterval = GetUpdateInterval(Data, TargetData, ClosestDistance, Data.Path.IsWalkingOnPath or false)
			Data.Frame.FrameSkip += DT
			if Data.Frame.FrameSkip < UpdateInterval then
				continue
			end

			local FrameDT = Data.Frame.FrameSkip
			Data.Frame.FrameSkip = 0

			-- CHECK FOR OBSTACLES FOR PATHFINDING
			local NoObstacleDetected = ZombieAIFW.NoObstacleBetweenTargetAndZombie(Target, ZombiePart)
			-- UPDATE COOLDOWNS
			if NoObstacleDetected then
				Data.Cooldowns.NoObstacleTimer += FrameDT
			else
				Data.Cooldowns.NoObstacleTimer = 0
			end
			Data.Path.PathGenerationCD += FrameDT

			-- GET LAST TARGET POSITION
			if not Data.Target.LastTargetPosition then
				Data.Target.LastTargetPosition = TargetRoot.Position
			end

			-- ATTACK TARGET
			ZombieAIFW.ZombieAttack(ZombiePart, Target, ClosestDistance)

			-- CHANGE SPEED DEPENDING ON HEALTH
			ZombieHealthFW.ChangeSpeed(ZombiePart)

			-- DETECT WHERE GROUND IS BUT ON CD
			Data.Cooldowns.GroundRaycastCD += FrameDT
			if Data.Cooldowns.GroundRaycastCD > 2 or not Data.Path.FirstPathGenerated then
				Data.Position.GroundPos = GetGroundPosition(ZombiePart)
				Data.Cooldowns.GroundRaycastCD = 0
			end

			-- FORCE ZOMBIEPART TO BE A CERTAIN DISTANCE FROM TARGET
			local DistanceToTarget = (TargetRoot.Position - ZombiePart.Position).Magnitude
			if DistanceToTarget < 3 then
				local DirectionFromTarget = (ZombiePart.Position - TargetRoot.Position).Unit

				local DesiredPosition = TargetRoot.Position + (DirectionFromTarget * DistanceToTarget)

				local NewPosition = Vector3.new(DesiredPosition.X, Data.Position.GroundPos or 4, DesiredPosition.Z)

				-- ADD A LTTLE TWITCH AND ADD TO NEW POS
				local TwitchOffset = Vector3.new((math.random(-1, 1) / 100), 0, (math.random(-1, 1) / 100))
				NewPosition = NewPosition + TwitchOffset

				local NewCFrame =
					CFrame.lookAt(NewPosition, Vector3.new(TargetRoot.Position.X, NewPosition.Y, TargetRoot.Position.Z))
				--ZombiePart.CFrame = NewCFrame
				table.insert(BulkParts, ZombiePart)
				table.insert(BulkCFrames, NewCFrame)
				continue
			end

			-- DIRECT MOVEMENT (NO OBSTACLES)
			if (Data.Cooldowns.NoObstacleTimer > 0) or Data.Position.TimeSinceMoved > 1 then
				local Direction = (TargetRoot.Position - ZombiePart.Position).Unit
				local Step = Direction * Data.Stats.WalkSpeed * FrameDT
				local TargetPosition = ZombiePart.Position + Step

				-- MOVEMENT AND COLLISION
				local MoveCollidedPos, FinalDirection = SpatialGridFW.MoveWithCollisions(ZombiePart, TargetPosition)
				local ZombieCollidedPos = HandleZombieCollisions(ZombiePart, TargetRoot, FrameDT)

				local FinalPos = MoveCollidedPos
				if ZombieCollidedPos then
					local RepelledPos = MoveCollidedPos + ZombieCollidedPos
					local LerpAlpha = math.clamp(1.5 * FrameDT, 0, 1)
					FinalPos = MoveCollidedPos:Lerp(RepelledPos, LerpAlpha)
				end
				local NewCFrame = CFrame.new(FinalPos, FinalPos + FinalDirection)
				table.insert(BulkParts, ZombiePart)
				table.insert(BulkCFrames, NewCFrame)
				--ZombiePart.CFrame = NewCFrame

				Data.Target.LastTargetPosition = TargetRoot.Position
				Data.Path.CurrentPath = nil
				Data.Path.IsWalkingOnPath = false
				Data.Path.FirstPathGenerated = true
				continue

			-- PATHFINDING MOVEMENT (WITH OBSTACLES)
			else
				-- GENERATE NEW PATH IF NEEDED
				if
					Data.Path.PathGenerationCD >= 1
					or not Data.Path.FirstPathGenerated
					or (TargetRoot.Position - Data.Target.LastTargetPosition).Magnitude >= 50
					or not Data.Path.CurrentPath
				then
					if CanPathFind and not Data.Path.IsWalkingOnPath then
						Data.Path.CurrentWaypointIndex = 1
						Data.Path.CurrentPath = ZombieAIFW.CreatePath(ZombiePart, Target)
						Data.Path.PathGenerationCD = 0
						Data.Path.FirstPathGenerated = true
						Data.Target.LastTargetPosition = TargetRoot.Position
					end
				end
				-- CHECK IF PATH EXISTS
				if not Data.Path.CurrentPath then
					continue
				end

				-- WAYPOINT MOVEMENT
				local Waypoints = Data.Path.CurrentPath:GetWaypoints()
				local CurrentWaypoint = Waypoints[Data.Path.CurrentWaypointIndex]

				if CurrentWaypoint then
					-- 2D (3d causing issues)
					local WaypointPos2D = Vector2.new(CurrentWaypoint.Position.X, CurrentWaypoint.Position.Z)
					local ZombiePos2D = Vector2.new(ZombiePart.Position.X, ZombiePart.Position.Z)
					local WaypointDistance = (WaypointPos2D - ZombiePos2D).Magnitude

					-- 3D HERE THO
					local DirectionToWaypoint = (CurrentWaypoint.Position - ZombiePart.Position).Unit

					-- CHECK TO INCREASE WAYPOINT INDEX
					if WaypointDistance <= 4 then
						Data.Path.CurrentWaypointIndex += 1

						-- CHECK IF NO WAYPOINTS LEFT
						if Data.Path.CurrentWaypointIndex > #Waypoints then
							Data.Path.CurrentPath = ZombieAIFW.CreatePath(ZombiePart, Target)
							Data.Path.CurrentWaypointIndex = 1
							Data.Path.PathGenerationCD = 0
							Data.Target.LastTargetPosition = TargetRoot.Position
							Data.Path.FirstPathGenerated = true
						end
						continue

					-- MOVE TO CURRENT WAYPOINT
					else
						-- MOVE FASTER ON A PATH
						local Step = DirectionToWaypoint * Data.Stats.WalkSpeed * FrameDT
						local TargetPosition = ZombiePart.Position + Step

						-- COLLISION MOVE
						local FinalPos, FinalDirection = SpatialGridFW.MoveWithCollisions(ZombiePart, TargetPosition)
						local NewCFrame = CFrame.new(FinalPos, FinalPos + FinalDirection)
						--ZombiePart.CFrame = NewCFrame

						table.insert(BulkParts, ZombiePart)
						table.insert(BulkCFrames, NewCFrame)

						Data.Path.IsWalkingOnPath = true
					end
				end
			end
		end
		FrameToPathfind = (FrameToPathfind + 1) % PathFindCycle

		-- BULK MOVE TO
		if #BulkParts > 0 then
			workspace:BulkMoveTo(BulkParts, BulkCFrames, Enum.BulkMoveMode.FireCFrameChanged)
		end

		-- BULK UPDATES
		for Player, CurrentZombieData in ClientZombieUpdates do
			local Count = #CurrentZombieData
			if Count > 0 then
				-- CREATE BUFFER (10 bytes per zombie)
				local Buffer = buffer.create(Count * 10)

				for i, Info in ipairs(CurrentZombieData) do
					local Offset = (i - 1) * 10
					buffer.writeu16(Buffer, Offset, Info.ID)
					buffer.writei16(Buffer, Offset + 2, Info.PX)
					buffer.writei16(Buffer, Offset + 4, Info.PY)
					buffer.writei16(Buffer, Offset + 6, Info.PZ)
					buffer.writei16(Buffer, Offset + 8, Info.RY)
				end

				-- SEND BUFFER TO CLIENT
				UpdateClientZombie:FireClient(Player, Buffer)
			end
		end
	end)
end

-- FUNCTION TO PICK PLAYER AND PICK CLOSEST SPAWN POINT
local SpawnPoints = workspace:WaitForChild("ZombieSpawners"):GetChildren()
local function ClosestSpawnPoint()
	local PlayerCount = #Players:GetPlayers()
	local RandomPlayer = Players:GetPlayers()[math.random(1, PlayerCount)]
	if not RandomPlayer then
		warn("Random PLayer not found")
		return workspace:WaitForChild("ZombieSpawners").GetChildren()[1]
	end

	-- SETTINGS
	local MinDistanceFromPlayer = 50

	-- LOOP THROUGH SPAWNPOINTS
	local ClosestDistance
	local ClosestSpawn = math.huge
	for _, SpawnPoint in ipairs(SpawnPoints) do
		-- CHECK DISTANCE TO PLAYER
		local Character = RandomPlayer.Character
		if not Character then
			continue
		end
		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			continue
		end

		-- CHECK DISTANCE
		local Distance = (SpawnPoint.Position - RootPart.Position).Magnitude

		if (not ClosestDistance or Distance < ClosestDistance) and Distance > MinDistanceFromPlayer then
			ClosestDistance = Distance
			ClosestSpawn = SpawnPoint
		end
	end
	return ClosestSpawn
end

-- FUNCTION TO MASS SPAWN ZOMBIES AT CORRECT LOCATION
local CurrentSpawnTask
function ZombieSpawnerFW.StopSpawning()
	if CurrentSpawnTask then
		task.cancel(CurrentSpawnTask)
	end
end
function ZombieSpawnerFW.SpawnZombies(Count)
	if AliveZombies > 0 then
		warn(AliveZombies, "Zombies are still currently alive")
	end

	local AllowedZombies = math.floor(Count / 4)
	local Spawned = 0

	-- START LOOPS
	CurrentSpawnTask = task.spawn(function()
		ZombiesCurrentSpawning = true
		while Spawned < Count do
			if AliveZombies < AllowedZombies then
				task.wait(0.001)
				local SpawnPart = ClosestSpawnPoint()
				ZombieSpawnerFW.SpawnZombie(SpawnPart)
				Spawned += 1
			else
				task.wait(0.5)
			end
		end
		ZombiesCurrentSpawning = false
		while AliveZombies > 0 do
			task.wait(0.5)
		end
		RoundResult:Fire(true)
	end)
end
-- START LOOP
task.spawn(ZombieLoop)

-- FUNCTION TO KILL ALL ZOMBIES
function ZombieSpawnerFW.KillAllZombies()
	for i = 1, #ZombieArray do
		local ZombiePart = ZombieArray[i]
		if not ZombiePart then
			continue
		end
		local Data = ZombieData:Get(ZombiePart)
		if not Data then
			continue
		end

		Data.Health.CurrentHealth = 0
	end
end

return ZombieSpawnerFW
