local MapSpawn = {}

-- SERVICES
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

-- FOLDERS
local MapFolder = ServerStorage:FindFirstChild("Maps")

-- FUNCTION TO SPAWN A RANDOM MAP
function MapSpawn.SpawnMap()
	while true do
		local Success, Result = pcall(function()
			local Maps = MapFolder:GetChildren()
			local MapTemplate = Maps[math.random(1, #Maps)]:Clone()

			return MapTemplate
		end)

		if Success then
			local ClonedMap = Result
			ClonedMap.Parent = workspace

			if ClonedMap.PrimaryPart then
				ClonedMap:SetPrimaryPartCFrame(CFrame.new(0, 1000, 0))
			end

			return ClonedMap
		else
			local ErrorMessage = Result
			warn("Failed to spawn map:", ErrorMessage)
			task.wait(0.2)
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
function MapSpawn.TeleportPlayersToMap(Map)
	local SpawnsFolder = Map:WaitForChild("Spawns")
	local Spawns = SpawnsFolder:GetChildren()

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

return MapSpawn
