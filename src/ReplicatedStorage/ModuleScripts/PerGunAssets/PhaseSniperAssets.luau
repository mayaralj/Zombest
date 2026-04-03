local PhaseSniperAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")


-- FOLDERS
local Frameworks= ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local Events = ReplicatedStorage:WaitForChild("Events")


-- MODULES
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))
local ScreenShake = require(Frameworks:WaitForChild("Screenshake"):WaitForChild("ScreenShake"))
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))


-- MOST SILENCER STRUCTURE WILL BE THE SAME AS PISTOL
-- MODULE
local PistolAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("PistolAssets"))



-- EQUIP ASSETS
function PhaseSniperAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
function PhaseSniperAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	return PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
end




-- MOVEMENT ASSETS
function PhaseSniperAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	return PistolAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
end



-- SHOOT ASSETS
function PhaseSniperAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
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
		
		if Tracks[PlayerFired]["ContinueShootingAnimation"] then
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
			Tracks[PlayerFired]["ContinueShootingAnimation"]:Destroy()
			Tracks[PlayerFired]["ContinueShootingAnimation"] = nil
		end

		if Connections[PlayerFired]["IsShotFiredChange"] then
			Connections[PlayerFired]["IsShotFiredChange"]:Disconnect()
			Connections[PlayerFired]["IsShotFiredChange"] = nil
		end
		
		if Tracks[PlayerFired]["ShotChargeSFX"] then
			Tracks[PlayerFired]["ShotChargeSFX"]:Stop()
			Tracks[PlayerFired]["ShotChargeSFX"]:Destroy()
			Tracks[PlayerFired]["ShotChargeSFX"] = nil
		end
		
		if Tracks[PlayerFired]["ChargeVFX"] then
			Tracks[PlayerFired]["ChargeVFX"]:Destroy()
			Tracks[PlayerFired]["ChargeVFX"] = nil
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
	ShootSFX.PlaybackRegionsEnabled = true
	ShootSFX.PlaybackRegion = NumberRange.new(0, 2.5)
	Tracks[PlayerFired]["ContinueShootingSFX"] = ShootSFX
	
	
	local ShotChargeSFX = Instance.new("Sound")
	ShotChargeSFX.SoundId = DefaultData.SoundFX.ShotChargeSFX
	ShotChargeSFX.Parent = RootPart
	ShotChargeSFX.Volume = 1.5
	ShotChargeSFX.PlaybackSpeed = 0.9
	ShotChargeSFX.Looped = false
	Tracks[PlayerFired]["ShotChargeSFX"] = ShotChargeSFX


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

		local TweenInfos = TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local TweenBack = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-15))
				TweenService:Create(ArmWeld, TweenInfos, {C0 = NewC0}):Play()
			end
		else
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenBack, {C0 = OriginalC0}):Play()
			end
		end
	end


	-- SET UP CHARGE VFX
	local ChargeVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("PhaseSniper"):FindFirstChild("Charge"):Clone()
	ChargeVFX.Parent = Muzzle
	Tracks[PlayerFired]["ChargeVFX"] = ChargeVFX
	local VFXIsPlaying
	
	
	-- HELPER TO PLAY SHOT CHARGE VFX
	local function PlayChargeVFX()
		if VFXIsPlaying then return end
		if Tracks[PlayerFired]["ChargeVFX"] then
			for _, VFX in (Tracks[PlayerFired]["ChargeVFX"]:GetDescendants()) do
				if VFX:IsA("ParticleEmitter") then
					VFX.Enabled = true
					VFX.Size = NumberSequence.new(0.1)
					VFXIsPlaying = true
				end
			end
			Tracks[PlayerFired]["ShotChargeSFX"]:Play()
			local CurrentSize = 0.1
			while VFXIsPlaying and CurrentSize < 2 do
				CurrentSize = math.min(CurrentSize + 0.05, 2)
	
				-- ADD A SCREENSHAKE
				local ScreenShakeIntensityMultiplier = 0.01 * CurrentSize*15
				ScreenShake.ApplyScreenShake(true, PlayerViewing, PlayerFired, ScreenShakeIntensityMultiplier, 10, 1)
				
				for _, VFX in (Tracks[PlayerFired]["ChargeVFX"]:GetDescendants()) do
					if VFX:IsA("ParticleEmitter") then
						VFX.Size = NumberSequence.new(CurrentSize)
					end
				end
				task.wait(0.1)
			end
		end
	end
	
	
	
	local function ResetChargeVFX(Rate)
		if Tracks[PlayerFired]["ChargeVFX"] then
			Tracks[PlayerFired]["ShotChargeSFX"]:Stop()
			for _, VFX in (Tracks[PlayerFired]["ChargeVFX"]:GetDescendants()) do
				if VFX:IsA("ParticleEmitter")  then
					VFX.Enabled = false
					VFXIsPlaying = false
					local CurrentSize = VFX.Size.Keypoints[1].Value

					task.spawn(function()
						while CurrentSize > 0 do
							CurrentSize = math.max(CurrentSize - 0.1, 0)
							VFX.Size = NumberSequence.new(CurrentSize)
							task.wait(Rate)
						end
					end)
				end
			end
		end
	end
	
	
	-- CONTINUE ANIMATION IF SHOT FIRED
	Connections[PlayerFired]["IsShotFiredChange"] = PlayerFired:GetAttributeChangedSignal("ShotFired"):Connect(function()
		if PlayerFired:GetAttribute("ShotFired") then
			RotateEquippedGun(true)
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				local ClonedSFX = Tracks[PlayerFired]["ContinueShootingSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				task.delay(2, function()
					ClonedSFX:Destroy()
				end)
			end
			if Tracks[PlayerFired]["ContinueShootingAnimation"] then
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Play()
			end
			
			ResetChargeVFX(0.01)
		else
			task.wait(0.03)
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
			RotateEquippedGun(false)
		end
	end)

	-- START SHOOTING ANIMATION
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting"):Connect(function()
		if not PlayerFired:GetAttribute("IsShooting") or PlayerFired:GetAttribute("IsKnocked") then
			PartialCleanup()
			ResetChargeVFX(0.025)
		else
			if not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying then
				Tracks[PlayerFired]["StartShootingAnimation"]:Play(0.1)
				Tracks[PlayerFired]["StartShootingAnimation"]:AdjustSpeed(2)
			end
			while PlayerFired:GetAttribute("IsShooting") do
				PlayChargeVFX()
				task.wait(0.1)
			end
		end
	end)
	
	return true
