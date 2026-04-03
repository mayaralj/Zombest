-- PLAYER
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))

-- DISABLE ANIMATE SCRIPT
local function DisableDefaultAnimate(Character)
	local Animate
	local Count = 0
	repeat
		Animate = Character:FindFirstChild("Animate")
		Count += 1
	until Animate or Count == 10
	if not Animate then
		return
	end
	Animate.Disabled = true
end

-- BIND TO CHARACTER
Utilities.BindToCharacter(Player, DisableDefaultAnimate)
