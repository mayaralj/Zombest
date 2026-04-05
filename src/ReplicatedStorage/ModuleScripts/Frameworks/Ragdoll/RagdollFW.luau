local RagdollFW = {}

-- SERVICES
local CollectionService = game:GetService("CollectionService")

-- MISC
local DeadCharacters = workspace:WaitForChild("DeadCharacters")

-- CREATE ATTACHMENT
local function CreateAttachment(Part, Name, Pos)
	local Attachment = Instance.new("Attachment")
	Attachment.Name = Name
	Attachment.Position = Pos
	Attachment.Parent = Part
	return Attachment
end

-- CREATE BALLSOCKETCONSTRAINTS
local function CreateBallSocket(Name, Attachment0, Attachment1, Parent, UpperAngle, TwistLower, TwistUpper)
	local BallSocket = Instance.new("BallSocketConstraint")
	BallSocket.Name = Name
	BallSocket.Attachment0 = Attachment0
	BallSocket.Attachment1 = Attachment1
	BallSocket.LimitsEnabled = true
	BallSocket.UpperAngle = UpperAngle or 60
	BallSocket.TwistLimitsEnabled = true
	BallSocket.TwistLowerAngle = TwistLower or -30
	BallSocket.TwistUpperAngle = TwistUpper or 30
	BallSocket.Parent = Parent
	return BallSocket
end

-- APPLY ATTACHMENTS AND BALLSOCKETCONSTRAINTS TO ALLOW RAGDOLL PHYSICS
local function RagdollRig(Model)
	-- GET ALL PARTS
	local Torso = Model:FindFirstChild("Torso")
	local Head = Model:FindFirstChild("Head")
	local RootPart = Model:FindFirstChild("HumanoidRootPart")

	local Limbs = {
		["Left Arm"] = { TorsoPos = Vector3.new(-1, 0.5, 0), LimbPos = Vector3.new(0.5, 1, 0) },
		["Right Arm"] = { TorsoPos = Vector3.new(1, 0.5, 0), LimbPos = Vector3.new(-0.5, 1, 0) },
		["Left Leg"] = { TorsoPos = Vector3.new(-0.5, -1, 0), LimbPos = Vector3.new(-0.5, 1, 0) },
		["Right Leg"] = { TorsoPos = Vector3.new(0.5, -1, 0), LimbPos = Vector3.new(0.5, 1, 0) },
	}

	-- TORSO AND HEAD BALL SOCKET
	if Head and Torso then
		local AttachTorso = CreateAttachment(Torso, "NeckAttachTorso", Vector3.new(0, 0.5, 0))
		local AttachHead = CreateAttachment(Head, "NeckAttachHead", Vector3.new(0, -0.5, 0))
		CreateBallSocket("HeadSocket", AttachTorso, AttachHead, Torso)
	end

	-- LIMB BALLSOCKET
	for LimbName, Pos in pairs(Limbs) do
		local Limb = Model:FindFirstChild(LimbName)
		if Limb and Torso then
			local AttachTorso = CreateAttachment(Torso, LimbName .. "AttachTorso", Pos.TorsoPos)
			local AttachLimb = CreateAttachment(Limb, LimbName .. "AttachLimb", Pos.LimbPos)
			if (LimbName == "Left Leg" or LimbName == "Right Leg") and Model:IsDescendantOf(DeadCharacters) then
				CreateBallSocket(LimbName .. "Constraint", AttachTorso, AttachLimb, Torso, 70, -20, 20)
			else
				CreateBallSocket(LimbName .. "Constraint", AttachTorso, AttachLimb, Torso, 70, -50, 50)
			end
		end
	end

	if RootPart then
		--task.wait(0.05) -- optional delay before ragdoll
		RootPart:Destroy()
	end
end

-- APPLY CORRECT SETTINGS TO HUMANOID TO ALLOW RAGDOLL TO WORK
local function ActivateRagdoll(Model)
	local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
	local IsZombie = CollectionService:HasTag(Model, "ClientZombieTag")

	local CollidableParts = {
		["Head"] = true,
		["Torso"] = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
	}

	for _, Part in ipairs(Model:GetDescendants()) do
		if Part:IsA("Motor6D") then
			Part:Destroy()
		end

		--if Part:IsA("BasePart") and not IsZombie then
		--	Part:SetNetworkOwner(nil)
		--end

		if Part:IsA("BasePart") then
			Part.CollisionGroup = "Default"
			Part.CanCollide = CollidableParts[Part.Name] or false
		end
	end
end

-- RANDOMIZE X, Y, Z VALUES OF A GIVEN VECTOR
local function RandomizeVector(Vector)
	local RandomX = Vector.X + math.random(-10, 10)
	local RandomY = Vector.Y + math.random(-10, 10)
	local RandomZ = Vector.Z + math.random(-10, 10)
	return Vector3.new(RandomX, RandomY, RandomZ)
end

-- APPLY FORCE TO RAGDOLL PARTS
local function ApplyImpulseToRagdollParts(Model, ImpulseVector, Direction)
	for _, Part in pairs(Model:GetChildren()) do
		if Part:IsA("BasePart") then
			local RandomizedImpulse = RandomizeVector(ImpulseVector)

			-- APPLY IMPUSE BASED ON DIRECTION
			if not Direction then
				Direction = Vector3.new(1, 1, 1)
			end
			Part:ApplyImpulse(
				Vector3.new(RandomizedImpulse.X * Direction.X, RandomizedImpulse.Y, RandomizedImpulse.Z * Direction.Z)
					* Part:GetMass()
			)
		end
	end
end

-- DEATH, APPLY RAGDOLL TO CHARACTER/NPC
local MaxAllowedRagdolls = 25
local ActiveRagdolls = {}
function RagdollFW.ActivateRagdoll(Character, ImpulseVector, Direction)
	-- IF LIMIT HIT
	if #ActiveRagdolls > MaxAllowedRagdolls then
		local OldestRagdoll = table.remove(ActiveRagdolls, 1)
		if OldestRagdoll then
			OldestRagdoll:Destroy()
		end
	end
	RagdollRig(Character)
	ActivateRagdoll(Character)
	if ImpulseVector then
		ApplyImpulseToRagdollParts(Character, ImpulseVector, Direction)
	else
		ApplyImpulseToRagdollParts(Character, Vector3.new(0, 15, 0), Direction) -- nice impulse for players
	end

	-- ADD RAGDOLL TO ACTIVE RAGDOLL TABLE
	table.insert(ActiveRagdolls, Character)
end

-- RETURN
return RagdollFW