end



-- RELOAD ASSETS
function PhaseSniperAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
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
		
		if Connections[PlayerReloading]["ReloadAttribute"] then
			Connections[PlayerReloading]["ReloadAttribute"]:Disconnect()
			Connections[PlayerReloading]["ReloadAttribute"] = nil
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
		
		if Connections[PlayerReloading]["OutOfAmmoSFX"] then
			Connections[PlayerReloading]["OutOfAmmoSFX"]:Disconnect()
			Connections[PlayerReloading]["OutOfAmmoSFX"] = nil
		end

		if Connections[PlayerReloading]["EquippedGunChanged_Reload"]  then
			Connections[PlayerReloading]["EquippedGunChanged_Reload"]:Disconnect()
			Connections[PlayerReloading]["EquippedGunChanged_Reload"] = nil
		end

		if Connections[PlayerReloading]["CharacterRemoving_Reload"]  then
			Connections[PlayerReloading]["CharacterRemoving_Reload"]:Disconnect()
			Connections[PlayerReloading]["CharacterRemoving_Reload"] = nil
		end
		
		if Tracks[PlayerReloading]["MagSFX"] then
			Tracks[PlayerReloading]["MagSFX"]:Stop()
			Tracks[PlayerReloading]["MagSFX"]:Destroy()
			Tracks[PlayerReloading]["MagSFX"] = nil
		end
		
		if Tracks[PlayerReloading]["MagBackSFX"] then
			Tracks[PlayerReloading]["MagBackSFX"]:Stop()
			Tracks[PlayerReloading]["MagBackSFX"]:Destroy()
			Tracks[PlayerReloading]["MagBackSFX"] = nil
		end
		
		if Tracks[PlayerReloading]["ChargeSFX"] then
			Tracks[PlayerReloading]["ChargeSFX"]:Stop()
			Tracks[PlayerReloading]["ChargeSFX"]:Destroy()
			Tracks[PlayerReloading]["ChargeSFX"] = nil
		end
		
		if Connections[PlayerReloading]["MagEvent"] then
			Connections[PlayerReloading]["MagEvent"]:Disconnect()
			Connections[PlayerReloading]["MagEvent"] = nil
		end
		
		if Connections[PlayerReloading]["MagBackEvent"] then
			Connections[PlayerReloading]["MagBackEvent"]:Disconnect()
			Connections[PlayerReloading]["MagBackEvent"] = nil
		end
		
		if Connections[PlayerReloading]["ChargeEvent"] then
			Connections[PlayerReloading]["ChargeEvent"]:Disconnect()
			Connections[PlayerReloading]["ChargeEvent"] = nil
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
	Tracks[PlayerReloading]["ReloadAnimation"].Priority = Enum.AnimationPriority.Action
	Tracks[PlayerReloading]["ReloadAnimation"].Looped = false 


	-- CREATE RELOAD SFX
	Tracks[PlayerReloading]["ReloadSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["ReloadSFX"].SoundId = DefaultData.SoundFX["ReloadSFX"]
	Tracks[PlayerReloading]["ReloadSFX"].Volume = 3.5
	Tracks[PlayerReloading]["ReloadSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["ReloadSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")



	-- OUT OF AMMO SFX
	Tracks[PlayerReloading]["OutOfAmmoSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["OutOfAmmoSFX"].SoundId = DefaultData.SoundFX["OutOfAmmoSFX"]
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Volume = 1
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegionsEnabled = true
	Tracks[PlayerReloading]["OutOfAmmoSFX"].PlaybackRegion = NumberRange.new(0, 0.5)
	Tracks[PlayerReloading]["OutOfAmmoSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
	
	
	-- MAG SFX
	Tracks[PlayerReloading]["MagSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["MagSFX"].SoundId = DefaultData.SoundFX["MagSFX"]
	Tracks[PlayerReloading]["MagSFX"].Volume = 4
	Tracks[PlayerReloading]["MagSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["MagSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
	
	
	-- MAG BACK SFX
	Tracks[PlayerReloading]["MagBackSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["MagBackSFX"].SoundId = DefaultData.SoundFX["MagBackSFX"]
	Tracks[PlayerReloading]["MagBackSFX"].Volume = 5
	Tracks[PlayerReloading]["MagBackSFX"].PlaybackSpeed = 1.5
	Tracks[PlayerReloading]["MagBackSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
	
	
	-- CHARGE SFX
	Tracks[PlayerReloading]["ChargeSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["ChargeSFX"].SoundId = DefaultData.SoundFX["ChargeSFX"]
	Tracks[PlayerReloading]["ChargeSFX"].Volume = 3
	Tracks[PlayerReloading]["ChargeSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["ChargeSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")



	Connections[PlayerReloading]["EquippedGunChanged_Reload"] = PlayerReloading:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then
			FullCleanup()
		end
	end)

	Connections[PlayerReloading]["CharacterRemoving_Reload"] = PlayerReloading.CharacterRemoving:Connect(function()
		FullCleanup()
	end)
	
	
	-- GET "MAG" ANIMATION SIGNAL
	local EquippedGun = Character:FindFirstChild("EquippedGun")
	if not EquippedGun then return end
	local Mag = EquippedGun:FindFirstChild("Mag")
	if not Mag then return end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then return end
	
	
	Connections[PlayerReloading]["MagEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Mag"):Connect(function()
		Tracks[PlayerReloading]["MagSFX"]:Play()
		-- CHECK IF MAG CLONE EXISTS
		if not MagClone then
			MagClone = Mag:Clone()
			MagClone.Anchored = false
			for _, Part in MagClone:GetDescendants() do
				if Part:IsA("Weld") then
					Part:Destroy()
				end
			end
			MagClone.Parent = LeftArm


			-- WELD TO ARM
			local Weld = Instance.new("Weld")
			Weld.Part0 = LeftArm
			Weld.Part1 = MagClone
			Weld.C0 = CFrame.new(-0.1, -0.05, -0.1)
			Weld.C1 = MagClone.CFrame:ToObjectSpace(LeftArm.CFrame  * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)))
			Weld.Parent = MagClone
		else
			MagClone.Transparency = 0
		end
		
		Mag.Transparency = 1
	end)
	Connections[PlayerReloading]["MagBackEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("MagBack"):Connect(function()
		Tracks[PlayerReloading]["MagBackSFX"]:Play()
		task.wait(0.1)
		if PlayerReloading:GetAttribute("IsEquippingGun") ~= GunEquipped then return end
		
		Mag.Transparency = 0
		if MagClone then
			MagClone.Transparency = 1
		end
	end)
	-- GET "CHARGE" ANIMATION EVENT
	Connections[PlayerReloading]["ChargeEvent"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Charge"):Connect(function()
		Tracks[PlayerReloading]["ChargeSFX"]:Play()
		
		local ReloadVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("PhaseSniper"):FindFirstChild("ReloadVFX"):Clone()
		ReloadVFX.Parent = PlayerReloading.Character:FindFirstChild("Left Arm")
		ReloadVFX.Position = Vector3.new(0,0,0)
		
		for _, VFX in ReloadVFX:GetDescendants() do
			if VFX:IsA("ParticleEmitter") then
				VFX:Emit(10)
			end
		end
		
		Debris:AddItem(ReloadVFX, 2)
	end)


	local LastClonedSFX
	Connections[PlayerReloading]["ReloadAttribute"] = PlayerReloading:GetAttributeChangedSignal("IsReloading"):Connect(function()
		if PlayerReloading:GetAttribute("IsReloading") then
			local ReloadTime = PlayerReloading:GetAttribute("ReloadTime")			
			Tracks[PlayerReloading]["ReloadAnimation"]:Play(0.1)
			Tracks[PlayerReloading]["ReloadAnimation"]:AdjustSpeed(0.55)
		else
			Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
			Mag.Transparency = 0
			if MagClone then
				MagClone.Transparency = 1
			end	
			Tracks[PlayerReloading]["MagBackSFX"]:Stop()
			Tracks[PlayerReloading]["ChargeSFX"]:Stop()
			Tracks[PlayerReloading]["MagSFX"]:Stop()
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
function PhaseSniperAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return PistolAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
end



-- N/A
function PhaseSniperAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end


-- UI
function PhaseSniperAssets.UI(LocalPlayer, GunEquipped)
	return PistolAssets.UI(LocalPlayer, GunEquipped)
end



-- WALL HIT VFX
function PhaseSniperAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	if not ResultData.Normal then return end
	-- DEFAULT DATA
	local DefaultData = ClientGunDataModule.DefaultData[EquippedGun]
	if not DefaultData then return end


	-- VFX
	local WallHitVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("PhaseSniper"):FindFirstChild("WallHit"):Clone()
	if not WallHitVFX then return end


	-- ALIGN WITH WALL
	WallHitVFX.Position = ResultData.Position
	WallHitVFX.CFrame = CFrame.new(ResultData.Position, ResultData.Position - ResultData.Normal)

	for _, VFX in pairs(WallHitVFX:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX:Emit(10)
		end
	end

	WallHitVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallHitVFX, 3)


	-- SMOKE VFX
	local WallHitVFX2 = ReplicatedStorage:FindFirstChild("GunVFX"):WaitForChild("PhaseSniper"):WaitForChild("MuzzleSmokeVFX"):Clone()
	if not WallHitVFX2 then return end

	WallHitVFX2.Position = ResultData.Position + Vector3.new(0,2,0)
	WallHitVFX2.CFrame = CFrame.new(WallHitVFX2.Position, ResultData.Position - ResultData.Normal)

	for _, VFX in pairs(WallHitVFX2:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX.Color = ColorSequence.new(ResultData.Instance.Color)
			VFX:Emit(10)
		end
	end

	WallHitVFX2.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallHitVFX2, 3)
	
	
	-- SFX
	local ID = HttpService:GenerateGUID(false)
	local SFXData = {
		Volume = 1.25,
		PlaybackSpeed = 1,
		PlaybackRegion = NumberRange.new(0.05, 1.5),
		ForceNew = true, 
		CleanupTime = 2,
		SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX"):WaitForChild("PhaseSniper"):WaitForChild("WallHitSFX")
	}
	PlaySFXModule.PlayPartSFX(PlayerFired, ResultData.Position, ID, SFXData)
end



-- WALL MARK VFX
function PhaseSniperAssets.WallMark(PlayerFired, EquippedGun, ResultData)
	-- END IF NO NORMAL
	if not ResultData.Normal then return end

	-- VFX
	local WallMarkVFX = ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("PhaseSniper"):FindFirstChild("WallMark"):Clone()
	if not WallMarkVFX then return end

	WallMarkVFX.Position = ResultData.Position + Vector3.new(0,1,0)
	WallMarkVFX.CFrame = CFrame.new(WallMarkVFX.Position, WallMarkVFX.Position  - ResultData.Normal)

	for _, VFX in pairs(WallMarkVFX:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX:Emit(1)
		end
	end

	WallMarkVFX.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(WallMarkVFX, 3)
end



-- ZOMBIE HIT VFX
function PhaseSniperAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end



-- RETURN
return PhaseSniperAssets