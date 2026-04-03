-- SERVICES
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local BulletEvents = Events:WaitForChild("BulletEvents")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))
local ClientZombieData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientZombieData"))
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))
local ScreenShake =
	require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Screenshake"):WaitForChild("ScreenShake"))

-- EVENTS
local GunOverChargeEvent = Events:WaitForChild("GunEvents"):WaitForChild("GunOverCharge")

-- WHEN OVERCHARGE HAPPENS
GunOverChargeEvent.OnClientEvent:Connect(function(PlayerCharged, Duration)
	-- DATA
	local CurrentGunData = ClientGunData:Get(PlayerCharged)
	if not CurrentGunData then
		return
	end

	-- VFX FOLDER
	local GunVFX = ReplicatedStorage:WaitForChild("GunVFX")

	-- LIGHTNING IMPACT SFX
	local LightningImpactSFX = ReplicatedStorage:FindFirstChild("GunSFX")
		:FindFirstChild("LightningFist")
		:FindFirstChild("LightningImpactSFX")
		:Clone()
	LightningImpactSFX.Parent = PlayerCharged.Character:WaitForChild("HumanoidRootPart")
	LightningImpactSFX:Play()
	LightningImpactSFX.Volume = 1
	Debris:AddItem(LightningImpactSFX, Duration)

	-- LIGHTNING IMPACT VFX
	local LightningImpactVFXClone =
		GunVFX:WaitForChild("Lightning"):WaitForChild(CurrentGunData.VFX.LightningImpactVFX):Clone()
	LightningImpactVFXClone.Parent = PlayerCharged.Character:WaitForChild("HumanoidRootPart")
	for _, VFX in pairs(LightningImpactVFXClone:GetDescendants()) do
		VFX.Parent = PlayerCharged.Character:WaitForChild("HumanoidRootPart")
		if VFX:IsA("ParticleEmitter") then
			VFX:Emit(10)
			VFX.Enabled = false
			VFX.LockedToPart = false
		end
	end
	Debris:AddItem(LightningImpactVFXClone, Duration)
	ScreenShake.ApplyScreenShake(false, Player, PlayerCharged, 0.5, 75, 10)

	-- AURA VFX
	local OverChargeVFXClone =
		GunVFX:FindFirstChild("Lightning"):FindFirstChild(CurrentGunData.VFX.OverChargeVFX):Clone()
	OverChargeVFXClone.Parent = PlayerCharged.Character:WaitForChild("HumanoidRootPart")
	for _, VFX in pairs(OverChargeVFXClone:GetDescendants()) do
		if VFX:IsA("ParticleEmitter") then
			VFX.Enabled = true
			VFX.LockedToPart = true
		end
	end
	Debris:AddItem(OverChargeVFXClone, Duration)

	-- AURA SFX
	local OverChargeSFX = ReplicatedStorage:FindFirstChild("GunSFX")
		:FindFirstChild("LightningFist")
		:FindFirstChild("OverChargeSFX")
		:Clone()
	OverChargeSFX.Parent = PlayerCharged.Character:WaitForChild("HumanoidRootPart")
	OverChargeSFX:Play()
	OverChargeSFX.Volume = 0.8
	OverChargeSFX.PlaybackRegionsEnabled = true
	OverChargeSFX.PlaybackRegion = NumberRange.new(0, 10)
	OverChargeSFX.Looped = true
	Debris:AddItem(OverChargeSFX, Duration)
end)
