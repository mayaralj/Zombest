-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local PerGunAssets = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("PerGunAssets")

-- MODULES
local ClientGunDataModule = require(ClientData:WaitForChild("ClientGunData"))
local ClientPlayerData = require(ClientData:WaitForChild("ClientPlayerData"))
local ClientUtilities =
	require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local DetermineAssets = require(PerGunAssets:WaitForChild("DetermineAssets"))

-- EVENTS
local TimeChange = Events:WaitForChild("MapEvents"):WaitForChild("TimeChange")

-- GUN ASSETS FOLDER AND EVENTS
local GunAssetsEvents = Events:WaitForChild("GunAssetsEvents")
local ZombieHitVFX = GunAssetsEvents:WaitForChild("ZombieHitVFX")
local WallFX = GunAssetsEvents:WaitForChild("WallFX")

-- EQUIP ASSETS
local function EquipAnimation(PlayerEquipped, EquippedGun)
	if not PlayerEquipped or not EquippedGun then
		return
	end
	-- GET ASSETS MODULE
	local EquipAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not EquipAssets then
		return
	end

	-- REPEAT TILL DATA HAS BEEN LOADED
	local Count = 0
	local DefaultData
	repeat
		DefaultData = ClientGunDataModule:Get(PlayerEquipped)
		Count += 1
		task.wait(0.1)
	until DefaultData or Count == 10
	-- PLAYER EQUIPPED DATA
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local RepeatCount = 0
		repeat
			if PlayerEquipped:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = EquipAssets.Equip(LocalPlayer, DefaultData, EquippedGun, PlayerEquipped)

			RepeatCount += 1
			task.wait()
		until SuccessfulAssets or RepeatCount == 100
	end)
end

-- IDLE ASSETS
local function IdleAnimation(PlayerEquipped, EquippedGun)
	if not PlayerEquipped or not EquippedGun then
		return
	end
	-- GET ASSETS MODULE
	local IdleAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not IdleAssets then
		return
	end

	-- REPEAT TILL DATA HAS BEEN LOADED
	local Count = 0
	local DefaultData
	repeat
		DefaultData = ClientGunDataModule:Get(PlayerEquipped)
		Count += 1
		task.wait(0.1)
	until DefaultData or Count == 10
	-- PLAYER EQUIPPED DATA
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local RepeatCount = 0
		repeat
			if PlayerEquipped:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = IdleAssets.Idle(LocalPlayer, DefaultData, EquippedGun, PlayerEquipped)

			RepeatCount += 1
			task.wait()
		until SuccessfulAssets or RepeatCount == 100
	end)
end

-- MOVEMENT ASSETS
local function MovementAnimation(PlayerRequired, EquippedGun)
	if not PlayerRequired or not EquippedGun then
		return
	end
	-- ASSETS
	local MovementAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not MovementAssets then
		return
	end

	local DefaultData = ClientGunDataModule:Get(PlayerRequired)
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local RepeatCount = 0
		repeat
			if PlayerRequired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = MovementAssets.Movement(LocalPlayer, DefaultData, EquippedGun, PlayerRequired)

			RepeatCount += 1
			task.wait()
		until SuccessfulAssets or RepeatCount == 100
	end)
end

-- SHOOT ASSETS
local function ShootAnimation(PlayerFired, EquippedGun)
	if not PlayerFired or not EquippedGun then
		return
	end
	local ShootAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not ShootAssets then
		return
	end

	local DefaultData = ClientGunDataModule:Get(PlayerFired)
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local Count = 0
		repeat
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = ShootAssets.Shoot(LocalPlayer, DefaultData, EquippedGun, PlayerFired)

			Count += 1
			task.wait()
		until SuccessfulAssets or Count == 100
	end)
end

