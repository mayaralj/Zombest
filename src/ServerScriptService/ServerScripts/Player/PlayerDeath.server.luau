-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local DataFolder = ModuleScripts:WaitForChild("Data")

-- MODULES
local PlayerHealthFW = require(Frameworks.Player:WaitForChild("PlayerHealthFW"))
local PlayerKnockedFW = require(Frameworks.Player:WaitForChild("PlayerKnockedFW"))
local RagdollFW = require(
	ReplicatedStorage:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("Ragdoll")
		:WaitForChild("RagdollFW")
)
local Utilities = require(ModuleScripts.Misc:WaitForChild("Utilities"))
local PlayerData = require(DataFolder:WaitForChild("PlayerData"))

-- EVENTS
local RagdollEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerEvents"):WaitForChild("RagdollEvent")

-- IF PLAYER DIES WHILE KNOCKED DOWN
local function HandleKnockedDeath(Character)
	-- RESET ATTRIBUTE
	local Player = game.Players:GetPlayerFromCharacter(Character)
	Player:SetAttribute("IsKnocked", false)

	-- RESET EXTRA ATTRIBUTES
	Player:SetAttribute("IsReviving", false)

	-- CLEAR OUT SOME DATA
	local Data = Player and PlayerData:Get(Player)
	if Data and Data.Knockdown then
		Data.Knockdown.IsKnocked = nil
	end
	if Data and Data.RoundStats then
		Data.RoundStats.Deaths += 1
		Player:SetAttribute("Deaths", Data.RoundStats.Deaths)
	end

	-- REMOVE ALL CONNECTIONS
	PlayerKnockedFW.RemoveKnockedHealthConns(Character)
end

-- KEEP DEAD BODY ON THE GROUND (RAGDOLL ONCLIENT)
local function DeadCharacterBody(Character, Position)
	RagdollEvent:FireAllClients(Character, Position)
end

-- CHARACTER ADDED STUFF
local function OnCharacterAdded(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	local Player = game.Players:GetPlayerFromCharacter(Character)
	if not Humanoid or not Player then
		return
	end

	-- APPLY KNOCKED SETUP
	PlayerKnockedFW.KnockedState(Character)

	-- IF PLAYER DIES
	Humanoid.Died:Once(function()
		HandleKnockedDeath(Character)
		DeadCharacterBody(Character, Character.Position)
	end)

	Character.AncestryChanged:Once(function(_, Parent)
		if not Parent then
			local Data = PlayerData:Get(Player)
			if Data and Data.Knockdown then
				Data.Knockdown.IsKnocked = false
			end
			Player:SetAttribute("IsKnocked", false)
		end
	end)

	return
end

-- CHARACTER ADDED
Utilities.BindToCharacter(OnCharacterAdded)
