-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local TableClone = require(ModuleScripts:WaitForChild("Clone"):WaitForChild("TableClone"))

-- MODULE TABLE
local ClientGunData = {}

-- DEFAULT WEAPON DATA TEMPLATE
ClientGunData.DefaultData = {
	Pistol = {
		About = {
			Name = "Glock 19",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Pistol",
			OutlineColor = Color3.fromRGB(76, 76, 76),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 100,
			CursorSizeIncrease = 100,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 30,
			ShotRotateWeight = 25,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://112122298635015",

			IdleAnimation = "rbxassetid://71151453368030",
			ReloadAnimation = "rbxassetid://86778253707326",

			WalkAnimation = "rbxassetid://78456925067984",
			RunAnimation = "rbxassetid://80284480014673",

			StartShooting = "rbxassetid://128639848315952",
			ContinueShooting = "rbxassetid://107207395282566",

			FrontDash = "rbxassetid://116691444006102",
			BackDash = "rbxassetid://84076846428589",
			LeftDash = "rbxassetid://111816466240684",
			RightDash = "rbxassetid://101561474740869",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		Ammo = {
			ReloadTime = 1, -- for animation syncing primarily
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(15, 20, 15),
		},
	},

	SemiPistol = {
		About = {
			Name = "RK5",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "SemiPistol",
			OutlineColor = Color3.fromRGB(29, 29, 29),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 100,
			CursorSizeIncrease = 100,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 30,
			ShotRotateWeight = 25,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://112122298635015",

			IdleAnimation = "rbxassetid://71151453368030",
			ReloadAnimation = "rbxassetid://86778253707326",

			WalkAnimation = "rbxassetid://78456925067984",
			RunAnimation = "rbxassetid://80284480014673",

			StartShooting = "rbxassetid://128639848315952",
			ContinueShooting = "rbxassetid://107207395282566",

			FrontDash = "rbxassetid://116691444006102",
			BackDash = "rbxassetid://84076846428589",
			LeftDash = "rbxassetid://111816466240684",
			RightDash = "rbxassetid://101561474740869",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://97681264385436",

			ShootSFX = "rbxassetid://9117400585",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://125192011892305",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://2757012623",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://18920777557",
			PullSFX = "rbxassetid://4527565140",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		Ammo = {
			ReloadTime = 1, -- for animation syncing primarily
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(15, 20, 15),
		},
	},

	Silencer = {
		About = {
			Name = "Silenced Glock",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Silencer",
			OutlineColor = Color3.fromRGB(76, 76, 76),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 100,
			CursorSizeIncrease = 100,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 30,
			ShotRotateWeight = 25,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://112122298635015",

			IdleAnimation = "rbxassetid://71151453368030",
			ReloadAnimation = "rbxassetid://86778253707326",

			WalkAnimation = "rbxassetid://78456925067984",
			RunAnimation = "rbxassetid://80284480014673",

			StartShooting = "rbxassetid://128639848315952",
			ContinueShooting = "rbxassetid://107207395282566",

			FrontDash = "rbxassetid://116691444006102",
			BackDash = "rbxassetid://84076846428589",
			LeftDash = "rbxassetid://111816466240684",
			RightDash = "rbxassetid://101561474740869",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://97681264385436",

			ShootSFX = "rbxassetid://124763531446154",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://2757012623",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://18920777557",
			PullSFX = "rbxassetid://4527565140",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(15, 20, 15),
		},
	},

	Rifle = {
		About = {
			Name = "Musket",
			BulletType = "RegularBigBullet",
			Casing = "RegularBigCasing",
			CasingDelay = 0.5,
			CasingSFX = "rbxassetid://9113630798",
			Model = "Rifle",
			OutlineColor = Color3.fromRGB(76, 68, 66),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 45,
			CursorMaxSize = 120,
			CursorSizeIncrease = 225,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 28,
			ShotRotateWeight = 20,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://138222667335847",
			ReloadAnimation = "rbxassetid://81247213763060",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://130053407336293",
			ContinueShooting = "rbxassetid://78551152738029",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://6862108495",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://7495307845",
			PullSFX = "rbxassetid://125152899230282",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		Ammo = {
			ReloadTime = 1, -- for animation syncing primarily
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(15, 20, 15),
		},
	},

	Deagle = {
		About = {
			Name = "Desert Eagle",
			BulletType = "RegularBullet",
			Casing = "SniperCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Deagle",
			OutlineColor = Color3.fromRGB(255, 223, 171),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 100,
			CursorSizeIncrease = 100,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 28,
			ShotRotateWeight = 20,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://112122298635015",

			IdleAnimation = "rbxassetid://71151453368030",
			ReloadAnimation = "rbxassetid://86778253707326",

			WalkAnimation = "rbxassetid://78456925067984",
			RunAnimation = "rbxassetid://80284480014673",

			StartShooting = "rbxassetid://128639848315952",
			ContinueShooting = "rbxassetid://107207395282566",

			FrontDash = "rbxassetid://116691444006102",
			BackDash = "rbxassetid://84076846428589",
			LeftDash = "rbxassetid://111816466240684",
			RightDash = "rbxassetid://101561474740869",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://72727217193577",

			ShootSFX = "rbxassetid://92985049101489",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://125192011892305",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://96510375242705",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://18920777557",
			PullSFX = "rbxassetid://4527565140",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 1,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.1,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.25,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(30, 20, 30),
		},
	},

	Uzi = {
		About = {
			Name = "Uzi",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Uzi",
			OutlineColor = Color3.fromRGB(16, 16, 16),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 80,
			CursorSizeIncrease = 20,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 18,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://135371412621232",

			IdleAnimation = "rbxassetid://101070773177329",
			ReloadAnimation = "rbxassetid://78384573300209",

			WalkAnimation = "rbxassetid://130637251023388",
			RunAnimation = "rbxassetid://134876221061010",

			StartShooting = "rbxassetid://106302271410861",

			FrontDash = "rbxassetid://97716899092897",
			BackDash = "rbxassetid://127329134385883",
			LeftDash = "rbxassetid://86724623633356",
			RightDash = "rbxassetid://107017830965293",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://72727217193577",

			ShootSFX = "rbxassetid://7131411690",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://125192011892305",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://81617850293501",
			MagOutSFX = "rbxassetid://18769017543",
			MagInSFX = "rbxassetid://18920777557",
			PullSFX = "rbxassetid://4527565140",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.05,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(10, 20, 10),
		},
	},

	TommyGun = {
		About = {
			Name = "Tommy Gun",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Tommy Gun",
			OutlineColor = Color3.fromRGB(30, 17, 11),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 80,
			CursorSizeIncrease = 20,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://88964848273926",

			IdleAnimation = "rbxassetid://98846481202737",
			ReloadAnimation = "rbxassetid://87746375736327",

			WalkAnimation = "rbxassetid://123017891912639",
			RunAnimation = "rbxassetid://71883886688160",

			StartShooting = "rbxassetid://140439375715978",

			FrontDash = "rbxassetid://109288371045647",
			BackDash = "rbxassetid://74232246803806",
			LeftDash = "rbxassetid://100854907236778",
			RightDash = "rbxassetid://107815125609405",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://7405483764",

			ShootSFX = "rbxassetid://2881626867",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://142491708",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(15, 20, 15),
		},
	},

	AK47 = {
		About = {
			Name = "AK-47",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "AK-47",
			OutlineColor = Color3.fromRGB(58, 21, 21),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 80,
			CursorSizeIncrease = 20,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://87746375736327",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://72591507241983",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://9117403445",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://3742928054",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 1.75,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(17, 22, 17),
		},
	},

	AR = {
		About = {
			Name = "AR-15",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "AR",
			OutlineColor = Color3.fromRGB(0, 0, 0),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 75,
			CursorSizeIncrease = 15,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://87746375736327",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://73225064818519",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://9113193653",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://140341132746608",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(17, 22, 17),
		},
	},

	SuppressedAR = {
		About = {
			Name = "Suppressed AR",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "SuppressedAR",
			OutlineColor = Color3.fromRGB(0, 0, 0),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 75,
			CursorSizeIncrease = 15,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://87746375736327",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://73225064818519",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://9114727561",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://140341132746608",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(17, 22, 17),
		},
	},

	BurstAR = {
		About = {
			Name = "Burst AR",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "BurstAR",
			OutlineColor = Color3.fromRGB(0, 0, 0),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 75,
			CursorSizeIncrease = 15,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://87746375736327",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://130212399996081",
			ContinueShooting = "rbxassetid://73225064818519",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://5735281491",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://140341132746608",
			MagOutSFX = "rbxassetid://18920777557",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(17, 22, 17),
		},
	},

	Minigun = {
		About = {
			Name = "Minigun",
			BulletType = "RegularBullet",
			Casing = "RegularCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "Minigun",
			OutlineColor = Color3.fromRGB(0, 0, 0),
		},

		Weight = {
			RotateWeight = 15,
			ShotRotateWeight = 8,
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 40,
			CursorMaxSize = 90,
			CursorSizeIncrease = 20,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://75572400295381",

			IdleAnimation = "rbxassetid://95654940888608",
			ReloadAnimation = "rbxassetid://88604528949203",

			WalkAnimation = "rbxassetid://136311255390315",
			RunAnimation = "rbxassetid://124603500335484",

			StartShooting = "rbxassetid://111380639073270",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://146830902",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://140341132746608",
			OutOfAmmoSFX = "rbxassetid://146830902",

			RotateToSFX = "rbxassetid://9110461166",
			RotateToLoopSFX = "rbxassetid://8509658502",
			RotateBackSFX = "rbxassetid://8509662150",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(5),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(25, 20, 25),
		},
	},

	PumpShotgun = {
		About = {
			Name = "Remington 870",
			BulletType = "RegularBullet",
			Casing = "ShotgunCasing",
			CasingSFX = "rbxassetid://7836856827",
			Model = "PumpShotgun",
			OutlineColor = Color3.fromRGB(70, 0, 1),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 15,
		},

		Cursor = {
			CursorImage = "rbxassetid://95081014476249",
			CursorDefaultSize = 100,
			CursorMaxSize = 250,
			CursorSizeIncrease = 300,
			CursorHitColor = Color3.fromRGB(162, 0, 5),
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://138222667335847",
			ReloadAnimation = "rbxassetid://88248027158817",
			StartReload = "rbxassetid://82407261431837",
			EndReload = "rbxassetid://90016035339792",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://90841346970725",
			ContinueShooting = "rbxassetid://115503752903077",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://111520248018511",

			ShootSFX = "rbxassetid://99280976493958",

			WallHitSFX = "rbxassetid://1489924400",
			ZombieHitSFX = "rbxassetid://118603344630208",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://139827026287805",
			EndReloadSFX = "rbxassetid://7129228370",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(25),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(35, 22, 35),
		},
	},

	TacticalShotgun = {
		About = {
			Name = "SPAS Tact",
			BulletType = "TactBullet",
			Casing = "TactCasing",
			CasingSFX = "rbxassetid://7836856827",
			Model = "TacticalShotgun",
			OutlineColor = Color3.fromRGB(241, 138, 140),
		},

		Cursor = {
			CursorImage = "rbxassetid://95081014476249",
			CursorDefaultSize = 100,
			CursorMaxSize = 250,
			CursorSizeIncrease = 300,
			CursorHitColor = Color3.fromRGB(162, 0, 5),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 15,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://135316398507210",
			ReloadAnimation = "rbxassetid://88248027158817",
			StartReload = "rbxassetid://82407261431837",
			EndReload = "rbxassetid://90016035339792",

			WalkAnimation = "rbxassetid://114321919362804",
			RunAnimation = "rbxassetid://88985917603968",

			StartShooting = "rbxassetid://73600324383416",
			ContinueShooting = "rbxassetid://126415667147486",

			FrontDash = "rbxassetid://86384404009959",
			BackDash = "rbxassetid://91263032551147",
			LeftDash = "rbxassetid://111029290498972",
			RightDash = "rbxassetid://123795713074118",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://111520248018511",

			ShootSFX = "rbxassetid://124742215378310",

			WallHitSFX = "rbxassetid://1489924400",
			ZombieHitSFX = "rbxassetid://118603344630208",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://139827026287805",
			EndReloadSFX = "rbxassetid://7129228370",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(25),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(35, 22, 35),
		},
	},

	AA12 = {
		About = {
			Name = "AA-12",
			BulletType = "RegularBullet",
			Casing = "ShotgunCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "AA-12",
			OutlineColor = Color3.fromRGB(0, 0, 0),
		},

		Cursor = {
			CursorImage = "rbxassetid://95081014476249",
			CursorDefaultSize = 100,
			CursorMaxSize = 300,
			CursorSizeIncrease = 350,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 27,
			ShotRotateWeight = 17,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://82483243453150",

			IdleAnimation = "rbxassetid://119787353313028",
			ReloadAnimation = "rbxassetid://88977358486310",

			WalkAnimation = "rbxassetid://111997161053961",
			RunAnimation = "rbxassetid://116239773529228",

			StartShooting = "rbxassetid://111824754174127",
			ContinueShooting = "rbxassetid://117804995219141",

			FrontDash = "rbxassetid://94048745080036",
			BackDash = "rbxassetid://87201071245829",
			LeftDash = "rbxassetid://138769630311620",
			RightDash = "rbxassetid://100917893054831",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://241338137",

			WallHitSFX = "rbxassetid://1489924400",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://3742928054",
			MagOutSFX = "rbxassetid://85766771173011",
			MagInSFX = "rbxassetid://94313384159651",
			PickSFX = "rbxassetid://9117409728",
			MagDropSFX = "rbxassetid://9117556114",
			BoltSFX = "rbxassetid://6129190959",
			OutOfAmmoSFX = "rbxassetid://94991291282460",
		},

		GunStats = {
			TimeToShoot = 1.75,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.06,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(10),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(35, 22, 35),
		},
	},

	PhaseSniper = {
		About = {
			Name = "Phantom-S",
			BulletType = "PhaseBullet",
			Casing = "PhaseCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "PhaseSniper",
			OutlineColor = Color3.fromRGB(185, 231, 255),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 55,
			CursorMaxSize = 400,
			CursorSizeIncrease = 600,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 24,
			ShotRotateWeight = 9,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://98361212102987",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://130053407336293",
			ContinueShooting = "rbxassetid://115183160996212",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://118733189323238",
			ShotChargeSFX = "rbxassetid://119906505566578",

			WallHitSFX = "rbxassetid://98613621656686",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://106576694218642",
			MagSFX = "rbxassetid://123389997043452",
			MagBackSFX = "rbxassetid://123389997043452",
			ChargeSFX = "rbxassetid://80694732550113",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 1,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.25,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 1,
			IntensityMultiplier = 10,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(10),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(30, 25, 30),
		},
	},

	RicochetSniper = {
		About = {
			Name = "Rico-150",
			BulletType = "SniperBullet",
			Casing = "SniperCasing",
			CasingSFX = "rbxassetid://9113630798",
			Model = "RicochetSniper",
			OutlineColor = Color3.fromRGB(255, 242, 219),
		},

		Cursor = {
			CursorImage = "rbxassetid://11792830715",
			CursorDefaultSize = 55,
			CursorMaxSize = 200,
			CursorSizeIncrease = 350,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 26,
			ShotRotateWeight = 15,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://85070799059051",

			IdleAnimation = "rbxassetid://107146541468825",
			ReloadAnimation = "rbxassetid://74685435637646",

			WalkAnimation = "rbxassetid://135258118026598",
			RunAnimation = "rbxassetid://98434694584012",

			StartShooting = "rbxassetid://130053407336293",
			ContinueShooting = "rbxassetid://115183160996212",

			FrontDash = "rbxassetid://98269558335680",
			BackDash = "rbxassetid://107524232915909",
			LeftDash = "rbxassetid://98940453847961",
			RightDash = "rbxassetid://136563062866295",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://3742927091",

			ShootSFX = "rbxassetid://5700090398",

			WallHitSFX = "rbxassetid://78578946566141",
			ZombieHitSFX = "rbxassetid://180083286",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			ReloadSFX = "rbxassetid://106576694218642",
			MagSFX = "rbxassetid://18920777557",
			MagBackSFX = "rbxassetid://18920777557",
			SniperPullSFX = "rbxassetid://6129190959",
			OutOfAmmoSFX = "rbxassetid://116975218704132",
		},

		GunStats = {
			TimeToShoot = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.06,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.5,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(15),
		},

		BulletStats = {
			MaxAge = 5,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(20, 22, 20),
		},
	},

	RayGun = {
		About = {
			Name = "Raygun",
			BulletType = "RayBullet",
			Casing = nil, -- assets handle casing for raygun
			CasingSFX = "rbxassetid://9113630798",
			Model = "RayGun",
			OutlineColor = Color3.fromRGB(44, 79, 33),
		},

		Cursor = {
			CursorImage = "rbxassetid://111560570406559",
			CursorDefaultSize = 30,
			CursorMaxSize = 90,
			CursorSizeIncrease = 140,
			CursorHitColor = Color3.fromRGB(211, 0, 7),
		},

		Weight = {
			RotateWeight = 30,
			ShotRotateWeight = 30,
		},

		Animations = {
			AnimationTracks = {},
			EquipAnimation = "rbxassetid://112122298635015",

			IdleAnimation = "rbxassetid://71151453368030",
			ReloadAnimation = "rbxassetid://84170702627557",

			WalkAnimation = "rbxassetid://78456925067984",
			RunAnimation = "rbxassetid://80284480014673",

			StartShooting = "rbxassetid://128639848315952",
			ContinueShooting = "rbxassetid://133513965653997",

			FrontDash = "rbxassetid://116691444006102",
			BackDash = "rbxassetid://84076846428589",
			LeftDash = "rbxassetid://111816466240684",
			RightDash = "rbxassetid://101561474740869",
		},

		VFX = {
			WalkVFX = "Dust",
			ZombieHitVFX = "BloodVFX",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://125555785090524",

			ShootSFX = "rbxassetid://137906449271113",

			WallHitSFX = "rbxassetid://6290067239",
			ZombieHitSFX = "rbxassetid://125192011892305",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://6563561749",

			DashSFX = "rbxassetid://6128977275",

			-- RELOAD BAG
			OpenSFX = "rbxassetid://107564483288851",
			CloseSFX = "rbxassetid://124574697748952",
			FillSFX = "rbxassetid://4874872056",
			OutOfAmmoSFX = "rbxassetid://114664682984662",
		},

		GunStats = {
			TimeToShoot = 2,
		},

		Ammo = {
			ReloadTime = 1, -- for animation syncing primarily
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 0.1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 0.5,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(20),
		},

		BulletStats = {
			MaxAge = 10,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(10, 20, 10),
		},
	},

	Scorchrift = {
		About = {
			Name = "Scorchrift",
			BulletType = "Stream",
			Model = "Scorchrift",
			OutlineColor = Color3.fromRGB(255, 97, 100),
		},

		Cursor = {
			CursorImage = "rbxassetid://86854089697673",
			CursorDefaultSize = 55,
			CursorMaxSize = 70,
			CursorSizeIncrease = 0,
			CursorHitColor = Color3.fromRGB(255, 11, 15),
		},

		Animations = {
			EquipAnimation = "rbxassetid://126536775442276",

			IdleAnimation = "rbxassetid://135602211817707",

			WalkAnimation = "rbxassetid://135602211817707",

			RunAnimation = "rbxassetid://135602211817707",

			StartShooting = "rbxassetid://103212435892728",
			ContinueShooting = "rbxassetid://77085933367575",

			ChargeStart = "rbxassetid://110251786545098",
			ChargeContinue = "rbxassetid://90476714455217",

			ChainStun = "rbxassetid://108552999692896",

			FrontDash = "rbxassetid://97342283060705",
			BackDash = "rbxassetid://89654408139975",
			LeftDash = "rbxassetid://87301997323057",
			RightDash = "rbxassetid://80025919155579",
		},

		VFX = {
			WalkVFX = "Dust",

			RunVFX = "LightningAura",
			RunLandVFX = "LightningRun",

			ChargeVFX = "LightningCharge",
			WindVFX = "WindEffect",

			EquipVFX = "LightningEquip",

			OverChargeVFX = "LightningOverCharge",
			LightningImpactVFX = "LightningImpact",

			DashVFX = "LightningDash",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://127793374596820",
			EquipSFX2 = "rbxassetid://9120769331",

			ShootSFX = "rbxassetid://83956246581661",

			WallHitSFX = "rbxassetid://158853971",
			ZombieHitSFX = "rbxassetid://158853971",
			BloodSFX = "rbxassetid://7837536770",

			StartChargeSFX = "rbxassetid://9120769331",
			LandChargeSFX = "rbxassetid://133098504541775",
			ContinueChargeSFX = "rbxassetid://9064807398",

			WalkSFX = "rbxassetid://596046130",

			RunSFX = "rbxassetid://596046130",
			RunSFX2 = "rbxassetid://6563561749",

			OverChargeSFX = "rbxassetid://9125516674",
			LightningImpactSFX = "rbxassetid://81920739716196",

			DashSFX = "rbxassetid://6128977275",
		},

		Weight = {
			TiltMultiplier = 1.5,
			WalkTilt = 1.5,
			RunTilt = 6,

			RotateWeight = 25,
			ShotRotateWeight = 18,
		},

		Ammo = {
			ReloadTime = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 1,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(0),
		},

		BulletStats = {
			BulletSpeed = 50,
			BulletSize = 0.1,
			MaxAge = math.huge,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(10, 15, 10),
		},
	},

	LightningFist = {
		About = {
			Name = "YousifSpec",
			BulletType = "Stream",
			Model = "LightningFist",
			OutlineColor = Color3.fromRGB(73, 150, 255),
		},

		Cursor = {
			CursorImage = "rbxassetid://86854089697673",
			CursorDefaultSize = 55,
			CursorMaxSize = 70,
			CursorSizeIncrease = 0,
			CursorHitColor = Color3.fromRGB(255, 11, 15),
		},

		Weight = {
			TiltMultiplier = 1.5,
			WalkTilt = 1.5,
			RunTilt = 6,

			RotateWeight = 30,
			ShotRotateWeight = 20,
		},

		Animations = {
			EquipAnimation = "rbxassetid://75207080617783",

			IdleAnimation = "rbxassetid://127882313290249",

			WalkAnimation = "rbxassetid://82050369114526",
			WalkReachedSignalLeft = "LeftStep",
			WalkReachedSignalRight = "RightStep",

			RunAnimation = "rbxassetid://99529066674273",
			RunReachedSignalLeft = "LeftLightning", -- leave empty if no aniamtion event
			RunReachedSignalRight = "RightLightning",

			StartShooting = "rbxassetid://131429976613412",
			ContinueShooting = "rbxassetid://115001279433732",
			EndShooting = "rbxassetid://85176308630255",

			ChargeStart = "rbxassetid://110262414869625",
			ChargeContinue = "rbxassetid://105137301303649",

			ChainStun = "rbxassetid://108552999692896",

			FrontDash = "rbxassetid://116287335056162",
			BackDash = "rbxassetid://89654408139975",
			LeftDash = "rbxassetid://87301997323057",
			RightDash = "rbxassetid://80025919155579",
		},

		VFX = {
			WalkVFX = "Dust",

			RunVFX = "LightningAura",
			RunLandVFX = "LightningRun",

			ChargeVFX = "LightningCharge",
			WindVFX = "WindEffect",

			EquipVFX = "LightningEquip",

			OverChargeVFX = "LightningOverCharge",
			LightningImpactVFX = "LightningImpact",

			DashVFX = "LightningDash",
		},

		SoundFX = {
			EquipSFX = "rbxassetid://9119594718",

			ShootSFX = "rbxassetid://5980690278",

			ChainHitSFX = "rbxassetid://9119594718",
			ChainLingerSFX = "rbxassetid://8952019380",

			WallHitSFX = "rbxassetid://9125516670",
			ZombieHitSFX = "rbxassetid://9125516670",
			BloodSFX = "rbxassetid://7837536770",

			StartChargeSFX = "rbxassetid://7768747890",
			ContinueChargeSFX = "rbxassetid://7287031267",

			WalkSFX = "rbxassetid://6563562192",

			RunSFX = "rbxassetid://18650085493",
			RunSFX2 = "rbxassetid://6563561749",

			OverChargeSFX = "rbxassetid://9125516674",
			LightningImpactSFX = "rbxassetid://81920739716196",

			DashSFX = "rbxassetid://9126067628",
		},

		GunStats = {},

		Ammo = {
			ReloadTime = 1,
		},

		RecoilCamera = {
			ConsecutiveShots = 0,
			MaxConsecutiveShots = 10,

			LastShotTime = 0,
			RecoveryTime = 1,
			RecoveryRate = 0.1,

			CurrentIntensity = 0,
			BaseIntensity = 0.025,
			MaxIntensity = 1,
			IntensityMultiplier = 0.05,
		},

		Rotation = {
			MinRotationAngle = math.rad(0),
			MaxRotationAngle = math.rad(0),
		},

		BulletStats = {
			BulletSpeed = 50,
			BulletSize = 0.75,
			MaxAge = math.huge,
		},

		Ragdoll = {
			ImpuseVector = Vector3.new(10, 15, 10),
		},
	},
}

-- ALL CLIENT WEAPON DATA STORAGE
ClientGunData.ClientGunDataTable = {}
ClientGunData.BulletConnection = nil

-- BULLET TABLES
ClientGunData.ClientBulletData = {}
ClientGunData.ClientBulletIndex = {}
ClientGunData.StreamBullet = {}

-- KNOCKED DATA
ClientGunData.KnockedGunData = {}

-- TRACKS AND CONNECTIONS
ClientGunData.Tracks = {}
ClientGunData.Connections = {}

-- TABLE TO WAIT TILL DATA IS CREATED
local ReadyToGet = {}

-- CREATE CLIENT GUN DATA
function ClientGunData:CreateData(Player, EquippedGun)
	if ClientGunData.ClientGunDataTable[Player] and ClientGunData.ClientGunDataTable[Player][EquippedGun] then
		return ClientGunData.ClientGunDataTable[Player][EquippedGun]
	end
	local DataCopy = TableClone.DeepClone(ClientGunData.DefaultData[EquippedGun])

	-- INITIALIZE PLAYER TABLES
	if not ClientGunData.ClientGunDataTable[Player] then
		ClientGunData.ClientGunDataTable[Player] = {}
		ReadyToGet[Player] = {}
	end

	-- CREATE AND STORE DATA
	ClientGunData.ClientGunDataTable[Player][EquippedGun] = DataCopy
	ReadyToGet[Player][EquippedGun] = true

	return DataCopy
end

-- KNOCKED DATA
function ClientGunData:CreateKnockedData(Player)
	local KnockedGuns = { "Pistol", "RayGun" }
	local CurrentGun = Player:GetAttribute("EquippedGun")

	local DataCopy
	if table.find(KnockedGuns, CurrentGun) then
		DataCopy = TableClone.DeepClone(ClientGunData.DefaultData[CurrentGun])
	else
		DataCopy = TableClone.DeepClone(ClientGunData.DefaultData["Pistol"])
	end

	-- CREATE AND STORE DATA
	ClientGunData.KnockedGunData[Player] = DataCopy
	return DataCopy
end

-- GET PLAYER'S WEAPON DATA
function ClientGunData:Get(Player)
	if Player:GetAttribute("IsKnocked") then
		if ClientGunData.KnockedGunData[Player] then
			return ClientGunData.KnockedGunData[Player]
		end
		local KnockedData = ClientGunData:CreateKnockedData(Player)
		if not KnockedData then
			return
		end

		return KnockedData
	end

	-- GRAB EQUIPPED GUN
	local EquippedGun = Player:GetAttribute("IsEquippingGun")
	if not EquippedGun then
		EquippedGun = Player:GetAttribute("EquippedGun")
	end
	-- END IF NO GUN
	if not EquippedGun then
		return
	end

	-- REPEAT TILL READY
	local Count = 0
	repeat
		Count += 1
		if not ReadyToGet[Player] or not ReadyToGet[Player][EquippedGun] then
			task.wait()
		end
	until (ReadyToGet[Player] and ReadyToGet[Player][EquippedGun]) or Count == 10
	if not ClientGunData.ClientGunDataTable[Player] then
		return
	end

	-- RETURN DATA TABLE
	return ClientGunData.ClientGunDataTable[Player][EquippedGun]
end

-- REMOVE PER GUN DATA
function ClientGunData:Remove(Player)
	local EquippedGun = Player:GetAttribute("IsEquippingGun")
	if not EquippedGun then
		EquippedGun = Player:GetAttribute("EquippedGun")
	end

	if not ClientGunData.ClientGunDataTable[Player] then
		return
	end
	if not EquippedGun then
		return
	end
	ClientGunData.ClientGunDataTable[Player][EquippedGun] = nil
	if ReadyToGet[Player][EquippedGun] then
		ReadyToGet[Player][EquippedGun] = nil
	end
end

-- FULLY REMOVE DATA
function ClientGunData:Clean(Player)
	ClientGunData.ClientGunDataTable[Player] = nil
	ClientGunData.KnockedGunData[Player] = nil
	ReadyToGet[Player] = nil
end

return ClientGunData
