local ChargeEffectsFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")
local Events = ReplicatedStorage:WaitForChild("Events")

-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))

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
	if not EffectData then
		return
	end
	local SpeedBuff = EffectData.SpeedBuff
	if not SpeedBuff then
		return
	end
	local Character = Player.Character
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		return
	end

	local OverChargeBuffed = Player:GetAttribute("OverChargeBuffed")
	if OverChargeBuffed then
		return
	end

	-- GIVE BUFFS
	if ChargeAmount >= 99 then
		Player:SetAttribute("OverChargeBuffed", true)
		task.wait(0.25) -- tiny wait to ensure the lightning effect is done
		GunOverChargeEvent:FireAllClients(Player, EffectData.Duration)
		CurrentPlayerData.Sprint.WalkSpeed += SpeedBuff
		CurrentPlayerData.Sprint.SprintSpeed += SpeedBuff
		task.delay(EffectData.Duration, function()
			Player:SetAttribute("OverChargeBuffed", false)
			CurrentPlayerData.Sprint.WalkSpeed -= SpeedBuff
			CurrentPlayerData.Sprint.SprintSpeed -= SpeedBuff
		end)
	end
end

return ChargeEffectsFW
