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

	Player.CharacterAdded:Connect(function(Character)
		Character = Player.Character or Player.CharacterAdded:Wait()
		Character:WaitForChild("Humanoid")
		Character:WaitForChild("HumanoidRootPart")
		task.defer(OnCharacter, Character)
	end)
end



-- RETURN
return ClientUtilities