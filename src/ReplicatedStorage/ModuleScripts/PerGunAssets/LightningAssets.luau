local LightningAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")


-- FOLDERS
local Frameworks= ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")


-- MODULE
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))
local ClientZombieDataModule = require(Client:WaitForChild("ClientZombieData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))
local RockModule = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Rock"):WaitForChild("RockModule"))
local ScreenShakeModule = require(Frameworks:WaitForChild("Screenshake"):WaitForChild("ScreenShake"))
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))



-- EVENTS
local TimeChange = Events:WaitForChild("MapEvents"):WaitForChild("TimeChange")



-- EQUIP ASSETS
function LightningAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	local RootPart = PlayerEquipped.Character or PlayerEquipped.CharacterAdded:Wait()
	if not RootPart then return end

	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end


	local Character = PlayerEquipped.Character or PlayerEquipped.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	
	
	-- CLEANUP
	local function FullCleanup()
		-- DISCONNECT CONNECTIONS
		if Connections[PlayerEquipped]["ArmVFXMarker"] then
			Connections[PlayerEquipped]["ArmVFXMarker"]:Disconnect()
			Connections[PlayerEquipped]["ArmVFXMarker"] = nil
		end
		if Connections[PlayerEquipped]["BodyVFXMarker"] then
			Connections[PlayerEquipped]["BodyVFXMarker"]:Disconnect()
			Connections[PlayerEquipped]["BodyVFXMarker"] = nil
		end
		if Connections[PlayerEquipped]["CharacterRemoving_Equip"] then
			Connections[PlayerEquipped]["CharacterRemoving_Equip"]:Disconnect()
			Connections[PlayerEquipped]["CharacterRemoving_Equip"] = nil
		end
		if Connections[PlayerEquipped]["EquippedGunChanged_Equip"] then
			Connections[PlayerEquipped]["EquippedGunChanged_Equip"]:Disconnect()
			Connections[PlayerEquipped]["EquippedGunChanged_Equip"] = nil
		end

		-- CLEANUP TRACKS
		if Tracks[PlayerEquipped]["EquipSFX"] then
			Tracks[PlayerEquipped]["EquipSFX"]:Destroy()
			Tracks[PlayerEquipped]["EquipSFX"] = nil
		end

		if Tracks[PlayerEquipped]["EquipAnimation"] then
			Tracks[PlayerEquipped]["EquipAnimation"]:Stop()
			Tracks[PlayerEquipped]["EquipAnimation"]:Destroy()
			Tracks[PlayerEquipped]["EquipAnimation"] = nil
		end
	end
	
	-- INCASE
	FullCleanup()


	-- CREATE SOUNDS
	local EquipSFX = Instance.new("Sound")
	EquipSFX.SoundId = DefaultData.SoundFX.EquipSFX
	EquipSFX.Name = "EquipSFX"
	EquipSFX.Volume = 0.25
	EquipSFX.Parent = RootPart
	Tracks[PlayerEquipped]["EquipSFX"] = EquipSFX



	-- CREATE ANIMATION
	local EquipAnimation = Instance.new("Animation")
	EquipAnimation.AnimationId = DefaultData.Animations.EquipAnimation
	local EquipTrack = Animator:LoadAnimation(EquipAnimation)
	EquipTrack.Name = "EquipAnimation"
	EquipTrack.Looped = false
	EquipTrack.Priority = Enum.AnimationPriority.Action4
	Tracks[PlayerEquipped]["EquipAnimation"] = EquipTrack


	-- PLAY TRACK
	local EquipVFX
	if DefaultData.VFX.EquipVFX then
		EquipVFX = ReplicatedStorage.GunVFX:FindFirstChild("Lightning"):FindFirstChild(DefaultData.VFX.EquipVFX):Clone()
	end
	if not EquipVFX then return end
	EquipVFX.Parent = RootPart
	EquipTrack:Play()

	Connections[PlayerEquipped]["ArmVFXMarker"] = EquipTrack:GetMarkerReachedSignal("ArmVFX"):Connect(function()
		EquipSFX:Play()
		for _, VFX in pairs(EquipVFX:GetDescendants()) do
			if VFX:IsA("ParticleEmitter") and VFX.Name == "Arm" then
				VFX:Emit(VFX:GetAttribute("EmitCount"))
			end
		end
	end)

	Connections[PlayerEquipped]["BodyVFXMarker"] = EquipTrack:GetMarkerReachedSignal("BodyVFX"):Connect(function()
		for _, VFX in pairs(EquipVFX:GetDescendants()) do
			if VFX:IsA("ParticleEmitter") and VFX.Name == "Body" then
				VFX:Emit(VFX:GetAttribute("EmitCount"))
			end
		end
	end)
	Debris:AddItem(EquipVFX, 2)
	


	Connections[PlayerEquipped]["CharacterRemoving_Equip"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged_Equip"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
			FullCleanup()
		end
	end)
	
	return true
end



-- IDLE ASSETS
function LightningAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	local RootPart = PlayerEquipped.Character or PlayerEquipped.CharacterAdded:Wait()
	if not RootPart then return end

	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end


	local Character = PlayerEquipped.Character or PlayerEquipped.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	

	-- CLEANUP
	local function FullCleanup()
		-- DISCONNECT CONNECTIONS
		if Connections[PlayerEquipped]["CharacterRemoving_Idle"] then
			Connections[PlayerEquipped]["CharacterRemoving_Idle"]:Disconnect()
			Connections[PlayerEquipped]["CharacterRemoving_Idle"] = nil
		end
		if Connections[PlayerEquipped]["EquippedGunChanged_Idle"] then
			Connections[PlayerEquipped]["EquippedGunChanged_Idle"]:Disconnect()
			Connections[PlayerEquipped]["EquippedGunChanged_Idle"] = nil
		end

		-- CLEANUP TRACKS
		if Tracks[PlayerEquipped]["IdleAnimation"] then
			Tracks[PlayerEquipped]["IdleAnimation"]:Stop()
			Tracks[PlayerEquipped]["IdleAnimation"]:Destroy()
			Tracks[PlayerEquipped]["IdleAnimation"] = nil
		end
	end
	
	
	-- INCASE
	FullCleanup()
	

	local IdleAnimation = Instance.new("Animation")
	IdleAnimation.AnimationId = DefaultData.Animations.IdleAnimation
	local IdleTrack = Animator:LoadAnimation(IdleAnimation)
	IdleTrack.Name = "IdleAnimation"
	IdleTrack.Priority = Enum.AnimationPriority.Idle
	IdleTrack.Looped = true
	Tracks[PlayerEquipped]["IdleAnimation"] = IdleTrack
	Tracks[PlayerEquipped]["IdleAnimation"]:Play()


	Connections[PlayerEquipped]["CharacterRemoving_Idle"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged_Idle"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
			FullCleanup()
		end
	end)
	
	return true
end




-- BUNCH OF RUN ASSETS
-- RUN VFX
local function RunVFX(DefaultData, RootPart)
	local GunVFXFolder = ReplicatedStorage.GunVFX
	local RunVFX = DefaultData.VFX.RunVFX
	local LightningAuraVFX = GunVFXFolder:WaitForChild("Lightning"):FindFirstChild(RunVFX):Clone()
	LightningAuraVFX.Parent = RootPart


	for _, Particle in ipairs(LightningAuraVFX:GetDescendants()) do
		if Particle:IsA("ParticleEmitter") then
			Particle.Enabled = false
			Particle.Transparency = NumberSequence.new(0)
			Particle:Emit(1)
		end
	end
	Debris:AddItem(LightningAuraVFX, 2)
end



