-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local PerGunAssets = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("PerGunAssets")

-- MODULES
local ClientGunDataModule = require(ClientData:WaitForChild("ClientGunData"))
local ClientUtilities =
	require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local DetermineAssets = require(PerGunAssets:WaitForChild("DetermineAssets"))

-- EVENTS

-- GUN ASSETS FOLDER AND EVENTS
local GunAssetsEvents = Events:WaitForChild("GunAssetsEvents")
local ZombieHitVFX = GunAssetsEvents:WaitForChild("ZombieHitVFX")
local WallFX = GunAssetsEvents:WaitForChild("WallFX")

-- HELPER TO PLAY ASSETS
local function PlayAssets(AssetsFunction, PlayerRequired, EquippedGun)
	local DefaultData
	local Count = 0
	repeat
		DefaultData = ClientGunDataModule:Get(PlayerRequired)
		Count += 1
		if not DefaultData then
			warn("No default data for player, waiting: " .. PlayerRequired.Name)
			task.wait(0.1)
		end
	until DefaultData or Count == 10
	if not DefaultData then
		return
	end

	-- PLAY ASSETS
	local SuccessfulAssets
	local Cancelled = false
	pcall(function()
		Count = 0
		repeat
			if PlayerRequired:GetAttribute("IsEquippingGun") ~= EquippedGun then
				Cancelled = true
				return
			end
			SuccessfulAssets = AssetsFunction(LocalPlayer, DefaultData, EquippedGun, PlayerRequired)

			Count += 1
			if not SuccessfulAssets then
				warn("Unsucessful assets load")
				task.wait(0.1)
			end
		until SuccessfulAssets or Count == 100 or Cancelled
	end)
end

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
	PlayAssets(EquipAssets.Equip, PlayerEquipped, EquippedGun)
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

	PlayAssets(IdleAssets.Idle, PlayerEquipped, EquippedGun)
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
	PlayAssets(MovementAssets.Movement, PlayerRequired, EquippedGun)
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
	PlayAssets(ShootAssets.Shoot, PlayerFired, EquippedGun)
end

-- RELOAD ASSETS
local function ReloadAnimation(PlayerReloading, EquippedGun)
	if not PlayerReloading or not EquippedGun then
		return
	end
	local ReloadAssets = DetermineAssets.DetermineAssets(EquippedGun)
	if not ReloadAssets then
		return
	end
	PlayAssets(ReloadAssets.Reload, PlayerReloading, EquippedGun)
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
	PlayAssets(ChargeAssets.Charge, PlayerCharging, EquippedGun)
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
	PlayAssets(DashAssets.Dash, PlayerDashing, EquippedGun)
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
	PlayAssets(GunAssets.GunUI, PlayerFired, EquippedGun)
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
local function StartGunAnimations(PlayerRequired)
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
	if Connections[PlayerRequired]["GeneralEquippedGun"] then
		Connections[PlayerRequired]["GeneralEquippedGun"]:Disconnect()
		Connections[PlayerRequired]["GeneralEquippedGun"] = nil
	end

	if Connections[PlayerRequired]["CleanClientData"] then
		Connections[PlayerRequired]["CleanClientData"]:Disconnect()
		Connections[PlayerRequired]["CleanClientData"] = nil
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
	local LastCharacter = nil
	if Player.Character then
		task.defer(StartGunAnimations, Player)
		LastCharacter = Player.Character
	end
	Player.CharacterAdded:Connect(function()
		if not Player.Character then
			return
		end
		-- PREVENT DUPLICATE CONNECTIONS
		if Player.Character == LastCharacter then
			LastCharacter = Player.Character
			return
		end
		task.defer(StartGunAnimations, Player)
	end)
end
-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(function(Player)
	OnPlayerAdded(Player)
end)
