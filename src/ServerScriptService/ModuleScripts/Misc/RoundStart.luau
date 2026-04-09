local RoundStart = {}

-- SERVICES
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EVENTS
local Events = ReplicatedStorage:WaitForChild("Events")
local RoundEvents = Events:WaitForChild("RoundEvents")
local UpdateTimerEvent = RoundEvents:WaitForChild("UpdateTimerEvent")
local WaveEvents = Events:WaitForChild("WaveEvents")
local RoundResult = WaveEvents:WaitForChild("RoundResult")

-- FUNCTION TO BEGIN TIMER
local TimerConnection
local PlayerAddedConn
function RoundStart.StartTimer(Duration)
	local StartTime = workspace:GetServerTimeNow()
	local EndTime = StartTime + Duration
	UpdateTimerEvent:FireAllClients(EndTime)

	if TimerConnection then
		TimerConnection:Disconnect()
	end
	if PlayerAddedConn then
		PlayerAddedConn:Disconnect()
	end

	PlayerAddedConn = Players.PlayerAdded:Connect(function(PlayerJoined)
		UpdateTimerEvent:FireClient(PlayerJoined, EndTime)
	end)

	TimerConnection = RunService.Heartbeat:Connect(function()
		local CurrentTime = workspace:GetServerTimeNow()
		if CurrentTime >= EndTime then
			TimerConnection:Disconnect()
			TimerConnection = nil
			PlayerAddedConn:Disconnect()
			PlayerAddedConn = nil
		end
	end)

	-- YIELD TILL TIMER ENDS
	while TimerConnection and PlayerAddedConn do
		task.wait(0.1)
	end
end

-- FUNCTION TO SET PLAYERS TEAMS
local InRound = Teams:FindFirstChild("InRound")
local Lobby = Teams:FindFirstChild("Lobby")
RoundStart.InRoundLookup = {}
RoundStart.InRoundCounter = 0

-- SAME CHECKS FOR PLAYER REMOVING TO HANDLE DC
Players.PlayerRemoving:Once(function(RemovingPlayer)
	if RoundStart.InRoundLookup[RemovingPlayer] then
		RoundStart.InRoundCounter -= 1
		RoundStart.InRoundLookup[RemovingPlayer] = nil
	end
	if RemovingPlayer and RemovingPlayer.Parent and RemovingPlayer.Team ~= Lobby then
		RemovingPlayer.Team = Lobby
	end
	if RoundStart.InRoundCounter <= 0 then
		RoundResult:Fire(false)
	end
end)
function RoundStart.SetPlayersTeams()
	-- LOOP THROUGH PLAYERS AND SET TEAMS
	for _, Player in pairs(Players:GetPlayers()) do
		if Player.Team ~= Lobby then
			continue
		end
		Player.Team = InRound
		RoundStart.InRoundLookup[Player] = true
		RoundStart.InRoundCounter += 1
		local Character = Player.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		-- UPDATE LOOKUP TABLE WHEN PLAYER DIES, IF NO PLAYERS LEFT IN ROUND, FIRE ROUND RESULT
		if Humanoid then
			Humanoid.Died:Once(function()
				if RoundStart.InRoundLookup[Player] then
					RoundStart.InRoundCounter -= 1
					RoundStart.InRoundLookup[Player] = nil
				end
				Player.Team = Lobby
				if RoundStart.InRoundCounter <= 0 then
					RoundResult:Fire(false)
				end
			end)
		end
	end
end

-- FUNCTION TO SHUFFLE AN ARRAY, USED TO RANDOMIZE SPAWN POINTS
local function ShuffleArray(Array)
	for i = #Array, 2, -1 do
		local j = math.random(1, i)
		Array[i], Array[j] = Array[j], Array[i]
	end
end

-- FUNCTION TO DETERMINE IF A PLAYER IS STANDING ON THE GROUND
local function IsStandingOnGround(Character)
	if not Character then
		return false
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
		return true
	end

	return false
end

-- TELEPORT ALL PLAYERS TO MAP SPAWNS
function RoundStart.TeleportPlayersToMap()
	local Spawns = workspace:WaitForChild("SpawnLocations"):GetChildren()
	ShuffleArray(Spawns)

	for i, Player in pairs(Players:GetPlayers()) do
		-- CHECK IF PLAYER PART OF LOBBY TEAM, IF NOT, SKIP
		if Player.Team ~= Teams:FindFirstChild("Lobby") then
			continue
		end
		local SpawnPart = Spawns[i]
		local Success = false

		for Attempt = 1, 10 do
			local Character = Player.Character
			if Character and SpawnPart and Character.PrimaryPart then
				Player.Character:SetPrimaryPartCFrame(SpawnPart.CFrame * CFrame.new(0, 3, 0))
				task.wait(0.1 + (Attempt * 0.02))
				if IsStandingOnGround(Character) then
					Success = true
					break
				end
			else
				task.wait(0.1)
			end
		end

		if not Success then
			warn("Failed to teleport player:", Player.Name, "after 10 attempts.")
		end
	end
end

-- TELEPORT ALL PLAYERS TO LOBBY
function RoundStart.TeleportPlayersToLobby()
	local LobbySpawns = workspace:WaitForChild("Lobby"):WaitForChild("Spawns"):GetChildren()
	ShuffleArray(LobbySpawns)
	for i, Player in pairs(Players:GetPlayers()) do
		local SpawnPart = LobbySpawns[i]
		local Success = false
		for Attempt = 1, 10 do
			local Character = Player.Character
			if Character and SpawnPart and Character.PrimaryPart then
				Player.Character:SetPrimaryPartCFrame(SpawnPart.CFrame * CFrame.new(0, 3, 0))
				task.wait(0.1 + (Attempt * 0.02))
				if IsStandingOnGround(Character) then
					Success = true
					break
				end
			else
				task.wait(0.1)
			end
		end
		if not Success then
			warn("Failed to teleport player Back to lobby:", Player.Name, "after 10 attempts.")
		end
	end
end

return RoundStart
