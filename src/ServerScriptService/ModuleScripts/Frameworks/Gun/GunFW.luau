local GunFW = {}

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunModels = ReplicatedStorage:WaitForChild("GunModels")
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local ServerData = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")

-- MODULES
local PlayerData = require(ServerData:WaitForChild("PlayerData"))
local GunData = require(ServerData:WaitForChild("GunData"))

-- EVENTS
local CreateClientGun = Events:WaitForChild("DataEvents"):WaitForChild("CreateClientGun")
local RemoveClientGun = Events:WaitForChild("DataEvents"):WaitForChild("RemoveClientGun")

-- TABLES
local KnockedAttribute = {}
local DeathConnection = {}

-- HELPER TO RESET GUN STATES
local function ResetGunStates(PlayerToReset)
	PlayerToReset:SetAttribute("IsShooting", false)
	PlayerToReset:SetAttribute("IsReloading", false)
	PlayerToReset:SetAttribute("IsCharging", false)
	PlayerToReset:SetAttribute("InWindup", false)
	PlayerToReset:SetAttribute("ShotFired", false)
	PlayerToReset:SetAttribute("WantsToCharge", false)
	PlayerToReset:SetAttribute("WantsToReload", false)
end

-- HELPER TO RESET GUN ATTRIBUTES FOR CLEANUP
local function ResetGunAttributes(PlayerToReset)
	PlayerToReset:SetAttribute("IsShooting", false)
	PlayerToReset:SetAttribute("IsReloading", false)
	PlayerToReset:SetAttribute("IsCharging", false)
	PlayerToReset:SetAttribute("InWindup", false)
	PlayerToReset:SetAttribute("EquippedGun", nil)
	PlayerToReset:SetAttribute("IsEquippingGun", nil)
	PlayerToReset:SetAttribute("IsEquipping", false)
	PlayerToReset:SetAttribute("ShotFired", false)
	PlayerToReset:SetAttribute("WantsToCharge", false)
	PlayerToReset:SetAttribute("WantsToReload", false)
end

-- INITIAL ATTRIBUTE
local function SetAttributes(Data, PlayerToSet)
	-- SET ATTRIBUTES NEEDED (MOST FOR GUI)
	PlayerToSet:SetAttribute("BulletType", Data.About.BulletType)
	if Data.About.BulletType == "Stream" then
		PlayerToSet:SetAttribute("CurrentCharge", Data.Charge.CurrentCharge)
	else
		if Data.Ammo.AmmoPerReload then
			PlayerToSet:SetAttribute("CurrentAmmo", Data.Ammo.CurrentAmmo / Data.Ammo.AmmoPerReload)
			PlayerToSet:SetAttribute("TotalAmmo", Data.Ammo.TotalAmmo / Data.Ammo.AmmoPerReload)
		else
			PlayerToSet:SetAttribute("CurrentAmmo", Data.Ammo.CurrentAmmo)
			PlayerToSet:SetAttribute("TotalAmmo", Data.Ammo.TotalAmmo)
		end
	end
end

-- RIGHT ARM GRIP POSITION
local function RightArmWeld(Character, GunClone, GripLocation)
	local Grip = Character:FindFirstChild(GripLocation)
	if Grip and GunClone:IsA("Model") and GunClone.PrimaryPart then
		GunClone.Parent = Character
		for _, Part in ipairs(GunClone:GetDescendants()) do
			if Part:IsA("BasePart") and Part ~= GunClone.PrimaryPart then
				local Weld = Instance.new("Weld")
				Weld.Part0 = GunClone.PrimaryPart
				Weld.Part1 = Part

				-- CALCULATE OFFSET
				Weld.C0 = GunClone.PrimaryPart.CFrame:ToObjectSpace(Part.CFrame)

				Weld.Parent = Part
				Part.Anchored = false
				Part.CanCollide = false
				Part.Massless = true
			end
		end
		-- CREATE WELD BETWEEN GRIP AND HANDLE
		local ArmWeld = Instance.new("Weld")
		ArmWeld.Part0 = Grip
		ArmWeld.Part1 = GunClone.PrimaryPart
		ArmWeld.C0 = CFrame.new(0, -1.1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90))
		ArmWeld.C1 = CFrame.new()

		ArmWeld.Parent = GunClone.PrimaryPart
		GunClone.PrimaryPart.Anchored = false
		GunClone.PrimaryPart.Massless = true
		GunClone.PrimaryPart.CanCollide = false
	end
