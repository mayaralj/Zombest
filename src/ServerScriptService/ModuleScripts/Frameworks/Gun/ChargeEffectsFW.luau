local ChargeEffectsFW = {}


-- SERVICES
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")
local Events = ReplicatedStorage:WaitForChild("Events")
local BulletEvents = Events:WaitForChild("BulletEvents")


-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))
local ZombieData = require(Data:WaitForChild("ZombieData"))


-- EVENTS
local GunOverChargeEvent = Events:WaitForChild("GunEvents"):WaitForChild("GunOverCharge")



-- HANDLE EFFECTS ON BULLET HIT
function ChargeEffectsFW.OnCharge(Player, CurrentGunData, ChargeAmount)
	for EffectIndex, EffectData in pairs(CurrentGunData.ChargeEffect) do
		local EffectFunction = EffectData.Type
		if typeof(EffectFunction) == "function" then
			EffectFunction(Player, CurrentGunData, EffectIndex, ChargeAmount)
		end
	end
end



-- OVERCHARGE EFFECT
function ChargeEffectsFW.OverCharge(Player, CurrentGunData, EffectIndex, ChargeAmount)
	local EffectData = CurrentGunData.ChargeEffect[EffectIndex]
	if not EffectData then return end
	local SpeedBuff = EffectData.SpeedBuff
	if not SpeedBuff then return end
	local Character = Player.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then return end
	
	local PlayerData = PlayerData:Get(Player)
	if not PlayerData then return end
	
	local OverChargeBuffed = Player:GetAttribute("OverChargeBuffed")
	if OverChargeBuffed then return end
	
	
	-- GIVE BUFFS
	if ChargeAmount >= 99 then
		Player:SetAttribute("OverChargeBuffed", true)
		task.wait(0.25) -- tiny wait to ensure the lightning effect is done
		GunOverChargeEvent:FireAllClients(Player, EffectData.Duration)
		PlayerData.Sprint.WalkSpeed += SpeedBuff
		PlayerData.Sprint.SprintSpeed += SpeedBuff
		task.delay(EffectData.Duration, function()
			Player:SetAttribute("OverChargeBuffed", false)
			PlayerData.Sprint.WalkSpeed -= SpeedBuff
			PlayerData.Sprint.SprintSpeed -= SpeedBuff
		end)
	end
end



return ChargeEffectsFW