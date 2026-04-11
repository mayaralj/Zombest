local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")
local PlayerData = require(ServerScriptService.ModuleScripts.Data.PlayerData)
local RoundStart = require(script.Parent.RoundStart)
local GunFW = require(ServerScriptService.ModuleScripts.Frameworks.Gun.GunFW)
local ZombieSpawnerFW = require(ServerScriptService.ModuleScripts.Frameworks.Zombie.ZombieSpawnerFW)

-- EVENTS
local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local WaveEvents = Events:WaitForChild("WaveEvents")
local UpdateWaveEvent = WaveEvents:WaitForChild("UpdateWaveEvent")
local RoundResult = WaveEvents:WaitForChild("RoundResult")

-- VARS
local WaveManager = {}
WaveManager.CurrentWave = 0

-- RESET ROUND STATS
local function ResetRoundStats()
	for _, Player in pairs(Players:GetPlayers()) do
		local CurrentPlayerData = PlayerData:Get(Player)
		if CurrentPlayerData and CurrentPlayerData.Points then
			CurrentPlayerData.Points.CurrentPoints = 500
			Player:SetAttribute("CurrentPoints", CurrentPlayerData.Points.CurrentPoints)
		end
		if CurrentPlayerData and CurrentPlayerData.RoundStats then
			CurrentPlayerData.RoundStats.Kills = 0
			CurrentPlayerData.RoundStats.Deaths = 0
			CurrentPlayerData.RoundStats.Revives = 0
			CurrentPlayerData.RoundStats.Knockdowns = 0

			Player:SetAttribute("Kills", 0)
			Player:SetAttribute("Deaths", 0)
			Player:SetAttribute("Revives", 0)
			Player:SetAttribute("Knockdowns", 0)
		end
	end
end

-- CALCULATE MVP
local function CalculateMVP()
	local MVPPlayer
	local HighestScore = -math.huge
	for _, Player in pairs(Players:GetPlayers()) do
		local CurrentPlayerData = PlayerData:Get(Player)
		if not CurrentPlayerData or not CurrentPlayerData.RoundStats then
			continue
		end
		-- CALCULATE EACH SCORE, EACH STAT HAVING ITS OWN WEIGHT
		local Score = CurrentPlayerData.RoundStats.Kills * 5
			+ CurrentPlayerData.RoundStats.Revives * 10
			- CurrentPlayerData.RoundStats.Deaths * 20
			- CurrentPlayerData.RoundStats.Knockdowns * 5
		if not MVPPlayer or Score > HighestScore then
			MVPPlayer = Player
			HighestScore = Score
		end
	end
	return MVPPlayer
end

-- CLEANUP AFTER ROUND END
local function HandleDeadPlayers()
	-- TELEPORT PLAYERS BACK TO LOBBY
	RoundStart.TeleportPlayersToLobby()
	-- CLEAR OUT ZOMBIES
	ZombieSpawnerFW.StopSpawning()
	ZombieSpawnerFW.KillAllZombies()

	-- CALCULATE MVP
	local MVPPlayer = CalculateMVP()

	-- RESET EACH PLAYER AND THEIR ROUND STATS
	ResetRoundStats()
end

-- SOME SETUP BEFORE STARTING FIRST WAVE
local function SetupWaveStart()
	WaveManager.CurrentWave = 0

	-- RESET EACH PLAYER AND THEIR ROUND STATS
	ResetRoundStats()
end

-- MAIN FUNCTION TO START WAVES
function WaveManager.StartWaves()
	-- ENSURE WAVE STUFF RESET BEFORE STARTING
	SetupWaveStart()

	-- CONTINUOUS LOOP TILL EITHER PLAYERS DEAD OR ZOMBIES DEAD
	while true do
		-- INCREMENT WAVE AND FIRE TO UPDATE GUI
		WaveManager.CurrentWave += 1
		UpdateWaveEvent:FireAllClients(WaveManager.CurrentWave)

		-- PLAYER TELEPORTS, GUNS GIVEN, TEAMS SET
		RoundStart.TeleportPlayersToMap()
		for _, Player in Players:GetPlayers() do
			if Player.Team ~= Teams:FindFirstChild("Lobby") then
				continue
			end
			GunFW.GiveWeapon(Player, "TacticalShotgun", true)
		end
		RoundStart.SetPlayersTeams()

		-- BREATHER
		task.wait(1.5)

		-- SPAWN DA ZOMBIES
		local ZombieCount = math.clamp(10 + (WaveManager.CurrentWave - 1) * 5, 10, 400)
		ZombieSpawnerFW.SpawnZombies(ZombieCount)

		-- WAIT TILL RESULT OF ROUND IS DECIDED
		local Result = RoundResult.Event:Wait()
		if not Result then
			HandleDeadPlayers()
			return
		else
			task.wait(3)
		end
	end
end

return WaveManager
