-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local DataEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DataEvents")


-- EVENTS
local CreateClientGun = DataEvents:WaitForChild("CreateClientGun")


-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))



-- FIRE CLIENT FOR CLIENT TO SHOW PLAYERS THAT JOIN LATER
Players.PlayerAdded:Connect(function(PlayerJoined)
	task.delay(3, function()
		for _, Player in pairs(Players:GetPlayers()) do
			-- GET EQUIPPED GUN
			local Count = 0
			local EquippedGun
			repeat 
				EquippedGun = Player:GetAttribute("IsEquippingGun")
				Count += 1
				task.wait(0.1)
			until EquippedGun or Count == 10
			if not EquippedGun then continue end

			-- FIRE TO CREATE DATA
			CreateClientGun:FireClient(PlayerJoined, Player, EquippedGun)
		end
	end)
end)