end

-- HEAD GRIP POSITION
local function HeadWeld(Character, GunClone, GripLocation)
	local Player = Players:GetPlayerFromCharacter(Character)
	Player:SetAttribute("IsWelding", true)
	task.wait(0.15)
	local Grip = Character:FindFirstChild(GripLocation)
	if Grip and GunClone:IsA("Model") and GunClone.PrimaryPart then
		GunClone.Parent = Character
		for _, Part in ipairs(GunClone:GetDescendants()) do
			if Part:IsA("BasePart") and Part ~= GunClone.PrimaryPart then
				local Weld = Instance.new("Weld")
				Weld.Part0 = GunClone.PrimaryPart
				Weld.Part1 = Part

				-- CALCULATE OFFSET
				Weld.C0 = GunClone.PrimaryPart.CFrame:ToObjectSpace(Part.CFrame)

				Weld.Parent = Part
				Part.Anchored = false
				Part.CanCollide = false
				Part.Massless = true
			end
		end
		-- CREATE WELD BETWEEN GRIP AND HANDLE
		local ArmWeld = Instance.new("Weld")
		ArmWeld.Part0 = Grip
		ArmWeld.Part1 = GunClone.PrimaryPart
		ArmWeld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(7), math.rad(0), math.rad(0))
		ArmWeld.C1 = CFrame.new()

		ArmWeld.Parent = GunClone.PrimaryPart
		GunClone.PrimaryPart.Anchored = false
		GunClone.PrimaryPart.Massless = true
		GunClone.PrimaryPart.CanCollide = false
	end
	Player:SetAttribute("IsWelding", false)
end

-- DETERMINE GRIP POSITION
local function DetermineWeld(Character, GunClone, GripLocation)
	if GripLocation == "Right Arm" then
		RightArmWeld(Character, GunClone, GripLocation)
	elseif GripLocation == "Head" then
		HeadWeld(Character, GunClone, GripLocation)
	end
end

-- GIVE KNOCKED GUN TO PLAYER
local function GiveKnockedGun(Player, WeaponName)
	-- SKIP IF NO GUN TO START
	if not Player:GetAttribute("IsEquippingGun") and not Player:GetAttribute("IsEquipping") then
		return
	end
	if Player:GetAttribute("IsEquippingGun") == WeaponName then
		return
	end

	-- CHARACTER
	local Character = Player.Character
	if not Character then
		return
	end

	-- RESET GUN STATES
	ResetGunStates(Player)
	RemoveClientGun:FireAllClients(Player)

	-- GET DATA
	local Data = GunData:Get(Player, WeaponName)
	if not Data then
		return
	end

	-- ATTRIBUTES

	-- DESTROY OTHER EQUIPPED GUN
	local CurrentEquippedGun = Player.Character:FindFirstChild("EquippedGun")
	if CurrentEquippedGun then
		CurrentEquippedGun:Destroy()
	end

	-- GUN MODEL NEEDED
	local GunModel = GunModels:FindFirstChild(Data.About.Model)
	if not GunModel then
		return
	end

	-- CLONE MODEL
	local GunClone = GunModel:Clone()
	GunClone.Name = "EquippedGun"
	GunClone.Parent = Character

	local Muzzle = GunClone:FindFirstChild("Muzzle")
	if not Muzzle then
		return
	end
	Muzzle.Transparency = 1

	-- GIVE A THIRD OF GUNS TOTAL AMMO
	Data.Ammo.TotalAmmo = math.floor(GunData.DefaultData[WeaponName].Ammo.TotalAmmo / 3)
	-- RESET AMMO
	Data.Ammo.CurrentAmmo = Data.Ammo.MaxAmmo

	-- SET EQUIPPING ATTRIBUTES
	SetAttributes(Data, Player)
	Player:SetAttribute("IsEquippingGun", WeaponName)
	Player:SetAttribute("IsEquipping", true)

	-- DETERMINE GRIP
	local GripLocation = Data.About.Location or "Right Arm"
	DetermineWeld(Character, GunClone, GripLocation)

	-- EQUIP TIME CHECKS
	task.delay(0.5, function()
		Player:SetAttribute("IsEquipping", false)
		Player:SetAttribute("EquippedGun", WeaponName)
	end)

	return true
