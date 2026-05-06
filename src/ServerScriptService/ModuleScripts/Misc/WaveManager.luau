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
local MVPEvent = WaveEvents:WaitForChild("MVPEvent")

-- VARS
local WaveManager = {}
WaveManager.CurrentWave = 0

local function ResetPoints(Player)
	local CurrentPlayerData = PlayerData:Get(Player)
	if CurrentPlayerData and CurrentPlayerData.Points then
		if CurrentPlayerData.Points.CurrentPoints == 500 then
			CurrentPlayerData.Points.CurrentPoints = 500.01 -- FORCE UPDATE TO POINTS GUI IF SAME
		else
			CurrentPlayerData.Points.CurrentPoints = 500
		end
		Player:SetAttribute("CurrentPoints", CurrentPlayerData.Points.CurrentPoints)
	end
end

local function ResetPlayerStats(Player)
	local CurrentPlayerData = PlayerData:Get(Player)
	ResetPoints(Player)
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

-- RESET ROUND STATS
local function ResetRoundStats()
	for _, Player in pairs(Players:GetPlayers()) do
		ResetPlayerStats(Player)
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
	-- RoundStart.TeleportPlayersToLobby()
	-- CLEAR OUT ZOMBIES
	ZombieSpawnerFW.StopSpawning()
	ZombieSpawnerFW.KillAllZombies()

	-- CALCULATE MVP
	local MVPPlayer = CalculateMVP()
	-- FIRE MVP EVENT
	MVPEvent:FireAllClients(MVPPlayer, WaveManager.CurrentWave)
end

-- SOME SETUP BEFORE STARTING FIRST WAVE
local function SetupWavesStart()
	WaveManager.CurrentWave = 0
	RoundStart.InRoundCounter = 0
	RoundStart.InRoundLookup = {}

	-- RESET EACH PLAYER AND THEIR ROUND STATS
	ResetRoundStats()
end

local function BeginWaveHelper()
	WaveManager.CurrentWave += 1
	UpdateWaveEvent:FireAllClients(WaveManager.CurrentWave)

	-- PLAYER TELEPORTS, GUNS GIVEN, TEAMS SET
	RoundStart.TeleportPlayersToMap()
	for _, Player in Players:GetPlayers() do
		if Player.Team ~= Teams:FindFirstChild("Lobby") then
			continue
		end
		-- DID THIS TO ENSURE POINT RESET ONLY WORKS ON PLAYERS THAT JOIN LATER OR ARE GETTING RESPAWNED
		if WaveManager.CurrentWave > 1 then
			ResetPoints(Player)
		end
		GunFW.GiveWeapon(Player, "Pistol", true)
		task.wait(2)
		GunFW.GiveWeapon(Player, "RayGun", true)
	end
	RoundStart.SetPlayersTeams()
end

-- MAIN FUNCTION TO START WAVES
function WaveManager.StartWaves()
	-- ENSURE WAVE STUFF RESET BEFORE STARTING
	task.wait(2)
	SetupWavesStart()

	-- CONTINUOUS LOOP TILL EITHER PLAYERS DEAD OR ZOMBIES DEAD
	while true do
		-- BEGIN WAVE CHECKS AND SETUP
		BeginWaveHelper()

		-- BREATHER
		task.wait(4)

		-- SPAWN DA ZOMBIES
		local ZombieCount = math.clamp(10 + (WaveManager.CurrentWave - 1) * 5, 10, 400)
		ZombieSpawnerFW.SpawnZombies(ZombieCount)

		-- WAIT TILL RESULT OF ROUND IS DECIDED
		local Result = RoundResult.Event:Wait()
		if not Result then
			HandleDeadPlayers()
			return
		else
			task.wait(2) -- SMALL WAIT BEFORE STARTING WAVE
		end
	end
end

return WaveManager
