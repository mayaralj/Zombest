local ScorchriftAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- FOLDERS
local Frameworks = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULE
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))
local RockModule = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Rock"):WaitForChild("RockModule"))
local ScreenShakeModule = require(Frameworks:WaitForChild("Screenshake"):WaitForChild("ScreenShake"))
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))
local LightningAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("LightningAssets"))

-- EVENTS

-- EQUIP ASSETS
function ScorchriftAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	local RootPart = PlayerEquipped.Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

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
	EquipSFX.Volume = 0.8
	EquipSFX.PlaybackSpeed = 2
	EquipSFX.Parent = RootPart
	Tracks[PlayerEquipped]["EquipSFX"] = EquipSFX

	local EquipSFX2 = Instance.new("Sound")
	EquipSFX2.SoundId = DefaultData.SoundFX.EquipSFX2
	EquipSFX2.Name = "EquipSFX2"
	EquipSFX2.Volume = 1.5
	EquipSFX2.PlaybackSpeed = 1
	EquipSFX2.Parent = RootPart
	Tracks[PlayerEquipped]["EquipSFX2"] = EquipSFX2

	-- CREATE ANIMATION
	local EquipAnimation = Instance.new("Animation")
	EquipAnimation.AnimationId = DefaultData.Animations.EquipAnimation
	local EquipTrack = Animator:LoadAnimation(EquipAnimation)
	EquipTrack.Name = "EquipAnimation"
	EquipTrack.Looped = false
	EquipTrack.Priority = Enum.AnimationPriority.Action4
	Tracks[PlayerEquipped]["EquipAnimation"] = EquipTrack

	-- HIGHLIGHT
	local Highlight = Character:WaitForChild("Highlight")
	if not Highlight then
		return
	end
	Highlight.FillColor = Color3.fromRGB(141, 1, 1)

	-- PLAY TRACK
	EquipTrack:Play()
	EquipTrack:AdjustSpeed(0.75)

	local EquipVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Scorchrift"):FindFirstChild("EquipVFX"):Clone()
	Connections[PlayerEquipped]["ArmVFXMarker"] = EquipTrack:GetMarkerReachedSignal("Pick"):Connect(function()
		EquipVFX.Parent = Character:FindFirstChild("Right Arm")
		EquipVFX.Position = Vector3.new(0, -1, 0)
	end)

	Connections[PlayerEquipped]["BodyVFXMarker"] = EquipTrack:GetMarkerReachedSignal("Hit"):Connect(function()
		-- CLEAN VFX AND PLAY SFX
		EquipSFX:Play()
		EquipSFX2:Play()
		EquipVFX:Destroy()

		Highlight.FillTransparency = 0.5
		task.spawn(function()
			while Highlight.FillTransparency < 1 do
				Highlight.FillTransparency += 0.02
				task.wait(0.02)
			end
		end)

		-- IMPACT VFX
		local EquipVFX2 = ReplicatedStorage:FindFirstChild("GunVFX")
			:FindFirstChild("Scorchrift")
			:FindFirstChild("EquipImpact")
			:Clone()
		EquipVFX2.Parent = RootPart
		for _, Emitter in EquipVFX2:GetDescendants() do
			if Emitter:IsA("ParticleEmitter") then
				Emitter:Emit(20)
			end
		end
		Debris:AddItem(EquipVFX2, 3)
	end)

	Connections[PlayerEquipped]["CharacterRemoving_Equip"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged_Equip"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
				FullCleanup()
			end
		end)

	return true
end

-- IDLE ASSETS
function ScorchriftAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	local RootPart = PlayerEquipped.Character or PlayerEquipped.CharacterAdded:Wait()
	if not RootPart then
		return
	end

	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

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
	--if Tracks[PlayerEquipped]["EquipAnimation"] then
	--Tracks[PlayerEquipped]["EquipAnimation"].Ended:Connect(function()
	if Tracks[PlayerEquipped]["IdleAnimation"] then
		Tracks[PlayerEquipped]["IdleAnimation"]:Play(0.25)
		Tracks[PlayerEquipped]["IdleAnimation"]:AdjustSpeed(0.6)
	end
	--end)
	--end

	Connections[PlayerEquipped]["CharacterRemoving_Idle"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged_Idle"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
				FullCleanup()
			end
		end)

	return true
