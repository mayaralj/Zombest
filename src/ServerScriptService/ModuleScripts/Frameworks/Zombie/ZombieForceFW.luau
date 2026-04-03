local ZombieForceFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Data = ModuleScripts:WaitForChild("Data")

-- MODULES
local ZombieData = require(Data:WaitForChild("ZombieData"))

-- TABLES
local ForcedMovementTask = {}

-- FUNCTION TO APPLY A FORCE TO CLIENT ZOMBIE VIA SERVER ZOMBIE
function ZombieForceFW.ApplyBodyForceToZombie(ZombiePart, BodyForce, BulletDirection)
	-- STRENGTH BASED ON FIRE RATE
	local Offset = BulletDirection * BodyForce

	-- PIVOT SERVER ZOMBIE (CLIENT WILL FOLLOW)
	ZombiePart:PivotTo(ZombiePart:GetPivot() + Offset)
end

return ZombieForceFW
