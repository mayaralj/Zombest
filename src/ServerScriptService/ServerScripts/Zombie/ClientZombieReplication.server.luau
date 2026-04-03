-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- FOLDERS
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")
local Events = ReplicatedStorage:WaitForChild("Events")
local ZombieEvents = Events:WaitForChild("ZombieEvents")

-- MODULES
local ZombieData = require(Data:WaitForChild("ZombieData"))

-- EVENTS
local ZombieSpawn = ZombieEvents:WaitForChild("ZombieSpawn")

-- FIRE CLIENT FOR CLIENT TO SHOW CLIENT ZOMBIES
Players.PlayerAdded:Connect(function(Player)
	for ZombiePart, ZData in pairs(ZombieData.ZombieDataTable) do
		if not ZombiePart or not ZombiePart.Parent then
			continue
		end
		if ZData.Health.CurrentHealth <= 0 then
			continue
		end
		if not ZData.Replication.ReplicatedToAll then
			continue
		end

		local ZombieID = ZData.About.ID
		if not ZombieID then
			continue
		end

		local ZombieType = ZData.ZombieType
		local ZombieSubType = ZData.ZombieSubType
		if not ZombieType or not ZombieSubType then
			continue
		end

		ZombieSpawn:FireClient(Player, ZombieID, ZombieType, ZombieSubType, ZombiePart.CFrame)
	end
end)
