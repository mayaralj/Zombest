local RockModule = {}
-- SERVICES
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ROCK DEBRIS FUNCTION
function RockModule.RockDebris(RockDebrisSettings)
	local Chance = RockDebrisSettings.Chance or 0
	local Random = math.random(1, 100)
	if Random < Chance then
		return
	end

	-- SKIP DEPENDING ON RANDOMNUM
	for i = 0, RockDebrisSettings.RockAmount do
		-- CREATE ROCK PART
		local RockPart = Instance.new("Part")
		RockPart.Name = "Rock"
		RockPart.Size = Vector3.new(RockDebrisSettings.Size, RockDebrisSettings.Size, RockDebrisSettings.Size)
		RockPart.Anchored = false
		RockPart.CanCollide = true
		RockPart.CanTouch = false
		RockPart.CanQuery = false
		RockPart.Material = Enum.Material.Concrete
		RockPart.Color = RockDebrisSettings.Part and RockDebrisSettings.Part.Color or Color3.fromRGB(66, 66, 66)
		RockPart.Transparency = 0
		RockPart.CollisionGroup = "Rocks"

		-- ADJUST ROCK
		RockPart.CFrame = CFrame.new(RockDebrisSettings.Position)
		RockPart.Parent = workspace:FindFirstChild("RockDebris")

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Velocity = Vector3.new(
			math.random(-RockDebrisSettings.HorizontalStrength, RockDebrisSettings.HorizontalStrength),
			math.random(RockDebrisSettings.VerticalStrength, RockDebrisSettings.VerticalStrength * 2),
			math.random(-RockDebrisSettings.HorizontalStrength, RockDebrisSettings.HorizontalStrength)
		)
		BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyVelocity.Parent = RockPart

		-- ADD DEBRIS
		game.Debris:AddItem(RockPart, RockDebrisSettings.Time)
		game.Debris:AddItem(BodyVelocity, RockDebrisSettings.Time / 10)
	end
end

-- ROCK TRAIL VFX
function RockModule.PlayRockTrailVFX(Character, RockAmount)
	local RockTrailIndex = 0
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	if not LeftLeg or not RightLeg then
		return
	end

	for i = 0, RockAmount do
		-- ROTATE BETWEEN LEGS
		local Parent
		if RockTrailIndex == 0 then
			Parent = RightLeg
			RockTrailIndex += 1
		else
			Parent = LeftLeg
			RockTrailIndex -= 1
		end

		local RockPart = Instance.new("Part")
		RockPart.Size = Vector3.new(1, 0.1, 1)
		RockPart.Color = Color3.fromRGB(100, 100, 100) -- default color
		RockPart.Material = Enum.Material.Concrete

		RockPart.Transparency = 0
		RockPart.CanCollide = false
		RockPart.CanTouch = false
		RockPart.CanQuery = false
		RockPart.Anchored = true

		-- RAYCAST TO DETERMINE ROCK COLOR
		local RayParams = RaycastParams.new()
		RayParams.FilterDescendantsInstances = { Character }
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		local RayResult = workspace:Raycast(Parent.Position, Vector3.new(0, -10, 0), RayParams)
		if RayResult then
			RockPart.Color = RayResult.Instance.Color
		end

		-- RANDOM ORIENTATION
		RockPart.Orientation = Vector3.new(math.random(-180, 180), 0, math.random(-180, 180))

		RockPart.CollisionGroup = "Rocks"

		if Parent == LeftLeg then
			RockPart.Position = Parent.Position + Vector3.new(0, -1, 0)
		else
			RockPart.Position = Parent.Position + Vector3.new(0, -1, 0)
		end
		RockPart.Parent = workspace.RockDebris

		-- TWEEN ROCK
		local TweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local Tween = TweenService:Create(RockPart, TweenInfo, { Position = RockPart.Position + Vector3.new(0, -3, 0) })
		-- SLIGHT DELAY BEFORE TWEENING
		task.delay(0.5, function()
			Tween:Play()
		end)

		Debris:AddItem(RockPart, 2)
	end
end

-- HELPER TO PLAY DUST VFX
function RockModule.PlayDustVFX(CharacterToAnimate, VFXAttachment, LeftorRight, EmitCount)
	if not VFXAttachment then
		return
	end
	if not CharacterToAnimate then
		return
	end
	local Parent
	if not LeftorRight then
		Parent = CharacterToAnimate:FindFirstChild("Torso")
		VFXAttachment.Position = Vector3.new(0, -1, 0)
	elseif LeftorRight == "Left" then
		Parent = CharacterToAnimate:FindFirstChild("Left Leg")
		VFXAttachment.Position = Vector3.new(0, 0, 0)
	elseif LeftorRight == "Right" then
		Parent = CharacterToAnimate:FindFirstChild("Right Leg")
		VFXAttachment.Position = Vector3.new(0, 0, 0)
	end

	local Color = Color3.fromRGB(100, 100, 100)
	-- RAYCAST TO DETERMINE WHAT COLOR SHOULD BE
	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterDescendantsInstances = { CharacterToAnimate, workspace.PlayerFolder }
	RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local RootPart = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end
	local RaycastResult = workspace:Raycast(RootPart.Position, Vector3.new(0, -10, 0), RaycastParams)
	if RaycastResult then
		Color = RaycastResult.Instance.Color
	end

	VFXAttachment.Parent = Parent
	if not EmitCount then
		EmitCount = 1
	end
	for _, Particle in pairs(VFXAttachment:GetDescendants()) do
		if Particle:IsA("ParticleEmitter") then
			Particle.Color = ColorSequence.new(Color)
			Particle:Emit(EmitCount)
		end
	end
end

return RockModule
