-- PLAYER
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local Player = Players.LocalPlayer

-- DISABLE RUNNING VOLUME
local function DisableDefaultSFX(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local RunningSound = RootPart:WaitForChild("Running", 5) -- to be safe
	if RunningSound then
		RunningSound.Volume = 0
	end
end

-- BIND TO CHARACTER
Utilities.BindToCharacter(Player, DisableDefaultSFX)