-- RUN LAND VFX
local function RunLandVFX(PlayerViewing, PlayerShaking, Character, RootPart, DefaultData, LeftOrRight)
	-- WHICH LEG TO PLACE VFX
	local Leg
	if LeftOrRight == "Left" then
		Leg = Character:FindFirstChild("Left Leg")
	else
		Leg = Character:FindFirstChild("Right Leg")
	end

	-- VFX CLONE
	local RunLandVFX = DefaultData.VFX.RunLandVFX
	local LightningRunVFX = ReplicatedStorage.GunVFX:WaitForChild("Lightning"):FindFirstChild(RunLandVFX):FindFirstChild(RunLandVFX):Clone()

	-- RAY PARAMS
	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = {Character}
	RayParams.FilterType = Enum.RaycastFilterType.Exclude
	RayParams.IgnoreWater = true

	-- RAY RESULT
	local RayResult = workspace:Raycast(Leg.Position, Vector3.new(0, -5, 0), RayParams)
	if not RayResult then return end

	-- UPDATE CFRAME
	local NewCFrame = if RayResult then CFrame.new(RayResult.Position + Vector3.new(0,0.15,0)) else CFrame.new(Leg.Position + Vector3.new(0, -1, 0))
	LightningRunVFX.CFrame = NewCFrame


	-- LOOP THROUGH PARTICLES
	for _, Particle in ipairs(LightningRunVFX:GetDescendants()) do
		if Particle:IsA("ParticleEmitter") then
			Particle.Enabled = false
			Particle.Transparency = NumberSequence.new(0)
			Particle:Emit(Particle.Rate)
		end
	end

	local RockDebrisSettings = {
		Part = RayResult.Instance,
		Position = RayResult.Position,
		RockAmount = 2,
		Size = 0.25,
		HorizontalStrength = 10,
		VerticalStrength = 15,
		Time = 1,
	}

	-- BUNCH OF STUFF
	Debris:AddItem(LightningRunVFX, 5)
	LightningRunVFX.Parent = workspace.ActiveVFX
	RockModule.RockDebris(RockDebrisSettings)
	RunVFX(DefaultData, RootPart)
	ScreenShakeModule.ApplyScreenShake(true, PlayerViewing, PlayerShaking, 0.1, 100)
end



-- MOVEMENT ASSETS
function LightningAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	-- TRACKS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end


	-- CONNECTIONS
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	-- CHARACTER
	local Character = PlayerRequired.Character or PlayerRequired.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	-- ANIMATOR
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	

	-- CLEANUP
	local function FullCleanup()
		-- CANCEL TASKS
		if Connections[PlayerRequired]["StopDebounceTask"] then
			task.cancel(Connections[PlayerRequired]["StopDebounceTask"])
			Connections[PlayerRequired]["StopDebounceTask"] = nil
		end

		if Connections[PlayerRequired]["WalkLeft"] then
			Connections[PlayerRequired]["WalkLeft"]:Disconnect()
			Connections[PlayerRequired]["WalkLeft"] = nil
		end
		if Connections[PlayerRequired]["WalkRight"] then
			Connections[PlayerRequired]["WalkRight"]:Disconnect()
			Connections[PlayerRequired]["WalkRight"] = nil
		end
		if Connections[PlayerRequired]["RunLeft"] then
			Connections[PlayerRequired]["RunLeft"]:Disconnect()
			Connections[PlayerRequired]["RunLeft"] = nil
		end
		if Connections[PlayerRequired]["RunRight"] then
			Connections[PlayerRequired]["RunRight"]:Disconnect()
			Connections[PlayerRequired]["RunRight"] = nil
		end
		if Connections[PlayerRequired]["CharacterRemoving_Walk"] then
			Connections[PlayerRequired]["CharacterRemoving_Walk"]:Disconnect()
			Connections[PlayerRequired]["CharacterRemoving_Walk"] = nil
		end
		if Connections[PlayerRequired]["EquippedGunChanged_Walk"] then
			Connections[PlayerRequired]["EquippedGunChanged_Walk"]:Disconnect()
			Connections[PlayerRequired]["EquippedGunChanged_Walk"] = nil
		end
		if Connections[PlayerRequired]["MoveHeartbeat"] then
			Connections[PlayerRequired]["MoveHeartbeat"]:Disconnect()
			Connections[PlayerRequired]["MoveHeartbeat"] = nil
		end


		-- CLEANUP TRACKS
		if Tracks[PlayerRequired]["WalkAnimation"] then
			Tracks[PlayerRequired]["WalkAnimation"]:Stop()
			Tracks[PlayerRequired]["WalkAnimation"]:Destroy()
			Tracks[PlayerRequired]["WalkAnimation"] = nil
		end
		if Tracks[PlayerRequired]["RunAnimation"] then
			Tracks[PlayerRequired]["RunAnimation"]:Stop()
			Tracks[PlayerRequired]["RunAnimation"]:Destroy()
			Tracks[PlayerRequired]["RunAnimation"] = nil
		end
		if Tracks[PlayerRequired]["RunSFX"]  then
			Tracks[PlayerRequired]["RunSFX"]:Stop()
			Tracks[PlayerRequired]["RunSFX"]:Destroy()
			Tracks[PlayerRequired]["RunSFX"] = nil
		end
		if Tracks[PlayerRequired]["RunSFX2"] then
			Tracks[PlayerRequired]["RunSFX2"]:Stop()
			Tracks[PlayerRequired]["RunSFX2"]:Destroy()
			Tracks[PlayerRequired]["RunSFX2"] = nil
		end
		if Tracks[PlayerRequired]["WalkSFX"] then
			Tracks[PlayerRequired]["WalkSFX"]:Stop()
			Tracks[PlayerRequired]["WalkSFX"]:Destroy()
			Tracks[PlayerRequired]["WalkSFX"] = nil
		end

		if Tracks[PlayerRequired]["DustVFX"] then
			Tracks[PlayerRequired]["DustVFX"]:Destroy()
			Tracks[PlayerRequired]["DustVFX"] = nil
		end
	end
	
	-- INCASE
	FullCleanup()


	-- ANIMATIONS
	local WalkAnimId = DefaultData.Animations.WalkAnimation
	if not WalkAnimId then return end
	local RunAnimID = DefaultData.Animations.RunAnimation
	if not RunAnimID then return end


	-- CREATE SOUNDS
	local RunSFX = Instance.new("Sound")
	RunSFX.SoundId = DefaultData.SoundFX.RunSFX
	RunSFX.Parent = RootPart
	RunSFX.Name = "RunSFX"
	RunSFX.Looped = false
	Tracks[PlayerRequired]["RunSFX"] = RunSFX


	local RunSFX2 = Instance.new("Sound")
	RunSFX2.SoundId = DefaultData.SoundFX.RunSFX2
	RunSFX2.Parent = RootPart
	RunSFX2.Name = "RunSFX2"
	RunSFX2.Looped = false
	Tracks[PlayerRequired]["RunSFX2"] = RunSFX2



	-- CREATE ANIMATION
	local WalkAnimation = Instance.new("Animation")
	WalkAnimation.AnimationId = WalkAnimId
	local WalkTrack = Animator:LoadAnimation(WalkAnimation)
	WalkTrack.Name = "WalkAnimation"
	WalkTrack.Priority = Enum.AnimationPriority.Movement
	WalkTrack.Looped = true
	Tracks[PlayerRequired]["WalkAnimation"] = WalkTrack



	-- WALK SOUND
	local WalkSFX = Instance.new("Sound")
	WalkSFX.SoundId = DefaultData.SoundFX.WalkSFX
	WalkSFX.Parent = RootPart
	WalkSFX.Volume = 0.25
	WalkSFX.Name = "WalkSFX"
	WalkSFX.Looped = false
	Tracks[PlayerRequired]["WalkSFX"] = WalkSFX



	-- WALK/RUN VFX
	local DustVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("Dust"):WaitForChild("Dust"):Clone()
	DustVFX.Parent = Character:WaitForChild("HumanoidRootPart")
	Tracks[PlayerRequired]["DustVFX"] = DustVFX




	local RunAnimation = Instance.new("Animation")
	RunAnimation.AnimationId = RunAnimID
	local RunTrack = Animator:LoadAnimation(RunAnimation)
	RunTrack.Name = "RunAnimation"
	RunTrack.Priority = Enum.AnimationPriority.Movement
	RunTrack.Looped = true
	Tracks[PlayerRequired]["RunAnimation"] = RunTrack


	-- SETUP MARKER SIGNALS
	Connections[PlayerRequired]["WalkLeft"] = WalkTrack:GetMarkerReachedSignal(DefaultData.Animations.WalkReachedSignalLeft):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Left", 1)
		if Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = WalkSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX.Volume = 0.25
			ClonedSFX:Play()
		end
	end)
	Connections[PlayerRequired]["WalkRight"] = WalkTrack:GetMarkerReachedSignal(DefaultData.Animations.WalkReachedSignalRight):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Right", 1)
		if Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = WalkSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX.Volume = 0.25
			ClonedSFX:Play()
		end
	end)


	Connections[PlayerRequired]["RunLeft"] = RunTrack:GetMarkerReachedSignal(DefaultData.Animations.RunReachedSignalLeft):Connect(function()
		RunLandVFX(PlayerViewing, PlayerRequired, Character, RootPart, DefaultData, "Left")
		if RunSFX then
			local ClonedSFX = RunSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			ClonedSFX.Volume = 0.2
			ClonedSFX.PlaybackSpeed = 1
			Debris:AddItem(ClonedSFX, 1)
		end
		if RunSFX2 then
			local ClonedSFX = RunSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			ClonedSFX.Volume = 0.1
			ClonedSFX.PlaybackSpeed = 1
			Debris:AddItem(ClonedSFX, 1)
		end
	end)
	Connections[PlayerRequired]["RunRight"] = RunTrack:GetMarkerReachedSignal(DefaultData.Animations.RunReachedSignalRight):Connect(function()
		RunLandVFX(PlayerViewing, PlayerRequired, Character, RootPart, DefaultData, "Right")
		if RunSFX then
			local ClonedSFX = RunSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			ClonedSFX.Volume = 0.2
			ClonedSFX.PlaybackSpeed = 1
			Debris:AddItem(ClonedSFX, 1)
		end
		if RunSFX2 then
			local ClonedSFX = RunSFX:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			ClonedSFX.Volume = 0.1
			ClonedSFX.PlaybackSpeed = 1
			Debris:AddItem(ClonedSFX, 1)
		end
	end)



	-- CONNECT TO WHEN RUNNING
	Connections[PlayerRequired]["MoveHeartbeat"] = RunService.Heartbeat:Connect(function(deltaTime)
		if not PlayerRequired or not Humanoid or not Humanoid.Parent then
			if Connections[PlayerRequired]["MoveHeartbeat"] then
				Connections[PlayerRequired]["MoveHeartbeat"]:Disconnect()
			end
			return
		end

		local Speed = Humanoid.WalkSpeed * Humanoid.MoveDirection.Magnitude

		-- GET ATTRIBUTES	
		local IsRunning = PlayerRequired:GetAttribute("IsSprinting")
		local IsShooting = PlayerRequired:GetAttribute("IsShooting")

		WalkTrack:AdjustSpeed(Humanoid.WalkSpeed/20)
		RunTrack:AdjustSpeed(Humanoid.WalkSpeed/40)

		if Speed > 2 then
			-- CANCEL EXISTING DEBOUNCE TASK
			if Connections[PlayerRequired]["StopDebounceTask"] then
				task.cancel(Connections[PlayerRequired]["StopDebounceTask"])
				Connections[PlayerRequired]["StopDebounceTask"] = nil
			end

			if IsRunning and not IsShooting then
				if WalkTrack.IsPlaying then
					WalkTrack:Stop(0.25)
				end
				if not RunTrack.IsPlaying then
					RunTrack:Play(0.25)
				end
			else
				if RunTrack.IsPlaying then
					RunTrack:Stop(0.1)
				end
				if not WalkTrack.IsPlaying then
					WalkTrack:Play(0.25)
				end
			end
		else
			-- STOP ANIMATIONS
			if not Connections[PlayerRequired]["StopDebounceTask"] then
				Connections[PlayerRequired]["StopDebounceTask"] = task.delay(0.1, function()
					if PlayerRequired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
					if RunTrack.IsPlaying then
						RunTrack:Stop(0.1)
					end
					if WalkTrack.IsPlaying then
						WalkTrack:Stop(0.25)
					end
					Connections[PlayerRequired]["StopDebounceTask"] = nil
				end)
			end
		end
	end)


	Connections[PlayerRequired]["CharacterRemoving_Walk"] = PlayerRequired.CharacterRemoving:Connect(function()
		FullCleanup()
	end)


	Connections[PlayerRequired]["EquippedGunChanged_Walk"] = PlayerRequired:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerRequired:GetAttribute("IsEquippingGun") ~= EquippedGun then
			FullCleanup()
		end
	end)
	
	return true
