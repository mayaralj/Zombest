-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local DebrisService = game:GetService("Debris")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ZombieEvents = Events:WaitForChild("ZombieEvents")
local ZombieModel = ReplicatedStorage:WaitForChild("ZombieModels")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- EVENTS
local ZombieSpawn = ZombieEvents:WaitForChild("ZombieSpawn")
local ZombieDelete = ZombieEvents:WaitForChild("ZombieDelete")
local UpdateClientZombie = ZombieEvents:WaitForChild("UpdateClientZombie")
local ZombieRagPulse = ZombieEvents:WaitForChild("ZombieRagPulse")

-- MODULES
local ClientZombieData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientZombieData"))
local ClientGunDataModule = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))
local RagdollFW = require(
	ReplicatedStorage:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("Ragdoll")
		:WaitForChild("RagdollFW")
)
local ClientZombieEffects = require(script.Parent:WaitForChild("ClientZombieEffects"))

-- CLIENT ZOMBIE FOLDERS
local ClientZombieStorage = ReplicatedStorage:FindFirstChild("ClientZombieStorage")
local ClientZombies = workspace:FindFirstChild("ClientZombies")
local ZombieSFX = ReplicatedStorage:WaitForChild("ZombieSFX")

-- SETTINGS
local VERY_CLOSE = 20
local CLOSE = 60
local MEDIUM = 225
local FAR = 275

-- PLAYER POS
local function GetPlayerPosition()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return LocalPlayer.Character.HumanoidRootPart.Position
	end
	return nil
end

-- Calculate update interval based on distance
local function GetUpdateInterval(Distance)
	if Distance < VERY_CLOSE then
		return 0
	elseif Distance < CLOSE then
		return 0
	elseif Distance < MEDIUM then
		return 0
	elseif Distance < FAR then
		return -1
	else
		return -1
	end
end

-- SETUP RAGDOLL FOR ZOMBIE NPC
local function RagdollSetup(ZombieClone)
	-- GET WEAPON AND DIRECTION
	local Weapon = ZombieClone:GetAttribute("DeadByWeapon")
	local DirectionDead = ZombieClone:GetAttribute("DirectionDead")

	-- GET IMPULSE VECTOR
	local ImpulseVector
	if Weapon then
		local GunData = ClientGunDataModule.DefaultData[Weapon]
		if not GunData then
			return
		end

		ImpulseVector = GunData.Ragdoll.ImpuseVector
		if not ImpulseVector then
			return
		end
	end

	-- CREATE RAGDOLL
	RagdollFW.ActivateRagdoll(ZombieClone, ImpulseVector, DirectionDead)
end

-- UPDATE RAGDOLL INFO EVENT
ZombieRagPulse.OnClientEvent:Connect(function(ZombieID, DeadByWeapon, DirectionDead)
	-- GET CLIENT ZOMBIE DATA
	local CurrentIndex = ClientZombieData.ZombieIndex[ZombieID]
	if not CurrentIndex then
		return
	end
	local CurrentZombie = ClientZombieData.ZombieArray[CurrentIndex]
	if not CurrentZombie then
		return
	end

	-- SET ATTRIBUTES
	CurrentZombie:SetAttribute("DeadByWeapon", DeadByWeapon)
	CurrentZombie:SetAttribute("DirectionDead", DirectionDead)
end)

