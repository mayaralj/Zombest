-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))

-- UI
local PlayerGui = LocalPlayer.PlayerGui
local GunGui = PlayerGui:WaitForChild("GunGuiFolder"):WaitForChild("GunGui")
local Frame = GunGui:WaitForChild("Frame")
local GunName = Frame:WaitForChild("GunName")
local CurrentAmmo = Frame:WaitForChild("CurrentAmmo")
local TotalAmmo = Frame:WaitForChild("TotalAmmo")

-- CONNECTIONS
local Connections = {}

-- AMMO GUI
local function SetUpAmmoGui()
	if LocalPlayer:GetAttribute("CurrentAmmo") then
		CurrentAmmo.Text = LocalPlayer:GetAttribute("CurrentAmmo")
	end
	if LocalPlayer:GetAttribute("TotalAmmo") then
		TotalAmmo.Text = LocalPlayer:GetAttribute("TotalAmmo")
	end
	Connections["CurrentAmmoChanged"] = LocalPlayer:GetAttributeChangedSignal("CurrentAmmo"):Connect(function()
		local EquippingGun = LocalPlayer:GetAttribute("IsEquippingGun")
		if not EquippingGun then
			return
		end
		CurrentAmmo.Text = LocalPlayer:GetAttribute("CurrentAmmo")
	end)
	Connections["TotalAmmoChanged"] = LocalPlayer:GetAttributeChangedSignal("TotalAmmo"):Connect(function()
		local EquippingGun = LocalPlayer:GetAttribute("IsEquippingGun")
		if not EquippingGun then
			return
		end
		TotalAmmo.Text = LocalPlayer:GetAttribute("TotalAmmo")
	end)
end

-- CHARGE GUI
local function SetUpChargeGui()
	if LocalPlayer:GetAttribute("CurrentCharge") then
		local EquippingGun = LocalPlayer:GetAttribute("IsEquippingGun")
		if not EquippingGun then
			return
		end

		local CurrentCharge = LocalPlayer:GetAttribute("CurrentCharge")
		if CurrentCharge <= 0 then
			CurrentCharge = 0
		end
		CurrentAmmo.Text = CurrentCharge
		TotalAmmo.Text = "%"
	end
	Connections["CurrentChargeChanged"] = LocalPlayer:GetAttributeChangedSignal("CurrentCharge"):Connect(function()
		local EquippingGun = LocalPlayer:GetAttribute("IsEquippingGun")
		if not EquippingGun then
			return
		end

		local CurrentCharge = LocalPlayer:GetAttribute("CurrentCharge")
		if CurrentCharge <= 0 then
			CurrentCharge = 0
		end
		CurrentAmmo.Text = CurrentCharge
		TotalAmmo.Text = "%"
	end)
end

-- GUN GUi
local function SetUpGunGui()
	local EquippingGun = LocalPlayer:GetAttribute("IsEquippingGun")
	if EquippingGun then
		local CurrentGunData
		local Count = 0
		repeat
			CurrentGunData = ClientGunData:Get(LocalPlayer)
			Count += 1
			task.wait()
		until CurrentGunData or Count == 10
		if not CurrentGunData then
			return
		end

		-- SET UP THE AMMO/CHARGE
		GunName.Text = CurrentGunData.About.Name
		if LocalPlayer:GetAttribute("BulletType") == "Regular" then
			--TotalAmmo.Position = UDim2.new(0.752, 0, 0.196, 0)
			SetUpAmmoGui()
		elseif LocalPlayer:GetAttribute("BulletType") == "Stream" then
			--TotalAmmo.Position = UDim2.new(0.725, 0, 0.196, 0)
			SetUpChargeGui()
		end

		-- ENABLE
		GunGui.Enabled = true
	else
		-- DISABLE IF NO GUN
		GunGui.Enabled = false
	end
end

-- SET UP GUI
local function SetUpAllGun()
	-- GUN NAME AND IMAGE
	if LocalPlayer:GetAttribute("IsEquippingGun") then
		SetUpGunGui()
	end
	Connections["GunChanged"] = LocalPlayer:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		SetUpGunGui()
	end)
end
-- SET UP ON FIRST SPAWN
SetUpAllGun()

-- CLEAN UP ALL CONNECTIONS ON DEATH
Humanoid.Died:Connect(function()
	for i, Connection in Connections do
		Connection:Disconnect()
		Connections[i] = nil
	end
end)
