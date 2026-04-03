local Utilities = {}

-- SERVICES
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = script.Parent.Parent

-- CHARACTER ADDED
function Utilities.BindToCharacter(OnCharacterAdded)
	local function OnPlayerAdded(Player)
		-- INITIAL
		local Character = Player.Character or Player.CharacterAdded:Wait()
		if Character then
			Character:WaitForChild("Humanoid")
			Character:WaitForChild("HumanoidRootPart")
			task.defer(OnCharacterAdded, Character)
		end

		-- RESPAWN
		Player.CharacterAdded:Connect(function(CharacterAdded)
			CharacterAdded:WaitForChild("Humanoid")
			CharacterAdded:WaitForChild("HumanoidRootPart")
			task.defer(OnCharacterAdded, CharacterAdded)
		end)
	end

	for _, Player in ipairs(Players:GetPlayers()) do
		OnPlayerAdded(Player)
	end
	Players.PlayerAdded:Connect(OnPlayerAdded)
end

-- PLAYER ADDED
function Utilities.BindToPlayer(OnPlayerAdded)
	local function HandlePlayerAdded(Player)
		task.defer(OnPlayerAdded, Player)
	end

	for _, Player in ipairs(Players:GetPlayers()) do
		HandlePlayerAdded(Player)
	end

	Players.PlayerAdded:Connect(HandlePlayerAdded)
end

return Utilities
