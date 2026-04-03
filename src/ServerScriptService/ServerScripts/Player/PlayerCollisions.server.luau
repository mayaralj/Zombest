-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")


-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Events = ReplicatedStorage:WaitForChild("Events")


-- MODULES
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("Utilities"))



-- SET COLLISION GROUP
local function AddCollisionGroup(Character)
	for _, Part in ipairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.CollisionGroup = "Players"
		end
	end
end
Utilities.BindToCharacter(AddCollisionGroup)