end

-- MOVEMENT ASSETS
function ScorchriftAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	-- TRACKS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

	-- CONNECTIONS
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

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
		if Tracks[PlayerRequired]["RunSFX"] then
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

		if Tracks[PlayerRequired]["FlyVFX"] then
			Tracks[PlayerRequired]["FlyVFX"]:Destroy()
			Tracks[PlayerRequired]["FlyVFX"] = nil
		end
	end

	-- INCASE
	FullCleanup()

	-- ANIMATIONS
	local WalkAnimId = DefaultData.Animations.WalkAnimation
	if not WalkAnimId then
		return
	end
	local RunAnimID = DefaultData.Animations.RunAnimation
	if not RunAnimID then
		return
	end

	-- CREATE SOUNDS
	local RunSFX = Instance.new("Sound")
	RunSFX.SoundId = DefaultData.SoundFX.RunSFX
	RunSFX.Parent = RootPart
	RunSFX.Name = "RunSFX"
	RunSFX.Looped = true
	RunSFX.Volume = 0.5
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

	local RunAnimation = Instance.new("Animation")
	RunAnimation.AnimationId = RunAnimID
	local RunTrack = Animator:LoadAnimation(RunAnimation)
	RunTrack.Name = "RunAnimation"
	RunTrack.Priority = Enum.AnimationPriority.Movement
	RunTrack.Looped = true
	Tracks[PlayerRequired]["RunAnimation"] = RunTrack

	local FlyWind =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Scorchrift"):FindFirstChild("FlyWind"):Clone()
	if not FlyWind then
		return
	end
	FlyWind.Parent = Character:FindFirstChild("Head")
	Tracks[PlayerRequired]["FlyVFX"] = FlyWind

	-- CONNECT TO WHEN RUNNING
	local WindTurnedOn = false
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
					DefaultData.Weight.TiltMultiplier = DefaultData.Weight.RunTilt
					RunTrack:Play(0.05)
					RunTrack:AdjustSpeed(0.7)
					if not RunSFX.IsPlaying then
						RunSFX:Play()
					end
				end
				for _, Emitter in FlyWind:GetDescendants() do
					if Emitter:IsA("ParticleEmitter") then
						WindTurnedOn = true
						Emitter.Enabled = true
					end
				end
				while RunSFX.Volume < 2.5 do
					if not IsRunning or IsShooting then
						break
					end
					RunSFX.Volume += 0.02
					task.wait()
				end
			else
				if RunTrack.IsPlaying then
					RunTrack:Stop(0.25)
				end
				if not WalkTrack.IsPlaying then
					DefaultData.Weight.TiltMultiplier = DefaultData.Weight.WalkTilt
					WalkTrack:Play(0.25)
					WalkTrack:AdjustSpeed(0.6)
				end
				for _, Emitter in FlyWind:GetDescendants() do
					if Emitter:IsA("ParticleEmitter") then
						Emitter.Enabled = false
					end
				end
				while RunSFX.Volume > 0 do
					if IsRunning then
						break
					end
					RunSFX.Volume -= 0.02
					task.wait()
				end
				RunSFX:Stop()
			end
		else
			-- STOP ANIMATIONS
			if not Connections[PlayerRequired]["StopDebounceTask"] then
				Connections[PlayerRequired]["StopDebounceTask"] = task.delay(0.1, function()
					DefaultData.Weight.TiltMultiplier = DefaultData.Weight.WalkTilt
					if RunTrack.IsPlaying then
						RunTrack:Stop(0.1)
					end
					if WalkTrack.IsPlaying then
						WalkTrack:Stop(0.25)
					end
					for _, Emitter in FlyWind:GetDescendants() do
						if Emitter:IsA("ParticleEmitter") then
							Emitter.Enabled = false
						end
					end
					while RunSFX.Volume > 0 do
						if IsRunning then
							break
						end
						RunSFX.Volume -= 0.02
						task.wait()
					end
					RunSFX:Stop()

					Connections[PlayerRequired]["StopDebounceTask"] = nil
				end)
			end
		end
	end)

	Connections[PlayerRequired]["CharacterRemoving_Walk"] = PlayerRequired.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerRequired]["EquippedGunChanged_Walk"] = PlayerRequired:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerRequired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				FullCleanup()
			end
		end)

	return true
