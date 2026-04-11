-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local BulletEffects = require(Frameworks:WaitForChild("Gun"):WaitForChild("BulletFW"))
local ChargeEffectsFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("ChargeEffectsFW"))
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

-- MODULE TABLE
local GunData = {}

-- DEFAULT WEAPON TEMPLATES
GunData.DefaultData = {
	Pistol = {
		About = {
			Name = "Pistol",
			BulletType = "Regular",
			Model = "Pistol",
			EquipTime = 0.7,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.05,
			RunMoveWeight = 0.05,
			ReloadMoveWeight = 0.4,
			ShootMoveWeight = 0.3,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 2,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 60,
			FireRate = 2.5,
			Windup = 0,
		},

		Ammo = {
			MaxAmmo = 12,
			CurrentAmmo = 12,
			TotalAmmo = 200,
			MaxTotalAmmo = 200,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	SemiPistol = {
		About = {
			Name = "SemiPistol",
			BulletType = "Regular",
			Model = "SemiPistol",
			EquipTime = 0.7,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.05,
			RunMoveWeight = 0.05,
			ReloadMoveWeight = 0.4,
			ShootMoveWeight = 0.3,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		Burst = {
			BulletsPerShot = 3,
			BurstDuration = 0.03,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 37,
			FireRate = 2,
			Windup = 0,
		},

		Ammo = {
			MaxAmmo = 60,
			CurrentAmmo = 60,
			TotalAmmo = 300,
			MaxTotalAmmo = 300,
			ReloadTime = 1.7,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Silencer = {
		About = {
			Name = "Silencer",
			BulletType = "Regular",
			Model = "Silencer",
			EquipTime = 0.7,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.05,
			RunMoveWeight = 0.05,
			ReloadMoveWeight = 0.4,
			ShootMoveWeight = 0.3,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1.75,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 90,
			FireRate = 2,
			Windup = 0,
		},

		Ammo = {
			MaxAmmo = 25,
			CurrentAmmo = 25,
			TotalAmmo = 200,
			MaxTotalAmmo = 200,
			ReloadTime = 1.64,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 200,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1.2,
		},

		Effect = {
			WallRicochet = {
				Type = BulletEffects.WallRicochetEffect,
				MaxReflections = 2,
				MaxReflectedHits = 2,
			},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Rifle = {
		About = {
			Name = "Rifle",
			BulletType = "Regular",
			Model = "Rifle",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.08,
			RunMoveWeight = 0.08,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 4,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 175,
			Damage = 100,
			FireRate = 0.8,
			Windup = 0.25,
			DelayIsShooting = 0.5,
		},

		Ammo = {
			MaxAmmo = 10,
			CurrentAmmo = 10,
			TotalAmmo = 100,
			MaxTotalAmmo = 100,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Deagle = {
		About = {
			Name = "Deagle",
			BulletType = "Regular",
			Model = "Deagle",
			EquipTime = 0.7,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.06,
			RunMoveWeight = 0.06,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 5,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 85,
			FireRate = 1.25,
			Windup = 0,
		},

		Ammo = {
			MaxAmmo = 10,
			CurrentAmmo = 10,
			TotalAmmo = 100,
			MaxTotalAmmo = 100,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 3,
			BulletPhaseType = "Zombie",
			BulletSpeed = 300,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 0.5,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Uzi = {
		About = {
			Name = "Uzi",
			BulletType = "Regular",
			Model = "Uzi",
			EquipTime = 0.75,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.075,
			RunMoveWeight = 0.075,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 0.5,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.04,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 30,
			FireRate = 14,
			Windup = 0.25,
		},

		Ammo = {
			MaxAmmo = 90,
			CurrentAmmo = 90,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 1.8,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	TommyGun = {
		About = {
			Name = "TommyGun",
			BulletType = "Regular",
			Model = "Tommy Gun",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.09,
			RunMoveWeight = 0.09,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.12,
			SpreadIncrease = 0.015,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 35,
			FireRate = 15,
			Windup = 0.2,
		},

		Ammo = {
			MaxAmmo = 100,
			CurrentAmmo = 100,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 1.9,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 225,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	AK47 = {
		About = {
			Name = "AK-47",
			BulletType = "Regular",
			Model = "AK-47",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1.2,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.08,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 33,
			FireRate = 16,
			Windup = 0.2,
		},

		Ammo = {
			MaxAmmo = 95,
			CurrentAmmo = 95,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	AR = {
		About = {
			Name = "AR",
			BulletType = "Regular",
			Model = "AR",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.08,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 32,
			FireRate = 17,
			Windup = 0.2,
		},

		Ammo = {
			MaxAmmo = 90,
			CurrentAmmo = 90,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 275,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	SuppressedAR = {
		About = {
			Name = "SuppressedAR",
			BulletType = "Regular",
			Model = "SuppressedAR",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 0.9,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.08,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 36,
			FireRate = 15,
			Windup = 0.2,
		},

		Ammo = {
			MaxAmmo = 90,
			CurrentAmmo = 90,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 210,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Effect = {
			WallRicochet = {
				Type = BulletEffects.WallRicochetEffect,
				MaxReflections = 2,
				MaxReflectedHits = 2,
			},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	BurstAR = {
		About = {
			Name = "BurstAR",
			BulletType = "Regular",
			Model = "BurstAR",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 0.8,
		},

		Burst = {
			BulletsPerShot = 5,
			BurstDuration = 0.04,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.05,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 70,
			FireRate = 3,
			Windup = 0.1,
		},

		Ammo = {
			MaxAmmo = 75,
			CurrentAmmo = 75,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 260,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Minigun = {
		About = {
			Name = "Minigun",
			BulletType = "Regular",
			Model = "Minigun",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.2,
			RunMoveWeight = 0.2,
			ReloadMoveWeight = 0.45, -- n/a
			ShootMoveWeight = 0.5,

			WalkDashWeight = 20,
			RunDashWeight = 20,
			DashDurationWeight = 10,
		},

		Burst = {
			BulletsPerShot = 1,
			BurstDuration = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.07,
			SpreadIncrease = 0.008,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 42,
			FireRate = 22,
			Windup = 0.75,
		},

		Ammo = {
			MaxAmmo = 2500,
			CurrentAmmo = 2500,
			TotalAmmo = 0,
			MaxTotalAmmo = 0,
			ReloadTime = -1, -- make reload time lower than 0 if no reload
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 200,
			BulletAge = 0,
			BulletMaxAge = 5,
			BulletSize = 1.5,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	PumpShotgun = {
		About = {
			Name = "PumpShotgun",
			BulletType = "Regular",
			Model = "PumpShotgun",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		Burst = {
			BulletsPerShot = 6,
			BurstDuration = 0,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.15,
			SpreadIncrease = 0.15,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 80,
			DamageFalloff = 0.9,
			FireRate = 1.35,
			Windup = 0.1,
		},

		Ammo = {
			MaxAmmo = 72,
			CurrentAmmo = 72,
			TotalAmmo = 300,
			MaxTotalAmmo = 300,
			ReloadTime = 0.5,
			ReloadType = "Shotgun",
			AmmoPerReload = 6,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 225,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	TacticalShotgun = {
		About = {
			Name = "TacticalShotgun",
			BulletType = "Regular",
			Model = "TacticalShotgun",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		Burst = {
			BulletsPerShot = 4,
			BurstDuration = 0,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.2,
			SpreadIncrease = 0.2,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 75,
			DamageFalloff = 1,
			FireRate = 2.5,
			Windup = 0.1,
		},

		Ammo = {
			MaxAmmo = 60,
			CurrentAmmo = 60,
			TotalAmmo = 400,
			MaxTotalAmmo = 400,
			ReloadTime = 0.25,
			ReloadType = "Shotgun",
			AmmoPerReload = 4,
		},

		BulletStats = {
			BulletPhase = 2,
			BulletPhaseType = "Zombie",
			BulletSpeed = 350,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	AA12 = {
		About = {
			Name = "AA-12",
			BulletType = "Regular",
			Model = "AA-12",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		Burst = {
			BulletsPerShot = 6,
			BurstDuration = 0,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.11,
			SpreadIncrease = 0.11,
			RecoveryTime = 0.1,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 100,
			DamageFalloff = 0.85,
			FireRate = 3.5,
			Windup = 0.1,
		},

		Ammo = {
			MaxAmmo = 150,
			CurrentAmmo = 150,
			TotalAmmo = 900,
			MaxTotalAmmo = 400,
			ReloadTime = 2.5,
			AmmoPerReload = 6,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 250,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 1,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	PhaseSniper = {
		About = {
			Name = "PhaseSniper",
			BulletType = "Regular",
			Model = "PhaseSniper",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.125,
			RunMoveWeight = 0.125,
			ReloadMoveWeight = 0.45,
			ShootMoveWeight = 0.4,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 3,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0,
			SpreadIncrease = 0,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 200,
			Damage = 100,
			FireRate = 0.3333,
			Windup = 3,
		},

		Ammo = {
			MaxAmmo = 5,
			CurrentAmmo = 5,
			TotalAmmo = 100,
			MaxTotalAmmo = 100,
			ReloadTime = 3,
		},

		BulletStats = {
			BulletPhase = 15,
			BulletSpeed = 140,
			BulletAge = 0,
			BulletMaxAge = 5,
			BulletSize = 4,
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	RicochetSniper = {
		About = {
			Name = "RicochetSniper",
			BulletType = "Regular",
			Model = "RicochetSniper",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0.1,
			RunMoveWeight = 0.1,
			ReloadMoveWeight = 0.4,
			ShootMoveWeight = 0.35,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 1,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.08,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 175,
			Damage = 100,
			FireRate = 1.1,
			Windup = 0.45,
		},

		Ammo = {
			MaxAmmo = 10,
			CurrentAmmo = 10,
			TotalAmmo = 100,
			MaxTotalAmmo = 100,
			ReloadTime = 2.4,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 120,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 2,
		},

		Effect = {
			ZombieRicochet = {
				Type = BulletEffects.ZombieRicochetEffect,
				MaxReflections = 10,
				Radius = 40,
				DamageFalloff = 5, -- in percentage
				CurrentCooldown = 0,
				ZombieCooldown = 0,
				GlobalCooldown = 0,
			},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	RayGun = {
		About = {
			Name = "RayGun",
			BulletType = "Regular",
			Model = "RayGun",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0,
			RunMoveWeight = 0,
			ReloadMoveWeight = 0.3,
			ShootMoveWeight = 0.2,

			WalkDashWeight = 0,
			RunDashWeight = 0,
			DashDurationWeight = 0,
		},

		BodyForce = {
			BodyForce = 2,
		},

		RecoilSpread = {
			ConsecutiveShots = 0,
			LastShotTime = 0,
			CurrentSpread = 0,
			BaseSpread = 0,
			MaxSpread = 0.1,
			SpreadIncrease = 0.01,
			RecoveryTime = 0.25,
			RecoveryRate = 0.05,
		},

		GunStats = {
			Range = 150,
			Damage = 100,
			FireRate = 2.5,
			Windup = 0.01,
		},

		Ammo = {
			MaxAmmo = 20,
			CurrentAmmo = 20,
			TotalAmmo = 500,
			MaxTotalAmmo = 500,
			ReloadTime = 2.5,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 300,
			BulletAge = 0,
			BulletMaxAge = 10,
			BulletSize = 2,
		},

		Effect = {
			AoeEffect = {
				Type = BulletEffects.AoeEffect,
				CurrentCooldown = 0,
				MaxCooldown = 0.1,

				DamageOrigZombie = true,
				DamagePlayer = false,
				DamageOtherPlayers = false,

				Damage = 150,
				MaxHits = 7,
				FallOffMultiplier = 3, -- 1 regular, above is weaker falloff
				Radius = 14,
			},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	Scorchrift = {
		About = {
			Name = "Scorchrift",
			BulletType = "Stream",
			Model = "Scorchrift",
			EquipTime = 1.2,
			Location = "Head",
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = -0.33,
			RunMoveWeight = -0.33,
			ReloadMoveWeight = 1,
			ShootMoveWeight = -0.1,

			WalkDashWeight = -15,
			RunDashWeight = -20,
			DashDurationWeight = 10,
		},

		BodyForce = {
			BodyForce = 0.2,
		},

		GunStats = {
			Range = 100,
			Damage = 25,
			FireRate = 25,
			Windup = 0.2,
		},

		-- CHARGE
		Charge = {
			TimeBeforeChargeTimer = 0,
			TimeBeforeCharge = 1,

			MaxCharge = 100, -- in percent
			CurrentCharge = 100,
			TimeToWait = 1.5,

			ChargeRegenRate = 15,
			ChargeDecreaseRate = 0.3,

			ManualChargeTimer = 100,
			ManualChargeCD = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 1000,
			BulletAge = 0,
			BulletMaxAge = 0.1,
			BulletSize = 0.1,
		},

		Effect = {
			Burn = {
				Type = BulletEffects.BurnEffect,
				Duration = 5.1,
				Damage = 15,
				PerZombieCD = 1,
				GlobalCD = 0.01,
				CurrentCD = 0,
			},
		},

		ChargeEffect = {
			--OverCharge = {
			--	Type = ChargeEffectsFW.OverCharge,
			--	SpeedBuff = 20, -- +x speed
			--	Duration = 10,
			--},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},

	LightningFist = {
		About = {
			Name = "LightningFist",
			BulletType = "Stream",
			Model = "LightningFist",
			ShotVFXFolder = "LightningBeam",
			EquipTime = 1,
		},

		Weight = {
			MoveWeight = 0,
			WalkMoveWeight = 0,
			RunMoveWeight = -0.1,
			ReloadMoveWeight = 1,
			ShootMoveWeight = 0.25,

			WalkDashWeight = -40,
			RunDashWeight = -30,
			DashDurationWeight = 0.1,
		},

		BodyForce = {
			BodyForce = 0.1,
		},

		GunStats = {
			Range = 100,
			Damage = 12,
			FireRate = 25,
			Windup = 0.15,
		},

		-- CHARGE
		Charge = {
			TimeBeforeChargeTimer = 0,
			TimeBeforeCharge = 1.75,

			MaxCharge = 100, -- in percent
			CurrentCharge = 100,
			TimeToWait = 2,

			ChargeRegenRate = 16,
			ChargeDecreaseRate = 0.3,

			ManualChargeTimer = 100,
			ManualChargeCD = 2,
		},

		BulletStats = {
			BulletPhase = 1,
			BulletSpeed = 1000,
			BulletAge = 0,
			BulletMaxAge = 0.1,
			BulletSize = 0.1,
		},

		Effect = {
			Chain = {
				Type = BulletEffects.ChainEffect,
				MaxChains = 25,
				Damage = 25,
				ChainRadius = 50,
				StunTime = 2,
				Cooldown = 1,
				GlobalCooldown = 2,
				CurrentCooldown = 0,
			},
		},

		ChargeEffect = {
			OverCharge = {
				Type = ChargeEffectsFW.OverCharge,
				SpeedBuff = 20, -- +x speed
				Duration = 10,
			},
		},

		Timer = {
			UpdateStreamTimer = 0,
		},
	},
}

-- SETUP
GunData.GunDataTable = {}
GunData.BulletData = {}
GunData.BulletIndex = {}
GunData.BulletConnection = nil

GunData.KnockedGunData = {}

-- TABLE TO WAIT TILL DATA IS CREATED
local ReadyToGet = {}

-- CREATE GUN DATA
function GunData:CreateData(Player, EquippedGun)
	if GunData.GunDataTable[Player] and GunData.GunDataTable[Player][EquippedGun] then
		return GunData.GunDataTable[Player][EquippedGun]
	end
	local DataCopy = TableClone.DeepClone(GunData.DefaultData[EquippedGun])

	-- INITIALIZE PLAYER TABLES
	if not GunData.GunDataTable[Player] then
		GunData.GunDataTable[Player] = {}
		ReadyToGet[Player] = {}
	end

	-- CREATE AND STORE DATA
	GunData.GunDataTable[Player][EquippedGun] = DataCopy
	ReadyToGet[Player][EquippedGun] = true
	return DataCopy
end

-- KNOCKED DATA
function GunData:CreateKnockedData(Player)
	local KnockedGuns = { "Pistol", "RayGun" }
	local CurrentGun = Player:GetAttribute("EquippedGun")

	local DataCopy
	if table.find(KnockedGuns, CurrentGun) then
		DataCopy = TableClone.DeepClone(GunData.DefaultData[CurrentGun])
	else
		DataCopy = TableClone.DeepClone(GunData.DefaultData["Pistol"])
	end

	-- CREATE AND STORE DATA
	GunData.KnockedGunData[Player] = DataCopy
	return DataCopy
end

-- GET DATA
function GunData:Get(Player, EquippedGun)
	if Player:GetAttribute("IsKnocked") then
		if GunData.KnockedGunData[Player] then
			return GunData.KnockedGunData[Player]
		end
		local KnockedData = GunData:CreateKnockedData(Player)
		if not KnockedData then
			return
		end

		return KnockedData
	end

	-- GRAB EQUIPPED GUN
	if not EquippedGun then
		EquippedGun = Player:GetAttribute("IsEquippingGun")
		if not EquippedGun then
			EquippedGun = Player:GetAttribute("EquippedGun")
		end
		-- END IF NO GUN
		if not EquippedGun then
			return
		end
	end

	-- REPEAT TILL READY
	local Count = 0
	repeat
		Count += 1
		task.wait()
	until ReadyToGet[Player] and ReadyToGet[Player][EquippedGun] or Count == 10
	if not GunData.GunDataTable[Player] then
		return
	end

	-- RETURN DATA TABLE
	return GunData.GunDataTable[Player][EquippedGun]
end

-- REMOVE PER GUN DATA
function GunData:Remove(Player)
	local EquippedGun = Player:GetAttribute("IsEquippingGun")
	if not EquippedGun then
		EquippedGun = Player:GetAttribute("EquippedGun")
	end

	if not GunData.GunDataTable[Player] then
		return
	end
	if not EquippedGun then
		return
	end
	GunData.GunDataTable[Player][EquippedGun] = nil
	if ReadyToGet[Player][EquippedGun] then
		ReadyToGet[Player][EquippedGun] = nil
	end
end

-- FULLY REMOVE DATA
function GunData:Clean(Player)
	GunData.GunDataTable[Player] = nil
	GunData.KnockedGunData[Player] = nil
	ReadyToGet[Player] = nil
end

-- RETURN
return GunData
