local PlayerHealthFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- FOLDERS
local Modules = ServerScriptService:WaitForChild("ModuleScripts")

-- MODULES
local PlayerData = require(Modules:WaitForChild("Data"):WaitForChild("PlayerData"))

-- Get Player from Character safely
local function GetPlayer(Character)
	return Players:GetPlayerFromCharacter(Character)
end

-- FORCE KILL FUNCTIOn (IGNORES KNOCKDOWN)
function PlayerHealthFW.ForceKill(Player)
	local Character = Player.Character
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	Player:SetAttribute("ForceKill", true)
	Humanoid.Health = 0

	-- SET DEAD POSITION
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if RootPart then
		Player:SetAttribute("DeadPosition", RootPart.Position)
	end

	task.delay(0.5, function()
		Player:SetAttribute("ForceKill", false)
	end)
end

-- CLEANUP CONNECTIONS
function PlayerHealthFW.CleanUpHealthConns(Character)
	local Player = GetPlayer(Character)
	if not Player then
		return
	end
	local PlayerCurrentData = PlayerData:Get(Player)
	if not PlayerCurrentData then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	-- CLEANUP
	if PlayerCurrentData.Health.HealthChangedConnection then
		PlayerCurrentData.Health.HealthChangedConnection:Disconnect()
		PlayerCurrentData.Health.HealthChangedConnection = nil
	end
	if PlayerCurrentData.Health.RegenConnection then
		PlayerCurrentData.Health.RegenConnection:Disconnect()
		PlayerCurrentData.Health.RegenConnection = nil
	end
end

-- DETECT WHEN PLAYER HAS BEEN HIT
function PlayerHealthFW.DetectHit(Character)
	local Player = GetPlayer(Character)
	if not Player then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	local PlayerCurrentData = PlayerData:Get(Player)
	if not PlayerCurrentData then
		return
	end

	if PlayerCurrentData.Health then
		PlayerCurrentData.Health.TimeSinceHit = tick()
		PlayerCurrentData.Health.PreviousHealth = Humanoid.Health
	end

	if PlayerCurrentData.Health.HealthChangedConnection then
		PlayerCurrentData.Health.HealthChangedConnection:Disconnect()
		PlayerCurrentData.Health.HealthChangedConnection = nil
	end

	PlayerCurrentData.Health.HealthChangedConnection = Humanoid.HealthChanged:Connect(function(NewHealth)
		local PreviousHealth = PlayerCurrentData.Health.PreviousHealth or NewHealth
		if NewHealth < PreviousHealth then
			PlayerCurrentData.Health.TimeSinceHit = tick()
		end
		PlayerCurrentData.Health.PreviousHealth = NewHealth
	end)
end

-- CONNECT HEARTBEAT LOOP TO REGEN
function PlayerHealthFW.StartRegen(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	local Player = GetPlayer(Character)
	if not Player then
		return
	end

	local PlayerCurrentData = PlayerData:Get(Player)
	if not PlayerCurrentData then
		return
	end

	if PlayerCurrentData.Health.RegenConnection then
		PlayerCurrentData.Health.RegenConnection:Disconnect()
		PlayerCurrentData.Health.RegenConnection = nil
	end

	PlayerCurrentData.Health.RegenConnection = RunService.Heartbeat:Connect(function(DT)
		if Humanoid.Health <= 0 then
			return
		end

		local TimeSinceDamage = tick() - PlayerCurrentData.Health.TimeSinceHit
		if TimeSinceDamage > PlayerCurrentData.Health.TimeToRegen then
			Humanoid.Health += PlayerCurrentData.Health.RegenRate * DT
		end
	end)
end

-- DISABLE REGEN BY REMOVING CONNECTIONS
function PlayerHealthFW.DisableRegen(Character)
	local Player = GetPlayer(Character)
	if not Player then
		return
	end
	local PlayerCurrentData = PlayerData:Get(Player)
	if not PlayerCurrentData then
		return
	end

	if PlayerCurrentData and PlayerCurrentData.Health and PlayerCurrentData.Health.RegenConnection then
		PlayerCurrentData.Health.RegenConnection:Disconnect()
		PlayerCurrentData.Health.RegenConnection = nil
	end
end

return PlayerHealthFW