end

-- SHOOT ASSETS
function ScorchriftAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
	local Tracks = ClientGunDataModule.Tracks
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	-- GET ANIMATION
	local StartAnimId = DefaultData.Animations["StartShooting"]
	if not StartAnimId then
		return
	end
	local ContinueAnimID = DefaultData.Animations["ContinueShooting"]
	if not ContinueAnimID then
		return
	end

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
			Tracks[PlayerFired]["ContinueShootingSFX"] = nil
		end

		Connections[PlayerFired]["ShootVolumeTask"] = task.spawn(function()
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				while
					Tracks[PlayerFired]["ContinueShootingSFX"]
					and Tracks[PlayerFired]["ContinueShootingSFX"].Volume > 0
				do
					Tracks[PlayerFired]["ContinueShootingSFX"].Volume =
						math.max(Tracks[PlayerFired]["ContinueShootingSFX"].Volume - 0.05, 0)
					task.wait(0.01)
				end
				if Tracks[PlayerFired]["ContinueShootingSFX"] then
					Tracks[PlayerFired]["ContinueShootingSFX"]:Stop()
					Tracks[PlayerFired]["ContinueShootingSFX"]:Destroy()
					Tracks[PlayerFired]["ContinueShootingSFX"] = nil
				end
			end
			Connections[PlayerFired]["ShootVolumeTask"] = nil
		end)

		Tracks[PlayerFired]["StartShootingAnimation"] = nil
		Tracks[PlayerFired]["ContinueShootingAnimation"] = nil
	end

	-- INCASSE
	FullCleanup()

	-- BEAM SHOOTING SFX
	local BeamSFX = Instance.new("Sound")
	BeamSFX.SoundId = DefaultData.SoundFX.ShootSFX
	BeamSFX.Volume = 3.5
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
		if Tracks[PlayerFired]["StartShootingAnimation"] then
			Tracks[PlayerFired]["StartShootingAnimation"]:Stop()
		end

		if Tracks[PlayerFired]["ContinueShootingAnimation"] then
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
		end

		Connections[PlayerFired]["ShootVolumeTask"] = task.spawn(function()
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				while Tracks[PlayerFired]["ContinueShootingSFX"].Volume > 0 do
					Tracks[PlayerFired]["ContinueShootingSFX"].Volume =
						math.max(Tracks[PlayerFired]["ContinueShootingSFX"].Volume - 0.1, 0)
					task.wait()
				end
				Tracks[PlayerFired]["ContinueShootingSFX"].Volume = 3.5
				Tracks[PlayerFired]["ContinueShootingSFX"]:Stop(0.2)
			end
			Connections[PlayerFired]["ShootVolumeTask"] = nil
		end)
	end

	Connections[PlayerFired]["CharacterRemoving_Shoot"] = PlayerFired.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	-- CLEANUP
	Connections[PlayerFired]["EquippedGunChanged_Shoot"] = PlayerFired:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				FullCleanup()
			end
		end)

	-- CONTINUE IF SHOOTING OR NOT
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting")
		:Connect(function()
			if not PlayerFired:GetAttribute("IsShooting") then
				PartialCleanup()
			else
				if Connections[PlayerFired]["ShootVolumeTask"] then
					task.cancel(Connections[PlayerFired]["ShootVolumeTask"])
					Connections[PlayerFired]["ShootVolumeTask"] = nil
				end
				if
					Tracks[PlayerFired]["StartShootingAnimation"]
					and not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying
				then
					Tracks[PlayerFired]["StartShootingAnimation"]:Play(0.2)
				end
				if
					Tracks[PlayerFired]["ContinueShootingAnimation"]
					and not Tracks[PlayerFired]["ContinueShootingAnimation"].IsPlaying
				then
					Tracks[PlayerFired]["ContinueShootingAnimation"]:Play(0.2)
				end
				if Tracks[PlayerFired]["ContinueShootingSFX"] then
					task.delay(0.2, function()
						if not PlayerFired:GetAttribute("IsShooting") then
							return
						end
						if Tracks[PlayerFired]["ContinueShootingSFX"].IsPlaying then
							Tracks[PlayerFired]["ContinueShootingSFX"].Volume = 3.5
						else
							Tracks[PlayerFired]["ContinueShootingSFX"]:Play()
						end
					end)
				end
			end
		end)

	return true
