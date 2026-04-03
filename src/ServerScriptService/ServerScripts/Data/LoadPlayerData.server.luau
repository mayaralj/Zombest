-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Data = ModuleScripts:WaitForChild("Data")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")

-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))
local GunData = require(Data:WaitForChild("GunData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))

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
