-- SERVICES
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local BulletEvents = Events:WaitForChild("BulletEvents")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))
local ClientZombieData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientZombieData"))
local DetermineAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("DetermineAssets"))

-- EVENTS
local WallRicochetEvent = BulletEvents:WaitForChild("WallRicochetEvent")
local ZombieRicochetEvent = BulletEvents:WaitForChild("ZombieRicochetEvent")
local ChainVFXEvent = BulletEvents:WaitForChild("ChainVFXEvent")
local AOEFX = BulletEvents:WaitForChild("AOEFX")
local BurnEffect = BulletEvents:WaitForChild("BurnEffect")

-- AOE FX
AOEFX.OnClientEvent:Connect(function(PlayerShooting, EquippedGun, Position, Radius)
	-- GET ASSETS REQUIRED
	local AssetsToUse = DetermineAssets.DetermineAssets(EquippedGun)
	if not AssetsToUse then
		return
	end

	-- USE CORRESPONDING GUN AOE EFFECT
	AssetsToUse.AoeEffect(PlayerShooting, EquippedGun, Position, Radius)
end)

-- BURN STATUS
local BurnZombieConn = {}
BurnEffect.OnClientEvent:Connect(function(ZombieID, NewBurnTime, NewBurnDamage)
	-- DATA
	local ClientHitIndex = ClientZombieData.ZombieIndex[ZombieID]
	if not ClientHitIndex then
		return
	end
	local Zombie = ClientZombieData.ZombieArray[ClientHitIndex]
	if not Zombie then
		return
	end
	local CurrentZombieData = ClientZombieData:Get(Zombie)
	if not CurrentZombieData then
		return
	end

	-- GET BURN DATA
	local BurnData = CurrentZombieData.Status.Burn
	if not BurnData then
		return
	end

	-- UPDATE DATA
	BurnData.BurnTime = NewBurnTime
	BurnData.BurnDamage = NewBurnDamage

	-- VFX
	local BurnEffectVFX =
		ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("BurnVFX"):FindFirstChild("BurnEffect")
	if not BurnEffectVFX then
		return
	end

	-- APPLY BURN VFX
	local Torso = Zombie:FindFirstChild("Torso")
	if not Torso then
		return
	end

	-- ADD VFX TO TORSO
	for _, Emitter in BurnEffectVFX:GetDescendants() do
		if Emitter:IsA("ParticleEmitter") then
			local EmitterClone = Emitter:Clone()
			EmitterClone.Enabled = true
			EmitterClone.Parent = Torso

			BurnData.BurnVFX = EmitterClone
		end
	end

	-- IF BURNING AND DEAD
	if BurnZombieConn[Zombie] then
		return
	end
	BurnZombieConn[Zombie] = Zombie:GetAttributeChangedSignal("IsDead"):Connect(function()
		-- END IF:
		if not BurnData.BurnVFX then
			return
		end
		if BurnData.BurnTime <= 0 then
			return
		end

		-- USE TORSO SINCE CURRENTZOMBIE IS A MODEL
		if not LocalPlayer.Character then
			return
		end
		if
			(Zombie.Torso.Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > 250
		then
			return
		end

		-- END OUTLINE
		if BurnData.Outline then
			Debris:AddItem(BurnData.Outline, 0.1)
			BurnData.Outline = nil
		end

		-- CHANGE UP BURN VFX AND DELETE AFTER 5 SEC
		if BurnData.BurnVFX then
			BurnData.BurnVFX.Speed = NumberRange.new(0.01)
			Debris:AddItem(BurnData.BurnVFX, 5)
		end

		-- RANDOM CHARRING
		if math.random() <= 0.5 then
			-- ADD CHARRING TO ZOMBIE
			for _, Part in Zombie:GetDescendants() do
				if Part:IsA("BasePart") then
					-- RANDOM NUM
					local RandomNum = math.random(1, 4)
					local NewColor

					-- RANDOMIZE COLOR
					if RandomNum == 1 then
						NewColor = Color3.new(0.470588, 0.470588, 0.470588)
					elseif RandomNum == 2 then
						NewColor = Color3.new(0.290196, 0.290196, 0.290196)
					elseif RandomNum == 3 then
						NewColor = Color3.new(0.164706, 0.164706, 0.164706)
					elseif RandomNum == 4 then
						NewColor = Color3.new(0.0431373, 0.0431373, 0.0431373)
					end

					-- SET MATERIAL AND TWEEN COLOR
					Part.Material = Enum.Material.Cardboard
					local ColorTween =
						TweenService:Create(Part, TweenInfo.new(10, Enum.EasingStyle.Linear), { Color = NewColor })
					ColorTween:Play()
				end
			end
		end

		-- CLEANUP CONNECTION
		BurnZombieConn[Zombie]:Disconnect()
		BurnZombieConn[Zombie] = nil
	end)
end)

-- CLIENT BULLET RICOCHET EFFECT
WallRicochetEvent.OnClientEvent:Connect(function(BulletID, NewDirection, NewPos)
	-- DATA
	local BulletIndex = ClientGunData.ClientBulletIndex[BulletID]
	if not BulletIndex then
		return
	end
	local BulletData = ClientGunData.ClientBulletData[BulletIndex]
	if not BulletData then
		return
	end

	-- DISABLE TRAIL
	local Trail = BulletData.BulletClone:FindFirstChild("Trail")
	Trail:Clear()

	-- UPDATE BULLET DATA
	BulletData.Direction = NewDirection
	BulletData.Velocity = NewDirection * BulletData.BulletSpeed
	BulletData.CurrentPos = NewPos

	-- UPDATE CFRAME
	BulletData.BulletClone.CFrame = CFrame.new(BulletData.CurrentPos, BulletData.CurrentPos + BulletData.Velocity)
end)

-- CLIENT ZOMBIE RICOCHET EFFECT
ZombieRicochetEvent.OnClientEvent:Connect(function(BulletID, NewDirection, NewPos)
	-- DATA
	local BulletIndex = ClientGunData.ClientBulletIndex[BulletID]
	if not BulletIndex then
		return
	end
	local BulletData = ClientGunData.ClientBulletData[BulletIndex]
	if not BulletData then
		return
	end

	-- DISABLE TRAIL
	local Trail = BulletData.BulletClone:FindFirstChild("Trail")
	Trail:Clear()

	-- UPDATE BULLET DATA
	BulletData.Direction = NewDirection
	BulletData.Velocity = NewDirection * BulletData.BulletSpeed
	BulletData.CurrentPos = NewPos

	-- UPDATE CFRAME
	BulletData.BulletClone.CFrame = CFrame.new(BulletData.CurrentPos, BulletData.CurrentPos + BulletData.Velocity)
end)

-- CHAIN VFX FOR CHAIN EFFECT
ChainVFXEvent.OnClientEvent:Connect(function(PlayerFired, ZombieID, StunTime, LastID)
	-- GET INSTANCE ON THE CLIENT
	local ClientHitIndex = ClientZombieData.ZombieIndex[ZombieID]
	if not ClientHitIndex then
		return
	end
	local CurrentZombie = ClientZombieData.ZombieArray[ClientHitIndex]
	if not CurrentZombie then
		return
	end
	local CurrentZombieData = ClientZombieData:Get(CurrentZombie)
	if not CurrentZombieData then
		return
	end

	-- UPDATE STUN TIME FOR ZOMBIE DATA
	CurrentZombieData.Status.Stun.StunTime += StunTime

	-- PREVIOUS ZOMBIE IF EXISTS
	local PreviousZombie
	if LastID then
		local PreviousInstanceIndex = ClientZombieData.ZombieIndex[LastID]
		PreviousZombie = ClientZombieData.ZombieArray[PreviousInstanceIndex]
		local PreviousZombieData = ClientZombieData:Get(PreviousZombie)
		if not PreviousZombieData then
			return
		end
	end

	-- VFX FOLDER
	local WorkspaceVFXFolder = ReplicatedStorage.GunVFX:FindFirstChild("Lightning")
	if not WorkspaceVFXFolder then
		return
	end
	local HitEffect = WorkspaceVFXFolder:FindFirstChild("LightningHitEffect")
	if not HitEffect then
		return
	end
	local ChainEffect = HitEffect:FindFirstChild("ChainEffect"):Clone()
	if not ChainEffect then
		return
	end

	-- BEAM EFFECTS
	local BeamEffect = ChainEffect:FindFirstChild("BeamEffect")
	if not BeamEffect then
		return
	end
	local StartBeam = BeamEffect:FindFirstChild("StartBeam")
	if not StartBeam then
		return
	end
	local EndBeam = BeamEffect:FindFirstChild("EndBeam")
	if not EndBeam then
		return
	end

	-- TORSO
	local PreviousTorso = PreviousZombie and PreviousZombie:FindFirstChild("Torso")
	local CurrentTorso = CurrentZombie:FindFirstChild("Torso")
	if not CurrentTorso then
		return
	end

	-- GUN DATA
	local CurrentGunData = ClientGunData:Get(PlayerFired)
	if not CurrentGunData then
		return
	end
	local PlayerFiredGun = PlayerFired:GetAttribute("EquippedGun")
	if not PlayerFiredGun then
		return
	end

	-- TRACKS
	local Tracks = ClientGunData.Tracks
	if not Tracks then
		return
	end

	if CurrentTorso:FindFirstChild("ChainHitSFX") then
		CurrentTorso.ChainHitSFX:Destroy()
	end

	-- SOUNDS
	local ChainHitSFX =
		ReplicatedStorage:FindFirstChild("GunSFX"):FindFirstChild("LightningFist"):FindFirstChild("ChainHitSFX"):Clone()
	ChainHitSFX.Volume = 0.1
	ChainHitSFX.RollOffMode = Enum.RollOffMode.Linear
	ChainHitSFX.RollOffMaxDistance = 125
	ChainHitSFX.RollOffMinDistance = 0
	ChainHitSFX.PlaybackSpeed = 1
	ChainHitSFX.Parent = CurrentTorso

	if CurrentTorso:FindFirstChild("ChainLingerSFX") then
		CurrentTorso.ChainLingerSFX:Destroy()
	end
	local ChainLingerSFX = ReplicatedStorage:FindFirstChild("GunSFX")
		:FindFirstChild("LightningFist")
		:FindFirstChild("ChainLingerSFX")
		:Clone()
	ChainLingerSFX.Volume = 0.08
	ChainLingerSFX.Looped = true
	ChainLingerSFX.RollOffMode = Enum.RollOffMode.Linear
	ChainLingerSFX.RollOffMaxDistance = 125
	ChainLingerSFX.RollOffMinDistance = 0
	ChainLingerSFX.PlaybackRegionsEnabled = true
	ChainLingerSFX.PlaybackRegion = NumberRange.new(0, 0.25)
	ChainLingerSFX.PlaybackSpeed = 1
	ChainLingerSFX.Parent = CurrentTorso

	ChainHitSFX:Play()
	ChainLingerSFX:Play()

	-- ANIMATIONS
	local ChainAnimationID = CurrentGunData.Animations.ChainStun
	if not ChainAnimationID then
		return
	end

	local AnimationController = CurrentZombie:FindFirstChild("AnimationController")
	if not AnimationController then
		return
	end

	local ChainAnimation = Instance.new("Animation")
	ChainAnimation.AnimationId = ChainAnimationID

	local CurrentAnimation = AnimationController:LoadAnimation(ChainAnimation)
	CurrentAnimation.Priority = Enum.AnimationPriority.Action3
	CurrentAnimation:Play()
	CurrentAnimation:AdjustSpeed(2)

	local StartWeld, EndWeld
	if PreviousZombie then
		StartBeam.CFrame = PreviousTorso.CFrame
		EndBeam.CFrame = CurrentTorso.CFrame
		if not PreviousTorso:FindFirstChild("StartWeld") or not CurrentTorso:FindFirstChild("EndWeld") then
			StartWeld = Instance.new("WeldConstraint")
			StartWeld.Name = "StartWeld"
			StartWeld.Part0 = PreviousTorso
			StartWeld.Part1 = StartBeam
			StartWeld.Parent = PreviousTorso

			EndWeld = Instance.new("WeldConstraint")
			EndWeld.Name = "EndWeld"
			EndWeld.Part0 = CurrentTorso
			EndWeld.Part1 = EndBeam
			EndWeld.Parent = CurrentTorso
		end
	else
		StartBeam.CFrame = CurrentTorso.CFrame
		EndBeam.CFrame = CurrentTorso.CFrame
	end

	for _, Particle in pairs(ChainEffect:GetDescendants()) do
		if Particle:IsA("ParticleEmitter") then
			Particle:Emit(Particle.Rate)
			Particle.Enabled = true
		end
	end

	-- KEEP VFX ON WHEN ZOMBIE DEAD
	local Connection2
	Connection2 = CurrentZombie:GetAttributeChangedSignal("IsDead"):Connect(function()
		if CurrentZombie:GetAttribute("IsDead") then
			if not ChainEffect then
				return
			end
			if BeamEffect then
				BeamEffect:Destroy()
			end
			if StartBeam then
				StartBeam:Destroy()
			end
			if EndBeam then
				EndBeam:Destroy()
			end
			if PreviousTorso and PreviousTorso:FindFirstChild("StartWeld") then
				PreviousTorso.StartWeld:Destroy()
			end
			if CurrentTorso:FindFirstChild("EndWeld") then
				CurrentTorso.EndWeld:Destroy()
			end
			if ChainLingerSFX then
				ChainLingerSFX:Destroy()
			end
			if ChainHitSFX then
				ChainHitSFX:Destroy()
			end
		end
		if Connection2 then
			Connection2:Disconnect()
			Connection2 = nil
		end
	end)

	-- DESTROY ANIMATION
	task.delay(StunTime + 0.1, function()
		if CurrentAnimation then
			CurrentAnimation:Stop()
			CurrentAnimation:Destroy()
			CurrentAnimation = nil
		end
		if ChainHitSFX then
			ChainHitSFX:Destroy()
		end
		if ChainLingerSFX then
			ChainLingerSFX:Destroy()
		end
		if ChainEffect then
			ChainEffect:Destroy()
			ChainEffect = nil
		end
		if Connection2 then
			Connection2:Disconnect()
			Connection2 = nil
		end
	end)

	-- PARENT EFFECT
	ChainEffect.Parent = CurrentTorso

	-- DESTROY INTIIAL HIT SFX
	ChainHitSFX.Ended:Connect(function()
		if ChainHitSFX then
			ChainHitSFX:Destroy()
		end
	end)
end)