end



-- SHOOT ASSETS
function LightningAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
	local Tracks = ClientGunDataModule.Tracks
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	-- GET ANIMATION
	local StartAnimId = DefaultData.Animations["StartShooting"]
	if not StartAnimId then return end
	local ContinueAnimID = DefaultData.Animations["ContinueShooting"]
	if not ContinueAnimID then return end

	local Character = PlayerFired.Character or PlayerFired.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	
	
	-- CLEANUP FUNCTION
	local function FullCleanup()
		-- CANCEL TASKS
		if Connections[PlayerFired]["ShootVolumeTask"] then
			task.cancel(Connections[PlayerFired]["ShootVolumeTask"])
			Connections[PlayerFired]["ShootVolumeTask"] = nil
		end

		-- DISCONNECT CONNECTIONS
		if Connections[PlayerFired]["CharacterRemoving_Shoot"] then
			Connections[PlayerFired]["CharacterRemoving_Shoot"]:Disconnect()
			Connections[PlayerFired]["CharacterRemoving_Shoot"] = nil
		end
		if Connections[PlayerFired]["EquippedGunChanged_Shoot"] then
			Connections[PlayerFired]["EquippedGunChanged_Shoot"]:Disconnect()
			Connections[PlayerFired]["EquippedGunChanged_Shoot"] = nil
		end
		if Connections[PlayerFired]["IsShootingChanged"] then
			Connections[PlayerFired]["IsShootingChanged"]:Disconnect()
			Connections[PlayerFired]["IsShootingChanged"] = nil
		end

		-- STOP ANIMATIONS
		if Tracks[PlayerFired]["StartShootingAnimation"] then 
			Tracks[PlayerFired]["StartShootingAnimation"]:Stop() 
		end
		if Tracks[PlayerFired]["ContinueShootingAnimation"] then 
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop() 
		end

		if Tracks[PlayerFired]["StartShootingAnimation"] then
			Tracks[PlayerFired]["StartShootingAnimation"]:Stop()
			Tracks[PlayerFired]["StartShootingAnimation"]:Destroy()
			Tracks[PlayerFired]["StartShootingAnimation"] = nil
		end

		if Tracks[PlayerFired]["ContinueShootingAnimation"] then
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Destroy()
			Tracks[PlayerFired]["ContinueShootingAnimation"] = nil
		end
		
		if Tracks[PlayerFired]["ContinueShootingSFX"] then
			Tracks[PlayerFired]["ContinueShootingSFX"]:Stop()
			Tracks[PlayerFired]["ContinueShootingSFX"]:Destroy()
		end

		Tracks[PlayerFired]["StartShootingAnimation"] = nil
		Tracks[PlayerFired]["ContinueShootingAnimation"] = nil
	end
	
	-- INCASSE
	FullCleanup()


	-- BEAM SHOOTING SFX
	local BeamSFX = Instance.new("Sound")
	BeamSFX.SoundId = DefaultData.SoundFX.ShootSFX
	BeamSFX.Volume = 0.5
	BeamSFX.Looped = true
	BeamSFX.Parent = RootPart
	BeamSFX.PlaybackRegionsEnabled = true
	BeamSFX.PlaybackRegion = NumberRange.new(0.4, 2)
	Tracks[PlayerFired]["ContinueShootingSFX"] = BeamSFX



	-- CREATE ANIMATION
	local StartAnimation = Instance.new("Animation")
	StartAnimation.AnimationId = StartAnimId
	local StartTrack = Animator:LoadAnimation(StartAnimation)
	StartTrack.Name = "StartShooting"
	StartTrack.Priority = Enum.AnimationPriority.Action3
	StartTrack.Looped = false
	Tracks[PlayerFired]["StartShootingAnimation"] = StartTrack



	local ContinueAnimation = Instance.new("Animation")
	ContinueAnimation.AnimationId = ContinueAnimID
	-- CREATE CONTINUE TRACK 
	local ContinueTrack = Animator:LoadAnimation(ContinueAnimation)
	ContinueTrack.Name = "ContinueShooting"
	ContinueTrack.Priority = Enum.AnimationPriority.Action2
	ContinueTrack.Looped = true
	Tracks[PlayerFired]["ContinueShootingAnimation"] = ContinueTrack




	local function PartialCleanup()
		if 	Tracks[PlayerFired]["StartShootingAnimation"] then
			Tracks[PlayerFired]["StartShootingAnimation"]:Stop()
		end

		if Tracks[PlayerFired]["ContinueShootingAnimation"] then
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
		end

		Connections[PlayerFired]["ShootVolumeTask"] = task.spawn(function()
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				while Tracks[PlayerFired]["ContinueShootingSFX"].Volume > 0 do
					if not Tracks[PlayerFired]["ContinueShootingSFX"] then 
						Connections[PlayerFired]["ShootVolumeTask"] = nil
						return
					end
					Tracks[PlayerFired]["ContinueShootingSFX"].Volume = math.max(Tracks[PlayerFired]["ContinueShootingSFX"].Volume - 0.05, 0)
					task.wait(0.01)
				end
				Tracks[PlayerFired]["ContinueShootingSFX"].Volume = 0.5
				Tracks[PlayerFired]["ContinueShootingSFX"]:Stop(0.2)
			end
			Connections[PlayerFired]["ShootVolumeTask"] = nil
		end)
	end


	Connections[PlayerFired]["CharacterRemoving_Shoot"] = PlayerFired.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	-- CLEANUP
	Connections[PlayerFired]["EquippedGunChanged_Shoot"] = PlayerFired:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
			FullCleanup()
		end
	end)



	-- CONTINUE IF SHOOTING OR NOT
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting"):Connect(function()
		if not PlayerFired:GetAttribute("IsShooting") then
			PartialCleanup()
		else
			if Connections[PlayerFired]["ShootVolumeTask"] then
				task.cancel(Connections[PlayerFired]["ShootVolumeTask"])
				Connections[PlayerFired]["ShootVolumeTask"] = nil
			end
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				Tracks[PlayerFired]["ContinueShootingSFX"].Volume = 0.5
			end
			if Tracks[PlayerFired]["StartShootingAnimation"] and not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying then
				Tracks[PlayerFired]["StartShootingAnimation"]:Play(0.2)
			end
			if Tracks[PlayerFired]["ContinueShootingAnimation"] and not Tracks[PlayerFired]["ContinueShootingAnimation"].IsPlaying then
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Play(0.2)
			end
			if Tracks[PlayerFired]["ContinueShootingSFX"] and not Tracks[PlayerFired]["ContinueShootingSFX"].IsPlaying then
				Tracks[PlayerFired]["ContinueShootingSFX"]:Play()
			end
		end
	end)
	
	return true
