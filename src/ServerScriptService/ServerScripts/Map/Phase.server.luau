-- SERVICES
local CollectionService = game:GetService("CollectionService")


-- FOLDERS
local PhaseParts = workspace:WaitForChild("PhaseParts")


task.wait(3)
for _, Part in ipairs(PhaseParts:GetDescendants()) do
	if Part.Name == "Base" then continue end
	if Part:IsA("BasePart") and not CollectionService:HasTag(Part, "PhaseTag") then
		CollectionService:AddTag(Part, "PhaseTag")
	end
end


PhaseParts.DescendantAdded:Connect(function(Decendant)
	if Decendant:IsA("BasePart") and Decendant.Name ~= "Base" then
		CollectionService:AddTag(Decendant, "PhaseTag")
	end
end)