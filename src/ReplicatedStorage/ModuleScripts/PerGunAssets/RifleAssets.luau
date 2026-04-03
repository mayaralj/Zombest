local RifleAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


-- FOLDERS
local Frameworks= ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")


-- MODULES
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))


-- MOST SILENCER STRUCTURE WILL BE THE SAME AS PISTOL
-- MODULE
local PistolAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("PistolAssets"))



-- EQUIP ASSETS
function RifleAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
function RifleAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	return PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
end




-- MOVEMENT ASSETS
function RifleAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	return PistolAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
end



-- SHOOT ASSETS
function RifleAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
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
		
		if Tracks[PlayerFired]["ContinueShootingAnimation"] then
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Destroy()
			Tracks[PlayerFired]["ContinueShootingAnimation"] = nil
		end
		
		if Connections[PlayerFired]["Pull"] then
			Connections[PlayerFired]["Pull"]:Disconnect()
			Connections[PlayerFired]["Pull"] = nil
		end
		
		if Tracks[PlayerFired]["PullSFX"] then
			Tracks[PlayerFired]["PullSFX"]:Destroy()
			Tracks[PlayerFired]["PullSFX"] = nil
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
	
	
	-- SHOT SFX
	local PullSFX = Instance.new("Sound")
	PullSFX.SoundId = DefaultData.SoundFX.PullSFX
	PullSFX.Parent = RootPart
	PullSFX.Volume = 1
	PullSFX.PlaybackSpeed = 1.5
	Tracks[PlayerFired]["PullSFX"] = PullSFX


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
				VFX:Emit(5)
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

		local TweenInfo = TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-8))
				TweenService:Create(ArmWeld, TweenInfo, {C0 = NewC0}):Play()
			end
		else
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenInfo, {C0 = OriginalC0}):Play()
			end
		end
	end
	
	-- CHARACTER
	local Character = PlayerFired.Character or PlayerFired.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	if not RootPart then return end
	local Torso = Character:WaitForChild("Torso")
	if not Torso then return end
	local RightArm = Character:WaitForChild("Right Arm")
	if not RightArm then return end
	local LeftArm = Character:WaitForChild("Left Arm")
	if not LeftArm then return end
	
	
	-- EQUIPPED GUN STUFF
	local EquippedGunOnCharacter = PlayerFired.Character:FindFirstChild("EquippedGun")
	if not EquippedGunOnCharacter then return end
	local Handle = EquippedGunOnCharacter:FindFirstChild("Handle")
	local ArmWeld = EquippedGunOnCharacter.PrimaryPart:FindFirstChild("Weld")
	if not Handle or not ArmWeld then return end
	
	
	local OriginalArmC0 = ArmWeld.C0
	Connections[PlayerFired]["Pull"] = Tracks[PlayerFired]["ContinueShootingAnimation"]:GetMarkerReachedSignal("Pull"):Connect(function()
		task.wait(0.06)
		if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
		task.delay(0.1, function()
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
			Tracks[PlayerFired]["PullSFX"]:Play()
		end)
		local HandleWorldCFrame = EquippedGunOnCharacter.PrimaryPart.CFrame

		ArmWeld.Part0 = RootPart
		ArmWeld.C0 = RootPart.CFrame:ToObjectSpace(HandleWorldCFrame)

		local NewC0 = CFrame.new(1.2, 0.8, -1) * CFrame.Angles(math.rad(0), math.rad(-85), math.rad(0))
		local TweenC0 = TweenService:Create(ArmWeld, TweenInfo.new(0.1), {C0 = NewC0})
		TweenC0:Play()

		task.wait(0.55)
		if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
		local HandleWorldCFrame = EquippedGunOnCharacter.PrimaryPart.CFrame

		ArmWeld.Part0 = RightArm
		ArmWeld.C0 = RightArm.CFrame:ToObjectSpace(HandleWorldCFrame)

		local TweenC0 = TweenService:Create(ArmWeld, TweenInfo.new(0.1), {C0 = OriginalArmC0})
		TweenC0:Play()
	end)
	
	
	
	-- CONTINUE ANIMATION IF SHOT FIRED
	Connections[PlayerFired]["IsShotFiredChange"] = PlayerFired:GetAttributeChangedSignal("ShotFired"):Connect(function()
		if PlayerFired:GetAttribute("ShotFired") then
			PlayMuzzleVFX()
			RotateEquippedGun(true)
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				local ClonedSFX = Tracks[PlayerFired]["ContinueShootingSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				task.delay(0.5, function()
					ClonedSFX:Destroy()
				end)
			end
			if Tracks[PlayerFired]["ContinueShootingAnimation"] then
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Play()
				Tracks[PlayerFired]["ContinueShootingAnimation"]:AdjustSpeed(1.2)
			end
		else
			RunService.Heartbeat:Wait()
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
function RifleAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
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


	local MagClone 
	local function FullCleanup()
		if Tracks[PlayerReloading]["ReloadAnimation"] then
			Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
			Tracks[PlayerReloading]["ReloadAnimation"]:Destroy()
			Tracks[PlayerReloading]["ReloadAnimation"] = nil
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
		
		if Tracks[PlayerReloading]["ReloadSFX"] then
			Tracks[PlayerReloading]["ReloadSFX"]:Stop()
			Tracks[PlayerReloading]["ReloadSFX"]:Destroy()
			Tracks[PlayerReloading]["ReloadSFX"] = nil
		end

		if Connections[PlayerReloading]["CharacterRemoving_Reload"]  then
			Connections[PlayerReloading]["CharacterRemoving_Reload"]:Disconnect()
			Connections[PlayerReloading]["CharacterRemoving_Reload"] = nil
		end
		
		if Connections[PlayerReloading]["ReloadAttribute"] then
			Connections[PlayerReloading]["ReloadAttribute"]:Disconnect()
			Connections[PlayerReloading]["ReloadAttribute"] = nil
		end
		
		if Connections[PlayerReloading]["OutOfAmmoSFX"] then
			Connections[PlayerReloading]["OutOfAmmoSFX"]:Disconnect()
			Connections[PlayerReloading]["OutOfAmmoSFX"] = nil
		end
	end


	-- INCASE
	FullCleanup()


	-- CREATE RELOAD ANIMATION
	local ReloadAnimation = Instance.new("Animation")
	ReloadAnimation.AnimationId = ReloadAnimId
	Tracks[PlayerReloading]["ReloadAnimation"] = Animator:LoadAnimation(ReloadAnimation)
	Tracks[PlayerReloading]["ReloadAnimation"].Name = "ReloadAnimation"
	Tracks[PlayerReloading]["ReloadAnimation"].Priority = Enum.AnimationPriority.Action
	Tracks[PlayerReloading]["ReloadAnimation"].Looped = false 


	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["ReloadSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["ReloadSFX"].SoundId = DefaultData.SoundFX["ReloadSFX"]
	Tracks[PlayerReloading]["ReloadSFX"].Volume = 3.5
	Tracks[PlayerReloading]["ReloadSFX"].PlaybackSpeed = 1.4
	Tracks[PlayerReloading]["ReloadSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")


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


	local LastClonedSFX
	Connections[PlayerReloading]["ReloadAttribute"] = PlayerReloading:GetAttributeChangedSignal("IsReloading"):Connect(function()
		if PlayerReloading:GetAttribute("IsReloading") then
			local ReloadTime = PlayerReloading:GetAttribute("ReloadTime")			
			Tracks[PlayerReloading]["ReloadAnimation"]:Play(0.1)
			Tracks[PlayerReloading]["ReloadAnimation"]:AdjustSpeed(0.75)
			task.wait()
			if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then return end
			
			local ClonedSFX = Tracks[PlayerReloading]["ReloadSFX"]:Clone()
			ClonedSFX.Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 3)
			LastClonedSFX = ClonedSFX
		else
			Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
			if LastClonedSFX then
				LastClonedSFX:Stop()
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
function RifleAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return PistolAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
end



-- N/A
function RifleAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end



-- UI
function RifleAssets.UI(LocalPlayer, GunEquipped)
	return PistolAssets.UI(LocalPlayer, GunEquipped)
end



-- WALL HIT VFX
function RifleAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.WallHit(PlayerFired, EquippedGun, ResultData)
end



-- WALL MARK VFX
function RifleAssets.WallMark(PlayerFired, EquippedGun, ResultData)
	PistolAssets.WallMark(PlayerFired, EquippedGun, ResultData)
end



-- ZOMBIE HIT VFX
function RifleAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end



-- RETURN
return RifleAssets