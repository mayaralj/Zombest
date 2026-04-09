local PlayerKnockedFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")

-- MODULES
local RoundStart = require(ServerScriptService.ModuleScripts.Misc.RoundStart)
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))
local PlayerReviveFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerReviveFW"))
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))

-- VARS
PlayerKnockedFW.KnockedPlayerCount = 0

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
		while Player and Player.Parent and Humanoid and Humanoid.Health > 0 do
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
		-- IGNORE KNOCKED IF FORCE KILL ACTIVATED
		if Health <= 0 and Player:GetAttribute("ForceKill") then
			return
		end

		-- CHECK IF ABOUT TO BE LAST TO GET KNOCKED
		if
			Health <= 1
			and not Player:GetAttribute("IsKnocked")
			and (PlayerKnockedFW.KnockedPlayerCount + 1) >= RoundStart.InRoundCounter
		then
			-- LOOP THROUGH ALL PLAYERS AND KILL THEM ALL
			for _, OtherPlayer in pairs(Players:GetPlayers()) do
				PlayerHealthFW.ForceKill(OtherPlayer)
			end
			return
		end

		-- KNOCK PLAYERS IF MORE THAN 1 NON KNOCKED PLAYER
		if Health <= 1 and not Player:GetAttribute("IsKnocked") and RoundStart.InRoundCounter > 1 then
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

-- HANDLE PLAYER REMOVAL TO UPDATE KNOCKED COUNT AND CLEANUP CONNS
local KnockedAttributeConns = {}
local ReviveAttributeConns = {}
local function HandlePlayerRemoving(Player)
	KnockedAttributeConns[Player]:Disconnect()
	KnockedAttributeConns[Player] = nil
	if Player:GetAttribute("IsKnocked") then
		PlayerKnockedFW.KnockedPlayerCount -= 1
		local Character = Player.Character
		if Character then
			PlayerKnockedFW.RemoveKnockedHealthConns(Character)
		end
	end
end
Players.PlayerRemoving:Connect(function(Player)
	HandlePlayerRemoving(Player)
end)

-- SET UP ATTRIBUTE CHANGED SIGNAL TO TRACK KNOCKED PLAYER COUNT
local function HandlePlayerAdded(Player)
	KnockedAttributeConns[Player] = Player:GetAttributeChangedSignal("IsKnocked"):Connect(function()
		if Player:GetAttribute("IsKnocked") then
			PlayerKnockedFW.KnockedPlayerCount += 1
		else
			PlayerKnockedFW.KnockedPlayerCount -= 1
		end
	end)
end
for _, Player in pairs(Players:GetPlayers()) do
	HandlePlayerAdded(Player)
end
Players.PlayerAdded:Connect(function(Player)
	HandlePlayerAdded(Player)
end)

return PlayerKnockedFW
