-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

-- MODULE CLIENT ZOMBIE TABLE
local ClientZombieData = {}

-- DEFAULT CLIENTZOMBIE DATA TEMPLATE
ClientZombieData.DefaultData = {
	Regular = {
		Normal = {
			ModelStuff = {
				Model = nil,
				HRP = nil,
				ID = nil,
				ServerZombie = nil,
			},

			Position = {
				TargetCF = nil,
			},

			Ragdoll = {
				DeadByWeapon = nil,
				DirectionDead = nil,
			},

			Timer = {
				TimeSinceMoved = 0,
				EffectTimer = 0,
			},

			Flags = {
				PreviouslyMoved = nil,
			},

			SFX = {
				SFXCooldown = nil,
				IsPlaying = false,
			},

			Status = {
				Burn = {
					BurnTime = 0,
					TickTime = 0,
					BurnDamage = 0,
					BurnVFX = nil,
					Outline = nil,
					SFX = nil,
				},

				Stun = {
					StunTime = 0,
				},
			},

			Animations = {
				AnimationController = nil,
				CurrentZombieAnimation = nil,
				WalkAnimation = "rbxassetid://101869943420204",
			},
		},
	},

	Boss = {},
}

-- ALL CLIENT ZOMBIES
ClientZombieData.ClientZombieDataTable = {}
ClientZombieData.ZombieIndex = {}
ClientZombieData.ZombieArray = {}
ClientZombieData.GetZombieByID = {}

-- CREATE CLIENT DATA FOR ZOMBIE
function ClientZombieData:CreateData(Zombie, ZombieType, ZombieSubType)
	ZombieType = ZombieType or "Regular"
	ZombieSubType = ZombieSubType or "Normal"

	local SpecificData = self.DefaultData[ZombieType][ZombieSubType]
	if not SpecificData then
		warn("Invalid ZombieType or ZombieSubType:", ZombieType, ZombieSubType)
		return nil
	end

	local DataCopy = TableClone.DeepClone(SpecificData)
	self.ClientZombieDataTable[Zombie] = DataCopy

	return DataCopy
end

-- GET CLIENT ZOMBIE DATA
function ClientZombieData:Get(Zombie)
	return self.ClientZombieDataTable[Zombie]
end

-- REMOVE CLIENT ZOMBIE DATA
function ClientZombieData:Remove(Zombie)
	self.ClientZombieDataTable[Zombie] = nil
end

return ClientZombieData
