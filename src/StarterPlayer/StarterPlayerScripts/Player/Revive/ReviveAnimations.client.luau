-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")

-- MODULES
local ClientPlayerDataModule = require(ClientData:WaitForChild("ClientPlayerData"))

-- REVIVE ANIMATION
local ReviveTrack
local function PlayReviveAnimation()
	-- CHARACTER
	local Character = Player.Character
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart or not Player then
		return
	end

	-- DATA
	local ClientPlayerData = ClientPlayerDataModule:Get(Player)
	if not ClientPlayerData then
		return
	end

	-- REVIVE ANIMATION
	local ReviveAnimation = Instance.new("Animation")
	ReviveAnimation.AnimationId = ClientPlayerData.Revive.ReviveAnimation

	-- REVIVE TRACK
	ReviveTrack = Humanoid:LoadAnimation(ReviveAnimation)

	-- SET LOOP AND PRIORITY
	ReviveTrack.Looped = true
	ReviveTrack.Priority = Enum.AnimationPriority.Action4

	-- PLAY REVIVE ANIMATION
	ReviveTrack:Play(0.2)
end

-- ON REVIVE ATTRIBUTE CHANGE
Player:GetAttributeChangedSignal("IsReviving"):Connect(function()
	if Player:GetAttribute("IsReviving") then
		if ReviveTrack and ReviveTrack.IsPlaying then
			return
		end
		if ReviveTrack then
			ReviveTrack:Play(0.2)
			return
		end
		PlayReviveAnimation()
	else
		if ReviveTrack then
			ReviveTrack:Stop()
			ReviveTrack:Destroy()
			ReviveTrack = nil
		end
	end
end)
