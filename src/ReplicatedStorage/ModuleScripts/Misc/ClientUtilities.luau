local ClientUtilities = {}

-- PLAYERS
local Players = game:GetService("Players")

-- FUNCTION FOR CHARACTER ADDED
function ClientUtilities.BindToCharacter(Player, OnCharacter)
	-- WAIT FOR CHARACTER LOAD
	local Character = Player.Character or Player.CharacterAdded:Wait()
	if Character then
		Character:WaitForChild("Humanoid")
		Character:WaitForChild("HumanoidRootPart")
		task.defer(OnCharacter, Character)
	end

	Player.CharacterAdded:Connect(function(CharacterAdded)
		CharacterAdded = Player.Character or Player.CharacterAdded:Wait()
		CharacterAdded:WaitForChild("Humanoid")
		CharacterAdded:WaitForChild("HumanoidRootPart")
		task.defer(OnCharacter, CharacterAdded)
	end)
end

-- RETURN
return ClientUtilities