-- RELOAD ASSETS
local function ReloadAnimation(PlayerReloading, EquippedGun, Action)
	if not PlayerReloading or not EquippedGun then
		return
	end
	local ReloadAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not ReloadAssets then
		return
	end

	local DefaultData = ClientGunDataModule:Get(PlayerReloading)
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local Count = 0
		repeat
			if PlayerReloading:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = ReloadAssets.Reload(LocalPlayer, DefaultData, EquippedGun, PlayerReloading)

			Count += 1
			task.wait()
		until SuccessfulAssets or Count == 100
	end)
end

-- CHARGE ASSETS
local function ChargeAnimation(PlayerCharging, EquippedGun)
	if not PlayerCharging or not EquippedGun then
		return
	end
	local ChargeAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not ChargeAssets then
		return
	end

	local DefaultData = ClientGunDataModule:Get(PlayerCharging)
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local Count = 0
		repeat
			if PlayerCharging:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = ChargeAssets.Charge(LocalPlayer, DefaultData, EquippedGun, PlayerCharging)

			Count += 1
			task.wait()
		until SuccessfulAssets or Count == 100
	end)
end

-- DASH ANIMATION
local function DashAnimation(PlayerDashing, EquippedGun)
	if not PlayerDashing or not EquippedGun then
		return
	end
	local DashAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not DashAssets then
		return
	end

	local DefaultData = ClientGunDataModule:Get(PlayerDashing)
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local Count = 0
		repeat
			if PlayerDashing:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = DashAssets.Dash(LocalPlayer, DefaultData, EquippedGun, PlayerDashing)

			Count += 1
			task.wait()
		until SuccessfulAssets or Count == 100
	end)
end

-- GUN UI
local function GunUI(PlayerFired, EquippedGun)
	if not PlayerFired or not EquippedGun then
		return
	end
	-- ONLY FOR THE PLAYER WITH GUN
	if LocalPlayer ~= PlayerFired then
		return
	end

	local GunAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not GunAssets then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	pcall(function()
		local Count = 0
		repeat
			if PlayerFired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				return
			end
			SuccessfulAssets = GunAssets.UI(LocalPlayer, EquippedGun)

			Count += 1
			task.wait()
		until SuccessfulAssets or Count == 100
	end)
end

-- WALL FX
WallFX.OnClientEvent:Connect(function(PlayerFired, ResultData)
	if not PlayerFired or not ResultData then
		return
	end
	local EquippedGun = PlayerFired:GetAttribute("EquippedGun")
	if not EquippedGun then
		return
	end

	local WallAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not WallAssets then
		return
	end

	-- WALL FX
	WallAssets.WallHit(PlayerFired, EquippedGun, ResultData)
	WallAssets.WallMark(PlayerFired, EquippedGun, ResultData)
end)

-- ZOMBIE HIT VFX
ZombieHitVFX.OnClientEvent:Connect(function(PlayerFired, ResultData)
	if not PlayerFired or not ResultData then
		return
	end
	local EquippedGun = PlayerFired:GetAttribute("EquippedGun")
	if not EquippedGun then
		return
	end

	local ZombieHitAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not ZombieHitAssets then
		return
	end

	ZombieHitAssets.ZombieHit(PlayerFired, EquippedGun, ResultData)
end)

