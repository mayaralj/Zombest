-- SERVICES
local StartPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")


-- MODULES
local CharacterUtlities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))


-- PLAYER
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


-- TABLES
local PromptVisibilityConnections = {}



-- UPDATE REVIVE PROMP VISIBILITY
local function UpdatePromptVisibility()
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid then return end
	
	local IsKnocked = Player:GetAttribute("IsKnocked") or false
	local IsShooting = Player:GetAttribute("IsShooting") or false
	local IsReloading = Player:GetAttribute("IsReloading") or false
	local IsCharging = Player:GetAttribute("IsCharging") or false
	
	for _, Prompt in ipairs(workspace:FindFirstChild("PlayerFolder"):GetDescendants()) do
		if Prompt:IsA("ProximityPrompt") then
			local PromptOwner = Prompt:FindFirstChild("PromptOwner")

			if PromptOwner then
				if PromptOwner.Value == Player or Humanoid.Health <= 0 then
					Prompt.Enabled = false
				else
					Prompt.Enabled = not IsKnocked and not IsShooting and not IsReloading and not IsCharging
				end
			else
				Prompt.Enabled = not IsKnocked and not IsShooting and not IsReloading and not IsCharging
			end
		end
	end
end



-- FIRST USE
UpdatePromptVisibility()



-- EVERYTIME A DESCENDANT IS ADDED, RUN THE FUNCTION
workspace:FindFirstChild("PlayerFolder").DescendantAdded:Connect(function(Descendant)
	if Descendant:IsA("ProximityPrompt") then
		UpdatePromptVisibility()
	end
end)



-- ON CHARACTER ADDED FUNCTION
local function OnCharacterAdded(Character)
	-- DISCONNECT CONNECTIONS
	if PromptVisibilityConnections["KnockedSignal"] then
		PromptVisibilityConnections["KnockedSignal"]:Disconnect()
		PromptVisibilityConnections["KnockedSignal"] = nil
	end
	
	if PromptVisibilityConnections["ShootingSignal"] then
		PromptVisibilityConnections["ShootingSignal"]:Disconnect()
		PromptVisibilityConnections["ShootingSignal"] = nil
	end
	
	if PromptVisibilityConnections["ReloadingSignal"] then
		PromptVisibilityConnections["ReloadingSignal"]:Disconnect()
		PromptVisibilityConnections["ReloadingSignal"] = nil
	end
	
	if PromptVisibilityConnections["ChargingSignal"] then
		PromptVisibilityConnections["ChargingSignal"]:Disconnect()
		PromptVisibilityConnections["ChargingSignal"] = nil
	end


	-- CHANGE BASED ON ATTRIBUTE
	PromptVisibilityConnections["KnockedSignal"] = Character:GetAttributeChangedSignal("IsKnocked"):Connect(UpdatePromptVisibility)
	PromptVisibilityConnections["ShootingSignal"] = Player:GetAttributeChangedSignal("IsShooting"):Connect(UpdatePromptVisibility)
	PromptVisibilityConnections["ReloadingSignal"] = Player:GetAttributeChangedSignal("IsReloading"):Connect(UpdatePromptVisibility)
	PromptVisibilityConnections["ChargingSignal"] = Player:GetAttributeChangedSignal("IsCharging"):Connect(UpdatePromptVisibility)
	UpdatePromptVisibility()
end



-- ON CHARACTER ADDED
CharacterUtlities.BindToCharacter(Player, OnCharacterAdded)