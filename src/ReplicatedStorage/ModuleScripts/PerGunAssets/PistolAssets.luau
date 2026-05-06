local PistolAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- FOLDERS
local Frameworks = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")

-- MODULE
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))
local ClientZombieData = require(Client:WaitForChild("ClientZombieData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))
local RockModule = require(Frameworks:WaitForChild("Rock"):WaitForChild("RockModule"))
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))
local ObjectPoolFW = require(Frameworks:WaitForChild("ObjectPool"):WaitForChild("ObjectPoolFW"))

-- EQUIP ASSETS
local PistolSFX = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("Pistol")
function PistolAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
		if Connections[PlayerEquipped]["CharacterRemoving_Equip"] then
			Connections[PlayerEquipped]["CharacterRemoving_Equip"]:Disconnect()
			Connections[PlayerEquipped]["CharacterRemoving_Equip"] = nil
		end
		if Connections[PlayerEquipped]["EquippedGunChanged"] then
			Connections[PlayerEquipped]["EquippedGunChanged"]:Disconnect()
			Connections[PlayerEquipped]["EquippedGunChanged"] = nil
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

	-- CLEANUP INCASE OF MULTIPLE ANIMATIONS
	FullCleanup()

	-- EQUIP SFX
	local EquipSFX = PistolSFX:FindFirstChild("EquipSFX"):Clone()
	EquipSFX.Parent = RootPart
	EquipSFX.Volume = 10
	EquipSFX.PlaybackSpeed = 2
	EquipSFX:Play()
	Tracks[PlayerEquipped]["EquipSFX"] = EquipSFX

	-- CREATE ANIMATION
	local EquipAnimation = Instance.new("Animation")
	EquipAnimation.AnimationId = DefaultData.Animations.EquipAnimation
	local EquipTrack = Animator:LoadAnimation(EquipAnimation)
	EquipTrack.Name = "EquipAnimation"
	EquipTrack.Looped = false
	EquipTrack:AdjustSpeed(0.25)
	EquipTrack.Priority = Enum.AnimationPriority.Action4
	Tracks[PlayerEquipped]["EquipAnimation"] = EquipTrack
	EquipTrack:Play()

	Connections[PlayerEquipped]["CharacterRemoving_Equip"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
				FullCleanup()
			end
		end)

	return true
end

