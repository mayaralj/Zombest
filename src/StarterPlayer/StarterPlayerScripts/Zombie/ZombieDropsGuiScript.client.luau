-- SERVICES
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ZombieDropsGuiFolder = PlayerGui:WaitForChild("ZombieDropsGuiFolder")
local ZombieDropsGui = ZombieDropsGuiFolder:WaitForChild("ZombieDropsGui")
local MainFrame = ZombieDropsGui:WaitForChild("MainFrame")

-- TEMPLATES
local Templates = ZombieDropsGui:WaitForChild("Templates")
local BonusPoints = Templates:WaitForChild("BonusPoints")
local DoublePoints = Templates:WaitForChild("DoublePoints")
local InstaKill = Templates:WaitForChild("InstaKill")
local MaxAmmo = Templates:WaitForChild("MaxAmmo")

-- ON PLAYER ATTRIBUTE CHANGED
LocalPlayer:GetAttributeChangedSignal("InstaKill"):Connect(function()
	-- CHECK IF ALREADY EXISTS
	local Existing = MainFrame:FindFirstChild("InstaKill")
	if Existing then
		return
	end
	if LocalPlayer:GetAttribute("InstaKill") then
		local Clone = InstaKill:Clone()
		Clone.Name = "InstaKill"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("InstaKill")
		Clone:Destroy()
	end
end)

LocalPlayer:GetAttributeChangedSignal("DoublePoints"):Connect(function()
	-- CHECK FOR EXISTING
	local Existing = MainFrame:FindFirstChild("DoublePoints")
	if Existing then
		return
	end
	if LocalPlayer:GetAttribute("DoublePoints") then
		local Clone = DoublePoints:Clone()
		Clone.Name = "DoublePoints"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("DoublePoints")
		Clone:Destroy()
	end
end)

LocalPlayer:GetAttributeChangedSignal("MaxAmmo"):Connect(function()
	-- CHECK FOR EXISTING
	local Existing = MainFrame:FindFirstChild("MaxAmmo")
	if Existing then
		return
	end
	if LocalPlayer:GetAttribute("MaxAmmo") then
		local Clone = MaxAmmo:Clone()
		Clone.Name = "MaxAmmo"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("MaxAmmo")
		Clone:Destroy()
	end
end)

LocalPlayer:GetAttributeChangedSignal("BonusPoints"):Connect(function()
	-- CHECK FOR EXISTING
	local Existing = MainFrame:FindFirstChild("BonusPoints")
	if Existing then
		return
	end
	if LocalPlayer:GetAttribute("BonusPoints") then
		local Clone = BonusPoints:Clone()
		Clone.Name = "BonusPoints"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("BonusPoints")
		Clone:Destroy()
	end
end)
