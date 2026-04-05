local ClientBulletProcess = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")

-- EVENTS

-- MODULES
local ClientBulletCleanup = require(Frameworks:WaitForChild("Gun"):WaitForChild("ClientBulletCleanup"))
local DetermineAssets = require(ModuleScripts:WaitForChild("PerGunAssets"):WaitForChild("DetermineAssets"))

-- OTHER

-- PROCESS REGULAR BULLETS
local function ProcessRegularBullet(BulletData, DT)
	BulletData.Age += DT
	local NewPos = BulletData.CurrentPos + BulletData.Velocity * DT
	BulletData.CurrentPos = NewPos

	BulletData.BulletClone.CFrame = CFrame.new(BulletData.CurrentPos, BulletData.CurrentPos + BulletData.Velocity)

	-- DESTROY IF TOO OLD
	if BulletData.Age >= 10 then
		ClientBulletCleanup.RemoveBullet(BulletData.BulletID)
	end
end

-- STREAM RESULT VFX
local function StreamResultVFX(RayResult, BulletData)
	local RayInstance = RayResult.Instance
	if not RayInstance then
		return
	end

	-- GUN DATA
	local PlayerFired = BulletData.PlayerFired
	local PlayerFiredGun = PlayerFired:GetAttribute("EquippedGun")
	if not PlayerFiredGun then
		return
	end

	local AssetsToUse = DetermineAssets.DetermineAssets(PlayerFiredGun)
	if not AssetsToUse then
		return
	end

	-- DEBUG PART
	--local NewPart = Instance.new("Part")
	--NewPart.Parent = workspace
	--NewPart.Anchored = true
	--NewPart.CanCollide = false
	--NewPart.CanTouch = false
	--NewPart.CanQuery = false
	--NewPart.Size = Vector3.new(0.1, 0.1, 14)
	--NewPart.Color = Color3.new(0, 1, 0.282353)
	--NewPart.Position = RayResult.Position
	--Debris:AddItem(NewPart, 0.1)

	-- WALL EFFECT
	if RayInstance:HasTag("PhaseTag") then
		AssetsToUse.WallMark(PlayerFired, RayResult)
		AssetsToUse.WallHit(PlayerFired, RayResult)
	end

	-- ZOMBIE EFFECT
	if CollectionService:HasTag(RayInstance, "ServerZombieTag") then
		AssetsToUse.ZombieHit(PlayerFired, RayResult)
	end
end

