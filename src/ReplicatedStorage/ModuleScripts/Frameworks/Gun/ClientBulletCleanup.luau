local ClientBulletCleanup = {}


-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Debris = game:GetService("Debris")


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Client = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")


-- EVENTS
local FireVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("FireVisualBullet")
local DeleteVisualBullet = Events:WaitForChild("GunEvents"):WaitForChild("DeleteVisualBullet")


-- MODULES
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local ObjectPoolFW = require(Frameworks:WaitForChild("ObjectPool"):WaitForChild("ObjectPoolFW"))



-- HELPER TO ADD BULLET TO ARRAYS
function ClientBulletCleanup.AddBulletToArrays(BulletData)
	local NewIndex = #ClientGunData.ClientBulletData + 1
	ClientGunData.ClientBulletIndex[BulletData.BulletID] = NewIndex
	ClientGunData.ClientBulletData[NewIndex] = BulletData
end



-- HELPER TO REMOVE BULLET FROM ARRAYS VIA SWAP
function ClientBulletCleanup.RemoveBulletFromArrays(BulletID)
	local BulletIndex = ClientGunData.ClientBulletIndex[BulletID]
	if not BulletIndex then return end

	local BulletData = ClientGunData.ClientBulletData[BulletIndex]
	if not BulletData then return end

	local LastIndex = #ClientGunData.ClientBulletData
	if BulletIndex == LastIndex then
		ClientGunData.ClientBulletData[LastIndex] = nil
		ClientGunData.ClientBulletIndex[BulletID] = nil
		return
	end

	local LastBulletData = ClientGunData.ClientBulletData[LastIndex]

	ClientGunData.ClientBulletData[BulletIndex] = ClientGunData.ClientBulletData[LastIndex]	
	ClientGunData.ClientBulletIndex[LastBulletData.BulletID] = BulletIndex

	ClientGunData.ClientBulletData[LastIndex] = nil
	ClientGunData.ClientBulletIndex[BulletID] = nil
end



-- ORGANIZED REMOVEBULLET FUNCTION
function ClientBulletCleanup.RemoveBullet(BulletID)
	-- BULLET DATA
	local BulletIndex = ClientGunData.ClientBulletIndex[BulletID]
	if not BulletIndex then return end
	local BulletData = ClientGunData.ClientBulletData[BulletIndex]
	if not BulletData then return end
	
	-- REMOVE FROM ARRAYS
	ClientBulletCleanup.RemoveBulletFromArrays(BulletID)
	
	-- DELETE BULLET
	if BulletData.BulletClone then
		-- MAKE TRANSPARENT INSTEAD OF DELETING RIGHT AWAY FOR VFX PURPOSES
		BulletData.BulletClone.Transparency = 1
		
		for _, Descendant in pairs(BulletData.BulletClone:GetDescendants()) do
			if Descendant:IsA("BasePart") then
				Descendant.Transparency = 1
			end
			if Descendant:IsA("ParticleEmitter")  then
				Descendant.Enabled = false
			end
			if Descendant:IsA("Trail") then
				Descendant.Lifetime = 0.5
				Descendant.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5), 
					NumberSequenceKeypoint.new(1, 1) 
				})
				Descendant.Enabled = false
			end
		end
	end
	
	
	-- RETURN TO POOL
	task.wait(2)
	ObjectPoolFW.Return(BulletData.BulletClone)
end



return ClientBulletCleanup