local BulletCleanupFW = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")

-- EVENTS
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")

-- MODULES
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))

-- HELPER TO ADD BULLET TO ARRAYS
function BulletCleanupFW.AddBulletToArrays(BulletData)
	local NewIndex = #GunData.BulletData + 1
	GunData.BulletIndex[BulletData.BulletID] = NewIndex
	GunData.BulletData[NewIndex] = BulletData
end

-- HELPER TO REMOVE BULLET FROM ARRAYS VIA SWAP
function BulletCleanupFW.RemoveBulletFromArrays(BulletID)
	local BulletIndex = GunData.BulletIndex[BulletID]
	if not BulletIndex then
		return
	end

	local BulletData = GunData.BulletData[BulletIndex]
	if not BulletData then
		return
	end

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
	if BulletData.BulletType == "Stream" then
		return
	end

	-- FIRE TO CLIENT TO DELETE RIGHT AWAY
	DeleteVisualBullet:FireAllClients(BulletData.BulletID)
end

return BulletCleanupFW
