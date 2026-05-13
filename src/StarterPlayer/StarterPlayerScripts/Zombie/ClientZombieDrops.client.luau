-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EVENTS
local ZombieDropEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZombieDropEvents")
local PlayDropSFX = ZombieDropEvents:WaitForChild("PlayDropSFX")

-- FOLDERS
local ZombieDropSFX = ReplicatedStorage:WaitForChild("ZombieDropSFX")

-- SFX
local MaxAmmoSFX = ZombieDropSFX:WaitForChild("MaxAmmo")
local InstaKillSFX = ZombieDropSFX:WaitForChild("InstaKill")
local DoublePointsSFX = ZombieDropSFX:WaitForChild("DoublePoints")
local BonusPointsSFX = ZombieDropSFX:WaitForChild("BonusPoints")

-- PLAY SFX ON CLIENT EVENT
PlayDropSFX.OnClientEvent:Connect(function(DropType)
	if DropType == "InstaKill" then
		-- CLONE SFX AND PLAY
		local SFX = InstaKillSFX:Clone()
		SFX.Parent = workspace:FindFirstChild("ActiveSFX")
		SFX:Play()
		SFX.Ended:Once(function()
			SFX:Destroy()
		end)
	elseif DropType == "DoublePoints" then
		local SFX = DoublePointsSFX:Clone()
		SFX.Parent = workspace:FindFirstChild("ActiveSFX")
		SFX:Play()
		SFX.Ended:Once(function()
			SFX:Destroy()
		end)
	elseif DropType == "MaxAmmo" then
		local SFX = MaxAmmoSFX:Clone()
		SFX.Parent = workspace:FindFirstChild("ActiveSFX")
		SFX:Play()
		SFX.Ended:Once(function()
			SFX:Destroy()
		end)
	elseif DropType == "BonusPoints" then
		local SFX = BonusPointsSFX:Clone()
		SFX.Parent = workspace:FindFirstChild("ActiveSFX")
		SFX:Play()
		SFX.Ended:Once(function()
			SFX:Destroy()
		end)
	end
end)