end



-- CHARGE ASSETS
function LightningAssets.Charge(PlayerViewing, DefaultData, GunEquipped, PlayerCharging)
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end

	local Connections = ClientGunDataModule.Connections
	if not Connections then return end


	-- GET CHARGE ANIMATION IDS
	local ChargeStartID = DefaultData.Animations["ChargeStart"]
	if not ChargeStartID then return end
	local ContinueChargeID = DefaultData.Animations["ChargeContinue"]
	if not ContinueChargeID then return end

	local Character = PlayerCharging.Character or PlayerCharging.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	local CurrentPlayerData = ClientPlayerData:Get(PlayerViewing)


	-- VARIABLES
	local LightningChargeUpAuraVFX
	local LightningChargeVFX
	local WindEffect


	-- CREATE SOUNDS
	local StartChargeSFX = Instance.new("Sound")
	StartChargeSFX.SoundId = DefaultData.SoundFX.StartChargeSFX
	StartChargeSFX.Parent = RootPart
	StartChargeSFX.Volume = 2
	StartChargeSFX.Looped = true
	Tracks[PlayerCharging]["StartChargeSFX"] = StartChargeSFX
	
	local ContinueChargeSFX = Instance.new("Sound")
	ContinueChargeSFX.SoundId = DefaultData.SoundFX.ContinueChargeSFX
	ContinueChargeSFX.Volume = 2
	ContinueChargeSFX.PlaybackSpeed = 1
	ContinueChargeSFX.PlaybackRegionsEnabled = true
	ContinueChargeSFX.PlaybackRegion = NumberRange.new(7,7.5)
	ContinueChargeSFX.Looped = true
	ContinueChargeSFX.Parent = RootPart
	Tracks[PlayerCharging]["ContinueChargeSFX"] = ContinueChargeSFX


	-- CREATE CHARGE ANIMATION
	local StartAnimation = Instance.new("Animation")
	StartAnimation.AnimationId = ChargeStartID
	local StartTrack = Animator:LoadAnimation(StartAnimation)
	StartTrack.Name = "ChargeStart"
	StartTrack.Priority = Enum.AnimationPriority.Action4
	StartTrack.Looped = false
	Tracks[PlayerCharging]["ChargeStartAnimation"] = StartTrack


	local ContinueAnimation = Instance.new("Animation")
	ContinueAnimation.AnimationId = ContinueChargeID
	local ContinueTrack = Animator:LoadAnimation(ContinueAnimation)
	ContinueTrack.Name = "ContinueCharge"
	ContinueTrack.Priority = Enum.AnimationPriority.Action3
	ContinueTrack.Looped = true
	Tracks[PlayerCharging]["ChargeContinueAnimation"] = ContinueTrack



	-- CLEANUP FUNCTIONS
	local function FullCleanup()
		-- CANCEL TASKS
		if Connections[PlayerCharging]["WhileTask"] then
			task.cancel(Connections[PlayerCharging]["WhileTask"])
			Connections[PlayerCharging]["WhileTask"] = nil
		end

		-- DISCONNECT CONNECTIONS
		if Connections[PlayerCharging]["StartTrackEnded"] then
			Connections[PlayerCharging]["StartTrackEnded"]:Disconnect()
			Connections[PlayerCharging]["StartTrackEnded"] = nil
		end
		if Connections[PlayerCharging]["EquippedGunChanged_Charge"] then
			Connections[PlayerCharging]["EquippedGunChanged_Charge"]:Disconnect()
			Connections[PlayerCharging]["EquippedGunChanged_Charge"] = nil
		end
		if Connections[PlayerCharging]["CharacterRemoving_Charge"] then
			Connections[PlayerCharging]["CharacterRemoving_Charge"]:Disconnect()
			Connections[PlayerCharging]["CharacterRemoving_Charge"] = nil
		end
		if Connections[PlayerCharging]["IsChargingChanged"] then
			Connections[PlayerCharging]["IsChargingChanged"]:Disconnect()
			Connections[PlayerCharging]["IsChargingChanged"] = nil
		end

		-- CLEANUP VFX
		if LightningChargeUpAuraVFX then
			for _, Aura in pairs(LightningChargeUpAuraVFX:GetDescendants()) do
				Aura.Enabled = false
			end
			Debris:AddItem(LightningChargeUpAuraVFX, 0.5)
		end
		if LightningChargeVFX then
			for _, VFX in pairs(LightningChargeVFX:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			local PointLight = LightningChargeVFX:FindFirstChild("PointLight")
			if PointLight then
				PointLight:Destroy()
			end
			Debris:AddItem(LightningChargeVFX, 1)
		end
		if WindEffect then
			for _, VFX in pairs(WindEffect:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			Debris:AddItem(WindEffect, 0.25)
		end


		-- MAP CLEANUP
		if PlayerCharging == PlayerViewing then
			TimeChange:FireServer(false, 0, 0)
		end


		-- CLEANUP ANIMATION
		if Tracks[PlayerCharging]["ChargeStartAnimation"] then
			Tracks[PlayerCharging]["ChargeStartAnimation"]:Stop()
			Tracks[PlayerCharging]["ChargeStartAnimation"]:Destroy()
			Tracks[PlayerCharging]["ChargeStartAnimation"] = nil
		end
		if Tracks[PlayerCharging]["ChargeContinueAnimation"] then
			Tracks[PlayerCharging]["ChargeContinueAnimation"]:Stop()
			Tracks[PlayerCharging]["ChargeContinueAnimation"]:Destroy()
			Tracks[PlayerCharging]["ChargeContinueAnimation"] = nil
		end
		if Tracks[PlayerCharging]["StartChargeSFX"] then
			Tracks[PlayerCharging]["StartChargeSFX"]:Stop()
			Tracks[PlayerCharging]["StartChargeSFX"]:Destroy()
			Tracks[PlayerCharging]["StartChargeSFX"] = nil
		end
		if Tracks[PlayerCharging]["ContinueChargeSFX"] then
			Tracks[PlayerCharging]["ContinueChargeSFX"]:Stop()
			Tracks[PlayerCharging]["ContinueChargeSFX"]:Destroy()
			Tracks[PlayerCharging]["ContinueChargeSFX"] = nil
		end
	end


	-- PARTIAL CLEANUP
	local function PartialCleanup()
		-- CLEANUP VFX
		if LightningChargeUpAuraVFX then
			for _, Aura in pairs(LightningChargeUpAuraVFX:GetDescendants()) do
				Aura.Enabled = false
			end
			Debris:AddItem(LightningChargeUpAuraVFX, 0.5)
		end
		if LightningChargeVFX then
			for _, VFX in pairs(LightningChargeVFX:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			local PointLight = LightningChargeVFX:FindFirstChild("PointLight")
			if PointLight then
				PointLight:Destroy()
			end
			Debris:AddItem(LightningChargeVFX, 1)
		end
		if WindEffect then
			for _, VFX in pairs(WindEffect:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			Debris:AddItem(WindEffect, 0.25)
		end


		-- MAP CLEANUP
		if PlayerCharging == PlayerViewing then
			TimeChange:FireServer(false, 0, 0)
		end


		-- CLEANUP ANIMATION
		if Connections[PlayerCharging]["StartTrackEnded"] then
			Connections[PlayerCharging]["StartTrackEnded"]:Disconnect()
			Connections[PlayerCharging]["StartTrackEnded"] = nil
		end
		if Tracks[PlayerCharging]["ChargeStartAnimation"] then
			Tracks[PlayerCharging]["ChargeStartAnimation"]:Stop()
		end
		if Tracks[PlayerCharging]["ChargeContinueAnimation"] then
			Tracks[PlayerCharging]["ChargeContinueAnimation"]:Stop()
		end
		if Tracks[PlayerCharging]["StartChargeSFX"] then
			Tracks[PlayerCharging]["StartChargeSFX"]:Stop()
		end
		if Tracks[PlayerCharging]["ContinueChargeSFX"] then
			Tracks[PlayerCharging]["ContinueChargeSFX"]:Stop()
		end
	end


	-- FULL CLEANUP CONNECTIONS
	Connections[PlayerCharging]["EquippedGunChanged_Charge"] = PlayerCharging:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerCharging:GetAttribute("IsEquippingGun") ~= GunEquipped then
			FullCleanup()
		end
	end)

	Connections[PlayerCharging]["CharacterRemoving_Charge"] = PlayerCharging.CharacterRemoving:Connect(function()
		FullCleanup()
	end)



	-- PLAY THE ASSETS
	local function PlayChargeAssets()
		-- PLAY TRACK
		if Tracks[PlayerCharging]["ChargeStartAnimation"] then
			Tracks[PlayerCharging]["ChargeStartAnimation"]:Play()
		end
		if Tracks[PlayerCharging]["ChargeContinueAnimation"] then
			Tracks[PlayerCharging]["ChargeContinueAnimation"]:Play()
		end
		if Tracks[PlayerCharging]["StartChargeSFX"] then
			Tracks[PlayerCharging]["StartChargeSFX"]:Play()
		end


		-- VFX
		LightningChargeUpAuraVFX = ReplicatedStorage.GunVFX.Lightning.LightningCharge.LightningChargeUpAura:Clone()
		LightningChargeUpAuraVFX.Parent = RootPart
		for _, Aura in pairs(LightningChargeUpAuraVFX:GetDescendants()) do
			Aura.EmissionDirection = Enum.NormalId.Top
			Aura.Speed = NumberRange.new(1,1.5)
			Aura.Enabled = true
			Aura.Rate = Aura.Rate/4
			Aura.Lifetime = NumberRange.new(0.5, 3)
		end

		if PlayerCharging == PlayerViewing then
			TimeChange:FireServer(true, 20, 0)
		end

		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		if RightArm:FindFirstChild("LightningCharge") then
			RightArm:FindFirstChild("LightningCharge"):Destroy()
		end

		-- INITIALIZE VFX
		LightningChargeVFX = ReplicatedStorage.GunVFX.Lightning.LightningCharge.LightningCharge:Clone()
		WindEffect = ReplicatedStorage.GunVFX.WindEffect.WindEffect:Clone()
		WindEffect.Parent = RootPart
		for _, Effect in pairs(WindEffect:GetDescendants()) do
			if Effect:IsA("ParticleEmitter") then
				Effect.Enabled = true
			end
		end

		-- START TRACK ENDED CONNECTION
		Connections[PlayerCharging]["StartTrackEnded"] = StartTrack.Ended:Connect(function()
			Tracks[PlayerCharging]["ContinueChargeSFX"]:Play()

			-- LIGHTNING EFFECT
			LightningChargeVFX.Parent = RightArm
			LightningChargeVFX.Position = Vector3.new(0, -20, 0)
			LightningChargeVFX.Orientation = Vector3.new(0, 0, 0)

			-- WIND EFFECT
			WindEffect.Position = Vector3.new(0, -2, 0)

			-- CREATE LIGHT ON ARM
			local PointLight = Instance.new("PointLight")
			PointLight.Brightness = 1
			PointLight.Range = 75
			PointLight.Color = Color3.fromRGB(73, 122, 255)
			PointLight.Parent = LightningChargeVFX

			-- ENABLE AND SPEED UP VFX
			for _, Aura in pairs(LightningChargeUpAuraVFX:GetDescendants()) do
				Aura.Rate = Aura.Rate*4
				Aura.Speed = NumberRange.new(0.01,0.01)
				Aura.Lifetime = NumberRange.new(0.5, 1)
			end
			for _, VFX in pairs(LightningChargeVFX:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = true
				end
			end	
			for _, VFX in pairs(WindEffect:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = true
				end
			end

			local RockDebrisSettings = {
				Position = RootPart.Position,
				RockAmount = 5,
				Size = 0.25,
				HorizontalStrength = 100,
				VerticalStrength = 10,
				Time = 1,
			}

			local FinalContinueTrack = Tracks[PlayerCharging]["ChargeContinueAnimation"]
			Connections[PlayerCharging]["WhileTask"] = task.spawn(function()
				while FinalContinueTrack.IsPlaying and PlayerCharging:GetAttribute("VisuallyCharging") do 
					ScreenShakeModule.ApplyScreenShake(false, PlayerViewing, PlayerCharging, 0.33, 100)
					RockModule.RockDebris(RockDebrisSettings)
					task.wait(0.1)
				end
				Connections[PlayerCharging]["WhileTask"] = nil
			end)
		end)
	end



	-- ATTRIBUTE CHANGED CONNECTION
	Connections[PlayerCharging]["IsChargingChanged"] = PlayerCharging:GetAttributeChangedSignal("VisuallyCharging"):Connect(function()
		if not PlayerCharging:GetAttribute("VisuallyCharging") or PlayerCharging:GetAttribute("IsShooting") then
			PartialCleanup()
		else
			PlayChargeAssets()
		end
	end)
	
	return true
end



-- DASH ASSETS
function LightningAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end

	local Connections = ClientGunDataModule.Connections
	if not Connections then return end


	-- GET CHARGE ANIMATION IDS
	local ChargeStartID = DefaultData.Animations["ChargeStart"]
	if not ChargeStartID then return end
	local ContinueChargeID = DefaultData.Animations["ChargeContinue"]
	if not ContinueChargeID then return end


	local Character = PlayerDashing.Character or PlayerDashing.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	


	-- CLEANUP FUNCTIONS
	local function FullCleanup()
		-- CLEAR TRACKS
		if Tracks[PlayerDashing]["FrontDashTrack"] then
			Tracks[PlayerDashing]["FrontDashTrack"]:Stop(0.25)
			Tracks[PlayerDashing]["FrontDashTrack"]:Destroy()
			Tracks[PlayerDashing]["FrontDashTrack"] = nil
		end
		if Tracks[PlayerDashing]["BackDashTrack"] then
			Tracks[PlayerDashing]["BackDashTrack"]:Stop(0.25)
			Tracks[PlayerDashing]["BackDashTrack"]:Destroy()
			Tracks[PlayerDashing]["BackDashTrack"] = nil
		end
		if Tracks[PlayerDashing]["LeftDashTrack"] then
			Tracks[PlayerDashing]["LeftDashTrack"]:Stop(0.25)
			Tracks[PlayerDashing]["LeftDashTrack"]:Destroy()
			Tracks[PlayerDashing]["LeftDashTrack"] = nil
		end
		if Tracks[PlayerDashing]["RightDashTrack"] then
			Tracks[PlayerDashing]["RightDashTrack"]:Stop(0.25)
			Tracks[PlayerDashing]["RightDashTrack"]:Destroy()
			Tracks[PlayerDashing]["RightDashTrack"] = nil
		end

		-- CLEAR SFX
		if Tracks[PlayerDashing]["DashSFX"] then
			Tracks[PlayerDashing]["DashSFX"]:Stop()
			Tracks[PlayerDashing]["DashSFX"]:Destroy()
			Tracks[PlayerDashing]["DashSFX"] = nil
		end

		-- CLEAR VFX (FIXED - Added LightningDashVFX cleanup)
		if Tracks[PlayerDashing]["DustVFX"] then
			Tracks[PlayerDashing]["DustVFX"]:Destroy()
			Tracks[PlayerDashing]["DustVFX"] = nil
		end
		if Tracks[PlayerDashing]["LightningDashVFX"] then
			Tracks[PlayerDashing]["LightningDashVFX"]:Destroy()
			Tracks[PlayerDashing]["LightningDashVFX"] = nil
		end

		-- CLEAR CONNECTIONS
		if Connections[PlayerDashing]["DashingSignal"] then
			Connections[PlayerDashing]["DashingSignal"]:Disconnect()
			Connections[PlayerDashing]["DashingSignal"] = nil
		end
		if Connections[PlayerDashing]["EquippedGunChanged_Dash"] then
			Connections[PlayerDashing]["EquippedGunChanged_Dash"]:Disconnect()
			Connections[PlayerDashing]["EquippedGunChanged_Dash"] = nil
		end
		if Connections[PlayerDashing]["CharacterRemoving_Dash"] then
			Connections[PlayerDashing]["CharacterRemoving_Dash"]:Disconnect()
			Connections[PlayerDashing]["CharacterRemoving_Dash"] = nil
		end
	end
	
	-- INCASE
	FullCleanup()


	-- DASH IDS
	local FrontDashID = DefaultData.Animations["FrontDash"]
	if not FrontDashID then return end
	local BackDashID = DefaultData.Animations["BackDash"]
	if not BackDashID then return end
	local LeftDashID = DefaultData.Animations["LeftDash"]
	if not LeftDashID then return end
	local RightDashID = DefaultData.Animations["RightDash"]
	if not RightDashID then return end

	-- DASH SFX
	local DashSFXID = DefaultData.SoundFX["DashSFX"]
	if not DashSFXID then return end



	-- DASH ANIMATIONS
	local FrontDashAnimation = Instance.new("Animation")
	FrontDashAnimation.AnimationId = FrontDashID
	local FrontDashTrack = Animator:LoadAnimation(FrontDashAnimation)
	FrontDashTrack.Priority = Enum.AnimationPriority.Action2
	FrontDashTrack.Looped = false
	Tracks[PlayerDashing]["FrontDashTrack"] = FrontDashTrack
	

	local BackDashAnimation = Instance.new("Animation")
	BackDashAnimation.AnimationId = BackDashID
	local BackDashTrack = Animator:LoadAnimation(BackDashAnimation)
	BackDashTrack.Priority = Enum.AnimationPriority.Action2
	BackDashTrack.Looped = false
	Tracks[PlayerDashing]["BackDashTrack"] = BackDashTrack


	local LeftDashAnimation = Instance.new("Animation")
	LeftDashAnimation.AnimationId = LeftDashID
	local LeftDashTrack = Animator:LoadAnimation(LeftDashAnimation)
	LeftDashTrack.Priority = Enum.AnimationPriority.Action2
	LeftDashTrack.Looped = false
	Tracks[PlayerDashing]["LeftDashTrack"] = LeftDashTrack

	local RightDashAnimation = Instance.new("Animation")
	RightDashAnimation.AnimationId = RightDashID
	local RightDashTrack = Animator:LoadAnimation(RightDashAnimation)
	RightDashTrack.Priority = Enum.AnimationPriority.Action2
	RightDashTrack.Looped = false
	Tracks[PlayerDashing]["RightDashTrack"] = RightDashTrack



	-- DASH SOUNDFX
	local DashSFX = Instance.new("Sound")
	DashSFX.SoundId = DashSFXID
	DashSFX.Parent = Character:FindFirstChild("HumanoidRootPart")
	DashSFX.Volume = 3
	DashSFX.PlaybackRegionsEnabled = true
	DashSFX.PlaybackRegion = NumberRange.new(0.25, 1.5)
	Tracks[PlayerDashing]["DashSFX"] = DashSFX		
	Tracks[PlayerDashing]["DashSFX"].PlaybackSpeed = 1


	-- DASH VFX
	local DustVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild(DefaultData.VFX.WalkVFX):WaitForChild(DefaultData.VFX.WalkVFX):Clone()
	DustVFX.Parent = Character:WaitForChild("Torso")
	DustVFX.Position = Vector3.new(0, -1, 0)
	Tracks[PlayerDashing]["DustVFX"] = DustVFX


	local LightningDashVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("Lightning"):WaitForChild(DefaultData.VFX.DashVFX):WaitForChild(DefaultData.VFX.DashVFX):Clone()
	LightningDashVFX.Parent = Character:WaitForChild("Torso")
	LightningDashVFX.Orientation = Vector3.new(0, 0, 0)
	Tracks[PlayerDashing]["LightningDashVFX"] = LightningDashVFX



	-- HELPER VFX PLAYER
	local function PlayVFX(VFXAttachment, EmitCount)
		-- Get movement direction
		local HumanoidDirection = Humanoid.MoveDirection
		if HumanoidDirection.Magnitude < 0.1 then
			HumanoidDirection = RootPart.CFrame.LookVector
		end

		local CurrentPosition = VFXAttachment.WorldPosition
		local TargetPosition = CurrentPosition + HumanoidDirection
		VFXAttachment.WorldCFrame = CFrame.lookAt(CurrentPosition, TargetPosition)

		-- DO NOT set Orientation here - it will override the CFrame

		if not EmitCount then EmitCount = 3 end
		for _, Particle in pairs(VFXAttachment:GetDescendants()) do
			if Particle:IsA("ParticleEmitter") then
				Particle:Emit(EmitCount)
			end
		end
	end



	Connections[PlayerDashing]["DashingSignal"] = PlayerDashing:GetAttributeChangedSignal("IsDashing"):Connect(function()
		if PlayerDashing:GetAttribute("IsDashing") then
			local DashDirection = PlayerDashing:GetAttribute("DashDirection")

			-- PLAY SFX
			if Tracks[PlayerDashing]["DashSFX"] then
				local ClonedSFX = Tracks[PlayerDashing]["DashSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				Debris:AddItem(ClonedSFX, 2)
			end
			PlayVFX(Tracks[PlayerDashing]["LightningDashVFX"], 1)
			-- LOOP AND PLAY VFX
			task.spawn(function()
				while (PlayerDashing == PlayerViewing and PlayerDashing:GetAttribute("IsDashing")) or 
					(PlayerDashing ~= PlayerViewing and PlayerDashing:GetAttribute("DashingVFX")) do
					RockModule.PlayDustVFX(Character, Tracks[PlayerDashing]["DustVFX"], nil, 1)

					RockModule.PlayRockTrailVFX(Character, 2)
					task.wait(0.05)
				end
			end)

			if DashDirection == "Front" then
				Tracks[PlayerDashing]["FrontDashTrack"]:Play()
				Tracks[PlayerDashing]["FrontDashTrack"]:AdjustSpeed(2)
			elseif DashDirection == "Back" then
				Tracks[PlayerDashing]["BackDashTrack"]:Play()
				Tracks[PlayerDashing]["BackDashTrack"]:AdjustSpeed(1.5) 
			elseif DashDirection == "Left" then
				Tracks[PlayerDashing]["LeftDashTrack"]:Play()
			elseif DashDirection == "Right" then
				Tracks[PlayerDashing]["RightDashTrack"]:Play()
			end
		else
			if Tracks[PlayerDashing]["FrontDashTrack"] then
				Tracks[PlayerDashing]["FrontDashTrack"]:Stop(0.25)
			end
			if Tracks[PlayerDashing]["LeftDashTrack"] then
				Tracks[PlayerDashing]["LeftDashTrack"]:Stop(0.25)
			end
			if Tracks[PlayerDashing]["BackDashTrack"] then
				Tracks[PlayerDashing]["BackDashTrack"]:Stop(0.25)
			end
			if Tracks[PlayerDashing]["RightDashTrack"] then
				Tracks[PlayerDashing]["RightDashTrack"]:Stop(0.25)
			end
		end
	end)


	Connections[PlayerDashing]["EquippedGunChanged_Dash"] = PlayerDashing:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerDashing:GetAttribute("IsEquippingGun") ~= GunEquipped then
			FullCleanup()
		end
	end)

	Connections[PlayerDashing]["CharacterRemoving_Dash"] = PlayerDashing.CharacterRemoving:Connect(function()
		FullCleanup()
	end)
	
	return true
end



-- RELOAD
function LightningAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have reload
end



-- UI
function LightningAssets.UI(LocalPlayer, GunEquipped)
	-- GET PLAYER UI
	local PlayerGui = LocalPlayer.PlayerGui
	if not PlayerGui then return end

	-- GET GUN GUI
	local GunGui = PlayerGui:WaitForChild("GunGuiFolder"):WaitForChild("GunGui")
	if not GunGui then return end

	-- TRACKS AND CONNECTIONS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	local CurrentlyLerping = false


	local function FullCleanup()
		if Connections[LocalPlayer]["EquippedGunChanged_UI"]  then
			Connections[LocalPlayer]["EquippedGunChanged_UI"]:Disconnect()
			Connections[LocalPlayer]["EquippedGunChanged_UI"] = nil
		end

		if Connections[LocalPlayer]["CharacterRemoving_UI"]  then
			Connections[LocalPlayer]["CharacterRemoving_UI"]:Disconnect()
			Connections[LocalPlayer]["CharacterRemoving_UI"] = nil
		end

		if Connections[LocalPlayer]["ShotAttribute_UI"] then
			Connections[LocalPlayer]["ShotAttribute_UI"]:Disconnect()
			Connections[LocalPlayer]["ShotAttribute_UI"] = nil
		end

		CurrentlyLerping = nil
	end

	-- INCASE
	FullCleanup()


	Connections[LocalPlayer]["EquippedGunChanged_UI"] = LocalPlayer:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if LocalPlayer:GetAttribute("IsEquippingGun") ~= GunEquipped then
			FullCleanup()
		end
	end)

	Connections[LocalPlayer]["CharacterRemoving_UI"] = LocalPlayer.CharacterRemoving:Connect(function()
		FullCleanup()
	end)


	-- GET ORIGINAL COLORS
	local OriginalCurrentColor = GunGui.Frame.CurrentAmmo.TextColor3

	-- SHOOTING
	Connections[LocalPlayer]["ShotAttribute_UI"] = LocalPlayer:GetAttributeChangedSignal("OutOfCharge"):Connect(function()
		if not LocalPlayer:GetAttribute("OutOfCharge") then return end
		if CurrentlyLerping then return end

		-- IF NO CURRENT OR TOTAL AMMO (TWEEN COLORS OF UI)
		if LocalPlayer:GetAttribute("OutOfCharge") and LocalPlayer:GetAttribute("WantsToShoot") then
			-- TWEEN TO
			local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local TargetColor = {TextColor3 = Color3.fromRGB(255, 0, 0)}

			local Tween
			for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
				Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
				Tween:Play()
			end
			CurrentlyLerping = true
			Tween.Completed:Wait()
			Tween:Destroy()
			
			while LocalPlayer:GetAttribute("CurrentCharge") <= 0 and LocalPlayer:GetAttribute("WantsToShoot") do
				task.wait(0.05)
			end

			-- TWEEN BACK
			local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local TargetColor = {TextColor3 = OriginalCurrentColor}
			local Tween
			for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
				Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
				Tween:Play()
			end
			Tween.Completed:Wait()
			Tween:Destroy()
			CurrentlyLerping = false
		end
	end)
	
	return true
end



-- WALL HIT VFX
local LightningSFX = {}
local TimeSinceHit = {}
local SFXRunning = {}
local MostRecentPosition = {}
function LightningAssets.WallHit(PlayerShot, ResultData)
	if not ResultData.Normal then return end

	-- DEFAULT DATA
	local EquippedGun = PlayerShot:GetAttribute("IsEquippingGun")
	if not EquippedGun then return end
	local DefaultData = ClientGunDataModule:Get(PlayerShot)
	if not DefaultData then return end

	TimeSinceHit[PlayerShot] = tick()
	MostRecentPosition[PlayerShot] = ResultData.Position
	if not SFXRunning[PlayerShot] then
		local ID = HttpService:GenerateGUID(false)
		local SFXData = {
			Volume = 2,
			PlaybackSpeed = 1,
			Looped = true,
			SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("LightningFist"):FindFirstChild("ZombieHitSFX")
		}

		task.spawn(function()
			while tick() - TimeSinceHit[PlayerShot] < 0.05 do
				if not SFXRunning[PlayerShot] then
					SFXRunning[PlayerShot] = true
				end
				PlaySFXModule.PlayPartSFX(PlayerShot, MostRecentPosition[PlayerShot], ID, SFXData)
				task.wait(0.1)
			end
			SFXRunning[PlayerShot] = false
			PlaySFXModule.DestroySFX(PlayerShot, ID, 0.35)
		end)
	end


	-- ROCK STUFF
	local RockDebrisSettings = {
		Part = ResultData.Instance,
		Position = ResultData.Position,
		RockAmount = 1,
		Size = 0.35,
		HorizontalStrength = 10,
		VerticalStrength = 15,
		Time = 1,
		Chance = 90
	}
	RockModule.RockDebris(RockDebrisSettings)
end



-- WALL MARK VFX
local LightningWallEffect = {}
local LastWallMarkPos = {}
local LastWallMarkConn = {}
function LightningAssets.WallMark(PlayerShot, ResultData)
	-- NEEDS NORMAL
	if not ResultData.Normal then return end
	
	local LightningVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Lightning")
	if not LightningVFX then return end 

	if LastWallMarkPos[PlayerShot] and LastWallMarkPos[PlayerShot]["WallEffect"] then
		if (LastWallMarkPos[PlayerShot]["WallEffect"].Position - ResultData.Position).Magnitude < 0.03 then
			LastWallMarkPos[PlayerShot]["WallEffect"]:Destroy()
			LastWallMarkPos[PlayerShot]["WallEffect"] = nil
		end
	end

	local WallEffect = LightningVFX:FindFirstChild("LightningHitEffect"):FindFirstChild("WallEffect"):FindFirstChild("WallEffect"):Clone()
	local Offset = 0.001
	local OffsetPos = ResultData.Position + (ResultData.Normal * Offset)
	WallEffect.CFrame = CFrame.new(OffsetPos, OffsetPos - ResultData.Normal)
	WallEffect.Parent = workspace:FindFirstChild("ActiveVFX")
	
	if not LastWallMarkPos[PlayerShot] then
		LastWallMarkPos[PlayerShot] = {}
	end
	LastWallMarkPos[PlayerShot]["WallEffect"] = WallEffect
	if LastWallMarkConn[PlayerShot] then
		task.cancel(LastWallMarkConn[PlayerShot])
		LastWallMarkConn[PlayerShot] = nil
	end
	
	LastWallMarkConn[PlayerShot] = task.delay(1, function()
		if LastWallMarkPos[PlayerShot] and LastWallMarkPos[PlayerShot]["WallEffect"] then
			LastWallMarkPos[PlayerShot]["WallEffect"]:Destroy()
			LastWallMarkPos[PlayerShot]["WallEffect"] = nil
		end
		LastWallMarkConn[PlayerShot] = nil
	end)


	for _, ClonedChild in ipairs(WallEffect:GetDescendants()) do
		if ClonedChild:IsA("ParticleEmitter") then
			ClonedChild.Transparency = NumberSequence.new(0)
			ClonedChild.Enabled = false
			ClonedChild:Emit(1)
		end
	end
	Debris:AddItem(WallEffect, 1)
end



-- ZOMBIE HIT VFX
local ZombieHit = {}
local TimeSinceBloodSFX = {}
function LightningAssets.ZombieHit(PlayerShot, ResultData)
	-- DEFAULT DATA
	local EquippedGun = PlayerShot:GetAttribute("IsEquippingGun")
	if not EquippedGun then return end
	local DefaultData = ClientGunDataModule:Get(PlayerShot)
	if not DefaultData then return end

	TimeSinceHit[PlayerShot] = tick()
	MostRecentPosition[PlayerShot] = ResultData.Position
	if not SFXRunning[PlayerShot] then
		local ID = HttpService:GenerateGUID(false)
		local SFXData = {
			Volume = 2,
			PlaybackSpeed = 1,
			Looped = true,
			SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("LightningFist"):FindFirstChild("ZombieHitSFX")
		}

		task.spawn(function()
			while tick() - TimeSinceHit[PlayerShot] < 0.2 do
				if not SFXRunning[PlayerShot] then
					SFXRunning[PlayerShot] = true
				end
				PlaySFXModule.PlayPartSFX(PlayerShot, MostRecentPosition[PlayerShot], ID, SFXData)
				task.wait(0.1)
			end
			SFXRunning[PlayerShot] = false
			PlaySFXModule.DestroySFX(PlayerShot, ID, 0.35)
		end)
	end


	local ZombieHitVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Lightning"):FindFirstChild("LightningHitEffect"):FindFirstChild("ZombieEffect"):FindFirstChild("ZombieEffect"):Clone()
	if not ZombieHitVFX then return end
	
	
	if ResultData.Normal then
		local Offset = -2
		local OffsetPos = ResultData.Position + (ResultData.Normal * Offset)
		ZombieHitVFX.CFrame = CFrame.new(OffsetPos, OffsetPos - ResultData.Normal)
	else
		ZombieHitVFX.CFrame = CFrame.new(ResultData.Position)
	end

	ZombieHitVFX.Parent = workspace:FindFirstChild("ActiveVFX")


	for _, Emitter in ZombieHitVFX:GetChildren() do
		if math.random() <= 0.5 then continue end
		Emitter:Emit(1)
	end
	Debris:AddItem(ZombieHitVFX, 0.7)


	if not ResultData.Position then return end -- some reason was crashing code
	if ZombieHit[ResultData.Instance] and (tick() - ZombieHit[ResultData.Instance] < 0.25) then return end
	ZombieHit[ResultData.Instance] = tick()


	-- VFX
	local BloodVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("BloodVFX"):Clone()
	if not BloodVFX then return end


	for _, VFX in pairs(BloodVFX:GetDescendants()) do
		if VFX:IsA("Attachment") then
			local AveragePosition = (ResultData.Position + ResultData.Instance.Position) / 2
			
			if ResultData.Normal then
				local Offset = -0.5
				local OffsetPos = AveragePosition + (ResultData.Normal * Offset)
				VFX.CFrame = CFrame.new(OffsetPos, OffsetPos - ResultData.Normal)
			else
				VFX.CFrame = CFrame.new(AveragePosition)
			end
		end
		if VFX:IsA("ParticleEmitter") then
			-- RANDOMIZE RED COLOR
			local RedColor = math.random(67, 160)
			local RandomColor = Color3.fromRGB(RedColor, 0, 0)
			VFX.Color = ColorSequence.new(RandomColor)
			VFX:Emit(1)
		end
	end

	BloodVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(BloodVFX, 1)

	-- SFX
	local BloodSFX = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("LightningFist"):FindFirstChild("BloodSFX"):Clone()
	BloodSFX.Volume = 0.1

	-- PICK RANDOM PLAYBACK SPEED
	local RandomPlaySpeed = math.random(100, 200) / 100
	BloodSFX.PlaybackSpeed = RandomPlaySpeed

	-- PLAY SOUND
	BloodSFX.Parent = ResultData.Instance
	BloodSFX:Play()

	Debris:AddItem(BloodSFX, 2)
end



-- STREAM BULLET
function LightningAssets.StreamBullet(PlayerFired, BulletData)
	local StreamBulletModel
	if not ClientGunDataModule.StreamBullet[PlayerFired] or ClientGunDataModule.StreamBullet[PlayerFired].CharacterFired ~= PlayerFired.Character then	
		local GunVFX = ReplicatedStorage:FindFirstChild("GunVFX")
		if not GunVFX then return end 
		local Muzzle = PlayerFired.Character:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle")
		if not Muzzle then return end


		-- CLONE VFX
		local BeamEffect = GunVFX:WaitForChild("Lightning"):WaitForChild("LightningBeam"):FindFirstChild("BeamEffect"):Clone()
		BeamEffect.Parent = workspace:WaitForChild("BulletsFolder")


		-- DESTROY PREVIOUS BULLET MODEL
		local PreviousModel = ClientGunDataModule.StreamBullet[PlayerFired] and ClientGunDataModule.StreamBullet[PlayerFired].BulletClone
		if PreviousModel then PreviousModel:Destroy() end


		-- CREATE NEW BULLET MODEL
		StreamBulletModel = BeamEffect
		local StartBeam = BeamEffect:FindFirstChild("StartBeam")
		local EndBeam = BeamEffect:FindFirstChild("EndBeam")


		-- BEAM PROPERTIES
		StartBeam.Anchored = false
		StartBeam.CanCollide = false
		StartBeam.Massless = true	
		StartBeam.Transparency = 1
		EndBeam.Anchored = false
		EndBeam.CanCollide = false
		EndBeam.Massless = true	
		EndBeam.Transparency = 1

		local Weld = Instance.new("Weld")
		Weld.Name = "StartBeamWeld"
		Weld.Part0 = Muzzle
		Weld.Part1 = StartBeam
		Weld.C0  = CFrame.new(0,0,0)
		Weld.C1 = CFrame.new(0, 0, 0)
		Weld.Parent = BeamEffect

		local Weld2 = Instance.new("Weld")
		Weld2.Name = "EndBeamWeld"
		Weld2.Part0 = Muzzle
		Weld2.Part1 = EndBeam
		Weld2.C0  = CFrame.new(0,0,0)
		Weld2.C1 = CFrame.new(0, 0, 0)
		Weld2.Parent = BeamEffect
	else
		StreamBulletModel = ClientGunDataModule.StreamBullet[PlayerFired].BulletClone
	end

	return StreamBulletModel
end



-- RETURN
return LightningAssets