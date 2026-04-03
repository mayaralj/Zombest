local GunRecoilFW = {}

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
local PlayerData =
	require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData =
	require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local BulletCleanupFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletCleanupFW"))
local GunMiscFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunMiscFW"))
local BulletProcessFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletProcessFW"))
local FireToProcessFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("FireToProcessFW"))

-- RECOIL BULLET SPREAD
function GunRecoilFW.GetRecoilSpread(Player, CurrentGunData, Direction)
	local RecoilSpreadData = CurrentGunData.RecoilSpread
	if not RecoilSpreadData then
		return Direction
	end

	local TimeSinceLastShot = tick() - RecoilSpreadData.LastShotTime
	-- DECAY THE SPREAD IF ENOUGH TIME PASSED
	if TimeSinceLastShot > RecoilSpreadData.RecoveryTime then
		-- RESET/DECAY SPREAD
		RecoilSpreadData.ConsecutiveShots = 0
		RecoilSpreadData.CurrentSpread =
			math.max(0, RecoilSpreadData.CurrentSpread - (RecoilSpreadData.RecoveryRate * TimeSinceLastShot))
	end

	-- TRACK SHOTS AND TIME
	RecoilSpreadData.ConsecutiveShots += 1
	RecoilSpreadData.LastShotTime = tick()

	-- CALCULATE NEW SPREAD
	local SpreadMultipliier = math.min(
		RecoilSpreadData.ConsecutiveShots * RecoilSpreadData.SpreadIncrease,
		RecoilSpreadData.MaxSpread - RecoilSpreadData.BaseSpread
	)
	RecoilSpreadData.CurrentSpread = RecoilSpreadData.BaseSpread + SpreadMultipliier

	-- GET SPREAD OFF SET
	local SpreadX = (math.random() - 0.5) * 2 * RecoilSpreadData.CurrentSpread
	local SpreadZ = (math.random() - 0.5) * 2 * RecoilSpreadData.CurrentSpread

	-- APPLY SPREAD OFFSET
	local SpreadDirection = Vector3.new(Direction.X + SpreadX, Direction.Y, Direction.Z + SpreadZ)

	-- SET CONSECUTIVE SHOT ATTRIBUTE
	Player:SetAttribute("ConsecutiveShots", RecoilSpreadData.ConsecutiveShots)
	-- RETURN NEW DIRECTION WITH OFFSET
	return SpreadDirection.Unit
end

return GunRecoilFW
