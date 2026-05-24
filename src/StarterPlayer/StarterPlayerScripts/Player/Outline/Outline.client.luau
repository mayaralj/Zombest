-- PLAYER
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- MODULES
local ClientGunDataModule = require(ReplicatedStorage.ModuleScripts.Client.ClientGunData)
local ClientUtilities =
	require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Misc"):WaitForChild("ClientUtilities"))

-- ADD CHARACTER OUTLINE
local Connections = {}
local function AddCharacterOutline(Character)
	local PlayerToOutline = Players:GetPlayerFromCharacter(Character)
	if not PlayerToOutline then
		return
	end

	-- CHECK IF ALREADY HAS OUTLINE
	local ExistingHighlight = Character:FindFirstChild("Highlight")
	if ExistingHighlight then
		return
	end

	-- DEFINE
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Highlight"
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 0.75
	Highlight.OutlineColor = Color3.new(1, 1, 1)
	Highlight.Parent = Character

	-- CHECK IF GUN
	if PlayerToOutline:GetAttribute("EquippedGun") or PlayerToOutline:GetAttribute("IsEquippingGun") then
		local CurrentGunData = ClientGunDataModule:Get(PlayerToOutline)
		if not CurrentGunData then
			return
		end
		Highlight.OutlineColor = CurrentGunData.About.OutlineColor
	end

	if not Connections[PlayerToOutline] then
		Connections[PlayerToOutline] = {}
	end

	if Connections[PlayerToOutline]["OutlineChangeGun"] then
		Connections[PlayerToOutline]["OutlineChangeGun"]:Disconnect()
		Connections[PlayerToOutline]["OutlineChangeGun"] = nil
	end

	if Connections[PlayerToOutline]["OutlineKnocked"] then
		Connections[PlayerToOutline]["OutlineKnocked"]:Disconnect()
		Connections[PlayerToOutline]["OutlineKnocked"] = nil
	end

	-- CONNECT TO SEE IF GUN CHANGES
	Connections[PlayerToOutline]["OutlineChangeGun"] = PlayerToOutline:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			-- IF KNOCKED GIVE RED OUTLINE
			if PlayerToOutline:GetAttribute("IsKnocked") then
				Highlight.OutlineColor = Color3.new(1, 0, 0)

			-- ELSE
			else
				if PlayerToOutline:GetAttribute("IsEquippingGun") then
					local CurrentGunData = ClientGunDataModule:Get(PlayerToOutline)
					if not CurrentGunData then
						return
					end
					Highlight.OutlineColor = CurrentGunData.About.OutlineColor
				else
					Highlight.Parent = nil
				end
			end
		end)

	-- CONNECTION FOR KNOCKED
	Connections[PlayerToOutline]["OutlineKnocked"] = PlayerToOutline:GetAttributeChangedSignal("IsKnocked")
		:Connect(function()
			-- IF KNOCKED GIVE RED OUTLINE
			if PlayerToOutline:GetAttribute("IsKnocked") then
				Highlight.OutlineColor = Color3.new(1, 0, 0)
			else
				if PlayerToOutline:GetAttribute("IsEquippingGun") then
					local CurrentGunData = ClientGunDataModule:Get(PlayerToOutline)
					if not CurrentGunData then
						return
					end
					Highlight.OutlineColor = CurrentGunData.About.OutlineColor
				else
					Highlight.Parent = nil
				end
			end
		end)
end

-- HELPER FOR CLEANUp
local function CleanUp(Player)
	if Connections[Player] then
		if Connections[Player]["OutlineChangeGun"] then
			Connections[Player]["OutlineChangeGun"]:Disconnect()
			Connections[Player]["OutlineChangeGun"] = nil
		end

		if Connections[Player]["OutlineKnocked"] then
			Connections[Player]["OutlineKnocked"]:Disconnect()
			Connections[Player]["OutlineKnocked"] = nil
		end

		Connections[Player] = nil
	end
end

-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	if Player.Character then
		AddCharacterOutline(Player.Character)
	end
	Player.CharacterAdded:Connect(function(Character)
		AddCharacterOutline(Character)
	end)
end
-- SETUP NOW
Players.PlayerAdded:Connect(function(Player)
	if Player.Character then
		AddCharacterOutline(Player.Character)
	end
	Player.CharacterAdded:Connect(function(Character)
		AddCharacterOutline(Character)
	end)
end)

-- CLEANUP ON LEAVE
Players.PlayerRemoving:Connect(function(Player)
	CleanUp(Player)
end)
