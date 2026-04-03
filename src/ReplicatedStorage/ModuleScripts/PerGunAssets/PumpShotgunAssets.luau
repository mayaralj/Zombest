local PumpShotgunAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")


-- FOLDERS
local Frameworks= ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))


-- MODULES
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))


-- MOST SILENCER STRUCTURE WILL BE THE SAME AS PISTOL
-- MODULE
local PistolAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("PistolAssets"))



-- EQUIP ASSETS
function PumpShotgunAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
	local EquipSFX = Instance.new("Sound")
	EquipSFX.SoundId = DefaultData.SoundFX.EquipSFX
	EquipSFX.Parent = RootPart
	EquipSFX.Volume = 3
	EquipSFX.PlaybackSpeed = 1
	EquipSFX:Play()
	Tracks[PlayerEquipped]["EquipSFX"] = EquipSFX


	-- CREATE ANIMATION
	local EquipAnimation = Instance.new("Animation")
	EquipAnimation.AnimationId = DefaultData.Animations.EquipAnimation
	local EquipTrack = Animator:LoadAnimation(EquipAnimation)
	EquipTrack.Name = "EquipAnimation"
	EquipTrack.Looped = false
	EquipTrack.Priority = Enum.AnimationPriority.Action4
	Tracks[PlayerEquipped]["EquipAnimation"] = EquipTrack
	EquipTrack:Play()
	EquipTrack:AdjustSpeed(0.75)



	Connections[PlayerEquipped]["CharacterRemoving_Equip"] = PlayerEquipped.CharacterRemoving:Connect(function()
		FullCleanup()
	end)

	Connections[PlayerEquipped]["EquippedGunChanged"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
			FullCleanup()
		end
	end)
	
	return true
end



-- IDLE ASSETS
function PumpShotgunAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	return PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
end




-- MOVEMENT ASSETS
function PumpShotgunAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	return PistolAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
end



-- SHOOT ASSETS
function PumpShotgunAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
	local Tracks = ClientGunDataModule.Tracks
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	-- GET ANIMATION
	local StartAnimId = DefaultData.Animations["StartShooting"]
	if not StartAnimId then return end

	-- CHARACTER
	local Character = PlayerFired.Character or PlayerFired.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)

	-- MUZZLE
	local Muzzle = Character and Character:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle")
	if not Muzzle then return end



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

		if Connections[PlayerFired]["IsShotFiredChange"] then
			Connections[PlayerFired]["IsShotFiredChange"]:Disconnect()
			Connections[PlayerFired]["IsShotFiredChange"] = nil
		end
	end


	-- INCASE
	FullCleanup()


	-- SHOT SFX
	local ShootSFX = Instance.new("Sound")
	ShootSFX.SoundId = DefaultData.SoundFX.ShootSFX
	ShootSFX.Parent = RootPart
	ShootSFX.Volume = 1.5
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
	ContinueAnimation.AnimationId = DefaultData.Animations["ContinueShooting"]
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
	Connections[PlayerFired]["EquippedGunChanged_Shoot"] = PlayerFired:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
			FullCleanup()
		end
	end)


	-- MUZZLE FIRE VFX
	local function PlayMuzzleVFX()
		for _, VFX in pairs(Muzzle:GetDescendants()) do
			if VFX:IsA("ParticleEmitter") then
				VFX:Emit(1)
			end
		end
	end


	-- ROTATE EQUIPPED GUN
	local OriginalC0
	local function RotateEquippedGun(RotateToOffset)
		local CharacterEquippedGun = PlayerFired.Character:FindFirstChild("EquippedGun")
		if not CharacterEquippedGun then return end
		local ArmWeld = CharacterEquippedGun.PrimaryPart:FindFirstChild("Weld")
		if not ArmWeld then return end
		-- STORE ORIGINAL C0
		if not OriginalC0 then
			OriginalC0 = ArmWeld.C0
		end

		local TweenInfo = TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-9))
				TweenService:Create(ArmWeld, TweenInfo, {C0 = NewC0}):Play()
			end
		else
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenInfo, {C0 = OriginalC0}):Play()
			end
		end
	end


	-- CONTINUE ANIMATION IF SHOT FIRED
	local TimeSinceShot = tick()
	Connections[PlayerFired]["IsShotFiredChange"] = PlayerFired:GetAttributeChangedSignal("ShotFired"):Connect(function()
		if PlayerFired:GetAttribute("ShotFired") then
			PlayMuzzleVFX()
			RotateEquippedGun(true)
			-- SFX
			if Tracks[PlayerFired]["ContinueShootingSFX"] and (tick() - TimeSinceShot) > 0.2 then
				local ClonedSFX = Tracks[PlayerFired]["ContinueShootingSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				task.delay(0.5, function()
					ClonedSFX:Destroy()
				end)
			end
			TimeSinceShot = tick()
			-- ANIMATION
			if Tracks[PlayerFired]["ContinueShootingAnimation"] then
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Play()
				Tracks[PlayerFired]["ContinueShootingAnimation"]:AdjustSpeed(1.25)
			end
		else
			task.wait(0.05)
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
			RotateEquippedGun(false)
		end
	end)

	-- START SHOOTING ANIMATION
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting"):Connect(function()
		if not PlayerFired:GetAttribute("IsShooting") or PlayerFired:GetAttribute("IsKnocked") then
			PartialCleanup()
		else
			if not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying then
				Tracks[PlayerFired]["StartShootingAnimation"]:Play(0.1)
				Tracks[PlayerFired]["StartShootingAnimation"]:AdjustSpeed(2)
			end
		end
	end)
	
	return true
