local PlayerKnockedFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")

-- MODULES
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))
local PlayerReviveFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerReviveFW"))
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))

-- EVENTS

-- APPLY KNOCKED EFFECT
local function KnockedEffect(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	local Player = Players:GetPlayerFromCharacter(Character)
	local Data = Player and PlayerData:Get(Player)
	if not Data then
		return
	end

	-- DISABLE ATTRIBUTES
	Player:SetAttribute("IsReviving", false)

	Humanoid.WalkSpeed = 7
	Humanoid.Health = 30

	PlayerHealthFW.DisableRegen(Character)

	if Data.Knockdown.HealthDrainTask then
		task.cancel(Data.Knockdown.HealthDrainTask)
		Data.Knockdown.HealthDrainTask = nil
	end

	Data.Knockdown.HealthDrainTask = task.spawn(function()
		while Player and Humanoid and Humanoid.Health > 0 do
			-- IF NO LONGER KNOCKED BREAK
			if not Player:GetAttribute("IsKnocked") then
				break
			end
			if Player:GetAttribute("IsRevived") then
				break
			end

			-- DISABLE HP LOSS IF GETTING REVIVED
			if Player:GetAttribute("IsGettingRevived") then
				task.wait(0.1)
				continue
			end

			-- DECREASE HP
			Humanoid.Health -= 1
			task.wait(1)
		end
	end)

	if Player then
		PlayerReviveFW.ReviveInteract(Player)
	end
end

-- KNOCKED STATE LISTENER
function PlayerKnockedFW.KnockedState(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid then
		return
	end

	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end

	local Data = PlayerData:Get(Player)
	if not Data then
		return
	end

	Humanoid.BreakJointsOnDeath = false
	Humanoid.RequiresNeck = false

	if Data.Knockdown.KnockedHealthConnections then
		Data.Knockdown.KnockedHealthConnections:Disconnect()
		Data.Knockdown.KnockedHealthConnections = nil
	end

	Data.Knockdown.KnockedHealthConnections = Humanoid.HealthChanged:Connect(function(Health)
		if Health <= 0 and Player:GetAttribute("ForceKill") then
			return
		end
		if Health <= 1 and not Player:GetAttribute("IsKnocked") and #Players:GetPlayers() > 1 then
			Data.Knockdown.IsKnocked = true
			Player:SetAttribute("IsKnocked", true)
			KnockedEffect(Character)
		end
	end)
end

-- CLEANUP CONNECTIONS
function PlayerKnockedFW.RemoveKnockedHealthConns(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end

	local Data = PlayerData:Get(Player)
	if not Data then
		return
	end

	if Data.Knockdown.KnockedHealthConnections then
		Data.Knockdown.KnockedHealthConnections:Disconnect()
		Data.Knockdown.KnockedHealthConnections = nil
	end
	if Data.Knockdown.HealthDrainTask then
		task.cancel(Data.Knockdown.HealthDrainTask)
		Data.Knockdown.HealthDrainTask = nil
	end
end

return PlayerKnockedFW