end

-- CHARGE ASSETS
function ScorchriftAssets.Charge(PlayerViewing, DefaultData, GunEquipped, PlayerCharging)
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	-- GET CHARGE ANIMATION IDS
	local ChargeStartID = DefaultData.Animations["ChargeStart"]
	if not ChargeStartID then
		return
	end
	local ContinueChargeID = DefaultData.Animations["ChargeContinue"]
	if not ContinueChargeID then
		return
	end

	local Character = PlayerCharging.Character or PlayerCharging.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	local CurrentPlayerData = ClientPlayerData:Get(PlayerViewing)
	local Highlight = Character:WaitForChild("Highlight")

	-- VARIABLES
	local LightningChargeUpAuraVFX
	local LightningChargeVFX
	local WindEffect
	local EquipVFX
	local ChargeVFX1
	local ChargeImpact
	local NewHighlight

	-- CLEANUP FUNCTIONS
	local function FullCleanup()
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

		if Connections[PlayerCharging]["Land"] then
			Connections[PlayerCharging]["Land"]:Disconnect()
			Connections[PlayerCharging]["Land"] = nil
		end

		if Connections[PlayerCharging]["Jump"] then
			Connections[PlayerCharging]["Jump"]:Disconnect()
			Connections[PlayerCharging]["Jump"] = nil
		end

		if WindEffect then
			for _, Emitter in WindEffect:GetDescendants() do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = false
				end
			end
			Debris:AddItem(WindEffect, 2)
			WindEffect = nil
		end

		if EquipVFX then
			for _, VFX in EquipVFX:GetDescendants() do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			Debris:AddItem(EquipVFX, 2)
			EquipVFX = nil
		end

		if ChargeVFX1 then
			for _, Emitter in ChargeVFX1:GetDescendants() do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = false
				end
			end
			Debris:AddItem(ChargeVFX1, 1)
			ChargeVFX1 = nil
		end

		if ChargeImpact then
			Debris:AddItem(ChargeImpact, 2)
			ChargeImpact = nil
		end

		if NewHighlight then
			NewHighlight.Enabled = false
			NewHighlight:Destroy()
			NewHighlight = nil
		end

		while Highlight.FillTransparency < 1 do
			Highlight.FillTransparency += 0.1
			task.wait()
		end
	end

	FullCleanup()

	-- CREATE SOUNDS
	local StartChargeSFX = Instance.new("Sound")
	StartChargeSFX.SoundId = DefaultData.SoundFX.StartChargeSFX
	StartChargeSFX.Parent = RootPart
	StartChargeSFX.Volume = 2
	StartChargeSFX.PlaybackRegionsEnabled = true
	StartChargeSFX.PlaybackRegion = NumberRange.new(0, 1)
	StartChargeSFX.PlaybackSpeed = 1.2
	StartChargeSFX.Looped = false
	Tracks[PlayerCharging]["StartChargeSFX"] = StartChargeSFX

	local ContinueChargeSFX = Instance.new("Sound")
	ContinueChargeSFX.SoundId = DefaultData.SoundFX.ContinueChargeSFX
	ContinueChargeSFX.Volume = 2
	ContinueChargeSFX.PlaybackSpeed = 1
	--ContinueChargeSFX.PlaybackRegionsEnabled = true
	--ContinueChargeSFX.PlaybackRegion = NumberRange.new(0,0.7)
	ContinueChargeSFX.Looped = true
	ContinueChargeSFX.Parent = RootPart
	Tracks[PlayerCharging]["ContinueChargeSFX"] = ContinueChargeSFX

	local LandChargeSFX = Instance.new("Sound")
	LandChargeSFX.SoundId = DefaultData.SoundFX.LandChargeSFX
	LandChargeSFX.Volume = 2
	LandChargeSFX.PlaybackSpeed = 1.5
	--ContinueChargeSFX.PlaybackRegionsEnabled = true
	--ContinueChargeSFX.PlaybackRegion = NumberRange.new(0,0.7)
	LandChargeSFX.Looped = false
	LandChargeSFX.Parent = RootPart
	Tracks[PlayerCharging]["LandChargeSFX"] = LandChargeSFX

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

	-- PARTIAL CLEANUP
	local function PartialCleanup()
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

		if WindEffect then
			for _, Emitter in WindEffect:GetDescendants() do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = false
				end
			end
			Debris:AddItem(WindEffect, 2)
			WindEffect = nil
		end

		if EquipVFX then
			for _, VFX in EquipVFX:GetDescendants() do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = false
				end
			end
			Debris:AddItem(EquipVFX, 2)
			EquipVFX = nil
		end

		if ChargeVFX1 then
			for _, Emitter in ChargeVFX1:GetDescendants() do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = false
				end
			end
		end

		if NewHighlight then
			NewHighlight.Enabled = false
			NewHighlight:Destroy()
			NewHighlight = nil
		end

		while Highlight.FillTransparency < 1 do
			Highlight.FillTransparency += 0.1
			task.wait()
		end
	end

	-- FULL CLEANUP CONNECTIONS
	Connections[PlayerCharging]["EquippedGunChanged_Charge"] = PlayerCharging
		:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerCharging:GetAttribute("IsEquippingGun") ~= GunEquipped then
				FullCleanup()
			end
		end)

	Connections[PlayerCharging]["CharacterRemoving_Charge"] = PlayerCharging.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerCharging]["Jump"] = StartTrack:GetMarkerReachedSignal("Jump"):Connect(function()
		if Tracks[PlayerCharging]["StartChargeSFX"] then
			Tracks[PlayerCharging]["StartChargeSFX"]:Play()
		end
	end)

	ChargeImpact =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Scorchrift"):FindFirstChild("ChargeImpact"):Clone()
	Connections[PlayerCharging]["Land"] = StartTrack:GetMarkerReachedSignal("Land"):Connect(function()
		if Tracks[PlayerCharging]["LandChargeSFX"] then
			Tracks[PlayerCharging]["LandChargeSFX"]:Play()
		end

		ChargeImpact.Position = RootPart.Position + Vector3.new(0, -1, 0)
		for _, Emitter in ChargeImpact:GetDescendants() do
			if Emitter:IsA("ParticleEmitter") then
				Emitter:Emit(40)
			end
		end
		ChargeImpact.Parent = workspace:FindFirstChild("ActiveVFX")

		-- ROCK DEBRIS
		local RockDebrisSettings = {
			Part = nil,
			Position = RootPart.Position,
			RockAmount = 8,
			Size = 0.5,
			HorizontalStrength = 20,
			VerticalStrength = 30,
			Time = 2,
		}

		-- BUNCH OF STUFF
		RockModule.RockDebris(RockDebrisSettings)
		ScreenShakeModule.ApplyScreenShake(false, PlayerViewing, PlayerCharging, 0.3, 100, 25)
	end)

	local function PlayChargeAssets()
		-- PLAY ASSETS
		if Tracks[PlayerCharging]["ChargeStartAnimation"] then
			Tracks[PlayerCharging]["ChargeStartAnimation"]:Play()
		end
		if Tracks[PlayerCharging]["ChargeContinueAnimation"] then
			Tracks[PlayerCharging]["ChargeContinueAnimation"]:Play()
		end

		-- START TRACK ENDED CONNECTION
		Connections[PlayerCharging]["StartTrackEnded"] = StartTrack.Ended:Connect(function()
			Tracks[PlayerCharging]["ContinueChargeSFX"]:Play()

			-- WIND EFFECT
			WindEffect = ReplicatedStorage.GunVFX.WindEffect.WindEffect:Clone()
			WindEffect.Parent = RootPart
			for _, Effect in pairs(WindEffect:GetDescendants()) do
				if Effect:IsA("ParticleEmitter") then
					Effect.Enabled = true
					Effect.Rate = Effect.Rate
					Effect.Color = ColorSequence.new(Color3.fromRGB(255, 185, 188))
				end
			end
			WindEffect.Position = Vector3.new(0, -2, 0)

			-- CHARGE VFX
			ChargeVFX1 = ReplicatedStorage:FindFirstChild("GunVFX")
				:FindFirstChild("Scorchrift")
				:FindFirstChild("ChargeVFX1")
				:Clone()
			ChargeVFX1.Parent = Character:FindFirstChild("Torso")
			for _, Emitter in ChargeVFX1:GetDescendants() do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = true
				end
			end

			task.spawn(function()
				while PlayerCharging:GetAttribute("VisuallyCharging") do
					ScreenShakeModule.ApplyScreenShake(false, PlayerViewing, PlayerCharging, 0.04, 100, 1)
					task.wait()
				end
			end)

			task.spawn(function()
				while PlayerCharging:GetAttribute("VisuallyCharging") do
					while Highlight.FillTransparency > 0.8 do
						if not PlayerCharging:GetAttribute("VisuallyCharging") then
							break
						end
						Highlight.FillTransparency -= 0.02
						task.wait(0.02)
					end
					if PlayerCharging:GetAttribute("VisuallyCharging") then
						task.wait(1)
					end
					while Highlight.FillTransparency < 1 do
						Highlight.FillTransparency += 0.02
						task.wait(0.02)
					end
				end
			end)
		end)

		-- ARM HIGHLIGHT
		NewHighlight = Instance.new("Highlight")
		NewHighlight.FillTransparency = 1
		NewHighlight.OutlineTransparency = 1
		NewHighlight.Parent = Character:FindFirstChild("Right Arm")
		NewHighlight.FillTransparency = 0.65
		Debris:AddItem(NewHighlight, 2)

		task.spawn(function()
			while NewHighlight and NewHighlight.FillTransparency < 1 do
				NewHighlight.FillTransparency += 0.01
				task.wait(0.03)
			end
			if NewHighlight then
				NewHighlight.Enabled = false
				NewHighlight:Destroy()
				NewHighlight = nil
			end
		end)
	end

	-- ATTRIBUTE CHANGED CONNECTION
	Connections[PlayerCharging]["IsChargingChanged"] = PlayerCharging:GetAttributeChangedSignal("VisuallyCharging")
		:Connect(function()
			if not PlayerCharging:GetAttribute("VisuallyCharging") or PlayerCharging:GetAttribute("IsShooting") then
				PartialCleanup()
			else
				PlayChargeAssets()
			end
		end)

	return true