-- IDLE ASSETS
function PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
	Tracks[PlayerEquipped]["IdleAnimation"]:Play()
	IdleTrack:AdjustSpeed(0.3)

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
function PistolAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
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
		if Connections[PlayerRequired]["MoveHeartbeat"] then
			Connections[PlayerRequired]["MoveHeartbeat"]:Disconnect()
			Connections[PlayerRequired]["MoveHeartbeat"] = nil
		end
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
	local RunSFX = PistolSFX:FindFirstChild("RunSFX"):Clone()
	RunSFX.Parent = RootPart
	RunSFX.Volume = 0.5
	RunSFX.Looped = false
	Tracks[PlayerRequired]["RunSFX"] = RunSFX

	-- CREATE ANIMATION
	local WalkAnimation = Instance.new("Animation")
	WalkAnimation.AnimationId = WalkAnimId
	local WalkTrack = Animator:LoadAnimation(WalkAnimation)
	WalkTrack.Name = "WalkAnimation"
	WalkTrack.Priority = Enum.AnimationPriority.Movement
	WalkTrack.Looped = true
	Tracks[PlayerRequired]["WalkAnimation"] = WalkTrack

	-- WALK SOUND
	local WalkSFX = PistolSFX:FindFirstChild("WalkSFX"):Clone()
	WalkSFX.Parent = RootPart
	WalkSFX.Volume = 0.35
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
	Connections[PlayerRequired]["WalkLeft"] = WalkTrack:GetMarkerReachedSignal("LeftStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Left", 1)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["WalkSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)
	Connections[PlayerRequired]["WalkRight"] = WalkTrack:GetMarkerReachedSignal("RightStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Right", 1)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["WalkSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)

	Connections[PlayerRequired]["RunLeft"] = RunTrack:GetMarkerReachedSignal("LeftStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Left", 1)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["RunSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["RunSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)
	Connections[PlayerRequired]["RunRight"] = RunTrack:GetMarkerReachedSignal("RightStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Right", 1)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["RunSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["RunSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
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

	-- CONNECT TO WHEN RUNNING
	Connections[PlayerRequired]["MoveHeartbeat"] = RunService.Heartbeat:Connect(function(deltaTime)
		if not PlayerRequired or not Humanoid or not Humanoid.Parent or not Character then
			if Connections[PlayerRequired]["MoveHeartbeat"] then
				Connections[PlayerRequired]["MoveHeartbeat"]:Disconnect()
			end
			return
		end
		local Speed = Humanoid.WalkSpeed * Humanoid.MoveDirection.Magnitude

		-- GET ATTRIBUTES
		local IsRunning = PlayerRequired:GetAttribute("IsSprinting")
		local IsShooting = PlayerRequired:GetAttribute("IsShooting")
		local IsKnocked = PlayerRequired:GetAttribute("IsKnocked")

		if Tracks[PlayerRequired]["WalkAnimation"] then
			Tracks[PlayerRequired]["WalkAnimation"]:AdjustSpeed(Humanoid.WalkSpeed / 20)
		end
		if Tracks[PlayerRequired]["RunAnimation"] then
			Tracks[PlayerRequired]["RunAnimation"]:AdjustSpeed(Humanoid.WalkSpeed / 20)
		end

		if Speed > 2 and not IsKnocked then
			-- CANCEL EXISTING DEBOUNCE TASK
			if Connections[PlayerRequired]["StopDebounceTask"] then
				task.cancel(Connections[PlayerRequired]["StopDebounceTask"])
				Connections[PlayerRequired]["StopDebounceTask"] = nil
			end

			if IsRunning and not IsShooting then
				if Tracks[PlayerRequired]["WalkAnimation"].IsPlaying then
					Tracks[PlayerRequired]["WalkAnimation"]:Stop(0.25)
				end
				if not Tracks[PlayerRequired]["RunAnimation"].IsPlaying then
					Tracks[PlayerRequired]["RunAnimation"]:Play(0.25)
				end
			else
				if Tracks[PlayerRequired]["RunAnimation"].IsPlaying then
					Tracks[PlayerRequired]["RunAnimation"]:Stop(0.1)
				end
				if not Tracks[PlayerRequired]["WalkAnimation"].IsPlaying then
					Tracks[PlayerRequired]["WalkAnimation"]:Play(0.25)
				end
			end
		else
			-- STOP ANIMATIONS
			if not Connections[PlayerRequired]["StopDebounceTask"] then
				Connections[PlayerRequired]["StopDebounceTask"] = task.delay(0.1, function()
					if Tracks[PlayerRequired]["RunAnimation"] and Tracks[PlayerRequired]["RunAnimation"].IsPlaying then
						Tracks[PlayerRequired]["RunAnimation"]:Stop(0.1)
					end
					if
						Tracks[PlayerRequired]["WalkAnimation"] and Tracks[PlayerRequired]["WalkAnimation"].IsPlaying
					then
						Tracks[PlayerRequired]["WalkAnimation"]:Stop(0.25)
					end
					Connections[PlayerRequired]["StopDebounceTask"] = nil
				end)
			end
		end
	end)

	return true
end

-- SHOOT ASSETS
function PistolAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
	-- TRACKS
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

	-- CHARACTER
	local Character = PlayerFired.Character or PlayerFired.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)

	-- MUZZLE
	local Muzzle = Character and Character:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle")
	if not Muzzle then
		return
	end

	-- CLEANUP FUNCTION
	local function FullCleanup()
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

		if Connections[PlayerFired]["IsShotFiredChange"] then
			Connections[PlayerFired]["IsShotFiredChange"]:Disconnect()
			Connections[PlayerFired]["IsShotFiredChange"] = nil
		end

		if Tracks[PlayerFired]["ContinueShootingSFX"] then
			Tracks[PlayerFired]["ContinueShootingSFX"]:Stop()
			Tracks[PlayerFired]["ContinueShootingSFX"]:Destroy()
			Tracks[PlayerFired]["ContinueShootingSFX"] = nil
		end
	end

	-- INCASE
	FullCleanup()

	-- SHOT SFX
	local ShootSFX = PistolSFX:FindFirstChild("ShootSFX"):Clone()
	ShootSFX.Parent = RootPart
	ShootSFX.Volume = 2
	ShootSFX.PlaybackSpeed = 1
	Tracks[PlayerFired]["ContinueShootingSFX"] = ShootSFX

	-- CREATE ANIMATION
	local StartAnimation = Instance.new("Animation")
	StartAnimation.AnimationId = StartAnimId
	local StartTrack = Animator:LoadAnimation(StartAnimation)
	StartTrack.Name = "StartShooting"
	StartTrack.Priority = Enum.AnimationPriority.Action2
	StartTrack.Looped = true
	Tracks[PlayerFired]["StartShootingAnimation"] = StartTrack

	local ContinueAnimation = Instance.new("Animation")
	ContinueAnimation.AnimationId = ContinueAnimID
	-- CREATE CONTINUE TRACK
	local ContinueTrack = Animator:LoadAnimation(ContinueAnimation)
	ContinueTrack.Name = "ContinueShooting"
	ContinueTrack.Priority = Enum.AnimationPriority.Action3
	ContinueTrack.Looped = false
	Tracks[PlayerFired]["ContinueShootingAnimation"] = ContinueTrack

	local function PartialCleanup()
		Tracks[PlayerFired]["StartShootingAnimation"]:Stop()
		Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
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

	-- MUZZLE FIRE VFX
	local function PlayMuzzleVFX()
		for _, VFX in pairs(Muzzle:GetDescendants()) do
			if VFX:IsA("ParticleEmitter") then
				VFX:Emit(2)
			end
		end
	end

	local OriginalC0
	local function RotateEquippedGun(RotateToOffset)
		local CharacterEquippedGun = PlayerFired.Character:FindFirstChild("EquippedGun")
		if not CharacterEquippedGun then
			return
		end
		if not CharacterEquippedGun.PrimaryPart then
			return
		end
		local ArmWeld = CharacterEquippedGun.PrimaryPart:FindFirstChild("Weld")
		if not ArmWeld then
			return
		end
		-- STORE ORIGINAL C0
		if not OriginalC0 then
			OriginalC0 = ArmWeld.C0
		end

		local TweenInfo = TweenInfo.new(0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-10))
				TweenService:Create(ArmWeld, TweenInfo, { C0 = NewC0 }):Play()
			end
		else
			if PlayerFired:GetAttribute("ShotFired") then
				return
			end
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenInfo, { C0 = OriginalC0 }):Play()
			end
		end
	end

	-- CONTINUE ANIMATION IF SHOT FIRED
	Connections[PlayerFired]["IsShotFiredChange"] = PlayerFired:GetAttributeChangedSignal("ShotFired")
		:Connect(function()
			if PlayerFired:GetAttribute("ShotFired") then
				PlayMuzzleVFX()
				RotateEquippedGun(true)
				if Tracks[PlayerFired]["ContinueShootingAnimation"] and not PlayerFired:GetAttribute("IsKnocked") then
					Tracks[PlayerFired]["ContinueShootingAnimation"]:Play()
					Tracks[PlayerFired]["ContinueShootingAnimation"]:AdjustSpeed(2)
				else
					Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
				end
				if Tracks[PlayerFired]["ContinueShootingSFX"] then
					local ClonedSFX = Tracks[PlayerFired]["ContinueShootingSFX"]:Clone()
					ClonedSFX.Parent = RootPart
					ClonedSFX:Play()
					task.delay(0.5, function()
						ClonedSFX:Destroy()
					end)
				end
			else
				task.delay(0.1, function()
					RotateEquippedGun(false)
				end)
			end
		end)

	-- START SHOOTING ANIMATION
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting")
		:Connect(function()
			if not PlayerFired:GetAttribute("IsShooting") or PlayerFired:GetAttribute("IsKnocked") then
				PartialCleanup()
			else
				if not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying then
					Tracks[PlayerFired]["StartShootingAnimation"]:Play()
				end
			end
		end)

	return true
