-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Data = ModuleScripts:WaitForChild("Data")

-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))

-- EXISTING PLAYERS
for _, Player in Players:GetPlayers() do
	PlayerData:CreateData(Player)
end

-- CREATE/LOAD DATA FOR PLAYER WHEN THEY JOIN
game.Players.PlayerAdded:Connect(function(Player)
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		PlayerData:CreateData(Player)
	end
end)

-- REMOVE THEIR CREATED/LOADED DATA
game.Players.PlayerRemoving:Connect(function(Player)
	PlayerData:Remove(Player)
end)