end

-- EQUIP AND WELD WEAPON TO CHARACTER
local function EquipAndWeld(Player, WeaponName, CreateData)
	-- SOME CHECKS WHEN NOT KNOCKED
	if not Player:GetAttribute("IsKnocked") then
		if Player:GetAttribute("IsEquipping") then
			return
		end
		if Player:GetAttribute("IsEquippingGun") == WeaponName then
			return
		end
	else
		-- KNOCKED GUN
		return GiveKnockedGun(Player, WeaponName)
	end

	-- CHARACTER
	local Character = Player.Character
	if not Character then
		return
	end

	-- FIND WHICH SLOT TO PUT THIS GUN IN
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		return
	end
	local WeaponSlotData = CurrentPlayerData.WeaponSlots
	if not WeaponSlotData then
		return
	end

	-- DETERMINE IF THERE ARE ANY SLOTS AVAILABLE
	local NoSlotAvailable = true
	for i, WeaponStoredName in WeaponSlotData do
		-- ONLY 2 SLOTS ALLOWED
		if i > 2 then
			NoSlotAvailable = true
			break
		end

		if WeaponStoredName == WeaponName then
			Player:SetAttribute("CurrentGunIndex", i)
			NoSlotAvailable = false
			CreateData = false -- ensure no data creation if weapon exists
			break
		end
		if WeaponStoredName == "Empty" then
			NoSlotAvailable = false
			break
		end
	end
	if NoSlotAvailable and not CreateData then
		return
	end

	-- RESET GUN STATES
	ResetGunStates(Player)

	-- IF REPLACING GUN ENSURE GUN IS REMOVED BEFORE CREATING NEW DATA (CONFLICTS WITH CLIENT DATA)
	if NoSlotAvailable and CreateData then
		GunFW.RemoveWeapon(Player)
	end

	-- CREATE OR GET DATA
	local Data
	if CreateData then
		Data = GunData:CreateData(Player, WeaponName)
	else
		Data = GunData:Get(Player, WeaponName)
	end
	if not Data then
		return
	end

	-- FIRE TO ALL CURRENT CLIENTS TO CREATE CLIENTGUNDATA
	CreateClientGun:FireAllClients(Player, WeaponName)

	-- DESTROY OTHER EQUIPPED GUN
	local CurrentEquippedGun = Player.Character:FindFirstChild("EquippedGun")
	if CurrentEquippedGun then
		CurrentEquippedGun:Destroy()
	end

	-- GUN MODEL NEEDED
	local GunModel = GunModels:FindFirstChild(Data.About.Model)
	if not GunModel then
		return
	end

	-- LOOP THROUGH AVAILABLE SLOTS AND FIND CORRECT
	if CreateData and not NoSlotAvailable then
		for i, WeaponStoredName in WeaponSlotData do
			if WeaponStoredName == "Empty" then
				WeaponSlotData[i] = WeaponName
				Player:SetAttribute("CurrentGunIndex", i)
				break
			end
		end
	end

	-- REPLACE GUN IF FORCE CREATE DATA AND NO SLOT
	if NoSlotAvailable and CreateData then
		for i, WeaponStoredName in WeaponSlotData do
			if i == Player:GetAttribute("CurrentGunIndex") then
				WeaponSlotData[i] = WeaponName
				Player:SetAttribute("CurrentGunIndex", i)
				break
			end
		end
	end

	-- CHECK IF WE HAVE A STORED MODEL FOR THIS WEAPON
	local GunClone = GunModel:Clone()
	GunClone.Name = "EquippedGun"
	GunClone.Parent = Character

	local Muzzle = GunClone:FindFirstChild("Muzzle")
	if not Muzzle then
		return
	end
	Muzzle.Transparency = 1

	-- SET EQUIPPING ATTRIBUTES
	SetAttributes(Data, Player)
	Player:SetAttribute("IsEquippingGun", WeaponName)
	Player:SetAttribute("IsEquipping", true)

	-- DETERMINE GRIP
	local GripLocation = Data.About.Location or "Right Arm"
	DetermineWeld(Character, GunClone, GripLocation)

	-- EQUIP TIME CHECKS
	local EquipTime
	if not Player:GetAttribute("IsRevived") then
		EquipTime = Data.About.EquipTime
	else
		EquipTime = 0.75
	end
	task.delay(EquipTime, function()
		Player:SetAttribute("IsEquipping", false)
		if Player:GetAttribute("IsKnocked") then
			return
		end
		Player:SetAttribute("EquippedGun", WeaponName)
	end)

	-- TO INDICATE SUCCESSFULLY GUN EQUIP
	return true
