local ZombieEffectFW = {}


-- SERVICES
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local BulletEvents = Events:WaitForChild("BulletEvents")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")


-- MODULES
local PlayerData = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))


-- EVENTS
local BurnEffect = BulletEvents:WaitForChild("BurnEffect")




-- SERVER SIDE BURN EFFECT
function ZombieEffectFW.ZombieBurn(Data, ZombiePart, DT)
	-- GET BURN DATA
	local BurnData = Data.Status.Burn
	if not BurnData then return end
	
	-- GET CURRENT PLAYER DATA
	local Player = BurnData.Player
	local CurrentPlayerData
	if Player then
		CurrentPlayerData = PlayerData:Get(Player)
	end
	
	
	-- END IF ZOMBIE DIED
	if Data.Health.CurrentHealth <= 0  then
		BurnData.BurnDamage = 0
		BurnData.TickTime = 0
		BurnData.BurnTime = 0
		return
	end
	

	-- END BURN IF TIME IS OVER
	if BurnData.BurnTime < 0 then
		BurnData.BurnDamage = 0
		BurnData.TickTime = 0
		BurnData.BurnTime = 0
		return
	end

	
	BurnData.BurnTime -= DT
	BurnData.TickTime += DT
	if BurnData.TickTime >= 0.8 then
		BurnData.TickTime = 0
		Data.Health.CurrentHealth -= BurnData.BurnDamage
		
		-- UPDATE CURRENT PLAYER POINTS
		if CurrentPlayerData then
			-- RANDOMIZED AMOUNT OF POINTS
			CurrentPlayerData.Points.CurrentPoints += math.random(
				1, 2
			)			
			-- EXTRA ON ZOMBIE KILL
			if Data.Health.CurrentHealth <= 0 then
				CurrentPlayerData.Points.CurrentPoints += math.random(40,60)
			end
			Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
		end
	end
end



-- RETURN
return ZombieEffectFW