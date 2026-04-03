local ClientZombieEffects = {}

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local DebrisService = game:GetService("Debris")
local PLayers = game:GetService("Players")
local LocalPlayer = PLayers.LocalPlayer

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- EVENTS

-- MODULES
local ClientZombieData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientZombieData"))

-- CLEANUP BURN
local BurnHighlightTween = {}
local function BurnCleanup(ZombieID, CurrentZombieData, DT)
	-- DONT CLEANUP IF BURNING AND DEAD
	local ClientZombieModel = CurrentZombieData.ModelStuff.Model
	if not ClientZombieModel then
		return
	end

	-- ENSURE TWEEN CLEANED UP
	if BurnHighlightTween[ClientZombieModel] then
		BurnHighlightTween[ClientZombieModel]:Destroy()
		BurnHighlightTween[ClientZombieModel] = nil
	end

	-- GET BURN DATA
	local BurnData = CurrentZombieData.Status.Burn
	if not BurnData then
		return
	end

	-- RESET TIMERS
	BurnData.BurnDamage = 0
	BurnData.TickTime = 0
	BurnData.BurnTime = 0

	-- DESTROY BURN SFX
	if BurnData.SFX then
		BurnData.SFX.Looped = false
		BurnData.SFX:Stop()
		BurnData.SFX:Destroy()
		BurnData.SFX = nil
	end

	-- IF OUTLINE EXISTS
	if BurnData.Outline then
		-- ENSURE SMOOTH END
		local FinalTween = TweenService:Create(BurnData.Outline, TweenInfo.new(0.3), { FillTransparency = 1 })
		FinalTween:Play()

		task.delay(0.2, function()
			if FinalTween then
				FinalTween:Destroy()
				FinalTween = nil
			end

			if BurnData.Outline then
				BurnData.Outline:Destroy()
				BurnData.Outline = nil
			end
		end)
	end

	-- GET RID OF VFX
	if BurnData.BurnVFX then
		BurnData.BurnVFX.Enabled = false
		DebrisService:AddItem(BurnData.BurnVFX, 1)
	end
end

-- BURN EFFECT
local function BurnEffect(ZombieID, CurrentZombieData, DT)
	-- ZOMBIE MODEL
	local ClientZombieModel = CurrentZombieData.ModelStuff.Model
	if not ClientZombieModel then
		return
	end

	-- GET BURN DATA
	local BurnData = CurrentZombieData.Status.Burn
	if not BurnData then
		return
	end

	-- UPDATE TIMERS
	BurnData.BurnTime -= DT
	BurnData.TickTime += DT
	if BurnData.TickTime >= 0.8 then
		BurnData.TickTime = 0

		-- GIVE OUTLINE
		if not BurnData.Outline then
			BurnData.Outline = Instance.new("Highlight")
			BurnData.Outline.OutlineColor = Color3.new(1, 0.25098, 0)
			BurnData.Outline.FillColor = Color3.new(1, 0, 0)
			BurnData.Outline.OutlineTransparency = 1
			BurnData.Outline.FillTransparency = 0.5
			BurnData.Outline.Parent = ClientZombieModel
		end

		-- CLEANUP
		if BurnHighlightTween[ClientZombieModel] then
			BurnHighlightTween[ClientZombieModel]:Destroy()
			BurnHighlightTween[ClientZombieModel] = nil
		end

		-- TWEEN TRANSPARENCY
		BurnData.Outline.FillTransparency = 0.8
		BurnHighlightTween[ClientZombieModel] =
			TweenService:Create(BurnData.Outline, TweenInfo.new(0.35), { FillTransparency = 0.95 })
		BurnHighlightTween[ClientZombieModel]:Play()
	else
		-- END IF NO OUTLINE OR PLAYING
		if not BurnData.Outline then
			return
		end
		if
			BurnHighlightTween[ClientZombieModel]
			and BurnHighlightTween[ClientZombieModel].PlaybackState == Enum.PlaybackState.Playing
		then
			return
		end

		-- CLEANUP
		if BurnHighlightTween[ClientZombieModel] then
			BurnHighlightTween[ClientZombieModel]:Destroy()
			BurnHighlightTween[ClientZombieModel] = nil
		end

		-- PLAY TWEEN BACK
		BurnHighlightTween[ClientZombieModel] =
			TweenService:Create(BurnData.Outline, TweenInfo.new(0.4), { FillTransparency = 1 })
		BurnHighlightTween[ClientZombieModel]:Play()
	end

	-- BURN SFX
	if not BurnData.SFX then
		BurnData.SFX =
			ReplicatedStorage:FindFirstChild("DefaultSFX"):FindFirstChild("Burn"):FindFirstChild("BurnSFX"):Clone()
		BurnData.SFX.Parent = ClientZombieModel.Torso
		BurnData.SFX.Looped = true
		BurnData.SFX.Volume = 0.25
		BurnData.SFX:Play()
	end
end

-- STUN EFFECT
local function StunEffect(ZombieID, Data, DT)
	-- CLIENT ZOMBIE
	local StunData = Data.Effect.Stun

	-- UPDATE STUN TIME
	StunData.StunTime -= DT
end

-- STUN CLEANUP
local function StunCleanup(ZombieID, Data, DT)
	-- CLIENT ZOMBIE
	local StunData = Data.Effect.Stun

	-- UPDATE STUN TIME
	StunData.StunTime = 0
end

-- DETERMINE EFFECT
function ClientZombieEffects.DetermineEffect(ZombieID, CurrentZombieData, DT)
	-- CLIENT ZOMBIE
	local ClientZombieModel = CurrentZombieData.ModelStuff.Model
	if not ClientZombieModel then
		return
	end

	local StatusEffectData = CurrentZombieData.Status
	if not StatusEffectData then
		return
	end

	-- BURN STATUS
	if StatusEffectData.Burn.BurnTime > 0 then
		BurnEffect(ZombieID, CurrentZombieData, DT)
	elseif StatusEffectData.Burn.BurnTime <= 0 then
		BurnCleanup(ZombieID, CurrentZombieData, DT)
	elseif StatusEffectData.Stun.StunTime > 0 then
		StunEffect(ZombieID, CurrentZombieData, DT)
	elseif StatusEffectData.Stun.StunTime <= 0 then
		StunCleanup(ZombieID, CurrentZombieData, DT)
	end
end

-- RETURN
return ClientZombieEffects
