-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local DataEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DataEvents")


-- EVENTS
local CreateClientGun = DataEvents:WaitForChild("CreateClientGun")
local RemoveClientGun = DataEvents:WaitForChild("RemoveClientGun")


-- PLAYER
local LocalPlayer = Players.LocalPlayer


-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))



-- LOAD DATA
for _, OtherPlayer in Players:GetPlayers() do
	ClientPlayerData:CreateData(OtherPlayer)
end


-- CREATE DATA FOR OTHER PLAYERS
Players.PlayerAdded:Connect(function(OtherPlayer)
	local OtherPlayerData = ClientPlayerData:Get(OtherPlayer)
	if not OtherPlayerData then
		ClientPlayerData:CreateData(OtherPlayer)
	end
end)


-- CREATE GUN DATA
CreateClientGun.OnClientEvent:Connect(function(PlayerToCreate, EquippedGun)
	ClientGunData:CreateData(PlayerToCreate, EquippedGun)
end)



-- REMOVE GUN DATA
RemoveClientGun.OnClientEvent:Connect(function(PlayerToRemove)
	ClientGunData:Remove(PlayerToRemove)
end)