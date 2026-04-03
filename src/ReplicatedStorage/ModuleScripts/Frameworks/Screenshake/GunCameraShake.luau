local GunCameraShake = {}


-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


-- FOLDERS 
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local Client = ModuleScripts:WaitForChild("Client")


-- MODULES
local ClientGunData = require(Client:WaitForChild("ClientGunData"))
local ClientPlayerData = require(Client:WaitForChild("ClientPlayerData"))



-- CLIENT SCREENSHAKE FOR BULLET FIRING
function GunCameraShake.ScreenShake(Player)
	-- GET DATA
	local PlayerDataTable = ClientPlayerData:Get(Player)
	if not PlayerDataTable then return end
	local CameraSettings = PlayerDataTable.CameraSettings
	if not CameraSettings then return end
	local CurrentGunData = ClientGunData:Get(Player)
	if not CurrentGunData then return end

	local RecoilCamera = CurrentGunData.RecoilCamera
	if not RecoilCamera then return end
	

	-- TIME
	local TimeSinceShot = tick() - RecoilCamera.LastShotTime
	if TimeSinceShot > RecoilCamera.RecoveryTime then
		RecoilCamera.ConsecutiveShots = 0
		PlayerDataTable.CameraSettings.ShakeOffset = Vector3.zero
		RecoilCamera.CurrentIntensity -= RecoilCamera.RecoveryRate * TimeSinceShot
	end 


	-- UPDATE SHOTS AND TIME
	RecoilCamera.ConsecutiveShots += 1
	RecoilCamera.LastShotTime = tick()


	-- CAP CONSECUTIVE SHOTS
	if RecoilCamera.ConsecutiveShots > RecoilCamera.MaxConsecutiveShots then
		RecoilCamera.ConsecutiveShots = RecoilCamera.MaxConsecutiveShots
	end
	
	
	-- INCREASE INTENSITY BASED ON FACTORS
	local IntensityIncrease = RecoilCamera.BaseIntensity * (RecoilCamera.ConsecutiveShots * RecoilCamera.IntensityMultiplier)
	RecoilCamera.CurrentIntensity = math.min(RecoilCamera.BaseIntensity + IntensityIncrease, RecoilCamera.MaxIntensity)

	-- GET SHAKE OFFSETS
	local ShakeX = (math.random() - 0.5) * 2 * RecoilCamera.CurrentIntensity
	local ShakeY = (math.random() - 0.5)* 2 * RecoilCamera.CurrentIntensity
	local ShakeZ = (math.random() - 0.5) * 2 * RecoilCamera.CurrentIntensity
	local ShakeOffset = Vector3.new(ShakeX, 0, ShakeZ)


	-- UPDATE CAMERA SETTINGS
	PlayerDataTable.CameraSettings.ShakeOffset += ShakeOffset
end



return GunCameraShake