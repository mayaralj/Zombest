local MinigunAssets = {}
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
local RockModule = require(Frameworks:WaitForChild("Rock"):WaitForChild("RockModule"))


-- MODULE
local PistolAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("PistolAssets"))



-- EQUIP ASSETS
function MinigunAssets.Equip(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
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
function MinigunAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
	return PistolAssets.Idle(PlayerViewing, DefaultData, WeaponName, PlayerEquipped)
end




-- MOVEMENT ASSETS
function MinigunAssets.Movement(PlayerViewing, DefaultData, EquippedGun, PlayerRequired)
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
	local WalkSFX = Instance.new("Sound")
	WalkSFX.SoundId = DefaultData.SoundFX.WalkSFX
	WalkSFX.Parent = RootPart
	WalkSFX.Volume = 0.35
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
	Connections[PlayerRequired]["WalkLeft"] = WalkTrack:GetMarkerReachedSignal("LeftStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Left", 2)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["WalkSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)
	Connections[PlayerRequired]["WalkRight"] = WalkTrack:GetMarkerReachedSignal("RightStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Right", 2)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["WalkSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["WalkSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)


	Connections[PlayerRequired]["RunLeft"] = RunTrack:GetMarkerReachedSignal("LeftStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Left", 2)
		if Tracks[PlayerRequired] and Tracks[PlayerRequired]["RunSFX"] then
			local ClonedSFX = Tracks[PlayerRequired]["RunSFX"]:Clone()
			ClonedSFX.Parent = RootPart
			ClonedSFX:Play()
			Debris:AddItem(ClonedSFX, 1)
		end
	end)
	Connections[PlayerRequired]["RunRight"] = RunTrack:GetMarkerReachedSignal("RightStep"):Connect(function()
		RockModule.PlayDustVFX(Character, Tracks[PlayerRequired]["DustVFX"], "Right", 2)
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


	Connections[PlayerRequired]["EquippedGunChanged_Walk"] = PlayerRequired:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
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
			Tracks[PlayerRequired]["WalkAnimation"]:AdjustSpeed(Humanoid.WalkSpeed/20)
		end
		if Tracks[PlayerRequired]["RunAnimation"] then
			Tracks[PlayerRequired]["RunAnimation"]:AdjustSpeed(Humanoid.WalkSpeed/25)
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
					if Tracks[PlayerRequired]["WalkAnimation"] and Tracks[PlayerRequired]["WalkAnimation"].IsPlaying then
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
function MinigunAssets.Shoot(PlayerViewing, DefaultData, EquippedGun, PlayerFired)
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
	if not RootPart or not Humanoid then return end
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	local EquippedGunOnCharacter = Character:FindFirstChild("EquippedGun")
	if not EquippedGunOnCharacter then return end
	local RotateWheel = EquippedGunOnCharacter:FindFirstChild("RotateWheel")
	if not RotateWheel then return end

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
		
		
		if Tracks[PlayerFired]["RotateBackSFX"] then
			Tracks[PlayerFired]["RotateBackSFX"]:Stop()
			Tracks[PlayerFired]["RotateBackSFX"]:Destroy()
			Tracks[PlayerFired]["RotateBackSFX"] = nil
		end
		
		if Tracks[PlayerFired]["RotateToSFX"] then
			Tracks[PlayerFired]["RotateToSFX"]:Stop()
			Tracks[PlayerFired]["RotateToSFX"]:Destroy()
			Tracks[PlayerFired]["RotateToSFX"] = nil
		end
		
		if Tracks[PlayerFired]["ModifiedRotateToSFX"] then
			Tracks[PlayerFired]["ModifiedRotateToSFX"]:Stop()
			Tracks[PlayerFired]["ModifiedRotateToSFX"]:Destroy()
			Tracks[PlayerFired]["ModifiedRotateToSFX"] = nil
		end
	end


	-- INCASE
	FullCleanup()


	-- SHOT SFX
	local ShootSFX = Instance.new("Sound")
	ShootSFX.SoundId = DefaultData.SoundFX.ShootSFX
	ShootSFX.Parent = RootPart
	ShootSFX.Volume = 2.5
	ShootSFX.PlaybackSpeed = 1
	Tracks[PlayerFired]["ContinueShootingSFX"] = ShootSFX
	
	
	-- ROTATE TO SFX
	local RotateToSFX = Instance.new("Sound")
	RotateToSFX.SoundId = DefaultData.SoundFX.RotateToSFX
	RotateToSFX.Parent = RootPart
	RotateToSFX.PlaybackSpeed = 1.5
	Tracks[PlayerFired]["RotateToSFX"] = RotateToSFX
	
	
	local ModifiedRotateToSFX = Instance.new("Sound")
	ModifiedRotateToSFX.SoundId = DefaultData.SoundFX.RotateToLoopSFX
	ModifiedRotateToSFX.Parent = RootPart
	ModifiedRotateToSFX.PlaybackSpeed = 1
	ModifiedRotateToSFX.Volume = 0.6
	ModifiedRotateToSFX.Looped = true
	Tracks[PlayerFired]["ModifiedRotateToSFX"] = ModifiedRotateToSFX
	
	
	
	-- ROTATE BACK SFX
	local RotateBackSFX = Instance.new("Sound")
	RotateBackSFX.SoundId = DefaultData.SoundFX.RotateBackSFX
	RotateBackSFX.Parent = RootPart
	RotateBackSFX.PlaybackSpeed = 1
	Tracks[PlayerFired]["RotateBackSFX"] = RotateBackSFX



	-- CREATE ANIMATION
	local StartAnimation = Instance.new("Animation")
	StartAnimation.AnimationId = StartAnimId
	local StartTrack = Animator:LoadAnimation(StartAnimation)
	StartTrack.Name = "StartShooting"
	StartTrack.Priority = Enum.AnimationPriority.Action2
	StartTrack.Looped = true
	Tracks[PlayerFired]["StartShootingAnimation"] = StartTrack



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
				VFX:Emit(1)
			end
		end
	end


	-- ROTATE EQUIPPED GUN
	local i = 0
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
				local NewC0 = ArmWeld.C0 * CFrame.Angles(0, 0, math.rad(-0.1))
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
		i += 1
		if PlayerFired:GetAttribute("ShotFired") then
			if i % 2 == 0 then return end
			Tracks[PlayerFired]["RotateToSFX"]:Stop()
			if not Tracks[PlayerFired]["ModifiedRotateToSFX"].IsPlaying then
				if PlayerFired:GetAttribute("IsShooting") then
					Tracks[PlayerFired]["ModifiedRotateToSFX"]:Play()
				end
			end
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
		else
			RotateEquippedGun(false)
		end
	end)


	-- EXTRA WELD TO ENSURE BOTH ROTATING PARTS ACT AS 1
	local RotateWheelAdditional = EquippedGunOnCharacter:FindFirstChild("RotatingWheelAdditional")
	local WheelExtraWeld = Instance.new("Weld")
	WheelExtraWeld.Part0 = RotateWheel
	WheelExtraWeld.Part1 = RotateWheelAdditional
	WheelExtraWeld.C0 = RotateWheel.CFrame:ToObjectSpace(RotateWheelAdditional.CFrame)
	WheelExtraWeld.Parent = RotateWheel
	
	-- ROTATE WHEEL AND HANDLE WELD
	local RotateWheelWeld = RotateWheel:FindFirstChild("Weld")
	
	local HeatPart = EquippedGunOnCharacter:FindFirstChild("HeatPart")
	local HeatPartSecondary = EquippedGunOnCharacter:FindFirstChild("HeatPartSecondary")
	-- START SHOOTING ANIMATION
	Connections[PlayerFired]["IsShootingChanged"] = PlayerFired:GetAttributeChangedSignal("IsShooting"):Connect(function()
		if not PlayerFired:GetAttribute("IsShooting") or PlayerFired:GetAttribute("IsKnocked") then
			PartialCleanup()
			

			-- ROTATE BACK SLOWLY
			if Tracks[PlayerFired]["RotateToSFX"] then
				Tracks[PlayerFired]["RotateToSFX"]:Stop()
			end
			if Tracks[PlayerFired]["ModifiedRotateToSFX"] then
				Tracks[PlayerFired]["ModifiedRotateToSFX"]:Stop()
			end
			if Tracks[PlayerFired]["RotateBackSFX"] then
				Tracks[PlayerFired]["RotateBackSFX"]:Play()
			end
			local Count = 0
			repeat
				if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
				local TweenRotateWheel = TweenService:Create(RotateWheelWeld, TweenInfo.new(0.1 * (Count+1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = RotateWheelWeld.C0 * CFrame.Angles(0, 0, math.rad(90))})
				TweenRotateWheel:Play()
				Count += 1
				task.wait(0.075)
			until Count == 15 or PlayerFired:GetAttribute("IsShooting")
		else
			-- PLAY ANIMATION
			if not Tracks[PlayerFired]["StartShootingAnimation"].IsPlaying then
				Tracks[PlayerFired]["StartShootingAnimation"]:Play(0.1)
			end
			
			
			-- ROTATE MINIGUN ROTATE WHEEL
			Tracks[PlayerFired]["RotateBackSFX"]:Stop()
			Tracks[PlayerFired]["RotateToSFX"]:Play()
			local TimeSinceShotStarted = tick()
			local TweenColor
			local TweenColor2
			while PlayerFired:GetAttribute("IsShooting") and not PlayerFired:GetAttribute("IsKnocked") do
				if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
				local SpeedMultiplier = (tick() - TimeSinceShotStarted)
				SpeedMultiplier = math.clamp(SpeedMultiplier, 0.5, 2.5)
				local TweenRotateWheel = TweenService:Create(RotateWheelWeld, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = RotateWheelWeld.C0 * CFrame.Angles(0, 0, math.rad(90 * SpeedMultiplier))})
				TweenRotateWheel:Play()


				-- SLOWLY TURN ROTATING WHEEL ADDITION TO A FLAME COLORED WHEEL
				if not TweenColor or not TweenColor2 then
					task.delay(1.5,function()
						if not PlayerFired:GetAttribute("IsShooting") then return end
						HeatPart.Material = Enum.Material.Neon
						HeatPartSecondary.Material = Enum.Material.Neon
					end)
					TweenColor = TweenService:Create(HeatPart, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Color = Color3.fromRGB(168, 77, 32)})
					TweenColor:Play()
					
					TweenColor2 = TweenService:Create(HeatPartSecondary, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Color = Color3.fromRGB(100, 45, 19)})
					TweenColor2:Play()
				end
				task.wait(0.09)
			end
			TweenColor:Cancel()
			TweenColor = nil
			
			TweenColor2:Cancel()
			TweenColor2 = nil
			
			TweenColor = TweenService:Create(HeatPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(0, 0, 0)})
			TweenColor:Play()
			
			TweenColor2 = TweenService:Create(HeatPartSecondary, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(0, 0, 0)})
			TweenColor2:Play()
			task.wait(0.5)
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then return end
			HeatPartSecondary.Material = Enum.Material.SmoothPlastic
			HeatPart.Material =  Enum.Material.SmoothPlastic
		end
	end)
	
	return true
end



-- RELOAD ASSETS
function MinigunAssets.Reload(PlayerViewing, DefaultData, GunEquipped, PlayerReloading)
	return true -- has no reload
end



-- DASH ASSETS
function MinigunAssets.Dash(PlayerViewing, DefaultData, GunEquipped, PlayerDashing)
	-- PLAYER WITH MINIGUN CANT DASH
	return true
end



-- N/A
function MinigunAssets.Charge(PlayerViewing, ClientGunData, DefaultData, GunEquipped, PlayerDashing)
	return true -- unused function this gun dont have Charge
end


-- UI
function MinigunAssets.UI(LocalPlayer, GunEquipped)
	return PistolAssets.UI(LocalPlayer, GunEquipped)
end



-- WALL HIT VFX
function MinigunAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.WallHit(PlayerFired, EquippedGun, ResultData)
end



-- WALL MARK VFX
function MinigunAssets.WallMark(PlayerFired, EquippedGun, ResultData)
	PistolAssets.WallMark(PlayerFired, EquippedGun, ResultData)
end



-- ZOMBIE HIT VFX
function MinigunAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
	PistolAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end



-- RETURN
return MinigunAssets