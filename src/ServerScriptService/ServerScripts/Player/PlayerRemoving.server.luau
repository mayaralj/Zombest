-- SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")


-- FOLDERS
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")


-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))



Players.PlayerRemoving:Connect(function(Player)
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then return end

	PlayerData:Remove(Player)
end)