end

-- CLEANUP FUNCTION
local function CleanupPlayerWeapon(Player)
	local Character = Player.Character
	local EquippedGun = Character and Character:FindFirstChild("EquippedGun")
	if EquippedGun then
		EquippedGun:Destroy()
	end
end

-- REMOVE CURRENT WEAPON
local function UnequipAndDestroy(PlayerToRemove)
	local CurrentPlayerData = PlayerData:Get(PlayerToRemove)
	if not CurrentPlayerData then
		return
	end

	local CurrentGun = PlayerToRemove:GetAttribute("EquippedGun")
	if not CurrentGun then
		return
	end

	-- REMOVE FROM SLOT
	for i, WeaponName in CurrentPlayerData.WeaponSlots do
		if WeaponName == CurrentGun then
			CurrentPlayerData.WeaponSlots[i] = "Empty"
		end
	end

	-- FIRE TO ALL CURRENT CLIENTS TO REMOVE CLIENTGUNDATA
	RemoveClientGun:FireAllClients(PlayerToRemove)

	-- REMOVE DATA
	GunData:Remove(PlayerToRemove)

	-- DELETE GUN AND SET ATTRIBUTES
	ResetGunAttributes(PlayerToRemove)
	CleanupPlayerWeapon(PlayerToRemove)
end

-- REFILL AMMO
function GunFW.RefillAmmo(Player)
	-- DONT ALLOW IF DEAD
	local Humanoid = Player.Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	if Humanoid.Health <= 0 then
		return
	end

	-- DONT ALLOW IF KNOCKED
	if Player:GetAttribute("IsKnocked") then
		return
	end

	-- GUN AND DATA
	local CurrentGun = Player:GetAttribute("EquippedGun")
	if not CurrentGun then
		return
	end

	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then
		return
	end
	if
		not CurrentGunData.Ammo
		or not CurrentGunData.Ammo.CurrentAmmo
		or not CurrentGunData.Ammo.MaxAmmo
		or not CurrentGunData.Ammo.TotalAmmo
	then
		return
	end

	-- IF ALREADY AT MAX AMMO
	if
		CurrentGunData.Ammo.CurrentAmmo == CurrentGunData.Ammo.MaxAmmo
		and CurrentGunData.Ammo.TotalAmmo == CurrentGunData.Ammo.MaxTotalAmmo
	then
		return
	end

	-- REFILL AMMO
	CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo
	CurrentGunData.Ammo.TotalAmmo = CurrentGunData.Ammo.MaxTotalAmmo

	-- UPDATE ATTRIBUTES
	if CurrentGunData.Ammo.AmmoPerReload then
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / CurrentGunData.Ammo.AmmoPerReload)
		Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo / CurrentGunData.Ammo.AmmoPerReload)
	else
		Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo)
		Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo)
	end

	return true
