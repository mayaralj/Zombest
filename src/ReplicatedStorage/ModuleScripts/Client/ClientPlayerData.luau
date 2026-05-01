-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

-- MODULE TABLE
local ClientPlayerData = {}

-- DEFAULT PLAYER DATA TEMPLATE
ClientPlayerData.DefaultData = {
	-- CAMERA SETTINGS
	CameraSettings = {
		PlayerViewing = nil,
		CameraType = Enum.CameraType.Scriptable,
		CameraAngle = 0,
		Rotating = false,
		MinRadius = 15,
		MaxRadius = 45,
		Radius = 45,
		RotateSensitivity = 0.005,
		ZoomSensitivity = 2,
		TiltAngle = math.rad(60),

		-- LERP CAMERA SETTINGS
		SprintZoomOffset = 0,
		TargetSprintZoom = 0,
		ZoomLerpSpeed = 7,

		-- CONNECTION
		RenderConnection = nil,

		-- SCREENSHAKE
		ShakeOffset = Vector3.zero,
		DecayToOriginSpeed = 5,
	},

	-- CAMERA ROTATION SETTINGS
	RotationSettings = {
		RotationEnabled = true,
		IsDead = false,
		LastLookVector = nil,
		RenderConnection = nil,
		NewLookVector = nil,
		AngleThreshold = math.rad(0),
	},

	-- FIRING WEAPON
	Shooting = {
		IsShooting = false,
		ShootingConnection = nil,
		ShotLimiter = 0,
	},

	Points = {
		LastPoints = 0,
	},

	--KNOCKDOWN
	RevivePromptSignals = {
		PlayerKnockedSignal = nil,
		PlayerShootingSignal = nil,
	},

	MovementConnections = {
		MoveAnimationConnection = nil,
		DashAnimationConnection = nil,
	},

	Knockdown = {
		IdleAnimation = "rbxassetid://115053074137156",
		MovingAnimation = "rbxassetid://115893533037225",
		KnockedShooting = "rbxassetid://81734032330813",
		MovingSFX = "rbxassetid://6563561749",
		OnKnockSFX = "rbxassetid://6932519682",
	},

	Revive = {
		ReviveAnimation = "rbxassetid://133662149170010",
	},
}

-- ALL CLIENT DATA STORAGE
ClientPlayerData.ClientDataTable = {}

-- CREATE DATA FOR PLAYER
function ClientPlayerData:CreateData(Player)
	local DataCopy = TableClone.DeepClone(self.DefaultData)
	self.ClientDataTable[Player] = DataCopy
	return DataCopy
end

-- GET PLAYER DATA
function ClientPlayerData:Get(Player)
	return self.ClientDataTable[Player]
end

-- REMOVE PLAYER DATA
function ClientPlayerData:Remove(Player)
	self.ClientDataTable[Player] = nil
end

return ClientPlayerData