end

-- DASH ASSETS
function ScorchriftAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return true -- no dash for this gun
end

-- RELOAD
function ScorchriftAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have reload
end

-- UI
function ScorchriftAssets.UI(LocalPlayer, GunEquipped)
	return LightningAssets.UI(LocalPlayer, GunEquipped)
end

-- WALL HIT VFX
local LightningSFX = {}
local TimeSinceHit = {}
local SFXRunning = {}
local MostRecentPosition = {}
function ScorchriftAssets.WallHit(PlayerShot, ResultData)
	if not ResultData.Normal then
		return
	end
	-- DEFAULT DATA
	local EquippedGun = PlayerShot:GetAttribute("IsEquippingGun")
	if not EquippedGun then
		return
	end
	local DefaultData = ClientGunDataModule:Get(PlayerShot)
	if not DefaultData then
		return
	end

	TimeSinceHit[PlayerShot] = tick()
	MostRecentPosition[PlayerShot] = ResultData.Position
	if not SFXRunning[PlayerShot] then
		local ID = HttpService:GenerateGUID(false)
		local SFXData = {
			Volume = 1.5,
			PlaybackSpeed = 1,
			Looped = true,
			SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX")
				:FindFirstChild("Scorchrift")
				:FindFirstChild("WallHitSFX"),
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

	local WallHitVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Scorchrift"):FindFirstChild("WallHit"):Clone()
	if not WallHitVFX then
		return
	end
	WallHitVFX.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal * -2)
	WallHitVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	for _, Emitter in WallHitVFX:GetChildren() do
		if math.random() <= 0.25 then
			continue
		end
		Emitter:Emit(1)
	end
	Debris:AddItem(WallHitVFX, 0.7)