end

-- GIVE MAX AMMO TO BOTH PLAYER GUNS
function GunFW.MaxAmmo(Player)
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		return
	end

	for _, WeaponName in ipairs(CurrentPlayerData.WeaponSlots) do
		local CurrentGunData = GunData:Get(Player, WeaponName)
		if not CurrentGunData then
			continue
		end
		if
			not CurrentGunData.Ammo
			or not CurrentGunData.Ammo.CurrentAmmo
			or not CurrentGunData.Ammo.MaxAmmo
			or not CurrentGunData.Ammo.TotalAmmo
		then
			continue
		end
		CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo
		CurrentGunData.Ammo.TotalAmmo = CurrentGunData.Ammo.MaxTotalAmmo

		-- UPDATE ATTRIBUTES IF CURRENT GUN
		if WeaponName ~= Player:GetAttribute("IsEquippingGun") then
			continue
		end

		if CurrentGunData.Ammo.AmmoPerReload then
			Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo / CurrentGunData.Ammo.AmmoPerReload)
			Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo / CurrentGunData.Ammo.AmmoPerReload)
		else
			Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo)
			Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo)
		end
	end
end

-- HELPER TO FIND GUN NAME EVEN IF UNMATCHED CASE OR PARTIAL MATCH
local function GetGunName(GunName)
	if not GunName then
		return "Pistol"
	end
	local LowerGunName = string.lower(GunName)
	local ExactMatch = nil
	local PartialMatch = nil
	for _, Weapon in pairs(GunData.DefaultData) do
		local LowerWeaponName = string.lower(Weapon.About.Name)
		if LowerWeaponName == LowerGunName then
			ExactMatch = Weapon.About.Name
			break
		elseif string.find(LowerWeaponName, LowerGunName) then
			PartialMatch = Weapon.About.Name
		end
	end
	return ExactMatch or PartialMatch
end

