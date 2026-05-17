-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")

-- MODULES
local PlayerData = require(ModuleScripts:FindFirstChild("Data"):FindFirstChild("PlayerData"))
local GunFW = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Gun"):WaitForChild("GunFW"))

-- EVENTS
local PromptEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PromptEvents")
local GiveGunPrompt = PromptEvents:WaitForChild("GiveGunPrompt")

-- ON SERVER EVENT FOR GIVE GUN
GiveGunPrompt.OnServerEvent:Connect(function(Player, Part)
	-- CHARACTER AND ROOT
	local Character = Player.Character
	if not Character then
		return
	end
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	if not RootPart then
		return
	end
	local Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid then
		return
	end

	-- CURRENT PLAYER DATA
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		return
	end

	-- IF TOO FAR THEN RETURN (SECURITY CHECK)
	if (RootPart.Position - Part.Position).Magnitude > 20 then
		return
	end

	-- YOUSIF SPEC
	local EquippingGun = Player:GetAttribute("IsEquippingGun")
	if
		Part.Name == "LightningFist"
		and Player.Name ~= "yousif86"
		and Player.Name ~= "V0TEDS"
		and (EquippingGun and EquippingGun ~= Part.Name)
	then
		-- KNOCK PLAYER
		Humanoid.Health = 0
		return
	end

	-- IF SAME GUN, REFILL AMMO WITH HALF COST
	if Player:GetAttribute("IsEquippingGun") and Player:GetAttribute("IsEquippingGun") == Part.Name then
		-- END IF STREAM
		if Player:GetAttribute("BulletType") == "Stream" then
			return
		end

		-- DETERMINE IF ENOUGH POINTS
		local HalfCost = Part:FindFirstChild("Cost") and Part:FindFirstChild("Cost").Value / 2 or 0
		if CurrentPlayerData.Points.CurrentPoints < HalfCost then
			return
		end

		-- REFILL AMMO
		local Success = GunFW.RefillAmmo(Player)
		if not Success then
			return
		end

		-- UPDATE POINTS
		CurrentPlayerData.Points.CurrentPoints -= HalfCost
		Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
		return
	end

	-- DETERMINE IF ENOUGH POINTS TO BUY
	local AlreadyHasGun = false
	if Part:FindFirstChild("Cost") then
		-- CHECK IF ENOUGH POINTS
		if not CurrentPlayerData.Points.CurrentPoints then
			return
		end

		-- FIND IF ALREADY HAS GUN
		for _, Gun in pairs(CurrentPlayerData.WeaponSlots) do
			if Gun == Part.Name then
				AlreadyHasGun = true
				break
			end
		end

		-- IF NOT ENOUGH POINTS AND NOT ALREADY HAS GUN
		if not AlreadyHasGun and CurrentPlayerData.Points.CurrentPoints < Part:FindFirstChild("Cost").Value then
			return
		end
	end

	-- GIVE THE GUN
	local SuccessfulGunEquip = GunFW.GiveWeapon(Player, Part.Name, true)

	-- ONLY UPDATE COST IF SUCCESSFUL PURCHASE
	if SuccessfulGunEquip and not AlreadyHasGun and Part:FindFirstChild("Cost") then
		CurrentPlayerData.Points.CurrentPoints -= Part:FindFirstChild("Cost").Value
		Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
	end
end)