end

-- RELOAD ASSETS
function PistolAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
	-- TRACKS AND CONNECTIONS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	-- GET RELOAD ANIMATION ID
	local ReloadAnimId = DefaultData.Animations["ReloadAnimation"]
	if not ReloadAnimId then
		return
	end

	-- CHARACTER
	local Character = PlayerReloading.Character or PlayerReloading.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)

	-- EQUIPPED GUN AND STUFF FOR WELD
	local EquippedGun = Character:FindFirstChild("EquippedGun")
	if not EquippedGun then
		return
	end
	local Mag = EquippedGun:FindFirstChild("Mag")
	if not Mag then
		return
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end

	local MagClone
	local function FullCleanup()
		if Tracks[PlayerReloading]["ReloadAnimation"] then
			Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
			Tracks[PlayerReloading]["ReloadAnimation"]:Destroy()
			Tracks[PlayerReloading]["ReloadAnimation"] = nil
		end

		if Tracks[PlayerReloading]["ReloadSFX"] then
			Tracks[PlayerReloading]["ReloadSFX"]:Stop()
			Tracks[PlayerReloading]["ReloadSFX"]:Destroy()
			Tracks[PlayerReloading]["ReloadSFX"] = nil
		end

		if Tracks[PlayerReloading]["OutOfAmmoSFX"] then
			Tracks[PlayerReloading]["OutOfAmmoSFX"]:Stop()
			Tracks[PlayerReloading]["OutOfAmmoSFX"]:Destroy()
			Tracks[PlayerReloading]["OutOfAmmoSFX"] = nil
		end

		if Connections[PlayerReloading]["EquippedGunChanged_Reload"] then
			Connections[PlayerReloading]["EquippedGunChanged_Reload"]:Disconnect()
			Connections[PlayerReloading]["EquippedGunChanged_Reload"] = nil
		end

		if Connections[PlayerReloading]["CharacterRemoving_Reload"] then
			Connections[PlayerReloading]["CharacterRemoving_Reload"]:Disconnect()
			Connections[PlayerReloading]["CharacterRemoving_Reload"] = nil
		end

		if Connections[PlayerReloading]["OutOfAmmoSFX"] then
			Connections[PlayerReloading]["OutOfAmmoSFX"]:Disconnect()
			Connections[PlayerReloading]["OutOfAmmoSFX"] = nil
		end

		if Connections[PlayerReloading]["ReloadAttribute"] then
			Connections[PlayerReloading]["ReloadAttribute"]:Disconnect()
			Connections[PlayerReloading]["ReloadAttribute"] = nil
		end

		if Tracks[PlayerReloading]["MagOutSFX"] then
			Tracks[PlayerReloading]["MagOutSFX"]:Stop()
			Tracks[PlayerReloading]["MagOutSFX"]:Destroy()
			Tracks[PlayerReloading]["MagOutSFX"] = nil
		end

		if Tracks[PlayerReloading]["MagInSFX"] then
			Tracks[PlayerReloading]["MagInSFX"]:Stop()
			Tracks[PlayerReloading]["MagInSFX"]:Destroy()
			Tracks[PlayerReloading]["MagInSFX"] = nil
		end

		if Tracks[PlayerReloading]["PullSFX"] then
			Tracks[PlayerReloading]["PullSFX"]:Stop()
			Tracks[PlayerReloading]["PullSFX"]:Destroy()
			Tracks[PlayerReloading]["PullSFX"] = nil
		end

		if Tracks[PlayerReloading]["MagDropSFX"] then
			Tracks[PlayerReloading]["MagDropSFX"]:Stop()
			Tracks[PlayerReloading]["MagDropSFX"]:Destroy()
			Tracks[PlayerReloading]["MagDropSFX"] = nil
		end

		if Connections[PlayerReloading]["Pull"] then
			Connections[PlayerReloading]["Pull"]:Disconnect()
			Connections[PlayerReloading]["Pull"] = nil
		end

		if Connections[PlayerReloading]["MagOutEvent"] then
			Connections[PlayerReloading]["MagOutEvent"]:Disconnect()
			Connections[PlayerReloading]["MagOutEvent"] = nil
		end
		if Connections[PlayerReloading]["MagInEvent"] then
			Connections[PlayerReloading]["MagInEvent"]:Disconnect()
			Connections[PlayerReloading]["MagInEvent"] = nil
		end
		if Connections[PlayerReloading]["MagDropEvent"] then
			Connections[PlayerReloading]["MagDropEvent"]:Disconnect()
			Connections[PlayerReloading]["MagDropEvent"] = nil
		end

		if MagClone then
			MagClone:Destroy()
			MagClone = nil
		end
	end

	-- INCASE
	FullCleanup()

	-- CREATE RELOAD ANIMATION
	local ReloadAnimation = Instance.new("Animation")
	ReloadAnimation.AnimationId = ReloadAnimId
	Tracks[PlayerReloading]["ReloadAnimation"] = Animator:LoadAnimation(ReloadAnimation)
	Tracks[PlayerReloading]["ReloadAnimation"].Name = "ReloadAnimation"
	Tracks[PlayerReloading]["ReloadAnimation"].Priority = Enum.AnimationPriority.Action3
	Tracks[PlayerReloading]["ReloadAnimation"].Looped = false

	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["MagOutSFX"] = PistolSFX:FindFirstChild("MagOutSFX"):Clone()
	Tracks[PlayerReloading]["MagOutSFX"].Volume = 5
	Tracks[PlayerReloading]["MagOutSFX"].PlaybackSpeed = 1.6
	Tracks[PlayerReloading]["MagOutSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["MagInSFX"] = PistolSFX:FindFirstChild("MagInSFX"):Clone()
	Tracks[PlayerReloading]["MagInSFX"].Volume = 5
	Tracks[PlayerReloading]["MagInSFX"].PlaybackSpeed = 1.6
	Tracks[PlayerReloading]["MagInSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["PullSFX"] = PistolSFX:FindFirstChild("PullSFX"):Clone()
	Tracks[PlayerReloading]["PullSFX"].Volume = 3
	Tracks[PlayerReloading]["PullSFX"].PlaybackSpeed = 1.6
	Tracks[PlayerReloading]["PullSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	-- CREATE MAG DROP SFX
	Tracks[PlayerReloading]["MagDropSFX"] = PistolSFX:FindFirstChild("MagDropSFX"):Clone()
	Tracks[PlayerReloading]["MagDropSFX"].Volume = 0.4
	Tracks[PlayerReloading]["MagDropSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["MagDropSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	-- OUT OF AMMO SFX
	Tracks[PlayerReloading]["OutOfAmmoSFX"] = PistolSFX:FindFirstChild("OutOfAmmoSFX"):Clone()
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Volume = 1
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegionsEnabled = true
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegion = NumberRange.new(0, 0.5)
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	-- GET "MAG" ANIMATION SIGNAL
	Connections[PlayerReloading]["MagOutEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]
		:GetMarkerReachedSignal("MagOut")
		:Connect(function()
			Tracks[PlayerReloading]["MagOutSFX"]:Play()

			-- CHECK IF MAG CLONE EXISTS
			if not MagClone then
				MagClone = Mag:Clone()
				MagClone.Anchored = false
				MagClone.CanCollide = true
				MagClone.CollisionGroup = "Mag"
				local MagCloneWeld = MagClone:FindFirstChildOfClass("Weld")
				if MagCloneWeld then
					MagCloneWeld:Destroy()
				end
				MagClone.Parent = LeftArm
				Debris:AddItem(MagClone, 5)
				MagClone = nil
			end

			Mag.Transparency = 1
		end)
	Connections[PlayerReloading]["MagDropEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]
		:GetMarkerReachedSignal("MagDrop")
		:Connect(function()
			Tracks[PlayerReloading]["MagDropSFX"]:Play()
		end)
	Connections[PlayerReloading]["MagInEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]
		:GetMarkerReachedSignal("MagIn")
		:Connect(function()
			task.wait(0.1)
			if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then
				return
			end

			Mag.Transparency = 0
			if MagClone then
				MagClone:Destroy()
				MagClone = nil
			end
		end)
	Connections[PlayerReloading]["Pull"] = Tracks[PlayerReloading]["ReloadAnimation"]
		:GetMarkerReachedSignal("Pull")
		:Connect(function()
			Tracks[PlayerReloading]["PullSFX"]:Play()
		end)

	Connections[PlayerReloading]["EquippedGunChanged_Reload"] = PlayerReloading
		:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then
				FullCleanup()
			end
		end)

	Connections[PlayerReloading]["CharacterRemoving_Reload"] = PlayerReloading.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	-- ON SIGNAL PLAY/STOP ANIMATION AND SFX
	Connections[PlayerReloading]["ReloadAttribute"] = PlayerReloading:GetAttributeChangedSignal("IsReloading")
		:Connect(function()
			if PlayerReloading:GetAttribute("IsReloading") then
				if Tracks[PlayerReloading]["ReloadAnimation"] then
					Tracks[PlayerReloading]["ReloadAnimation"]:Play(0.1)
					Tracks[PlayerReloading]["ReloadAnimation"]:AdjustSpeed(0.8)
				end
			else
				Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
				if Tracks[PlayerReloading]["MagOutSFX"] then
					Tracks[PlayerReloading]["MagOutSFX"]:Stop()
				end

				if Tracks[PlayerReloading]["MagInSFX"] then
					Tracks[PlayerReloading]["MagInSFX"]:Stop()
				end

				if Tracks[PlayerReloading]["PullSFX"] then
					Tracks[PlayerReloading]["PullSFX"]:Stop()
				end

				if Tracks[PlayerReloading]["MagDropSFX"] then
					Tracks[PlayerReloading]["MagDropSFX"]:Stop()
				end
			end
		end)

	Connections[PlayerReloading]["OutOfAmmoSFX"] = PlayerReloading:GetAttributeChangedSignal("OutOfAmmoSFX")
		:Connect(function()
			-- ENSURE OUTOFAMMO SFX AND NOT RELOADING BEFORE PLAYING SFX
			if PlayerReloading:GetAttribute("OutOfAmmoSFX") and not PlayerReloading:GetAttribute("IsReloading") then
				if not Tracks[PlayerReloading]["OutOfAmmoSFX"].IsPlaying then
					Tracks[PlayerReloading]["OutOfAmmoSFX"]:Play()
				end
			end
		end)

	return true
end

-- DASH ASSETS
function PistolAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

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

		-- CLEAR VFX
		if Tracks[PlayerDashing]["DustVFX"] then
			Tracks[PlayerDashing]["DustVFX"]:Destroy()
			Tracks[PlayerDashing]["DustVFX"] = nil
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
	if not FrontDashID then
		return
	end
	local BackDashID = DefaultData.Animations["BackDash"]
	if not BackDashID then
		return
	end
	local LeftDashID = DefaultData.Animations["LeftDash"]
	if not LeftDashID then
		return
	end
	local RightDashID = DefaultData.Animations["RightDash"]
	if not RightDashID then
		return
	end

	-- DASH ANIMATIONS
	local FrontDashAnimation = Instance.new("Animation")
	FrontDashAnimation.AnimationId = FrontDashID
	local FrontDashTrack = Animator:LoadAnimation(FrontDashAnimation)
	FrontDashTrack.Priority = Enum.AnimationPriority.Action
	FrontDashTrack.Looped = false
	Tracks[PlayerDashing]["FrontDashTrack"] = FrontDashTrack

	local BackDashAnimation = Instance.new("Animation")
	BackDashAnimation.AnimationId = BackDashID
	local BackDashTrack = Animator:LoadAnimation(BackDashAnimation)
	BackDashTrack.Priority = Enum.AnimationPriority.Action
	BackDashTrack.Looped = false
	Tracks[PlayerDashing]["BackDashTrack"] = BackDashTrack

	local LeftDashAnimation = Instance.new("Animation")
	LeftDashAnimation.AnimationId = LeftDashID
	local LeftDashTrack = Animator:LoadAnimation(LeftDashAnimation)
	LeftDashTrack.Priority = Enum.AnimationPriority.Action
	LeftDashTrack.Looped = false
	Tracks[PlayerDashing]["LeftDashTrack"] = LeftDashTrack

	local RightDashAnimation = Instance.new("Animation")
	RightDashAnimation.AnimationId = RightDashID
	local RightDashTrack = Animator:LoadAnimation(RightDashAnimation)
	RightDashTrack.Priority = Enum.AnimationPriority.Action
	RightDashTrack.Looped = false
	Tracks[PlayerDashing]["RightDashTrack"] = RightDashTrack

	-- DASH SOUNDFX
	local DashSFX = PistolSFX:FindFirstChild("DashSFX"):Clone()
	DashSFX.Parent = Character:FindFirstChild("HumanoidRootPart")

	DashSFX.Volume = 4
	Tracks[PlayerDashing]["DashSFX"] = DashSFX

	-- DASH VFX
	local DustVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("Dust"):WaitForChild("Dust"):Clone()
	DustVFX.Parent = Character:WaitForChild("Torso")
	DustVFX.Position = Vector3.new(0, -1, 0)
	Tracks[PlayerDashing]["DustVFX"] = DustVFX

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

		if not EmitCount then
			EmitCount = 3
		end
		for _, Particle in pairs(VFXAttachment:GetDescendants()) do
			if Particle:IsA("ParticleEmitter") then
				Particle:Emit(EmitCount)
			end
		end
	end

	-- DSAH SIGNAL
	Connections[PlayerDashing]["DashingSignal"] = PlayerDashing:GetAttributeChangedSignal("IsDashing")
		:Connect(function()
			if PlayerDashing:GetAttribute("IsDashing") then
				local DashDirection = PlayerDashing:GetAttribute("DashDirection")

				-- PLAY SFX
				local ClonedSFX = Tracks[PlayerDashing]["DashSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				Debris:AddItem(ClonedSFX, 2)

				-- LOOP AND PLAY VFX
				task.spawn(function()
					while
						(PlayerDashing == PlayerViewing and PlayerDashing:GetAttribute("IsDashing"))
						or (PlayerDashing ~= PlayerViewing and PlayerDashing:GetAttribute("DashingVFX"))
					do
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
				Tracks[PlayerDashing]["FrontDashTrack"]:Stop(0.25)
				Tracks[PlayerDashing]["LeftDashTrack"]:Stop(0.25)
				Tracks[PlayerDashing]["BackDashTrack"]:Stop(0.25)
				Tracks[PlayerDashing]["RightDashTrack"]:Stop(0.25)
			end
		end)

	Connections[PlayerDashing]["EquippedGunChanged_Dash"] = PlayerDashing:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerDashing:GetAttribute("IsEquippingGun") ~= GunEquipped then
				FullCleanup()
			end
		end)

	Connections[PlayerDashing]["CharacterRemoving_Dash"] = PlayerDashing.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	return true
end

-- N/A
function PistolAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end

-- UI
function PistolAssets.UI(LocalPlayer, GunEquipped)
	-- GET PLAYER UI
	local PlayerGui = LocalPlayer.PlayerGui
	if not PlayerGui then
		return
	end

	-- GET GUN GUI
	local GunGui = PlayerGui:FindFirstChild("GunGuiFolder"):FindFirstChild("GunGui")
	if not GunGui then
		return
	end

	-- TRACKS AND CONNECTIONS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end
	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	local CurrentlyLerping = false

	local function FullCleanup()
		if Connections[LocalPlayer]["EquippedGunChanged_UI"] then
			Connections[LocalPlayer]["EquippedGunChanged_UI"]:Disconnect()
			Connections[LocalPlayer]["EquippedGunChanged_UI"] = nil
		end

		if Connections[LocalPlayer]["CharacterRemoving_UI"] then
			Connections[LocalPlayer]["CharacterRemoving_UI"]:Disconnect()
			Connections[LocalPlayer]["CharacterRemoving_UI"] = nil
		end

		if Connections[LocalPlayer]["ReloadAttribute_UI"] then
			Connections[LocalPlayer]["ReloadAttribute_UI"]:Disconnect()
			Connections[LocalPlayer]["ReloadAttribute_UI"] = nil
		end

		if Connections[LocalPlayer]["ShotAttribute_UI"] then
			Connections[LocalPlayer]["ShotAttribute_UI"]:Disconnect()
			Connections[LocalPlayer]["ShotAttribute_UI"] = nil
		end

		if Connections[LocalPlayer]["OutOfAmmoAttribute_UI"] then
			Connections[LocalPlayer]["OutOfAmmoAttribute_UI"]:Disconnect()
			Connections[LocalPlayer]["OutOfAmmoAttribute_UI"] = nil
		end

		CurrentlyLerping = nil
	end

	-- INCASE
	FullCleanup()

	Connections[LocalPlayer]["EquippedGunChanged_UI"] = LocalPlayer:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if LocalPlayer:GetAttribute("IsEquippingGun") ~= GunEquipped then
				FullCleanup()
			end
		end)

	Connections[LocalPlayer]["CharacterRemoving_UI"] = LocalPlayer.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	-- GET ORIGINAL COLORS
	local OriginalCurrentColor = GunGui.Frame.CurrentAmmo.TextColor3
	--Connections[LocalPlayer]["ReloadAttribute_UI"] = LocalPlayer:GetAttributeChangedSignal("WantsToReload"):Connect(function()
	--	if not LocalPlayer:GetAttribute("WantsToReload") then return end
	--	if CurrentlyLerping then return end

	--	-- IF NO CURRENT OR TOTAL AMMO (TWEEN COLORS OF UI)
	--	if LocalPlayer:GetAttribute("TotalAmmo") <= 0 and LocalPlayer:GetAttribute("CurrentAmmo") <= 0 then
	--		-- TWEEN TO
	--		local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local TargetColor = {TextColor3 = Color3.fromRGB(255, 0, 0)}

	--		local Tween
	--		for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
	--			Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
	--			Tween:Play()
	--		end
	--		CurrentlyLerping = true
	--		Tween.Completed:Wait()
	--		Tween:Destroy()

	--		-- TWEEN BACK
	--		local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local TargetColor = {TextColor3 = OriginalCurrentColor}
	--		local Tween
	--		for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
	--			Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
	--			Tween:Play()
	--		end
	--		Tween.Completed:Wait()
	--		Tween:Destroy()
	--		CurrentlyLerping = false

	--	-- IF NO TOTAL AMMO
	--	elseif LocalPlayer:GetAttribute("TotalAmmo") <= 0 then
	--		local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local Tween = TweenService:Create(GunGui.Frame.TotalAmmo, TweenToInfo, {TextColor3 = Color3.fromRGB(255, 0, 0)})
	--		Tween:Play()
	--		CurrentlyLerping = true
	--		Tween.Completed:Wait()
	--		Tween:Destroy()

	--		local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local Tween = TweenService:Create(GunGui.Frame.TotalAmmo, TweenBackInfo, {TextColor3 = OriginalCurrentColor})
	--		Tween:Play()
	--		Tween.Completed:Wait()
	--		Tween:Destroy()
	--		CurrentlyLerping = false
	--	end
	--end)

	-- SHOOTING
	--Connections[LocalPlayer]["ShotAttribute_UI"] = LocalPlayer:GetAttributeChangedSignal("WantsToShoot"):Connect(function()
	--	if not LocalPlayer:GetAttribute("WantsToShoot") then return end
	--	if CurrentlyLerping then return end

	--	-- IF NO CURRENT OR TOTAL AMMO (TWEEN COLORS OF UI)
	--	if LocalPlayer:GetAttribute("TotalAmmo") <= 0 and LocalPlayer:GetAttribute("CurrentAmmo") <= 0 then
	--		-- TWEEN TO
	--		local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local TargetColor = {TextColor3 = Color3.fromRGB(255, 0, 0)}

	--		local Tween
	--		for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
	--			Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
	--			Tween:Play()
	--		end
	--		CurrentlyLerping = true
	--		Tween.Completed:Wait()
	--		Tween:Destroy()

	--		-- TWEEN BACK
	--		local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local TargetColor = {TextColor3 = OriginalCurrentColor}
	--		local Tween
	--		for _, AmmoType in ipairs({GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo}) do
	--			Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
	--			Tween:Play()
	--		end
	--		Tween.Completed:Wait()
	--		Tween:Destroy()
	--		CurrentlyLerping = false

	--		-- IF NO CURRENT AMMO
	--	elseif LocalPlayer:GetAttribute("CurrentAmmo") <= 0 then
	--		local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local Tween = TweenService:Create(GunGui.Frame.CurrentAmmo, TweenToInfo, {TextColor3 = Color3.fromRGB(255, 0, 0)})
	--		Tween:Play()
	--		CurrentlyLerping = true
	--		Tween.Completed:Wait()
	--		Tween:Destroy()

	--		local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	--		local Tween = TweenService:Create(GunGui.Frame.CurrentAmmo, TweenBackInfo, {TextColor3 = OriginalCurrentColor})
	--		Tween:Play()
	--		Tween.Completed:Wait()
	--		Tween:Destroy()
	--		CurrentlyLerping = false
	--	end
	--end)

	Connections[LocalPlayer]["OutOfAmmoAttribute_UI"] = LocalPlayer:GetAttributeChangedSignal("OutOfAmmoSFX")
		:Connect(function()
			if not LocalPlayer:GetAttribute("OutOfAmmoSFX") then
				return
			end
			if CurrentlyLerping then
				return
			end
			-- IF NO CURRENT OR TOTAL AMMO (TWEEN COLORS OF UI)
			if LocalPlayer:GetAttribute("TotalAmmo") <= 0 and LocalPlayer:GetAttribute("CurrentAmmo") <= 0 then
				-- TWEEN TO
				local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local TargetColor = { TextColor3 = Color3.fromRGB(255, 0, 0) }

				local Tween
				for _, AmmoType in ipairs({ GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo }) do
					Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
					Tween:Play()
				end
				CurrentlyLerping = true
				Tween.Completed:Wait()
				Tween:Destroy()

				-- TWEEN BACK
				local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TargetColor = { TextColor3 = OriginalCurrentColor }
				for _, AmmoType in ipairs({ GunGui.Frame.CurrentAmmo, GunGui.Frame.TotalAmmo }) do
					Tween = TweenService:Create(AmmoType, TweenToInfo, TargetColor)
					Tween:Play()
				end
				Tween.Completed:Wait()
				Tween:Destroy()
				CurrentlyLerping = false

			-- IF NO CURRENT AMMO
			elseif LocalPlayer:GetAttribute("CurrentAmmo") <= 0 then
				local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local Tween = TweenService:Create(
					GunGui.Frame.CurrentAmmo,
					TweenToInfo,
					{ TextColor3 = Color3.fromRGB(255, 0, 0) }
				)
				Tween:Play()
				CurrentlyLerping = true
				Tween.Completed:Wait()
				Tween:Destroy()

				local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Tween =
					TweenService:Create(GunGui.Frame.CurrentAmmo, TweenBackInfo, { TextColor3 = OriginalCurrentColor })
				Tween:Play()
				Tween.Completed:Wait()
				Tween:Destroy()
				CurrentlyLerping = false
			elseif LocalPlayer:GetAttribute("TotalAmmo") <= 0 then
				local TweenToInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local Tween =
					TweenService:Create(GunGui.Frame.TotalAmmo, TweenToInfo, { TextColor3 = Color3.fromRGB(255, 0, 0) })
				Tween:Play()
				CurrentlyLerping = true
				Tween.Completed:Wait()
				Tween:Destroy()

				local TweenBackInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Tween =
					TweenService:Create(GunGui.Frame.TotalAmmo, TweenBackInfo, { TextColor3 = OriginalCurrentColor })
				Tween:Play()
				Tween.Completed:Wait()
				Tween:Destroy()
				CurrentlyLerping = false
			end
		end)

	return true
end

-- WALL HIT VFX
function PistolAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	if not ResultData.Normal then
		return
	end
	-- DEFAULT DATA
	local DefaultData = ClientGunDataModule.DefaultData[EquippedGun]
	if not DefaultData then
		return
	end

	-- SFX
	local ID = HttpService:GenerateGUID(false)
	local SFXData = {
		Volume = 1.25,
		PlaybackSpeed = 1,
		PlaybackRegion = NumberRange.new(0.05, 1.5),
		ForceNew = true,
		CleanupTime = 1,
		SFXToClone = PistolSFX:FindFirstChild("WallHitSFX"),
	}
	PlaySFXModule.PlayPartSFX(PlayerFired, ResultData.Position, ID, SFXData)

	-- VFX
	local WallHitVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Pistol"):FindFirstChild("WallHit"):Clone()
	if not WallHitVFX then
		return
	end

	-- ALIGN WITH WALL
	WallHitVFX.Position = ResultData.Position
	WallHitVFX.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal)

	for _, VFX in pairs(WallHitVFX:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX:Emit(1)
		end
	end

	WallHitVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallHitVFX, 3)

	-- SMOKE VFX
	local WallHitVFX2 =
		ReplicatedStorage:FindFirstChild("GunVFX"):WaitForChild("SmokeVFX"):WaitForChild("MuzzleSmokeVFX"):Clone()
	if not WallHitVFX2 then
		return
	end

	WallHitVFX2.Position = ResultData.Position
	WallHitVFX2.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal)

	for _, VFX in pairs(WallHitVFX2:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX.Color = ColorSequence.new(ResultData.Instance.Color)
			VFX:Emit(1)
		end
	end

	WallHitVFX2.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallHitVFX2, 3)
end

-- WALL MARK VFX
function PistolAssets.WallMark(PlayerFired, EquippedGun, ResultData)
	-- END IF NO NORMAL
	if not ResultData.Normal then
		return
	end

	-- VFX
	local WallMarkVFX =
		ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("Pistol"):FindFirstChild("WallMark"):Clone()
	if not WallMarkVFX then
		return
	end

	WallMarkVFX.Position = ResultData.Position
	WallMarkVFX.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal)

	for _, VFX in pairs(WallMarkVFX:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX:Emit(1)
		end
	end

	WallMarkVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallMarkVFX, 3)
end

-- ZOMBIE HIT VFX
function PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	-- DEFAULT DATA
	local DefaultData = ClientGunDataModule.DefaultData[EquippedGun]
	if not DefaultData then
		return
	end

	if not ResultData.Position or not ResultData.ID then
		return
	end

	-- GET THE ZOMBIE INSTANCE FROM ID
	local ZombieIndex = ClientZombieData.ZombieIndex[ResultData.ID]

	-- ZOMBIE CLONE
	local ZombieClone
	if ZombieIndex then
		ZombieClone = ClientZombieData.ZombieArray[ZombieIndex]
	else
		ZombieClone = ClientZombieData.GetZombieByID[ResultData.ID]
	end

	if not ZombieClone then
		return
	end
	if not ZombieClone.PrimaryPart then
		return
	end

	-- VFX
	local BloodVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("BloodVFX"):FindFirstChild("ZombieBlood"):Clone()
	if not BloodVFX then
		return
	end

	local AveragePosition = (ResultData.Position + ZombieClone.PrimaryPart.Position) / 2
	BloodVFX.Position = AveragePosition

	for _, VFX in pairs(BloodVFX:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") and not VFX:GetAttribute("EmitCount") then
			-- RANDOMIZE RED COLOR
			local RedColor = math.random(67, 140)
			local RandomColor = Color3.fromRGB(RedColor, 0, 0)
			VFX.Color = ColorSequence.new(RandomColor)
			VFX:Emit(1)
		end
		if VFX:GetAttribute("EmitCount") then
			VFX:Emit(VFX:GetAttribute("EmitCount"))
		end
	end
	BloodVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(BloodVFX, 2.5)

	-- SFX
	local ClonePistolSFX =
		ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("Pistol"):FindFirstChild("ZombieHitSFX"):Clone()

	-- PICK RANDOM PLAYBACK SPEED
	local RandomPlaySpeed = math.random(100, 200) / 100
	ClonePistolSFX.PlaybackSpeed = RandomPlaySpeed

	-- PLAY SOUND
	ClonePistolSFX.Parent = ZombieClone
	ClonePistolSFX:Play()

	Debris:AddItem(ClonePistolSFX, 2)
end

-- RETURN
return PistolAssets
