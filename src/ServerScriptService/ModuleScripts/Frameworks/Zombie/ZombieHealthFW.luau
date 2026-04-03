local ZombieHealthFW = {}


-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")


-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Data = ModuleScripts:WaitForChild("Data")


-- MODULES
local ZombieData = require(Data:WaitForChild("ZombieData"))



-- CHANGE ZOMBIE SPEED BASED ON ZOMBIE HP
function ZombieHealthFW.ChangeSpeed(ZombiePart)
	--local CurrentZombieData = ZombieData.ZombieDataTable[ZombiePart]
	--if not CurrentZombieData then return end
	
	--local Health = CurrentZombieData.Health.CurrentHealth
	--local MaxHealth = CurrentZombieData.Health.MaxHealth

	--if Health <= math.round(MaxHealth/3) then
	--	CurrentZombieData.Stats.WalkSpeed = math.round(CurrentZombieData.Stats.MaxSpeed/1.5)
	--elseif Health <= math.round(MaxHealth / 2) then
	--	CurrentZombieData.Stats.WalkSpeed = math.round(CurrentZombieData.Stats.MaxSpeed/1.25)
	--end
end



return ZombieHealthFW