-- PROCESS STREAM BULLET
local function ProcessStream(BulletData, DT)
	-- REFERENCE VFX
	local BeamEffect = BulletData.BulletClone
	if not BeamEffect then
		return
	end

	-- BEAM VFX
	local StartBeam = BeamEffect:FindFirstChild("StartBeam")
	local EndBeam = BeamEffect:FindFirstChild("EndBeam")
	if not StartBeam or not EndBeam then
		return
	end

	local StartBeamWeld = BeamEffect:FindFirstChild("StartBeamWeld")
	local EndBeamWeld = BeamEffect:FindFirstChild("EndBeamWeld")
	if not StartBeamWeld or not EndBeamWeld then
		return
	end

	-- MUZZLE
	if not BulletData.CharacterFired then
		return
	end
	if not BulletData.CharacterFired:FindFirstChild("EquippedGun") then
		return
	end
	local Muzzle = BulletData.CharacterFired:FindFirstChild("EquippedGun"):FindFirstChild("Muzzle")
	if not Muzzle then
		return
	end

	-- CHANGE TRANSPARENCY OF VFX DEPENDING ON STATE
	if
		not BulletData.PlayerFired:GetAttribute("IsShooting")
		or BulletData.PlayerFired:GetAttribute("IsCharging")
		or BulletData.PlayerFired:GetAttribute("InWindup")
		or BulletData.PlayerFired:GetAttribute("IsEquipping")
	then
		StartBeamWeld.C1 = CFrame.new(0, 0, 0)
		EndBeamWeld.C1 = CFrame.new(0, 0, 0)

		for _, VFX in ipairs(BulletData.BulletClone:GetDescendants()) do
			if VFX:IsA("BasePart") then
				VFX.Transparency = 1
			elseif VFX:IsA("Beam") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("Trail") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("ParticleEmitter") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("Light") then
				VFX.Enabled = false
			end
		end
		return
	else
		for _, VFX in ipairs(BulletData.BulletClone:GetDescendants()) do
			if VFX:IsA("BasePart") then
				VFX.Transparency = 1
			elseif VFX:IsA("Beam") then
				VFX.Transparency = NumberSequence.new(0)
			elseif VFX:IsA("Trail") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("ParticleEmitter") then
				VFX.Transparency = NumberSequence.new(0)
			elseif VFX:IsA("Light") then
				VFX.Enabled = true
			end
		end
	end

	local RayDistance
	local Overlap
	local RayResult

	-- OVERLAP FIRST
	local OverlapParams = OverlapParams.new()
	OverlapParams.FilterType = Enum.RaycastFilterType.Include
	OverlapParams.FilterDescendantsInstances = {
		workspace:FindFirstChild("ServerZombies"),
		workspace:FindFirstChild("PhaseParts"),
	}
	Overlap = workspace:GetPartBoundsInRadius(Muzzle.Position, 2, OverlapParams)

	if #Overlap > 0 then
		for _, VFX in ipairs(BulletData.BulletClone:GetDescendants()) do
			if VFX:IsA("BasePart") then
				VFX.Transparency = 1
			elseif VFX:IsA("Beam") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("Trail") then
				VFX.Transparency = NumberSequence.new(1)
			elseif VFX:IsA("ParticleEmitter") then
				VFX.Transparency = NumberSequence.new(0)
			elseif VFX:IsA("Light") then
				VFX.Enabled = false
			end
		end
		for _, Part in Overlap do
			local ResultData = {
				Instance = Part,
				Position = Part.Position,
			}
			StreamResultVFX(ResultData, BulletData)
		end
		return
	else
		-- RAYCAST IF NO OVERLAP
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = {
			workspace:FindFirstChild("ServerZombies"),
			workspace:FindFirstChild("PhaseParts"),
		}
		local PlayerFiredRoot = BulletData.PlayerFired.Character:FindFirstChild("HumanoidRootPart")
		RayResult = workspace:Raycast(Muzzle.Position, Muzzle.CFrame.LookVector * 100, RayParams)

		if RayResult then
			-- DETERMINE DISTANCE FROM SERVER ZOMBIE TO CLIENT ZOMBIE
			local ZombieDistance = 0
			if CollectionService:HasTag(RayResult.Instance, "ServerZombieTag") then
				local ServerZombie = RayResult.Instance
				local ClientZombie = workspace
					:FindFirstChild("ClientZombies")
					:FindFirstChild("ClientZombie" .. ServerZombie:GetAttribute("ZombieID"))
				if not ClientZombie or not ServerZombie then
					return
				end
				ZombieDistance = (ServerZombie.Position - ClientZombie.PrimaryPart.Position).Magnitude
			end

			RayDistance = RayResult.Distance + ZombieDistance
			StreamResultVFX(RayResult, BulletData)
		end
	end
	if not RayDistance then
		RayDistance = 100
	end

	-- HOW MUCH TO EXTRA LENGTHEN THE BEAM
	local ExtraLength = 1
	if RayResult and CollectionService:HasTag(RayResult.Instance, "ServerZombieTag") then
		ExtraLength = 3
	end

	StartBeamWeld.C1 = CFrame.new(0, 0, 0)
	if EndBeamWeld.C1.Position.Magnitude > RayDistance then
		EndBeamWeld.C1 = CFrame.new(0, 0, RayDistance + ExtraLength)
	else
		local StartC1 = EndBeamWeld.C1
		local TargetC1 = CFrame.new(0, 0, RayDistance)

		-- IF ZOMBIE MAKE THE LERP ALPHA GREATER
		local LerpAlpha
		local RayInstance = RayResult and RayResult.Instance
		if RayInstance then
			LerpAlpha = 1
		else
			LerpAlpha = 6 * DT
		end
		EndBeamWeld.C1 = StartC1:Lerp(TargetC1, LerpAlpha)
	end

	-- ADJUST LIGHT ALONG BEAM
	if StartBeam:FindFirstChild("SpotLight") then
		local BeamDistance = (StartBeam.Position - EndBeam.Position).Magnitude
		StartBeam:FindFirstChild("SpotLight").Range = BeamDistance + 15
	end
end

-- DETERMINE WHICH BULLET TO PROCESS
function ClientBulletProcess.ProcessBulletType(BulletData, DT)
	local BulletType = BulletData.BulletType
	if BulletType == "Stream" then
		ProcessStream(BulletData, DT)
	else
		ProcessRegularBullet(BulletData, DT)
	end
end

return ClientBulletProcess
