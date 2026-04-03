local PlayerReviveFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")

-- MODULES
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))

-- CONNECTION TABLE
local ReviveConnections = {}
local RevivePair = {}

-- APPLY REVIVE EFFECT
local function RevivePlayer(Player)
	local Character = Player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	local Data = PlayerData:Get(Player)
	if not Data then
		return
	end

	Data.Knockdown.IsKnocked = false

	PlayerHealthFW.StartRegen(Character)
	Humanoid.Health = Humanoid.MaxHealth
	Humanoid.WalkSpeed = Data.Sprint.WalkSpeed

	-- RESET SOME ATTRIBUTES
	Player:SetAttribute("IsCharging", false)
	Player:SetAttribute("IsReloading", false)
	Player:SetAttribute("IsShooting", false)
	Player:SetAttribute("IsSprinting", false)
	Player:SetAttribute("WantsToShoot", false)
	Player:SetAttribute("WantsToSprint", false)
	Player:SetAttribute("WantsToReload", false)
	Player:SetAttribute("WantsToCharge", false)
	Player:SetAttribute("IsReviving", false)

	-- INCASE CHECKS
	if not Player:GetAttribute("IsKnocked") then
		Player:SetAttribute("IsKnocked", true)
		task.delay(0.1, function()
			Player:SetAttribute("IsKnocked", false)
		end)
	else
		Player:SetAttribute("IsKnocked", false)
		task.delay(0.1, function()
			Player:SetAttribute("IsKnocked", false)
		end)
	end
end

