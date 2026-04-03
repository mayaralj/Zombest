-- SET EXISTING SOUNDS
for _, Sound in pairs(game:GetDescendants()) do
	if Sound:IsA("Sound") then
		Sound.RollOffMode = Enum.RollOffMode.Linear
		Sound.RollOffMaxDistance = 150
	end
end

-- HANDLE NEWER SOUNDS
game.DescendantAdded:Connect(function(Descendant)
	if Descendant:IsA("Sound") then
		Descendant.RollOffMode = Enum.RollOffMode.Linear
		Descendant.RollOffMaxDistance = 150
	end
end)