-- SPAWN ZOMBIE
local ZombieIDSpawned = {}
local FullySpawned = {}
ZombieSpawn.OnClientEvent:Connect(function(ZombieID, ZombieType, ZombieSubType, StartCFrame)
	-- DONT REPLICATE TWICE
	if ZombieIDSpawned[ZombieID] then
		return
	end

	-- CLONE
	local ZombieClone = ZombieModel:WaitForChild(ZombieSubType):Clone()
	if not ZombieClone then
		return
	end
	ZombieClone.PrimaryPart = ZombieClone:WaitForChild("Torso")

	local ZombieHumanoid = ZombieClone:FindFirstChild("Humanoid")
	local ZombieRoot = ZombieClone:FindFirstChild("HumanoidRootPart")
	if not ZombieHumanoid or not ZombieRoot then
		return
	end

	-- NAME AND OCCUPY ID
	ZombieClone.Name = "ClientZombie" .. ZombieID

	-- CREATE AND GET DATA
	ClientZombieData:CreateData(ZombieClone, ZombieType, ZombieSubType)
	local GetZombieData = ClientZombieData:Get(ZombieClone)
	if not GetZombieData then
		return
	end
	ZombieIDSpawned[ZombieID] = true

	-- SPAWN CLIENT ZOMBIE IN
	ZombieClone:PivotTo(StartCFrame)

	-- DESTROY HUMANOID
	ZombieHumanoid:Destroy()
	ZombieRoot.Anchored = true

	-- TAG
	ZombieClone:AddTag("ClientZombieTag")

	-- SET PROPERTIES
	for _, Part in pairs(ZombieClone:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.CanCollide = false
		end
	end
	ZombieClone.Parent = workspace:WaitForChild("ClientZombies")

	-- ANIMATIONCONTROLLER
	local AnimationController = Instance.new("AnimationController")
	AnimationController.Parent = ZombieClone

	-- ANIMATOR
	local Animator = Instance.new("Animator")
	Animator.Parent = AnimationController

	-- CLONE SOUND EFFECTS FOLDER INTO ZOMBIE
	local ClonedSFXFolder = ZombieSFX:Clone()
	ClonedSFXFolder.Parent = ZombieClone
	-- RANDOMIZE SFX COOLDOWN
	local SoundData = ClientZombieData:Get(ZombieClone).SFX
	if SoundData then
		SoundData.SFXCooldown = tick() + math.random(-25, 15)
	end

	-- ANIMATION LOADING
	local WalkAnimation = Instance.new("Animation")
	WalkAnimation.AnimationId = GetZombieData.Animations.WalkAnimation
	ContentProvider:PreloadAsync({ WalkAnimation })

	GetZombieData.Animations.CurrentAnimation = Animator:LoadAnimation(WalkAnimation)
	GetZombieData.Animations.CurrentAnimation.Looped = true
	GetZombieData.Animations.CurrentAnimation.Priority = Enum.AnimationPriority.Movement

	-- UPDATE ARRAY AND INDEX
	local ArrayIndex = #ClientZombieData.ZombieArray + 1
	ClientZombieData.ZombieArray[ArrayIndex] = ZombieClone
	ClientZombieData.ZombieIndex[ZombieID] = ArrayIndex
	ClientZombieData.GetZombieByID[ZombieID] = ZombieClone

	-- UPDATE CLONE DATA
	GetZombieData.ModelStuff.Model = ZombieClone
	GetZombieData.ModelStuff.HRP = ZombieRoot
	GetZombieData.Animations.AnimationController = AnimationController

	-- UPDATE DATA
	GetZombieData.Position.TargetCF = StartCFrame
	GetZombieData.ModelStuff.ServerZombie = ZombieID

	-- MARK AS FULLY SPAWNED
	FullySpawned[ZombieID] = true
end)

-- CLEAN UP ANIMATIONS
local function DestroyAllAnimations(ZombieClone)
	local AnimationController = ZombieClone:FindFirstChild("AnimationController")
	if not AnimationController then
		return
	end

	local Animator = AnimationController:FindFirstChildOfClass("Animator")
	if not Animator then
		return
	end

	local PlayingTracks = Animator:GetPlayingAnimationTracks()

	for _, Track in pairs(PlayingTracks) do
		Track:Stop()
		Track:Destroy()
	end

	Animator:Destroy()
	AnimationController:Destroy()
end

-- HELPER TO PLAY ZOMBIE SFX
local LastPlayedSFX = ""
local function PlayZombieSFX(ZombieClone, Data, DeathSFX)
	local SFXFolder = ZombieClone:FindFirstChild("ZombieSFX")
	if not SFXFolder then
		return
	end

	-- GET SOUND DATA AND CHECK FOR CD
	local SoundData = Data.SFX
	if not SoundData then
		return
	end
	-- NON DEATH SFX
	if not DeathSFX then
		if SoundData.SFXCooldown and tick() - SoundData.SFXCooldown < 15 then
			return
		end
		SoundData.SFXCooldown = tick()
		if SoundData.IsPlaying then
			return
		end
	end
	-- DEATH SFX
	if DeathSFX then
		-- STOP ALL CURRENT PLAYING SFX
		for _, Sound in pairs(SFXFolder:GetChildren()) do
			if Sound:IsA("Sound") and Sound.IsPlaying then
				Sound:Stop()
			end
		end
	end
	SoundData.IsPlaying = true

	-- PICK RANDOM SFX
	local SFXPicked = SFXFolder:GetChildren()[math.random(1, #SFXFolder:GetChildren())]
	while LastPlayedSFX == SFXPicked.Name do
		SFXPicked = SFXFolder:GetChildren()[math.random(1, #SFXFolder:GetChildren())]
		task.wait()
	end
	-- PLAY SFX
	SFXPicked:Play()
	LastPlayedSFX = SFXPicked.Name
	SFXPicked.Ended:Once(function()
		SoundData.IsPlaying = false
	end)
end

-- DELETE CLIENT ZOMBIE AND ITS DATA
local CleanupQueue = {}
function CleanupZombie(ZombieID)
	-- CLEAR UP SPAWN TABLES
	ZombieIDSpawned[ZombieID] = nil
	FullySpawned[ZombieID] = nil

	-- SWAP INDEXES BETWEEN CURRENT AND LAST ZOMBIE
	local CurrentIndex = ClientZombieData.ZombieIndex[ZombieID]
	if not CurrentIndex then
		warn("No index for zombie ID: " .. ZombieID)
		return
	end

	local CurrentZombie = ClientZombieData.ZombieArray[CurrentIndex]
	if not CurrentZombie then
		warn("Zombie at index " .. CurrentIndex .. " does not exist for zombie ID: " .. ZombieID)
		return
	end

	local CurrentZombieData = ClientZombieData:Get(CurrentZombie)
	if not CurrentZombieData then
		warn("No data for zombie ID: " .. ZombieID)
		CurrentZombie:Destroy()
		return
	end

	-- SWAP DATA
	ClientZombieData.ZombieIndex[ZombieID] = nil
	local LastIndex = #ClientZombieData.ZombieArray

	if CurrentIndex == LastIndex then
		ClientZombieData.ZombieArray[LastIndex] = nil
	else
		local LastZombie = ClientZombieData.ZombieArray[LastIndex]
		if LastZombie then
			ClientZombieData.ZombieArray[CurrentIndex] = LastZombie

			local LastZombieData = ClientZombieData:Get(LastZombie)
			if LastZombieData and LastZombieData.ModelStuff and LastZombieData.ModelStuff.ServerZombie then
				ClientZombieData.ZombieIndex[LastZombieData.ModelStuff.ServerZombie] = CurrentIndex
			end
		end
		ClientZombieData.ZombieArray[LastIndex] = nil
	end

	-- DELAY TO ALLOW FOR VFX AND STUFF TO FINISH
	task.delay(1, function()
		ClientZombieData.GetZombieByID[ZombieID] = nil
	end)

	-- REMOVE CLIENT DATA
	DestroyAllAnimations(CurrentZombieData.ModelStuff.Model)

	-- ENSURE PLAYER IS CLOSE ENOUGH TO SHOW RAGDOLL
	local Character = LocalPlayer.Character
	if not Character then
		CurrentZombie:Destroy()
		ClientZombieData:Remove(CurrentZombie)
		warn("No character found for zombie ID: " .. ZombieID)
		return
	end
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		CurrentZombie:Destroy()
		ClientZombieData:Remove(CurrentZombie)
		warn("No root part found for zombie ID: " .. ZombieID)
		return
	end

	-- PLAY ZOMBIE SFX
	task.spawn(function()
		PlayZombieSFX(CurrentZombie, CurrentZombieData, true)
	end)

	local RootToCheck = RootPart
	local Spectating = LocalPlayer:GetAttribute("SpectatingId")
	if Spectating then
		local SpectatingPlayer = Players:GetPlayerByUserId(Spectating)
		local CharacterSpectating = SpectatingPlayer and SpectatingPlayer.Character
		local RootPartSpectating = CharacterSpectating and CharacterSpectating:FindFirstChild("HumanoidRootPart")
		if RootPartSpectating then
			RootToCheck = RootPartSpectating
		end
	end

	-- ENSURE CLOSE ENOUGH
	local ZombieRoot = CurrentZombieData.ModelStuff.HRP
	local DistanceCheck = ZombieRoot and ((ZombieRoot.Position - RootToCheck.Position).Magnitude < 175)

	-- CHECK AMOUNT OF ZOMBIES TO DETERMINE RAGDOLL CHANCES
	if DistanceCheck then
		CurrentZombieData.ModelStuff.Model:SetAttribute("IsDead", true)
		CurrentZombieData.ModelStuff.Model.Parent = workspace:FindFirstChild("DeadCharacters")

		-- ADD NPC RAGDOLL
		RagdollSetup(CurrentZombieData.ModelStuff.Model)

		-- ADD RAGDOLL NPC FOR 5 SECONDS
		DebrisService:AddItem(CurrentZombieData.ModelStuff.Model, 3)

		-- ELSE JUST DESTROY RIGHT AWAY
	else
		CurrentZombieData.ModelStuff.Model:Destroy()
	end

	-- CLEANUP DATA
	ClientZombieData:Remove(CurrentZombie)
end

-- PLACE ZOMBIE IN CLEANUP QUEUE AND WAIT FOR TURN TO CLEANUP
local function InitiateCleanup(ZombieID)
	table.insert(CleanupQueue, ZombieID)
	while CleanupQueue[1] ~= ZombieID do
		task.wait()
	end
	while not FullySpawned[ZombieID] do
		task.wait()
	end
	pcall(CleanupZombie, ZombieID)
	table.remove(CleanupQueue, 1)
end

-- ON CLIENT EVENT TO CLEANUP CLIENT ZOMBIE
ZombieDelete.OnClientEvent:Connect(function(ZombieID)
	InitiateCleanup(ZombieID)
end)

-- HELPER TO MOVE CLIENT ZOMBIE TO SERVER
local function LerpClientToServer(Data, DT)
	-- GET CFRAME
	local CurrentCFrame = Data.ModelStuff.HRP.CFrame
	local TargetCFrame = Data.Position.TargetCF

	--GET SERVER ZOMBIE ORIENTATION AND APPLY POSITION
	local LerpAlpha = math.clamp(6.5 * DT, 0, 1)
	local LerpedCFrame = CurrentCFrame:Lerp(TargetCFrame, LerpAlpha)

	return LerpedCFrame
end

UpdateClientZombie.OnClientEvent:Connect(function(Buffer)
	local Count = buffer.len(Buffer) / 10

	for i = 0, Count - 1 do
		local Offset = i * 10
		local ID = buffer.readu16(Buffer, Offset)
		local PX = buffer.readi16(Buffer, Offset + 2) / 10
		local PY = buffer.readi16(Buffer, Offset + 4) / 10
		local PZ = buffer.readi16(Buffer, Offset + 6) / 10
		local YLOOKS = buffer.readi16(Buffer, Offset + 8) / 1000

		-- RECONSTRUCT CFRAME
		local Position = Vector3.new(PX, PY, PZ)
		local NewCFrame = CFrame.new(Position) * CFrame.Angles(0, YLOOKS, 0)

		-- UPDATE ZOMBIE
		local ArrayIndex = ClientZombieData.ZombieIndex[ID]
		if not ArrayIndex then
			continue
		end
		local ZombieClone = ClientZombieData.ZombieArray[ArrayIndex]
		if not ZombieClone then
			continue
		end
		local Data = ClientZombieData:Get(ZombieClone)
		if not Data or not Data.ModelStuff.HRP then
			continue
		end

		Data.Position.TargetCF = NewCFrame
	end
end)

-- OPTIMIZED CLIENT HEARTBEAT
RunService.Heartbeat:Connect(function(DT)
	local PlayerPos = GetPlayerPosition()
	if not PlayerPos then
		return
	end
	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

	-- BULK MOVE TO
	local BulkParts = {}
	local BulkCFrames = {}

	-- LOOP THROUGH ALL CLIENT ZOMBIES WITH DISTANCE CULLING
	for i = 1, #ClientZombieData.ZombieArray do
		local ZombieClone = ClientZombieData.ZombieArray[i]
		if not ZombieClone then
			continue
		end
		local RootPart = ZombieClone:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			continue
		end

		local Data = ClientZombieData:Get(ZombieClone)
		if not Data then
			continue
		end
		-- ID
		local ServerZombieID = Data.ModelStuff.ServerZombie

		-- DETERMINE VISUAL EFFECT
		Data.Timer.EffectTimer += DT
		if Data.Timer.EffectTimer >= 0.1 then
			ClientZombieEffects.DetermineEffect(ServerZombieID, Data, Data.Timer.EffectTimer)
			Data.Timer.EffectTimer = 0
		end

		-- CALCULATE POSITIONS AND DISTANCE
		local CurrentPos = Data.ModelStuff.HRP.Position
		local TargetPos = Data.Position.TargetCF.Position
		if not CurrentPos or not TargetPos then
			continue
		end

		-- DISTANCE FROM PLAYER OR PLAYER SPECTATING TO ZOMBIE
		local Spectating = LocalPlayer:GetAttribute("SpectatingId")
		local Distance
		if Spectating then
			local PlayerSpectating = Players:GetPlayerByUserId(Spectating)
			local CharacterSpectating = PlayerSpectating and PlayerSpectating.Character
			local RootPartSpectating = CharacterSpectating and CharacterSpectating:FindFirstChild("HumanoidRootPart")
			if RootPartSpectating then
				Distance = (TargetPos - RootPartSpectating.Position).Magnitude
			else
				Distance = (TargetPos - RootPart.Position).Magnitude
			end
		else
			Distance = (TargetPos - RootPart.Position).Magnitude
		end

		-- UPDATE INTERVAL
		local UpdateInterval = GetUpdateInterval(Distance)

		-- DISTANCE BETWEEN CLIENT AND SERVER ZOMBIE
		local ServerDistanceClient = (TargetPos - Data.ModelStuff.HRP.Position).Magnitude

		Data.Timer.TimeSinceMoved += DT
		if Data.Timer.TimeSinceMoved < UpdateInterval then
			continue
		end
		local FrameDT = Data.Timer.TimeSinceMoved
		Data.Timer.TimeSinceMoved = 0

		-- CHECK IF CLIENT ZOMBIE TOO FAR FROM SERVER ZOMBIE
		if ServerDistanceClient > 20 then
			Data.ModelStuff.HRP.CFrame = Data.Position.TargetCF
			continue
		end

		-- STOP ZOMBIES TOO FAR AWAY OR TOO CLOSE TO SERVER ZOMBIE
		if UpdateInterval < 0 and Humanoid.Health > 0 and not LocalPlayer:GetAttribute("IsKnocked") then
			ZombieClone.Parent = ClientZombieStorage
			if Data.Animations and Data.Animations.CurrentAnimation and Data.Animations.CurrentAnimation.IsPlaying then
				Data.Animations.CurrentAnimation:Stop()
			end
			continue
		else
			ZombieClone.Parent = ClientZombies
			if not Data.Animations.CurrentAnimation.IsPlaying then
				Data.Animations.CurrentAnimation:Play()
			end
		end

		-- LERP
		local NewCFrame = LerpClientToServer(Data, FrameDT)
		table.insert(BulkParts, RootPart)
		table.insert(BulkCFrames, NewCFrame)

		-- PLAY SFX
		PlayZombieSFX(ZombieClone, Data)
	end

	-- BULK MOVE TO
	if #BulkParts > 0 then
		workspace:BulkMoveTo(BulkParts, BulkCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
