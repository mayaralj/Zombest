local GunMiscFW = {}


-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")


-- FOLDERS 
local Events = ReplicatedStorage:WaitForChild("Events")
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local PhaseParts = workspace:WaitForChild("PhaseParts")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")


-- EVENTS
local StartShooting = Events:WaitForChild("GunEvents"):WaitForChild("StartShooting")
local StopShooting = Events:WaitForChild("GunEvents"):WaitForChild("StopShooting")
local FireVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("FireVisualBullet")
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")
local GunCameraShakeEvent = Events:WaitForChild("GunEvents"):WaitForChild("GunCameraShakeEvent")


-- MODULES
local BulletFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletFW"))
local PlayerData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local BulletCleanupFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletCleanupFW"))



-- LIST TO EXCLUDE THINGS FROM RAYCAST
function GunMiscFW.GetListToExclude(LocalPlayer, ExcludeLocal, ExcludePlayers)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if not Character then return {} end

	local GunModel = Character:FindFirstChild("EquippedGun")
	local BulletEffects = workspace:WaitForChild("BulletsFolder"):WaitForChild("BulletEffects")
	local DeadCharacters = workspace:WaitForChild("DeadCharacters")
	local Excluded = {BulletEffects, DeadCharacters}

	if GunModel then
		table.insert(Excluded, GunModel)
	end

	if BulletEffects then
		table.insert(Excluded, BulletEffects)
	end

	if ExcludePlayers then
		for _, Player in ipairs(Players:GetPlayers()) do
			if Player ~= LocalPlayer and Player.Character then
				table.insert(Excluded, Player.Character)
			end
		end
	end

	if ExcludeLocal and LocalPlayer.Character then
		table.insert(Excluded, LocalPlayer.Character)
	end

	return Excluded
end



-- LIST TO EXCLUDE THINGS FROM RAYCAST
function GunMiscFW.GetListToInclude(LocalPlayer)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if not Character then return {} end
	
	local ServerZombies = workspace:WaitForChild("ServerZombies")
	local PhaseParts = workspace:WaitForChild("PhaseParts")
	local Included = {ServerZombies, PhaseParts}

	return Included
end




return GunMiscFW