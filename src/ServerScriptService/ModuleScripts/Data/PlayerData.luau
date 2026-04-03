-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

local PlayerData = {}

PlayerData.DefaultData = {
	Health = {
		RegenConnection = nil,
		HealthChangedConnection = nil,

		RegenRate = 20,
		TimeToRegen = 5,
		PreviousHealth = nil,
	},

	Knockdown = {
		KnockedHealthConnections = nil,
		IsKnocked = nil,
		IdleAnimation = "rbxassetid://92008953438996",
		MovingAnimation = "rbxassetid://96282135379399",
	},

	Points = {
		CurrentPoints = 5000,
	},

	Stamina = {
		CurrentStamina = 100,
		MaxStamina = 100,
		CurrentlySprinting = false,
		TimeSinceSprinted = 0,
	},

	Sprint = {
		WalkSpeed = 20,
		SprintSpeed = 30,
		SprintLoop = nil,
		WaitToSprint = 0,
	},

	Dash = {
		DashForce = 65,
		DashDuration = 0.25,
		DashTimer = 0,
		DashCooldown = 2,
	},

	Shooting = {
		TimeSincePlayerShot = nil,
	},

	Cooldowns = {
		PlayerHitCooldown = nil,
	},

	Agro = {
		TotalZombiesAgroed = 0,
	},

	WeaponSlots = {
		"Empty",
		"Empty",
		"Empty",
	},
}

PlayerData.PlayerDataTable = {}

function PlayerData:CreateData(Player)
	local DataCopy = TableClone.DeepClone(self.DefaultData)
	self.PlayerDataTable[Player] = DataCopy
	return DataCopy
end

function PlayerData:Get(Player)
	return self.PlayerDataTable[Player]
end

function PlayerData:Remove(Player)
	self.PlayerDataTable[Player] = nil
end

return PlayerData
