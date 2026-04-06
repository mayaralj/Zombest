-- SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local Misc = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Misc")

-- MODULES
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))
local ZombieSpawnerFW = require(Frameworks:WaitForChild("Zombie"):WaitForChild("ZombieSpawnerFW"))
local RoundStart = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("RoundStart"))
local GunFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunFW"))
local Utilities = require(Misc:WaitForChild("Utilities"))

-- KEEP SHUFFLING THE GIVE GUN PARTS AROUND MAP
task.spawn(function()
	local GiveGunParts = workspace:WaitForChild("GiveGunParts")
	if not GiveGunParts then
		return
	end
	local AvailableCFrames = {}
	for _, Part in GiveGunParts:GetChildren() do
		if Part:IsA("BasePart") and Part.Name ~= "LightningFist" then
			table.insert(AvailableCFrames, Part.CFrame)
		end
	end

	local LightningFist = GiveGunParts:FindFirstChild("LightningFist")
	for _, Part in GiveGunParts:GetDescendants() do
		-- Skip anything that IS or is INSIDE LightningFist
		if LightningFist and (Part == LightningFist or Part:IsDescendantOf(LightningFist)) then
			continue
		end
		if Part:IsA("BasePart") or Part:IsA("MeshPart") then
			Part.Anchored = false
		end
	end

	local CFrameOccupied = {}
	for _, Part in GiveGunParts:GetChildren() do
		if Part:IsA("BasePart") and Part.Name ~= "LightningFist" then
			Part.Anchored = true
			local Model = Part:FindFirstChildWhichIsA("Model")
			if Model then
				for _, Child in Model:GetDescendants() do
					if Child:IsA("BasePart") then
						Child.Anchored = false

						-- WELD ALL TOGETHER
						local Weld = Instance.new("WeldConstraint")
						Weld.Part0 = Part
						Weld.Part1 = Child
						Weld.Parent = Part
					end
				end
			end
		end
	end
	while true do
		-- SHUFFLED LIST
		local ShuffledIndices = {}
		for i = 1, #AvailableCFrames do
			table.insert(ShuffledIndices, i)
		end

		-- SHUFFLE
		for i = #ShuffledIndices, 2, -1 do
			local j = math.random(i)
			ShuffledIndices[i], ShuffledIndices[j] = ShuffledIndices[j], ShuffledIndices[i]
		end

		-- ASSIGN EACH PART TO A UNIQUE CFRAME
		local Index = 1
		for _, Part in GiveGunParts:GetChildren() do
			if Part:IsA("BasePart") and Part.Name ~= "LightningFist" then
				Part.CFrame = AvailableCFrames[ShuffledIndices[Index]]
				Index = Index + 1
			end
		end

		task.wait(15)
	end
end)

--- TEST TEST TESTTTTTTTTTTTTTTT ---
-- HELPER
--local Connections = {}
-- local function GivePistolToPlayer(Character)
-- 	local Player = Players:GetPlayerFromCharacter(Character)
-- 	if not Player then
-- 		return
-- 	end
-- 	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
-- 	if not Humanoid then
-- 		return
-- 	end

-- 	-- GIVE GUN DONT ALLOW IF ALREADY HAS GUN AND ADD A DELAY
-- 	task.delay(1, function()
-- 		if not Player or not Character then
-- 			return
-- 		end
-- 		local CurrentPlayerData = PlayerData:Get(Player)
-- 		if not CurrentPlayerData then
-- 			return
-- 		end
-- 		Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))

-- 		GunFW.GiveWeapon(Player, "Pistol", true)
-- 		--task.wait(2)
-- 		--GunFW.GiveWeapon(Player, "Pistol", true)
-- 	end)

-- 	task.delay(5, function()
-- 		if not Player or not Player.Parent or not Character then
-- 			return
-- 		end
-- 		Player.Team = Teams:FindFirstChild("InRound")
-- 	end)

-- 	if Connections[Player] then
-- 		Connections[Player]:Disconnect()
-- 		Connections[Player] = nil
-- 	end

-- 	Connections[Player] = Humanoid.Died:Connect(function()
-- 		local CurrentPlayerData = PlayerData:Get(Player)
-- 		if not CurrentPlayerData then
-- 			return
-- 		end

-- 		-- RESET TEAM
-- 		Player.Team = Teams:FindFirstChild("Lobby")

-- 		-- LOWER POINTS IF DEAD
-- 		CurrentPlayerData.Points.CurrentPoints = CurrentPlayerData.Points.CurrentPoints * 0.75

-- 		-- UPDATE ATTRIBUTE
-- 		Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))

-- 		if Connections[Player] then
-- 			Connections[Player]:Disconnect()
-- 		end
-- 	end)
-- end
-- -- GIVE PISTOL TO PLAYERS ON EACH RESPAWN
-- Utilities.BindToCharacter(GivePistolToPlayer)

-- CURRENT MAP
while #Players:GetPlayers() == 0 do
	task.wait(1)
end
RoundStart.StartTimer(15)
task.wait(3)
RoundStart.TeleportPlayersToMap()
RoundStart.SetPlayersTeams()
ZombieSpawnerFW.SpawnZombies(1000000)