end

-- WALL MARK VFX
local LightningWallEffect = {}
local LastWallMarkPos = {}
local LastWallMarkConn = {}
function ScorchriftAssets.WallMark(PlayerShot, ResultData)
	if not ResultData.Normal then
		return
	end

	local LightningVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Lightning")
	if not LightningVFX then
		return
	end

	if LastWallMarkPos[PlayerShot] and LastWallMarkPos[PlayerShot]["WallEffect"] then
		if (LastWallMarkPos[PlayerShot]["WallEffect"].Position - ResultData.Position).Magnitude < 0.03 then
			LastWallMarkPos[PlayerShot]["WallEffect"]:Destroy()
			LastWallMarkPos[PlayerShot]["WallEffect"] = nil
		end
	end

	-- WALL EFFECT AND POS OFFSET
	local WallEffect = LightningVFX:FindFirstChild("LightningHitEffect")
		:FindFirstChild("WallEffect")
		:FindFirstChild("WallEffect")
		:Clone()
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
function ScorchriftAssets.ZombieHit(PlayerShot, ResultData)
	-- DEFAULT DATA
	local EquippedGun = PlayerShot:GetAttribute("IsEquippingGun")
	if not EquippedGun then
		return
	end
	local DefaultData = ClientGunDataModule:Get(PlayerShot)
	if not DefaultData then
		return
	end

	TimeSinceHit[PlayerShot] = tick()
	MostRecentPosition[PlayerShot] = ResultData.Position
	if not SFXRunning[PlayerShot] then
		local ID = HttpService:GenerateGUID(false)
		local SFXData = {
			Volume = 1.5,
			PlaybackSpeed = 1,
			Looped = true,
			SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX")
				:FindFirstChild("Scorchrift")
				:FindFirstChild("ZombieHitSFX"),
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

	local WallHitVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Scorchrift"):FindFirstChild("WallHit"):Clone()
	if not WallHitVFX then
		return
	end
	if ResultData.Normal then
		WallHitVFX.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal)
	else
		WallHitVFX.CFrame = CFrame.new(ResultData.Position)
	end
	WallHitVFX.Parent = workspace:FindFirstChild("ActiveVFX")

	for _, Emitter in WallHitVFX:GetChildren() do
		if math.random() <= 0.5 then
			continue
		end
		Emitter:Emit(1)
	end
	Debris:AddItem(WallHitVFX, 0.7)

	if not ResultData.Position or not ResultData.Instance then
		return
	end -- some reason was crashing code
	if ZombieHit[ResultData.Instance] and (tick() - ZombieHit[ResultData.Instance] < 0.5) then
		return
	end
	ZombieHit[ResultData.Instance] = tick()

	-- VFX
	local BloodVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("BloodVFX"):Clone()
	if not BloodVFX then
		return
	end

	--if TimeSinceBloodSFX[PlayerShot] and (tick() - TimeSinceBloodSFX[PlayerShot] < 0.2) then return end

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
	local BloodSFX = Instance.new("Sound")
	BloodSFX.SoundId = DefaultData.SoundFX.BloodSFX
	BloodSFX.Volume = 0.15

	-- PICK RANDOM PLAYBACK SPEED
	local RandomPlaySpeed = math.random(100, 200) / 100
	BloodSFX.PlaybackSpeed = RandomPlaySpeed

	-- PLAY SOUND
	BloodSFX.Parent = ResultData.Instance
	BloodSFX:Play()

	Debris:AddItem(BloodSFX, 2)

	TimeSinceBloodSFX[PlayerShot] = tick()
