local RoundStart = {}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EVENTS
local Events = ReplicatedStorage:WaitForChild("Events")
local RoundEvents = Events:WaitForChild("RoundEvents")
local UpdateTimerEvent = RoundEvents:WaitForChild("UpdateTimerEvent")

-- FUNCTION TO BEGIN TIMER
function RoundStart.StartTimer(Duration)
	local StartTime = workspace:GetServerTimeNow()
	local EndTime = StartTime + Duration
	UpdateTimerEvent:FireAllClients(EndTime)

	Players.PlayerAdded:Connect(function(PlayerJoined)
		UpdateTimerEvent:FireClient(PlayerJoined, EndTime)
	end)

	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		local CurrentTime = workspace:GetServerTimeNow()
		if CurrentTime >= EndTime then
			task.delay(3, function()
				UpdateTimerEvent:FireAllClients("0")
				Connection:Disconnect()
			end)
		end
	end)
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

return RoundStart
