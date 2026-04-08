local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")
local RoundStart = require(script.Parent.RoundStart)
local GunFW = require(ServerScriptService.ModuleScripts.Frameworks.Gun.GunFW)
local ZombieSpawnerFW = require(ServerScriptService.ModuleScripts.Frameworks.Zombie.ZombieSpawnerFW)

-- EVENTS
local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local WaveEvents = Events:WaitForChild("WaveEvents")
local UpdateWaveEvent = WaveEvents:WaitForChild("UpdateWaveEvent")
local RoundResult = WaveEvents:WaitForChild("RoundResult")

local WaveManager = {}
WaveManager.CurrentWave = 0

function WaveManager.StartWaves()
	-- ENSURE CURENT WAVE IS RESET
	WaveManager.CurrentWave = 0
	while true do
		WaveManager.CurrentWave += 1
		UpdateWaveEvent:FireAllClients(WaveManager.CurrentWave)

		RoundStart.TeleportPlayersToMap()
		for _, Player in Players:GetPlayers() do
			if Player.Team ~= Teams:FindFirstChild("Lobby") then
				continue
			end
			GunFW.GiveWeapon(Player, "Pistol", true)
		end
		RoundStart.SetPlayersTeams()

		task.wait(1.5)

		local ZombieCount = math.clamp(10 + (WaveManager.CurrentWave - 1) * 5, 40, 200)
		task.spawn(ZombieSpawnerFW.SpawnZombies, ZombieCount)

		local Result = RoundResult.Event:Wait()
		if not Result then
			print("PLayers all dead")
			return
		else
			print("Zombies all dead")
		end
	end
end

return WaveManager