-- BIND FUNCTIONS TO PLAYER CHARACTER
local function StartGunAnimations(CharacterRequired)
	-- GET PLAYER
	local PlayerRequired = Players:GetPlayerFromCharacter(CharacterRequired)
	if not PlayerRequired then
		return
	end

	local Tracks = ClientGunDataModule.Tracks
	if not Tracks then
		return
	end

	local Connections = ClientGunDataModule.Connections
	if not Connections then
		return
	end

	if not Tracks[PlayerRequired] then
		Tracks[PlayerRequired] = {}
	end
	if not Connections[PlayerRequired] then
		Connections[PlayerRequired] = {}
	end

	local Flag
	-- INITIAL CHECK
	if PlayerRequired:GetAttribute("EquippedGun") then
		local GunEquipped = PlayerRequired:GetAttribute("EquippedGun")
		if Flag ~= GunEquipped then
			GunUI(PlayerRequired, GunEquipped)
			EquipAnimation(PlayerRequired, GunEquipped)
			IdleAnimation(PlayerRequired, GunEquipped)
			MovementAnimation(PlayerRequired, GunEquipped)
			DashAnimation(PlayerRequired, GunEquipped)
			ChargeAnimation(PlayerRequired, GunEquipped)
			ReloadAnimation(PlayerRequired, GunEquipped)
			ShootAnimation(PlayerRequired, GunEquipped)
			Flag = GunEquipped
		end
		-- INITIAL IF THEY ARE EQUIPPING CHECK
	elseif PlayerRequired:GetAttribute("IsEquipping") then
		local GunEquipped = PlayerRequired:GetAttribute("IsEquippingGun")
		if Flag ~= GunEquipped then
			GunUI(PlayerRequired, GunEquipped)
			EquipAnimation(PlayerRequired, GunEquipped)
			IdleAnimation(PlayerRequired, GunEquipped)
			MovementAnimation(PlayerRequired, GunEquipped)
			DashAnimation(PlayerRequired, GunEquipped)
			ChargeAnimation(PlayerRequired, GunEquipped)
			ReloadAnimation(PlayerRequired, GunEquipped)
			ShootAnimation(PlayerRequired, GunEquipped)
			Flag = GunEquipped
		end
	end

	-- CLEAR CONNECTIONS
	if Connections[PlayerRequired] then
		if Connections[PlayerRequired]["EquippedGun"] then
			Connections[PlayerRequired]["EquippedGun"]:Disconnect()
			Connections[PlayerRequired]["EquippedGun"] = nil
		end

		if Connections[PlayerRequired]["CleanClientData"] then
			Connections[PlayerRequired]["CleanClientData"]:Disconnect()
			Connections[PlayerRequired]["CleanClientData"] = nil
		end
	end

	-- LISTEN TO GUN CHANGES
	Connections[PlayerRequired]["GeneralEquippedGun"] = PlayerRequired:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerRequired:GetAttribute("IsEquippingGun") then
				-- GUN
				--RunService.Heartbeat:Wait()
				local GunEquipped = PlayerRequired:GetAttribute("IsEquippingGun")
				if Flag and Flag == GunEquipped then
					return
				end
				if not PlayerRequired:GetAttribute("IsRevived") and not PlayerRequired:GetAttribute("IsKnocked") then
					EquipAnimation(PlayerRequired, GunEquipped)
				end
				GunUI(PlayerRequired, GunEquipped)
				IdleAnimation(PlayerRequired, GunEquipped)
				MovementAnimation(PlayerRequired, GunEquipped)
				DashAnimation(PlayerRequired, GunEquipped)
				ReloadAnimation(PlayerRequired, GunEquipped)
				ChargeAnimation(PlayerRequired, GunEquipped)
				ShootAnimation(PlayerRequired, GunEquipped)
				Flag = GunEquipped
			end
		end)

	-- CLEANUP ON DEATH
	Connections[PlayerRequired]["CleanClientData"] = PlayerRequired.CharacterRemoving:Connect(function()
		ClientGunDataModule:Clean(PlayerRequired)
		if Connections[PlayerRequired]["GeneralEquippedGun"] then
			Connections[PlayerRequired]["GeneralEquippedGun"]:Disconnect()
			Connections[PlayerRequired]["GeneralEquippedGun"] = nil
		end

		if Connections[PlayerRequired]["CleanClientData"] then
			Connections[PlayerRequired]["CleanClientData"]:Disconnect()
			Connections[PlayerRequired]["CleanClientData"] = nil
		end
	end)
end

-- RECIEVE SIGNAL TO LOAD DEFAULT ANIMATIONS FOR SPECIFIC CHARACTER
local function OnPlayerAdded(Player)
	ClientUtilities.BindToCharacter(Player, StartGunAnimations)
end
-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(OnPlayerAdded)