-- GIVE PLAYER A WEAPON WITH CORRECT MODIFICATIONS AND STATS
local PreviousAmmo = {}
function GunFW.GiveWeapon(Player, WeaponName, CreateData)
	-- GET GUN NAME (allow for case insensitive and partial matching)
	WeaponName = GetGunName(WeaponName)
	-- DONT ALLOW IF DEAD
	local Character = Player.Character
	if not Character then
		return
	end
	local Humanoid = Player.Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	if Humanoid.Health <= 0 and not Player:GetAttribute("IsKnocked") then
		return
	end

	-- CURRENT PLAYER DATA
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		return
	end
	local WeaponSlotData = CurrentPlayerData.WeaponSlots

	-- ATTEMPT TO EQUIP GUN
	local SuccessfulEquip = EquipAndWeld(Player, WeaponName, CreateData)

	-- SET KNOCKED SIGNAL
	if not KnockedAttribute[Player] then
		KnockedAttribute[Player] = Player:GetAttributeChangedSignal("IsKnocked"):Connect(function()
			-- ALLOWED KNOCKED GUNS
			local AllowedKnockedGuns = { "Pistol", "RayGun" }
			-- GUNS
			local EquippingGun = Player:GetAttribute("IsEquippingGun")

			-- IF PLAYER IS KNOCKED
			if Player:GetAttribute("IsKnocked") then
				-- CHECK IF ALREADY EQUIPPED A KNOCKED GUN
				if table.find(AllowedKnockedGuns, EquippingGun) and not Player:GetAttribute("IsEquipping") then
					local CurrentGunData = GunData:Get(Player)
					if not CurrentGunData then
						return
					end

					-- STORE PREVIOUS AMMO
					PreviousAmmo[Player] = {
						CurrentAmmo = Player:GetAttribute("CurrentAmmo"),
						TotalAmmo = Player:GetAttribute("TotalAmmo"),
					}

					-- GIVE A THIRD OF GUNS TOTAL AMMO
					CurrentGunData.Ammo.TotalAmmo = math.floor(GunData.DefaultData[EquippingGun].Ammo.TotalAmmo / 3)
					-- RESET AMMO
					CurrentGunData.Ammo.CurrentAmmo = CurrentGunData.Ammo.MaxAmmo

					-- ATTRIBUTES
					SetAttributes(CurrentGunData, Player)

					return
				end

				-- GIVE PISTOL IF NOT ALREADY EQUIPPED A KNOCKED GUN
				GunFW.GiveWeapon(Player, "Pistol")
			else
				GunData.KnockedGunData[Player] = nil
				-- GIVE BACK THEIR WEAPON
				for i, WeaponStoredName in WeaponSlotData do
					if i == Player:GetAttribute("CurrentGunIndex") then
						-- IF WAS WITH KNOCKED GUN
						if table.find(AllowedKnockedGuns, WeaponStoredName) and PreviousAmmo[Player] then
							-- GIVE ORIGINAL AMMO BACK
							local CurrentGunData = GunData:Get(Player)
							if not CurrentGunData then
								continue
							end

							-- STORED AMMO
							local StoredAmmo = PreviousAmmo[Player]
							CurrentGunData.Ammo.CurrentAmmo = StoredAmmo.CurrentAmmo
							CurrentGunData.Ammo.TotalAmmo = StoredAmmo.TotalAmmo

							-- UPDATE ATTRIBUTES
							Player:SetAttribute("CurrentAmmo", CurrentGunData.Ammo.CurrentAmmo)
							Player:SetAttribute("TotalAmmo", CurrentGunData.Ammo.TotalAmmo)
							break
						end

						-- ELSE JUST GIVE NEW GUN
						GunFW.GiveWeapon(Player, WeaponStoredName, false)
						break
					end
				end
				-- RESET PREVIOUS AMMO
				PreviousAmmo[Player] = nil
			end
		end)
	end

	-- RESET ALL ON DEATH
	if not DeathConnection[Player] then
		DeathConnection[Player] = Humanoid.Died:Connect(function()
			ResetGunAttributes(Player)
			ResetGunStates(Player)
			UnequipAndDestroy(Player)
			GunData:Clean(Player)

			-- CLEANUP SLOT DATA
			local NewCurrentPlayerData = PlayerData:Get(Player)
			if NewCurrentPlayerData then
				Player:SetAttribute("CurrentGunIndex", nil)
				local NewWeaponSlotData = NewCurrentPlayerData.WeaponSlots
				if not NewWeaponSlotData then
					return
				end
				for i, WeaponStoredName in WeaponSlotData do
					-- REMOVE DATA
					WeaponSlotData[i] = "Empty"
				end
			end

			-- CLEAN CONNECTIONS
			if KnockedAttribute[Player] then
				KnockedAttribute[Player]:Disconnect()
				KnockedAttribute[Player] = nil
			end
			if DeathConnection[Player] then
				DeathConnection[Player]:Disconnect()
				DeathConnection[Player] = nil
			end
		end)
	end

	-- RETURN IF SUCCESSFUL
	return SuccessfulEquip
end

-- REMOVE WEAPON
function GunFW.RemoveWeapon(Player)
	UnequipAndDestroy(Player)
end

-- RETURN
return GunFW
