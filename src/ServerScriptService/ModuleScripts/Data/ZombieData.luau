-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

local ZombieData = {}

-- DEFAULT DATA TEMPLATE
ZombieData.DefaultData = {
	Normal = {
		About = {
			ZombiePart = nil,
			ID = nil,
		},

		Stats = {
			WalkSpeed = 16.5,
			MaxSpeed = 16.5,
		},

		Collision = {
			CanCollideOthers = true,
		},

		Health = {
			LastHealth = 60,
			CurrentHealth = 60,
			MaxHealth = 60,
		},

		Status = {
			Burn = {
				BurnTime = 0,
				TickTime = 0,
				BurnDamage = 0,
			},

			Stun = {
				CurrentStun = 0,
				MaxStun = 10,
			},
		},

		Replication = {
			ReplicatedToAll = false,
			ReplicatedTask = nil,
			SpawnTime = nil,
		},

		Cooldowns = {
			ZombieAttackCooldown = nil,
			NoObstacleTimer = 0,
			GroundRaycastCD = 0,
			SendToClientCD = 0,
		},

		Damage = {
			DamagePerHit = 25,
		},

		Frame = {
			FrameSkip = 0,
		},

		Position = {
			LastZomPos = nil,
			TimeSinceMoved = 0,
			GroundPos = 0,
		},

		Path = {
			CurrentWaypointIndex = 2,
			CurrentPath = nil,
			PathGenerationCD = 0,
			FirstPathGenerated = false,
			IsWalkingOnPath = false,
		},

		Target = {
			LastTarget = nil,
			LastTargetDiedConn = nil,
			LastTargetPosition = nil,
			ClosestDistance = nil,
		},

		Grid = {
			NearbyPartsCD = 0,
			NearbyParts = nil,
			ObstacleNearby = false,
		},
	},
}

-- PER ZOMBIE TABLE
ZombieData.ZombieDataTable = {}

-- CREATE DATA
function ZombieData:CreateData(Zombie)
	local DataCopy = TableClone.DeepClone(ZombieData.DefaultData["Normal"])
	self.ZombieDataTable[Zombie] = DataCopy

	return DataCopy
end

-- GET DATA
function ZombieData:Get(Zombie)
	return self.ZombieDataTable[Zombie]
end

-- REMOVE DATA
function ZombieData:Remove(Zombie)
	self.ZombieDataTable[Zombie] = nil
end

return ZombieData
