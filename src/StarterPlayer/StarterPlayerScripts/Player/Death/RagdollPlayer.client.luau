-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")


-- MODULE SCRIPTS
local Module = ReplicatedStorage:WaitForChild("ModuleScripts")
local RagdollFW = require(Module:WaitForChild("Frameworks"):WaitForChild("Ragdoll"):WaitForChild("RagdollFW"))


-- EVENTS
local RagdollEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerEvents"):WaitForChild("RagdollEvent")



-- RAGDOLL PLAYER
RagdollEvent.OnClientEvent:Connect(function(Character)
	-- CHARACTER STUFF
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then return end

	-- CREATE NEW MODEL
	local DeadCharacters = workspace:FindFirstChild("DeadCharacters")
	local DeadModel = Instance.new("Model")
	DeadModel.Name = Character.Name .. "_DeadBody"
	DeadModel.Parent = DeadCharacters

	-- CLONE EACH PART
	for _, Child in ipairs(Character:GetChildren()) do
		if Child:IsA("BasePart") or Child:IsA("Accessory") or Child:IsA("Shirt") or Child:IsA("Pants") or Child:IsA("BodyColors") then
			local Clone = Child:Clone()
			Clone.Parent = DeadModel
		end
	end

	-- SET UP HUMANOID
	local DeadHumanoid = Humanoid:Clone()
	DeadHumanoid.Parent = DeadModel

	-- HUMANOID STATES AND SETTINGS
	DeadHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	DeadHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	DeadHumanoid.PlatformStand = true
	DeadHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
	DeadHumanoid:ChangeState(Enum.HumanoidStateType.Physics)


	-- WAIT A FRAME
	task.wait()
	-- ACTIVATE RAGDOLL
	RagdollFW.ActivateRagdoll(DeadModel)
	Debris:AddItem(DeadModel, 30)
	
	-- SET CHARACTER PARENT TO NIL (HIDE ORIGINAL CHARACTER)
	Character.Parent = nil
end)