end



-- RELOAD ASSETS
function PumpShotgunAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
	-- TRACKS AND CONNECTIONS
	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then return end
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	-- GET RELOAD ANIMATION ID
	local ReloadAnimId = DefaultData.Animations["ReloadAnimation"]
	if not ReloadAnimId then return end

	local Character = PlayerReloading.Character or PlayerReloading.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)


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

		if Connections[PlayerReloading]["EquippedGunChanged_Reload"]  then
			Connections[PlayerReloading]["EquippedGunChanged_Reload"]:Disconnect()
			Connections[PlayerReloading]["EquippedGunChanged_Reload"] = nil
		end

		if Connections[PlayerReloading]["CharacterRemoving_Reload"]  then
			Connections[PlayerReloading]["CharacterRemoving_Reload"]:Disconnect()
			Connections[PlayerReloading]["CharacterRemoving_Reload"] = nil
		end
		
		if Tracks[PlayerReloading]["StartReload"] then
			Tracks[PlayerReloading]["StartReload"]:Stop()
			Tracks[PlayerReloading]["StartReload"]:Destroy()
			Tracks[PlayerReloading]["StartReload"] = nil
		end
		
		if Tracks[PlayerReloading]["EndReload"] then
			Tracks[PlayerReloading]["EndReload"]:Stop()
			Tracks[PlayerReloading]["EndReload"]:Destroy()
			Tracks[PlayerReloading]["EndReload"] = nil
		end
		
		if Connections[PlayerReloading]["OutOfAmmoSFX"] then
			Connections[PlayerReloading]["OutOfAmmoSFX"]:Disconnect()
			Connections[PlayerReloading]["OutOfAmmoSFX"] = nil
		end

		if Connections[PlayerReloading]["ReloadAttribute"] then
			Connections[PlayerReloading]["ReloadAttribute"]:Disconnect()
			Connections[PlayerReloading]["ReloadAttribute"] = nil
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
	
	
	-- START ANIMATION
	local StartAnimation = Instance.new("Animation")
	StartAnimation.AnimationId = DefaultData.Animations["StartReload"]
	local StartTrack = Animator:LoadAnimation(StartAnimation)
	StartTrack.Name = "StartReload"
	StartTrack.Priority = Enum.AnimationPriority.Action2
	StartTrack.Looped = true
	Tracks[PlayerReloading]["StartReload"] = StartTrack
	
	
	-- END ANIMATION
	local EndAnimation = Instance.new("Animation")
	EndAnimation.AnimationId = DefaultData.Animations["EndReload"]
	local EndTrack = Animator:LoadAnimation(EndAnimation)
	EndTrack.Name = "EndReload"
	EndTrack.Priority = Enum.AnimationPriority.Action3
	EndTrack.Looped = false
	Tracks[PlayerReloading]["EndReload"] = EndTrack


	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["ReloadSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["ReloadSFX"].SoundId = DefaultData.SoundFX["ReloadSFX"]
	Tracks[PlayerReloading]["ReloadSFX"].Volume = 3.5
	Tracks[PlayerReloading]["ReloadSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["ReloadSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")


	-- CREATE END RELOAD SFX
	Tracks[PlayerReloading]["EndReloadSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["EndReloadSFX"].SoundId = DefaultData.SoundFX["EndReloadSFX"]
	Tracks[PlayerReloading]["EndReloadSFX"].Volume = 5
	Tracks[PlayerReloading]["EndReloadSFX"].PlaybackSpeed = 1.5
	Tracks[PlayerReloading]["EndReloadSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")



	-- OUT OF AMMO SFX
	Tracks[PlayerReloading]["OutOfAmmoSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["OutOfAmmoSFX"].SoundId = DefaultData.SoundFX["OutOfAmmoSFX"]
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Volume = 1
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegionsEnabled = true
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegion = NumberRange.new(0, 0.5)
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")



	Connections[PlayerReloading]["EquippedGunChanged_Reload"] = PlayerReloading:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then
			FullCleanup()
		end
	end)

	Connections[PlayerReloading]["CharacterRemoving_Reload"] = PlayerReloading.CharacterRemoving:Connect(function()
		FullCleanup()
	end)



	local ClonedSFX
	Connections[PlayerReloading]["BulletReloaded"] = PlayerReloading:GetAttributeChangedSignal("BulletReloaded"):Connect(function()
		if PlayerReloading:GetAttribute("BulletReloaded") then
			if Tracks[PlayerReloading]["ReloadAnimation"] then
				Tracks[PlayerReloading]["ReloadAnimation"]:Play()
				Tracks[PlayerReloading]["ReloadAnimation"]:AdjustSpeed(0.5)
			end
			if Tracks[PlayerReloading]["ReloadSFX"] then
				ClonedSFX = Tracks[PlayerReloading]["ReloadSFX"]:Clone()
				ClonedSFX.Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
				ClonedSFX:Play()
				Debris:AddItem(ClonedSFX, 0.5)
			end
		end
	end)
	Connections[PlayerReloading]["ReloadAttribute"] = PlayerReloading:GetAttributeChangedSignal("ShotgunReload"):Connect(function()
		if PlayerReloading:GetAttribute("ShotgunReload") then
			if Tracks[PlayerReloading]["StartReload"] then
				Tracks[PlayerReloading]["StartReload"]:Play(0.25)
			end
			while PlayerReloading:GetAttribute("ShotgunReload") and PlayerReloading:GetAttribute("IsReloading") do
				task.wait(0.02)
			end
			if Tracks[PlayerReloading]["ReloadSFX"] then
				Tracks[PlayerReloading]["ReloadSFX"]:Stop()
			end
			if ClonedSFX then
				ClonedSFX:Destroy()
				ClonedSFX = nil
			end
			if Tracks[PlayerReloading]["EndReloadSFX"] then
				Tracks[PlayerReloading]["EndReloadSFX"]:Play()
			end
			if Tracks[PlayerReloading]["EndReload"] then
				Tracks[PlayerReloading]["EndReload"]:Play()
			end
			if Tracks[PlayerReloading]["StartReload"] then
				Tracks[PlayerReloading]["StartReload"]:Stop(0.25)
			end
		end
	end)

	Connections[PlayerReloading]["OutOfAmmoSFX"] = PlayerReloading:GetAttributeChangedSignal("OutOfAmmoSFX"):Connect(function()
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
function PumpShotgunAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return PistolAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
end



-- N/A
function PumpShotgunAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end



-- UI
function PumpShotgunAssets.UI(LocalPlayer, GunEquipped)
	return PistolAssets.UI(LocalPlayer, GunEquipped)
end



-- WALL HIT VFX
function PumpShotgunAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	-- DEFAULT DATA
	local DefaultData = ClientGunDataModule.DefaultData[EquippedGun]
	if not DefaultData then return end

	-- VFX
	local WallHitVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("Pistol"):FindFirstChild("WallHit"):Clone()
	if not WallHitVFX then return end

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
	local WallHitVFX2 = ReplicatedStorage:FindFirstChild("GunVFX"):WaitForChild("SmokeVFX"):WaitForChild("MuzzleSmokeVFX"):Clone()
	if not WallHitVFX2 then return end

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


	-- SFX
	local ID = HttpService:GenerateGUID(false)
	local SFXData = {
		Volume = 1.25,
		PlaybackSpeed = 1,
		ForceNew = true, 
		CleanupTime = 2,
		SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("PumpShotgun"):FindFirstChild("WallHitSFX")
	}
	PlaySFXModule.PlayPartSFX(PlayerFired, ResultData.Position, ID, SFXData)
end



-- WALL MARK VFX
function PumpShotgunAssets.WallMark(PlayerFired, EquippedGun, ResultData)
	PistolAssets.WallMark(PlayerFired, EquippedGun, ResultData)
end



-- ZOMBIE HIT VFX
function PumpShotgunAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end



-- RETURN
return PumpShotgunAssets