local RayGunAssets = {}
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
local PlaySFXModule = require(Frameworks:WaitForChild("Sound"):WaitForChild("PlaySFX"))


-- MODULES
local ClientGunDataModule = require(Client:WaitForChild("ClientGunData"))


-- MOST SILENCER STRUCTURE WILL BE THE SAME AS PISTOL
-- MODULE
local PistolAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("PistolAssets"))



-- EQUIP ASSETS
function RayGunAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
	EquipSFX.Volume = 4
	EquipSFX.PlaybackSpeed = 1
	EquipSFX.PlaybackRegionsEnabled = true
	EquipSFX.PlaybackRegion = NumberRange.new(0.1, 1)
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

	Connections[PlayerEquipped]["EquippedGunChanged"] = PlayerEquipped:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerEquipped:GetAttribute("IsEquippingGun") ~= WeaponName then
			FullCleanup()
		end
	end)
	
	return true
end



-- IDLE ASSETS
function RayGunAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	return PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
end




-- MOVEMENT ASSETS
function RayGunAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
	return PistolAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
end



-- SHOOT ASSETS
function RayGunAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
	local Tracks = ClientGunDataModule.Tracks
	local Connections = ClientGunDataModule.Connections
	if not Connections then return end

	-- GET ANIMATION
	local StartAnimId = DefaultData.Animations["StartShooting"]
	if not StartAnimId then return end
	local ContinueAnimID = DefaultData.Animations["ContinueShooting"]
	if not ContinueAnimID then return end

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
	Connections[PlayerFired]["EquippedGunChanged_Shoot"] = PlayerFired:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
			FullCleanup()
		end
	end)


	-- MUZZLE FIRE VFX
	local function PlayMuzzleVFX()
		for _, VFX in pairs(Muzzle:GetDescendants()) do
			if VFX:IsA("ParticleEmitter") then
				VFX:Emit(3)
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
		
		local TweenInfo = TweenInfo.new(0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-5))
				TweenService:Create(ArmWeld, TweenInfo, {C0 = NewC0}):Play()
			end
		else
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenInfo, {C0 = OriginalC0}):Play()
			end
		end
	end


	-- CONTINUE ANIMATION IF SHOT FIRED
	Connections[PlayerFired]["IsShotFiredChange"] = PlayerFired:GetAttributeChangedSignal("ShotFired"):Connect(function()
		if PlayerFired:GetAttribute("ShotFired") then
			PlayMuzzleVFX()
			RotateEquippedGun(true)
			if Tracks[PlayerFired]["ContinueShootingAnimation"] and not PlayerFired:GetAttribute("IsKnocked") then
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Play()
				Tracks[PlayerFired]["ContinueShootingAnimation"]:AdjustSpeed(2.5)
			else
				Tracks[PlayerFired]["ContinueShootingAnimation"]:Stop()
			end
			if Tracks[PlayerFired]["ContinueShootingSFX"] then
				local ClonedSFX = Tracks[PlayerFired]["ContinueShootingSFX"]:Clone()
				ClonedSFX.Parent = RootPart
				ClonedSFX:Play()
				task.delay(1.5, function()
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
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting"):Connect(function()
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
function RayGunAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
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
		
		if Connections[PlayerReloading]["OutOfAmmoSFX"] then
			Connections[PlayerReloading]["OutOfAmmoSFX"]:Disconnect()
			Connections[PlayerReloading]["OutOfAmmoSFX"] = nil
		end

		if Connections[PlayerReloading]["ReloadAttribute"] then
			Connections[PlayerReloading]["ReloadAttribute"]:Disconnect()
			Connections[PlayerReloading]["ReloadAttribute"] = nil
		end
		
		if Tracks[PlayerReloading]["OpenSFX"] then
			Tracks[PlayerReloading]["OpenSFX"]:Stop()
			Tracks[PlayerReloading]["OpenSFX"]:Destroy()
			Tracks[PlayerReloading]["OpenSFX"] = nil
		end
		if Tracks[PlayerReloading]["CloseSFX"] then
			Tracks[PlayerReloading]["CloseSFX"]:Stop()
			Tracks[PlayerReloading]["CloseSFX"]:Destroy()
			Tracks[PlayerReloading]["CloseSFX"] = nil
		end
		if Tracks[PlayerReloading]["FillSFX"] then
			Tracks[PlayerReloading]["FillSFX"]:Stop()
			Tracks[PlayerReloading]["FillSFX"]:Destroy()
			Tracks[PlayerReloading]["FillSFX"] = nil
		end
		
		if Connections[PlayerReloading]["Open"] then
			Connections[PlayerReloading]["Open"]:Disconnect()
			Connections[PlayerReloading]["Open"] = nil
		end
		if Connections[PlayerReloading]["Close"] then
			Connections[PlayerReloading]["Close"]:Disconnect()
			Connections[PlayerReloading]["Close"] = nil
		end
		if Connections[PlayerReloading]["Fill"] then
			Connections[PlayerReloading]["Fill"]:Disconnect()
			Connections[PlayerReloading]["Fill"] = nil
		end
		if Connections[PlayerReloading]["Empty"] then
			Connections[PlayerReloading]["Empty"]:Disconnect()
			Connections[PlayerReloading]["Empty"] = nil
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
	
	
	local OriginalC0
	local function RotateEquippedGun(RotateToOffset)
		local CharacterEquippedGun = PlayerReloading.Character:FindFirstChild("EquippedGun")
		if not CharacterEquippedGun then return end
		local ArmWeld = CharacterEquippedGun.PrimaryPart:FindFirstChild("Weld")
		if not ArmWeld then return end
		-- STORE ORIGINAL C0
		if not OriginalC0 then
			OriginalC0 = ArmWeld.C0
		end

		local TweenInfo = TweenInfo.new(0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if RotateToOffset then
			if ArmWeld then
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-5))
				TweenService:Create(ArmWeld, TweenInfo, {C0 = NewC0}):Play()
			end
		else
			if ArmWeld then
				TweenService:Create(ArmWeld, TweenInfo, {C0 = OriginalC0}):Play()
			end
		end
	end
	
	
	-- BULLET CASING
	local function RegularBulletCasing(PlayerFiredCharacter, CasingType, CasingSFX)
		local RootPart = PlayerFiredCharacter:FindFirstChild("HumanoidRootPart")
		if not RootPart then return end
		local CharEquippedGun = PlayerFiredCharacter:FindFirstChild("EquippedGun")
		if not CharEquippedGun then return end
		
		-- CREATE BULLET CASING FALLING ON THE GROUND
		local BulletCase = ReplicatedStorage:FindFirstChild("BulletCasings"):FindFirstChild(CasingType):Clone()
		BulletCase.Name = "BulletCase"
		BulletCase.Anchored = false
		BulletCase.CanCollide = true
		BulletCase.CanTouch = false
		BulletCase.CanQuery = false
		BulletCase.Transparency = 0
		BulletCase.CollisionGroup = "Rocks"

		-- ADJUST POSITION
		BulletCase.CFrame = CFrame.new(CharEquippedGun.PrimaryPart.Position)
		BulletCase.Parent = workspace:FindFirstChild("BulletsFolder"):FindFirstChild("BulletCasings")

		-- BODY VELOCITY FOR REALISM
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Velocity = RootPart.CFrame.LookVector * math.random(10, 20) + RootPart.CFrame.UpVector * math.random(-10, 10)
		BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyVelocity.Parent = BulletCase

		-- ADD ROTATION
		local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
		BodyAngularVelocity.AngularVelocity = Vector3.new(
			math.random(-50, 50),
			math.random(-50, 50),
			math.random(-50, 50)
		)
		BodyAngularVelocity.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		BodyAngularVelocity.Parent = BulletCase


		-- ADD DEBRIS
		game.Debris:AddItem(BulletCase, 1.5)
		game.Debris:AddItem(BodyVelocity, 0.1)
		game.Debris:AddItem(BodyAngularVelocity, 0.1)


		-- SFX
		local CasingSoundFX = Instance.new("Sound")
		CasingSoundFX.SoundId = CasingSFX
		CasingSoundFX.Parent = BulletCase
		CasingSoundFX.Volume = 0.5

		task.delay(0.1, function()
			CasingSoundFX:Play()
		end)
	end
	
	
	-- EACH CUSTOM SFX
	Tracks[PlayerReloading]["OpenSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["OpenSFX"].SoundId = DefaultData.SoundFX["OpenSFX"]
	Tracks[PlayerReloading]["OpenSFX"].Volume = 3
	Tracks[PlayerReloading]["OpenSFX"].PlaybackSpeed = 1.2
	Tracks[PlayerReloading]["OpenSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")

	Tracks[PlayerReloading]["CloseSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["CloseSFX"].SoundId = DefaultData.SoundFX["CloseSFX"]
	Tracks[PlayerReloading]["CloseSFX"].Volume = 3
	Tracks[PlayerReloading]["CloseSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["CloseSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
	
	Tracks[PlayerReloading]["FillSFX"] = Instance.new("Sound")
	Tracks[PlayerReloading]["FillSFX"].SoundId = DefaultData.SoundFX["FillSFX"]
	Tracks[PlayerReloading]["FillSFX"].Volume = 5
	Tracks[PlayerReloading]["FillSFX"].PlaybackSpeed = 1
	Tracks[PlayerReloading]["FillSFX"].PlaybackRegionsEnabled = true
	Tracks[PlayerReloading]["FillSFX"].PlaybackRegion = NumberRange.new(0, 0.25)
	Tracks[PlayerReloading]["FillSFX"].Parent = PlayerReloading.Character:FindFirstChild("HumanoidRootPart")
	
	
	
	-- ANIMATION EVENTS
	local RayGunModel = PlayerReloading.Character:WaitForChild("EquippedGun")
	if not RayGunModel then return end
	local OpenFolder = RayGunModel:FindFirstChild("OpenPart")
	if not OpenFolder then return end
	
	local OriginalC0 = {}
	Connections[PlayerReloading]["Open"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Open"):Connect(function()
		-- PLAY SFX
		Tracks[PlayerReloading]["OpenSFX"]:Play()
		
		-- OPEN PART VISUALLY
		for _, Child in OpenFolder:GetDescendants() do
			if Child.Name == "BasePart" then
				Child.Transparency = 1
			end
			if Child:IsA("MeshPart") then
				local WeldOnChild = Child:FindFirstChild("Weld")
				OriginalC0[Child] = WeldOnChild.C0
				if WeldOnChild then
					WeldOnChild.C0 = CFrame.new(-1, 0, 0) * CFrame.Angles(0, math.rad(-180), math.rad(90))
				end
			end
		end
	end)
	Connections[PlayerReloading]["Close"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Close"):Connect(function()
		-- PLAY CLOSE SFX
		Tracks[PlayerReloading]["CloseSFX"]:Play()

		-- RESET OPEN PART POSITION AND TRANSPARENCY
		for _, Child in OpenFolder:GetDescendants() do
			if Child.Name == "BasePart" then
				Child.Transparency = 0
			end
			if Child:IsA("MeshPart") then
				local WeldOnChild = Child:FindFirstChild("Weld")
				if WeldOnChild then
					WeldOnChild.C0 = OriginalC0[Child]
				end
			end
		end
	end)
	Connections[PlayerReloading]["Fill"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Fill"):Connect(function()
		if Tracks[PlayerReloading] and Tracks[PlayerReloading]["FillSFX"] then
			Tracks[PlayerReloading]["FillSFX"]:Play()
			task.wait(0.2)
			if not Tracks[PlayerReloading]["FillSFX"] then return end
			Tracks[PlayerReloading]["FillSFX"].PlaybackRegion = NumberRange.new(0, 1)
			Tracks[PlayerReloading]["FillSFX"]:Play()

			task.wait(1)
			if not Tracks[PlayerReloading]["FillSFX"] then return end
			Tracks[PlayerReloading]["FillSFX"].PlaybackRegion = NumberRange.new(0, 0.25)
		end
	end)
	Connections[PlayerReloading]["Empty"] = Tracks[PlayerReloading]["ReloadAnimation"]:GetMarkerReachedSignal("Empty"):Connect(function()
		for i = 1, 2 do
			RegularBulletCasing(PlayerReloading.Character, "RayCasing", DefaultData.About["CasingSFX"])
		end
	end)


	Connections[PlayerReloading]["ReloadAttribute"] = PlayerReloading:GetAttributeChangedSignal("IsReloading"):Connect(function()
		if PlayerReloading:GetAttribute("IsReloading") then
			Tracks[PlayerReloading]["ReloadAnimation"]:Play()
		else
			Tracks[PlayerReloading]["ReloadAnimation"]:Stop()
			Tracks[PlayerReloading]["OpenSFX"]:Stop()
			Tracks[PlayerReloading]["FillSFX"]:Stop()
			
			-- RESET PART POSITION 
			for _, Child in OpenFolder:GetDescendants() do
				if Child.Name == "BasePart" then
					Child.Transparency = 0
				end
				if Child:IsA("MeshPart") then
					local WeldOnChild = Child:FindFirstChild("Weld")
					if WeldOnChild and OriginalC0[Child] then
						WeldOnChild.C0 = OriginalC0[Child]
					end
				end
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
function RayGunAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	return PistolAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
end



-- N/A
function RayGunAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end



-- UI
function RayGunAssets.UI(LocalPlayer, GunEquipped)
	return PistolAssets.UI(LocalPlayer, GunEquipped)
end



-- WALL HIT VFX
function RayGunAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	if not ResultData.Normal then return end
	-- DEFAULT DATA
	local DefaultData = ClientGunDataModule.DefaultData[EquippedGun]
	if not DefaultData then return end
	
	-- SFX
	local ID = HttpService:GenerateGUID(false)
	local SFXData = {
		Volume = 0.5,
		PlaybackSpeed = 1,
		PlaybackRegion = NumberRange.new(0.15, 1),
		ForceNew = true, 
		CleanupTime = 2,
		SFXToClone = ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("RayGun"):FindFirstChild("WallHitSFX")
	}
	PlaySFXModule.PlayPartSFX(PlayerFired, ResultData.Position, ID, SFXData)
end



-- WALL MARK VFX
function RayGunAssets.WallMark(PlayerFired, EquippedGun, ResultData)
end



-- ZOMBIE HIT VFX
function RayGunAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end



-- AOE EFFECT
function RayGunAssets.AoeEffect(PlayerShooting, EquippedGun, Position, Radius)
	local RayGunVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("RayGun")
	local AOEEffect = RayGunVFX:FindFirstChild("AOE"):Clone()
	if not RayGunVFX or not AOEEffect then return end
	
	AOEEffect.Position = Position
	for _, Emitter in AOEEffect:GetDescendants() do
		if not Emitter:IsA("ParticleEmitter") then continue end
		if Emitter.Name == "Emit1" then
			Emitter:Emit(1)
		else
			Emitter:Emit(3)
		end
	end
	AOEEffect.Parent = workspace:FindFirstChild("ActiveVFX")
	Debris:AddItem(AOEEffect, 3)
end



-- RETURN
return RayGunAssets