end

-- STREAM BULLET
function ScorchriftAssets.StreamBullet(PlayerFired, BulletData)
	if PlayerFired:GetAttribute("IsWelding") then
		return
	end
	local StreamBulletModel
	if
		not ClientGunDataModule.StreamBullet[PlayerFired]
		or ClientGunDataModule.StreamBullet[PlayerFired].CharacterFired ~= PlayerFired.Character
	then
		local GunVFX = ReplicatedStorage:FindFirstChild("GunVFX")
		if not GunVFX then
			return
		end
		local Muzzle = PlayerFired.Character:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle")
		if not Muzzle then
			return
		end

		-- CLONE VFX
		local BeamEffect = GunVFX:FindFirstChild("Scorchrift"):FindFirstChild("BeamEffect"):Clone()
		BeamEffect.Parent = workspace:WaitForChild("BulletsFolder")

		-- DESTROY PREVIOUS BULLET MODEL
		local PreviousModel = ClientGunDataModule.StreamBullet[PlayerFired]
			and ClientGunDataModule.StreamBullet[PlayerFired].BulletClone
		if PreviousModel then
			PreviousModel:Destroy()
		end

		-- CREATE NEW BULLET MODEL
		StreamBulletModel = BeamEffect
		local StartBeam = BeamEffect:FindFirstChild("StartBeam")
		local EndBeam = BeamEffect:FindFirstChild("EndBeam")

		local BeamEffect2 = BeamEffect:Clone()
		BeamEffect2.Parent = BeamEffect
		local StartBeam2 = BeamEffect2:FindFirstChild("StartBeam")
		local EndBeam2 = BeamEffect2:FindFirstChild("EndBeam")

		-- WELD START BEAM2 TO START BEAM 1
		local Weld3 = Instance.new("Weld")
		Weld3.Name = "StartBeamWeld2"
		Weld3.Part0 = StartBeam
		Weld3.Part1 = StartBeam2
		Weld3.C0 = CFrame.new(-0.6, 0, 0)
		Weld3.C1 = CFrame.new(0, 0, 0)
		Weld3.Parent = StartBeam2

		-- WELD END BEAM2 TO END BEAM 1
		local Weld4 = Instance.new("Weld")
		Weld4.Name = "EndBeamWeld2"
		Weld4.Part0 = EndBeam
		Weld4.Part1 = EndBeam2
		Weld4.C0 = CFrame.new(-0.6, 0, 0)
		Weld4.C1 = CFrame.new(0, 0, 0)
		Weld4.Parent = EndBeam2

		-- BEAM 2PROPERTIES
		StartBeam2.Anchored = false
		StartBeam2.CanCollide = false
		StartBeam2.Massless = true
		StartBeam2.Color = Color3.fromRGB(255, 0, 4)
		StartBeam2.Transparency = 1
		EndBeam2.Anchored = false
		EndBeam2.CanCollide = false
		EndBeam2.Massless = true
		EndBeam2.Color = Color3.fromRGB(255, 0, 4)
		EndBeam2.Transparency = 1

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
		Weld.C0 = CFrame.new(0.3, 0, 0)
		Weld.C1 = CFrame.new(0, 0, 0)
		Weld.Parent = BeamEffect

		local Weld2 = Instance.new("Weld")
		Weld2.Name = "EndBeamWeld"
		Weld2.Part0 = Muzzle
		Weld2.Part1 = EndBeam
		Weld2.C0 = CFrame.new(0.3, 0, 0)
		Weld2.C1 = CFrame.new(0, 0, 0)
		Weld2.Parent = BeamEffect
	else
		StreamBulletModel = ClientGunDataModule.StreamBullet[PlayerFired].BulletClone
	end

	return StreamBulletModel
end

-- RETURN
return ScorchriftAssets
