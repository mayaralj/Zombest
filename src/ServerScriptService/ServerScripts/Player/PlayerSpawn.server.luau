local Players = game:GetService("Players")

for _, Player in Players:GetPlayers() do
	if Player.Character then
		Player.Character.Parent = workspace:WaitForChild("PlayerFolder")
	end
end


Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		if Character then
			Character.Parent = workspace:WaitForChild("PlayerFolder")
		end
	end)
end)