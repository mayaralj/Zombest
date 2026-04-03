local BulletCleanupFW = {}



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
local PlayerData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))
local ClientGunData = require(Client:WaitForChild("ClientGunData"))




-- HELPER TO ADD BULLET TO ARRAYS
function BulletCleanupFW.AddBulletToArrays(BulletData)
	local NewIndex = #GunData.BulletData + 1
	GunData.BulletIndex[BulletData.BulletID] = NewIndex
	GunData.BulletData[NewIndex] = BulletData
end



-- HELPER TO REMOVE BULLET FROM ARRAYS VIA SWAP
function BulletCleanupFW.RemoveBulletFromArrays(BulletID)
	local BulletIndex = GunData.BulletIndex[BulletID]
	if not BulletIndex then return end
	
	local BulletData = GunData.BulletData[BulletIndex]
	if not BulletData then return end
	
	local LastIndex = #GunData.BulletData
	
	if BulletIndex == LastIndex then
		GunData.BulletData[LastIndex] = nil
		GunData.BulletIndex[BulletID] = nil
		return
	end
	
	local LastBulletData = GunData.BulletData[LastIndex]
	GunData.BulletData[BulletIndex] = GunData.BulletData[LastIndex]	
	GunData.BulletIndex[LastBulletData.BulletID] = BulletIndex
	
	GunData.BulletData[LastIndex] = nil
	GunData.BulletIndex[BulletID] = nil
end



-- BATCH CLEANUP SYSTEM
function BulletCleanupFW.ScheduleBulletCleanup(BulletData)
	-- SKIP STREAM BULLETS
	if BulletData.BulletType == "Stream" then return end
	
	-- FIRE TO CLIENT TO DELETE RIGHT AWAY
	DeleteVisualBullet:FireAllClients(BulletData.BulletID)
end



return BulletCleanupFW