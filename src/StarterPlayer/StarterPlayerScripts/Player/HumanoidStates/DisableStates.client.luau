-- PLAYER
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer


-- MODULES
local Modules = ReplicatedStorage:WaitForChild("ModuleScripts")
local Utilities = require(Modules:WaitForChild("Misc"):WaitForChild("ClientUtilities"))



-- DISABLE UNNECESSARY STATES
local function DisableHumanoidStates(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	-- DISABLE HUMANOID STATES
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end



-- BIND TO CHARACTER
Utilities.BindToCharacter(Player, DisableHumanoidStates)