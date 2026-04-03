local DetermineAssets = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- FOLDERS
local PerGunAssets = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("PerGunAssets")


-- ASSET MODULES
local LightningAssets = require(PerGunAssets:WaitForChild("LightningAssets"))
local PistolAssets = require(PerGunAssets:WaitForChild("PistolAssets"))
local SilencerAssets = require(PerGunAssets:WaitForChild("SilencerAssets"))
local DeagleAssets = require(PerGunAssets:WaitForChild("DeagleAssets"))
local UziAssets = require(PerGunAssets:WaitForChild("UziAssets"))
local TommyGunAssets = require(PerGunAssets:WaitForChild("TommyGunAssets"))
local AK47Assets = require(PerGunAssets:WaitForChild("AK47Assets"))
local ARAssets = require(PerGunAssets:WaitForChild("ARAssets"))
local SuppressedARAssets = require(PerGunAssets:WaitForChild("SuppressedARAssets"))
local BurstARAssets = require(PerGunAssets:WaitForChild("BurstARAssets"))
local MinigunAssets = require(PerGunAssets:WaitForChild("MinigunAssets"))
local PumpShotgunAssets = require(PerGunAssets:WaitForChild("PumpShotgunAssets"))
local TacticalShotgunAssets = require(PerGunAssets:WaitForChild("TacticalShotgunAssets"))
local PhaseSniperAssets = require(PerGunAssets:WaitForChild("PhaseSniperAssets"))
local RicochetSniperAssets = require(PerGunAssets:WaitForChild("RicochetSniperAssets"))
local SemiPistolAssets = require(PerGunAssets:WaitForChild("SemiPistolAssets"))
local RifleAssets = require(PerGunAssets:WaitForChild("RifleAssets"))
local RayGunAssets = require(PerGunAssets:WaitForChild("RayGunAssets"))
local ScorchriftAssets = require(PerGunAssets:WaitForChild("ScorchriftAssets"))
local AA12Assets = require(PerGunAssets:WaitForChild("AA12Assets"))



-- DETERMINE WHICH ASSETS TO USE 
function DetermineAssets.DetermineAssets(EquippedGun)
	if EquippedGun == "LightningFist" then
		return LightningAssets
	elseif EquippedGun == "Pistol" then
		return PistolAssets
	elseif EquippedGun == "Silencer" then
		return SilencerAssets
	elseif EquippedGun == "Deagle" then
		return DeagleAssets
	elseif EquippedGun == "Uzi" then
		return UziAssets
	elseif EquippedGun == "TommyGun" then
		return TommyGunAssets
	elseif EquippedGun == "AK47" then
		return AK47Assets
	elseif EquippedGun == "AR" then
		return ARAssets
	elseif EquippedGun == "SuppressedAR" then
		return SuppressedARAssets
	elseif EquippedGun == "BurstAR" then
		return BurstARAssets
	elseif EquippedGun == "Minigun" then
		return MinigunAssets
	elseif EquippedGun == "PumpShotgun" then
		return PumpShotgunAssets
	elseif EquippedGun == "TacticalShotgun" then
		return TacticalShotgunAssets
	elseif EquippedGun == "PhaseSniper" then
		return PhaseSniperAssets
	elseif EquippedGun == "RicochetSniper" then
		return RicochetSniperAssets
	elseif EquippedGun == "SemiPistol" then
		return SemiPistolAssets
	elseif EquippedGun == "Rifle" then
		return RifleAssets
	elseif EquippedGun == "RayGun" then
		return RayGunAssets
	elseif EquippedGun == "Scorchrift" then
		return ScorchriftAssets
	elseif EquippedGun == "AA12" then
		return AA12Assets
	else
		warn("Where the assets at")
		return 
	end
end



-- RETURN ASSETS
return DetermineAssets