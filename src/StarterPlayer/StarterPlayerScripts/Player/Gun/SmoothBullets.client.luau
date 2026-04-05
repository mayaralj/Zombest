-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")

-- EVENTS
local FireVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("FireVisualBullet")
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")

-- MODULES
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local ClientBulletCleanup = require(Frameworks:WaitForChild("Gun"):WaitForChild("ClientBulletCleanup"))
local ClientFireProcess = require(Frameworks:WaitForChild("Gun"):WaitForChild("ClientFireProcess"))

-- OTHER

-- CREATE BULLET VISUAL
FireVisualBullet.OnClientEvent:Connect(function(PlayerFired, ServerData)
	local PlayerFiredGunData = ClientGunData:Get(PlayerFired)
	if not PlayerFiredGunData then
		return
	end

	ClientFireProcess.FireToProcess(PlayerFired, PlayerFiredGunData, ServerData)
end)

-- CLEANUP
DeleteVisualBullet.OnClientEvent:Connect(function(BulletID)
	ClientBulletCleanup.RemoveBullet(BulletID)
end)
