local PlaySFX = {}

-- SERVICES
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- MODULES
local ObjectPoolFW = require(
	ReplicatedStorage:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("ObjectPool")
		:WaitForChild("ObjectPoolFW")
)

-- DEFAULT SFX PART
local SFXPart = Instance.new("Part")
SFXPart.Anchored = true
SFXPart.CanCollide = false
SFXPart.Transparency = 1
SFXPart.Size = Vector3.new(0.01, 0.01, 0.01)
SFXPart.Parent = workspace
SFXPart.Name = "SFXPart"

-- CREATE AN OBJECT POOL
ObjectPoolFW.Create(SFXPart, 2000)

-- TWEEN SOUND
local function FadeSound(Sound, FadeTime)
	local OriginalVolume = Sound.Volume
	local TweenInfo = TweenInfo.new(FadeTime, Enum.EasingStyle.Quad)
	local Tween = TweenService:Create(Sound, TweenInfo, { Volume = 0 })

	Tween:Play()
	Tween.Completed:Wait()
	Tween:Destroy()
end

-- CLEANUP SFX
local PartSFX = {}
function PlaySFX.DestroySFX(Player, ID, FadeTime)
	if PartSFX[Player] and PartSFX[Player][ID] then
		local SFXInPart = PartSFX[Player][ID]:FindFirstChild("Sound")
		if SFXInPart then
			if FadeTime then
				FadeSound(SFXInPart, FadeTime)
			end
			SFXInPart.Looped = false
			SFXInPart:Stop()
			SFXInPart:Destroy()
		end
		-- RETURN TO POOL
		ObjectPoolFW.Return(PartSFX[Player][ID])
		PartSFX[Player][ID] = nil
	end
end

-- FUNCTION TO CREATE PART AND PLAY SFX ON THAT PART AT SPECIFIC POS
local ActiveSFX = workspace:FindFirstChild("ActiveSFX")
function PlaySFX.PlayPartSFX(Player, Position, ID, SFXData)
	local ForceNew = SFXData.ForceNew
	local SFXToClone = SFXData.SFXToClone

	if not PartSFX[Player] then
		PartSFX[Player] = {}
	end

	if PartSFX[Player][ID] and not ForceNew then
		PartSFX[Player][ID].Position = Position
		local SFXInPart = PartSFX[Player][ID]:FindFirstChild("Sound")
		if not SFXInPart then
			return
		end
		if not SFXInPart.IsPlaying then
			SFXInPart:Play()
		end
		return
	end

	-- NEW PART FOR SOUND
	local NewPart = ObjectPoolFW.Get(SFXPart)
	NewPart.Position = Position

	local SFX = SFXToClone:Clone()
	SFX.Parent = NewPart
	SFX.Name = "Sound"
	SFX.Volume = SFXData.Volume or 1
	SFX.PlaybackSpeed = SFXData.PlaybackSpeed or 1
	SFX.Looped = SFXData.Looped or false
	if SFXData.PlaybackRegion then
		SFX.PlaybackRegionsEnabled = true
		SFX.PlaybackRegion = SFXData.PlaybackRegion
	end
	SFX:Play()
	PartSFX[Player][ID] = NewPart

	if SFXData.CleanupTime then
		task.delay(SFXData.CleanupTime, function()
			PlaySFX.DestroySFX(Player, ID)
		end)
	end
end

-- RETURN
return PlaySFX
