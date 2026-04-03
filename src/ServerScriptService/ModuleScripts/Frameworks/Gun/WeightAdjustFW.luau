local WeightAdjustFW = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- FOLDERS
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")

-- MODULES
local BulletFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletFW"))
local PlayerData =
	require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))
local GunData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("GunData"))
local ZombieData =
	require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("ZombieData"))

-- ADJUST MOVE WEIGHT IF SHOOTING OR NOT
function WeightAdjustFW.MoveWeightAdjust(Player, CurrentGunData)
	if
		not Player:GetAttribute("IsReloading")
		and not Player:GetAttribute("IsCharging")
		and not Player:GetAttribute("VisuallyCharging")
	then
		if Player:GetAttribute("IsShooting") then
			CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ShootMoveWeight
		else
			if Player:GetAttribute("IsSprinting") then
				CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RunMoveWeight
			else
				CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.WalkMoveWeight
			end
		end
	end
end

return WeightAdjustFW