-- CREATE REVIVE INTERACT PROMPT
function PlayerReviveFW.ReviveInteract(KnockedPlayer)
	local Character = KnockedPlayer.Character
	if not Character then
		return
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	if not KnockedPlayer:GetAttribute("IsKnocked") then
		return
	end
	if RootPart:FindFirstChild("RevivePrompt") then
		return
	end

	-- CREATE PROMPT
	local Prompt = Instance.new("ProximityPrompt")
	Prompt.Name = "RevivePrompt"
	Prompt.ActionText = "Revive"
	Prompt.MaxActivationDistance = 15
	Prompt.Style = Enum.ProximityPromptStyle.Custom
	Prompt.KeyboardKeyCode = Enum.KeyCode.E
	Prompt.RequiresLineOfSight = false
	Prompt.HoldDuration = 1.5
	Prompt.Parent = RootPart

	-- CREATE PROMPT ATTACHMENT
	local PromptAttachment = Instance.new("ObjectValue")
	PromptAttachment.Name = "PromptOwner"
	PromptAttachment.Value = KnockedPlayer
	PromptAttachment.Parent = Prompt

	-- INITIALIZE KNOCKED PLAYER TABLE
	if not ReviveConnections[KnockedPlayer] then
		ReviveConnections[KnockedPlayer] = {}
	end

	if #Players:GetPlayers() == 1 then
		task.delay(5, function()
			-- DESTROY PROMPT
			Prompt:Destroy()
			-- REMOVE ISREVIVING ATTRIBUTE
			RevivePlayer(KnockedPlayer)
			-- GIVE KNOCKED PLAYER REVIVED ATTRIBUTE
			KnockedPlayer:SetAttribute("IsRevived", true)
			task.delay(1, function()
				KnockedPlayer:SetAttribute("IsRevived", false)
			end)
			-- SET GETTING REVIVED ATTRIBUTE TO KNOCKED PLAYER
			KnockedPlayer:SetAttribute("IsGettingRevived", false)
		end)
	end

	-- PROMPT TRIGGERED
	ReviveConnections[KnockedPlayer]["PromptTriggered"] = Prompt.Triggered:Connect(function(PlayerReviving)
		-- CHECKS
		if PlayerReviving == KnockedPlayer then
			return
		end
		if PlayerReviving:GetAttribute("IsShooting") then
			return
		end
		if PlayerReviving:GetAttribute("IsKnocked") then
			return
		end
		if PlayerReviving:GetAttribute("IsReloading") then
			return
		end
		if PlayerReviving:GetAttribute("IsCharging") then
			return
		end

		-- ENSURE A NON KNOCKED PLAYER DOESNT GET REVIVED
		if not KnockedPlayer:GetAttribute("IsKnocked") then
			return
		end

		-- DESTROY PROMPT
		Prompt:Destroy()
		-- REMOVE ISREVIVING ATTRIBUTE
		RevivePlayer(KnockedPlayer)
		PlayerReviving:SetAttribute("IsReviving", false)
		-- GIVE KNOCKED PLAYER REVIVED ATTRIBUTE
		KnockedPlayer:SetAttribute("IsRevived", true)
		task.delay(1, function()
			KnockedPlayer:SetAttribute("IsRevived", false)
		end)
		-- SET GETTING REVIVED ATTRIBUTE TO KNOCKED PLAYER
		KnockedPlayer:SetAttribute("IsGettingRevived", false)

		-- GIVE POINTS TO PLAYER REVIVING
		local PlayerRevivingData = PlayerData:Get(PlayerReviving)
		if not PlayerRevivingData then
			return
		end
		if PlayerRevivingData.Points and PlayerRevivingData.Points.CurrentPoints then
			PlayerRevivingData.Points.CurrentPoints += 500
			PlayerReviving:SetAttribute("CurrentPoints", PlayerRevivingData.Points.CurrentPoints)
		end

		-- MAKE GUN VISIBLE AGAIN
		local CharacterReviving = PlayerReviving.Character
		if not CharacterReviving then
			return
		end
		local EquippedGun = CharacterReviving:FindFirstChild("EquippedGun")
		if not EquippedGun then
			return
		end
		if EquippedGun then
			for _, Part in pairs(EquippedGun:GetDescendants()) do
				if Part.Name == "Muzzle" then
					continue
				end
				if
					(Part:IsA("BasePart") or Part:IsA("MeshPart")) and not CollectionService:HasTag(Part, "WeightPart")
				then
					Part.Transparency = 0
				end
			end
		end
	end)

	-- ON PROMPT HOLD
	ReviveConnections[KnockedPlayer]["PromptHold"] = Prompt.PromptButtonHoldBegan:Connect(function(PlayerReviving)
		-- CHECKS
		if PlayerReviving == KnockedPlayer then
			return
		end
		if PlayerReviving:GetAttribute("IsShooting") then
			return
		end
		if PlayerReviving:GetAttribute("IsKnocked") then
			return
		end
		if PlayerReviving:GetAttribute("IsReloading") then
			return
		end
		if PlayerReviving:GetAttribute("IsCharging") then
			return
		end

		-- HAVE PLAYER REVIVING FACE THE PLAYER KNOCKED
		local CharacterReviving = PlayerReviving.Character
		if not CharacterReviving then
			return
		end
		local RootReviving = CharacterReviving:FindFirstChild("HumanoidRootPart")
		if not RootReviving then
			return
		end

		-- SET REVIVING ATTRIBUTE
		PlayerReviving:SetAttribute("IsReviving", true)

		-- SET DIRECTION REVIVING PLAYER
		PlayerReviving:SetAttribute("RevivingPlayer", KnockedPlayer.Name)

		-- SET GETTING REVIVED ATTRIBUTE TO KNOCKED PLAYER
		KnockedPlayer:SetAttribute("IsGettingRevived", true)

		-- PAIR UP PLAYERS
		RevivePair[KnockedPlayer] = {}
		RevivePair[KnockedPlayer]["Reviver"] = PlayerReviving
		-- MAKE GUN TRANSPARENT
		local EquippedGun = CharacterReviving:FindFirstChild("EquippedGun")
		if EquippedGun then
			for _, Part in pairs(EquippedGun:GetDescendants()) do
				if Part.Name == "Muzzle" then
					continue
				end
				if
					(Part:IsA("BasePart") or Part:IsA("MeshPart")) and not CollectionService:HasTag(Part, "WeightPart")
				then
					Part.Transparency = 1
				end
			end
		end
	end)

	-- ON PROMPT END
	ReviveConnections[KnockedPlayer]["PromptEnd"] = Prompt.PromptButtonHoldEnded:Connect(function(PlayerReviving)
		-- RESET ATTRIBUTES
		PlayerReviving:SetAttribute("IsReviving", false)
		PlayerReviving:SetAttribute("RevivingPlayer", false)

		-- SET GETTING REVIVED ATTRIBUTE TO KNOCKED PLAYER
		KnockedPlayer:SetAttribute("IsGettingRevived", false)

		-- CHARACTER
		local CharacterReviving = PlayerReviving.Character
		if not CharacterReviving then
			return
		end

		-- MAKE GUN VISIBLE AGAIN
		local EquippedGun = CharacterReviving:FindFirstChild("EquippedGun")
		if EquippedGun then
			for _, Part in pairs(EquippedGun:GetDescendants()) do
				if Part.Name == "Muzzle" then
					continue
				end
				if
					(Part:IsA("BasePart") or Part:IsA("MeshPart")) and not CollectionService:HasTag(Part, "WeightPart")
				then
					Part.Transparency = 0
				end
			end
		end
	end)

	-- CLEANUP
	local function Cleanup()
		if Prompt then
			Prompt:Destroy()
		end

		-- SET GETTING REVIVED ATTRIBUTE TO KNOCKED PLAYER
		KnockedPlayer:SetAttribute("IsGettingRevived", false)
		KnockedPlayer:SetAttribute("IsKnocked", false)

		if ReviveConnections[KnockedPlayer]["PromptTriggered"] then
			ReviveConnections[KnockedPlayer]["PromptTriggered"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PromptTriggered"] = nil
		end
		if ReviveConnections[KnockedPlayer]["PromptHold"] then
			ReviveConnections[KnockedPlayer]["PromptHold"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PromptHold"] = nil
		end
		if ReviveConnections[KnockedPlayer]["PromptEnd"] then
			ReviveConnections[KnockedPlayer]["PromptEnd"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PromptEnd"] = nil
		end
		if ReviveConnections[KnockedPlayer]["PlayerKnockedDead"] then
			ReviveConnections[KnockedPlayer]["PlayerKnockedDead"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PlayerKnockedDead"] = nil
		end

		if ReviveConnections[KnockedPlayer]["PromptDestroyedConnect"] then
			ReviveConnections[KnockedPlayer]["PromptDestroyedConnect"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PromptDestroyedConnect"] = nil
		end

		if ReviveConnections[KnockedPlayer]["PlayerRemoving"] then
			ReviveConnections[KnockedPlayer]["PlayerRemoving"]:Disconnect()
			ReviveConnections[KnockedPlayer]["PlayerRemoving"] = nil
		end

		-- REMOVE ATTRIBUTES FROM PLAYER REVIVING
		if RevivePair[KnockedPlayer] and RevivePair[KnockedPlayer]["Reviver"] then
			RevivePair[KnockedPlayer]["Reviver"]:SetAttribute("IsReviving", nil)
			RevivePair[KnockedPlayer]["Reviver"]:SetAttribute("RevivingPlayer", nil)

			-- MAKE GUN VISIBLE AGAIN
			local CharacterReviving = RevivePair[KnockedPlayer]["Reviver"].Character
			if not CharacterReviving then
				return
			end
			local EquippedGun = CharacterReviving:FindFirstChild("EquippedGun")
			if not EquippedGun then
				return
			end
			for _, Part in pairs(EquippedGun:GetDescendants()) do
				if Part.Name == "Muzzle" then
					continue
				end
				if
					(Part:IsA("BasePart") or Part:IsA("MeshPart")) and not CollectionService:HasTag(Part, "WeightPart")
				then
					Part.Transparency = 0
				end
			end

			-- CLEANUp
			RevivePair[KnockedPlayer]["Reviver"] = nil
			RevivePair[KnockedPlayer] = nil
		end

		ReviveConnections[KnockedPlayer] = {}
	end

	-- CLEANUP
	ReviveConnections[KnockedPlayer]["PlayerKnockedDead"] = Humanoid.Died:Connect(function()
		Cleanup()
	end)

	-- ON PLAYER REMOVING
	ReviveConnections[KnockedPlayer]["PlayerRemoving"] = KnockedPlayer.CharacterRemoving:Connect(function()
		Cleanup()
	end)

	-- CLEANUP
	ReviveConnections[KnockedPlayer]["PromptDestroyedConnect"] = Prompt.Destroying:Connect(function()
		Cleanup()
	end)
end

-- RETURN
return PlayerReviveFW
