-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ZombieDropsGui = PlayerGui:WaitForChild("ZombieDropsGui")
local MainFrame = ZombieDropsGui:WaitForChild("MainFrame")

-- TEMPLATES
local Templates = ZombieDropsGui:WaitForChild("Templates")
local BonusPoints = Templates:WaitForChild("BonusPoints")
local DoublePoints = Templates:WaitForChild("DoublePoints")
local InstaKill = Templates:WaitForChild("InstaKill")
local MaxAmmo = Templates:WaitForChild("MaxAmmo")

-- ON PLAYER ATTRIBUTE CHANGED
LocalPlayer:GetAttributeChangedSignal("InstaKill"):Connect(function()
	if LocalPlayer:GetAttribute("InstaKill") then
		-- CHECK IF ALREADY EXISTS
		local Existing = MainFrame:FindFirstChild("InstaKill")
		if Existing then
			return
		end
		local Clone = InstaKill:Clone()
		Clone.Name = "InstaKill"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("InstaKill")
		if Clone then
			Clone:Destroy()
		end
	end
end)

LocalPlayer:GetAttributeChangedSignal("DoublePoints"):Connect(function()
	if LocalPlayer:GetAttribute("DoublePoints") then
		-- CHECK FOR EXISTING
		local Existing = MainFrame:FindFirstChild("DoublePoints")
		if Existing then
			return
		end
		local Clone = DoublePoints:Clone()
		Clone.Name = "DoublePoints"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("DoublePoints")
		if Clone then
			Clone:Destroy()
		end
	end
end)

LocalPlayer:GetAttributeChangedSignal("MaxAmmo"):Connect(function()
	if LocalPlayer:GetAttribute("MaxAmmo") then
		-- CHECK FOR EXISTING
		local Existing = MainFrame:FindFirstChild("MaxAmmo")
		if Existing then
			return
		end
		local Clone = MaxAmmo:Clone()
		Clone.Name = "MaxAmmo"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("MaxAmmo")
		if Clone then
			Clone:Destroy()
		end
	end
end)

LocalPlayer:GetAttributeChangedSignal("BonusPoints"):Connect(function()
	if LocalPlayer:GetAttribute("BonusPoints") then
		-- CHECK FOR EXISTING
		local Existing = MainFrame:FindFirstChild("BonusPoints")
		if Existing then
			return
		end
		local Clone = BonusPoints:Clone()
		Clone.Name = "BonusPoints"
		Clone.Parent = MainFrame
		Clone.Visible = true
	else
		local Clone = MainFrame:FindFirstChild("BonusPoints")
		if Clone then
			Clone:Destroy()
		end
	end
end)
