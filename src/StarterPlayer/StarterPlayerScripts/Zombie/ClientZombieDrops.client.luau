-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- EVENTS
local ZombieDropEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZombieDropEvents")
local PlayDropSFX = ZombieDropEvents:WaitForChild("PlayDropSFX")

-- FOLDERS
local ZombieDropSFX = ReplicatedStorage:WaitForChild("ZombieDropSFX")
local ZombieDropVFX = ReplicatedStorage:WaitForChild("ZombieDropVFX")

-- VFX
local PickupVFX = ZombieDropVFX:WaitForChild("PickupVFX")

-- SFX
local MaxAmmoSFX = ZombieDropSFX:WaitForChild("MaxAmmo")
local InstaKillSFX = ZombieDropSFX:WaitForChild("InstaKill")
local DoublePointsSFX = ZombieDropSFX:WaitForChild("DoublePoints")
local BonusPointsSFX = ZombieDropSFX:WaitForChild("BonusPoints")

-- HELPER TO PLAY PICKUP VFX
local function PlayPickupVFX(Character)
	-- CREATE PLAYER HIGHLIGHT
	local Highlight = Instance.new("Highlight")
	Highlight.FillColor = Color3.fromRGB(121, 255, 159)
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 1
	Highlight.Parent = Character
	-- TWEEN HIGHLIGHT
	local HighlightTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local HighlightTween = TweenService:Create(Highlight, HighlightTweenInfo, { FillTransparency = 1 })
	HighlightTween:Play()
	Debris:AddItem(Highlight, 1)

	-- CLONE VFX
	local ClonedVFX = PickupVFX:Clone()
	ClonedVFX.Parent = Character
	for _, Part in ClonedVFX:GetDescendants() do
		if Part:IsA("ParticleEmitter") then
			Part:Emit(Part.Rate)
		end
	end
	Debris:AddItem(ClonedVFX, 2)
end

-- PLAY SFX ON CLIENT EVENT
PlayDropSFX.OnClientEvent:Connect(function(DropType, Character)
	-- PLAY VFX
	PlayPickupVFX(Character)

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
