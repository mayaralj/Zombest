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

-- CLEANUP AFTER ROUND END
local function HandleDeadPlayers()
	-- TELEPORT PLAYERS BACK TO LOBBY
	RoundStart.TeleportPlayersToLobby()
	-- CLEAR OUT ZOMBIES
	ZombieSpawnerFW.StopSpawning()
	ZombieSpawnerFW.KillAllZombies()

	-- LOOP THROUGH PLAYERS AND RESET A BUNCH OF THEIR STATS
	for _, Player in pairs(Players:GetPlayers()) do
		local CurrentPlayerData = PlayerData:Get(Player)
		CurrentPlayerData.Points.CurrentPoints = 500
		Player:SetAttribute("CurrentPoints", false)
	end
end

-- SOME SETUP BEFORE STARTING FIRST WAVE
local function SetupWaveStart()
	WaveManager.CurrentWave = 0
	-- LOOP THROUGH PLAYERS AND SET A BUNCH OF THEIR STATS
	for _, Player in pairs(Players:GetPlayers()) do
		local CurrentPlayerData = PlayerData:Get(Player)
		CurrentPlayerData.Points.CurrentPoints = 500
		Player:SetAttribute("CurrentPoints", CurrentPlayerData.Points.CurrentPoints)
	end
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
			GunFW.GiveWeapon(Player, "Pistol", true)
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
