-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")

-- MODULES
local PlayerData = require(ModuleScripts:FindFirstChild("Data"):FindFirstChild("PlayerData"))
local GunFW = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Gun"):WaitForChild("GunFW"))
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))

-- EVENTS
local PromptEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PromptEvents")
local MysteryPrompt = PromptEvents:WaitForChild("MysteryPrompt")

-- FOLDERS
local MysteryBox = workspace:WaitForChild("MysteryBox")
local MysteryBoxModel = MysteryBox:WaitForChild("MysteryBoxModel")
local Top = MysteryBoxModel:WaitForChild("Top")
local NeonBase = MysteryBoxModel:WaitForChild("NeonBase")
local MysteryBoxGuns = MysteryBox:WaitForChild("MysteryBoxGuns")
local MysteryBoxLight = MysteryBoxModel:WaitForChild("Base"):WaitForChild("MysteryBoxLight")

-- COST
local Cost = 2500
-- CD
local OpenCD = 2
-- TOTAL ROLLS TO DISPLAY
local TotalRolls = 20

-- RATES
local ZehahaRate = 90
local Rates = {
	Common = {
		Rarity = 50,
		Weapons = {
			"Rifle",
			"SemiPistol",
			"Silencer",
		},
	},
	Uncommon = {
		Rarity = 24,
		Weapons = {
			"AK47",
			"AR",
			"Deagle",
			"PumpShotgun",
			"TommyGun",
		},
	},
	Rare = {
		Rarity = 10,
		Weapons = {
			"RicochetSniper",
			"BurstAR",
			"SuppressedAR",
			"Uzi",
		},
	},
	Epic = {
		Rarity = 5,
		Weapons = {
			"AA12",
			"TacticalShotgun",
			"Minigun",
			"PhaseSniper",
		},
	},
	Legendary = {
		Rarity = 1,
		Weapons = {
			"RayGun",
			"Scorchrift",
		},
	},
}

-- ENSURE GUN PARTS ANCHORED AND WELDED FOR MYSTERY BOX:
local function AnchorAndWeldParts()
	-- WELD ALL GUN PARTS TOGETHER, ANCHOR AND REMOVE CAST SHADOW
	for _, Gun in pairs(MysteryBoxGuns:GetChildren()) do
		if Gun:IsA("Model") then
			for _, Part in Gun:GetDescendants() do
				if Part:IsA("BasePart") or Part:IsA("MeshPart") then
					Part.Anchored = true
					Part.CastShadow = false
					-- WELD ALL TOGETHER
					local Weld = Instance.new("WeldConstraint")
					Weld.Part0 = Gun.PrimaryPart
					Weld.Part1 = Part
					Weld.Parent = Gun.PrimaryPart
				end
			end
		end
	end
end
AnchorAndWeldParts()

-- GET EXACT GUN CENTER
local function GetModelCenter(Model)
	local CF, Size = Model:GetBoundingBox()
	return CF
end

-- DISPLAY GUN HELPER
local function DisplayGun(GunModel)
	local CurrentPivot = GunModel:GetPivot()
	local BoundingCF = GetModelCenter(GunModel)

	-- POSITION OFFSET FROM PIVOT TO BOUNDING CENTER (NO ROTATION)
	local PivotToBoundingOffset = CFrame.new(CurrentPivot:ToObjectSpace(BoundingCF).Position)

	-- TARGET POSITION ABOVE NEON BASE
	local TargetCF = NeonBase:GetPivot() * CFrame.new(0, 4, 0)

	-- APPLY CENTERING OFFSET + PRESERVE THE GUN'S OWN ROTATION
	GunModel:PivotTo(CFrame.new(TargetCF.Position) * CurrentPivot.Rotation * PivotToBoundingOffset:Inverse())
end

-- ON SERVER EVENT FOR GIVE GUN
local IsOpening = false
MysteryPrompt.OnServerEvent:Connect(function(Player, Prompt)
	-- ENSURE 2 PLAYERS DONT OPEN AT SAME TIME
	if IsOpening then
		return
	end
	IsOpening = true
	if not Prompt.Enabled then
		IsOpening = false
		return
	end

	-- CHARACTER AND ROOT
	local Character = Player.Character
	if not Character then
		IsOpening = false
		return
	end
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	if not RootPart then
		IsOpening = false
		return
	end
	local Humanoid = Character:WaitForChild("Humanoid")
	if not Humanoid then
		IsOpening = false
		return
	end

	-- CURRENT PLAYER DATA
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then
		IsOpening = false
		return
	end

	-- CHECK IF ENOUGH POINTS
	if CurrentPlayerData.Points.CurrentPoints < Cost then
		IsOpening = false
		return
	end

	-- DISABLE PROMPT
	Prompt.Enabled = false

	-- ONLY UPDATE COST IF SUCCESSFUL PURCHASE
	CurrentPlayerData.Points.CurrentPoints -= Cost
	Player:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))

	-- ANIMATE MYSTERY BOX
	local CFValue = Instance.new("CFrameValue")
	CFValue.Value = Top:GetPivot()
	CFValue.Changed:Connect(function(NewCF)
		Top:PivotTo(NewCF)
	end)

	-- TWEEN POSITION BACK AND ROTATE IT
	local OriginalTop = Top:GetPivot()
	local OpenTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local Goal = Top:GetPivot() * CFrame.new(0, 2, 2) * CFrame.Angles(math.rad(90), 0, 0)
	local OpenTween = TweenService:Create(CFValue, OpenTweenInfo, { Value = Goal })
	OpenTween.Completed:Connect(function()
		OpenTween:Destroy()
	end)
	OpenTween:Play()

	-- PLAY ALL PARTICLE EMITTERS
	for _, Descendant in pairs(NeonBase:GetDescendants()) do
		if Descendant:IsA("ParticleEmitter") then
			Descendant.Enabled = true
		end
	end

	-- ROLLS
	local FinalGun

	-- ROLL FOR ZEHAHA
	local ZehahaRoll = math.random(1, 100)
	if ZehahaRoll <= ZehahaRate then
		FinalGun = "Zehaha"
	else
		-- ROLL FOR GUN
		local Roll = math.random(1, 100)
		if Roll <= Rates.Legendary.Rarity then
			FinalGun = Rates.Legendary.Weapons[math.random(1, #Rates.Legendary.Weapons)]
		elseif Roll <= Rates.Epic.Rarity then
			FinalGun = Rates.Epic.Weapons[math.random(1, #Rates.Epic.Weapons)]
		elseif Roll <= Rates.Rare.Rarity then
			FinalGun = Rates.Rare.Weapons[math.random(1, #Rates.Rare.Weapons)]
		elseif Roll <= Rates.Uncommon.Rarity then
			FinalGun = Rates.Uncommon.Weapons[math.random(1, #Rates.Uncommon.Weapons)]
		else
			FinalGun = Rates.Common.Weapons[math.random(1, #Rates.Common.Weapons)]
		end
	end

	-- WAIT TILL TOP FULLY OPENS BEFORE DISPLAYING GUNS
	OpenTween.Completed:Wait()

	local StartingWait = 0.075
	local MaxWait = 0.5

	local LastGun
	for i = 1, TotalRolls do
		-- CALCULATE WAIT TIME
		local t = i / TotalRolls
		local WaitTime = StartingWait + (MaxWait - StartingWait) * (t * t * t * t)

		-- PICK A RANDOM GUN, ENSURE NOT SAME AS LAST, NOT ZEHAHA, AND NOT THE FINAL GUN ON THE LAST ROLL
		local RandomGun = MysteryBoxGuns:GetChildren()[math.random(1, #MysteryBoxGuns:GetChildren())]
		while RandomGun.Name == "Zehaha" or RandomGun == LastGun or (i == TotalRolls and RandomGun == FinalGun) do
			RandomGun = MysteryBoxGuns:GetChildren()[math.random(1, #MysteryBoxGuns:GetChildren())]
		end

		LastGun = RandomGun
		local OriginalCFrame = RandomGun:GetPivot()

		-- DISPLAY GUN
		DisplayGun(RandomGun)

		task.wait(WaitTime)
		-- RETURN GUN TO ORIGINAL POSITION
		RandomGun:PivotTo(OriginalCFrame)
	end

	-- DISPLAY THE GUN TO GIVE
	local GunToGive = MysteryBoxGuns:FindFirstChild(FinalGun)
	local OriginalCFrame = GunToGive:GetPivot()
	DisplayGun(GunToGive)

	-- IF ZEHAHA
	if FinalGun == "Zehaha" then
		-- RESET ZEHAHA RATE
		ZehahaRate = 10

		-- TWEEN BRIGHTNESS
		local OriginalBrightness = MysteryBoxLight.Brightness
		-- TWEEN BRIGHTNESS TO OFF
		local ZehahaTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		local ZehahaTween = TweenService:Create(MysteryBoxLight, ZehahaTweenInfo, { Brightness = 0 })
		ZehahaTween:Play()

		-- DISABLE PARTICLE EMITTERS
		for _, Descendant in pairs(NeonBase:GetDescendants()) do
			if Descendant:IsA("ParticleEmitter") then
				Descendant.Enabled = false
			end
		end

		task.wait(1)

		local ZehahaCFValue = Instance.new("CFrameValue")
		ZehahaCFValue.Value = GunToGive:GetPivot()
		ZehahaCFValue.Changed:Connect(function(NewCF)
			GunToGive:PivotTo(NewCF)
		end)
		-- MOVE ZEHAHA UPWARDS
		local ZehahaRiseTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		local StartCF = GunToGive:GetPivot()
		local ZehahaRiseTween =
			TweenService:Create(ZehahaCFValue, ZehahaRiseTweenInfo, { Value = StartCF * CFrame.new(0, 100, 0) })
		ZehahaRiseTween.Completed:Once(function()
			ZehahaCFValue:Destroy()
			ZehahaRiseTween:Destroy()
		end)
		ZehahaRiseTween:Play()

		-- WAIT FOR A BIT
		task.wait(5)

		-- RETURN ZEHAHA
		GunToGive:PivotTo(OriginalCFrame)
	else
		-- INCREASE ZEHAHA RATE FOR NEXT ROLL
		ZehahaRate += 10
		-- CREATE PROMPT
		local GiveGunPrompt = Instance.new("ProximityPrompt")
		GiveGunPrompt.Name = "MysteryGiveGun"
		GiveGunPrompt.ActionText = "MysteryGiveGun"
		GiveGunPrompt.MaxActivationDistance = 15
		GiveGunPrompt.Style = Enum.ProximityPromptStyle.Custom
		GiveGunPrompt.KeyboardKeyCode = Enum.KeyCode.E
		GiveGunPrompt.RequiresLineOfSight = false
		GiveGunPrompt.HoldDuration = 0
		GiveGunPrompt.Parent = MysteryBoxModel:FindFirstChild("Base")

		-- SET PROMPT ATTRIBUTES
		GiveGunPrompt:SetAttribute("GunToGive", GunToGive.Name)
		GiveGunPrompt:SetAttribute("Player", Player.Name)

		-- ON PROMPT TRIGGERED
		local PromptTriggeredConnection
		local PlayerGotGun = false
		PromptTriggeredConnection = GiveGunPrompt.Triggered:Connect(function(TriggeringPlayer)
			if TriggeringPlayer ~= Player then
				return
			end
			PlayerGotGun = true

			-- CLEANUP
			PromptTriggeredConnection:Disconnect()
			PromptTriggeredConnection = nil
			GiveGunPrompt:Destroy()
			GunToGive:PivotTo(OriginalCFrame)

			-- GIVE GUN/REFILL AMMO
			local PlayerGun = Player:GetAttribute("IsEquippingGun")
			if PlayerGun and PlayerGun == GunToGive.Name then
				-- REFILL AMMO
				GunFW.RefillAmmo(Player)
			else
				-- GIVE GUN
				GunFW.GiveWeapon(Player, GunToGive.Name, true)
			end
		end)

		-- STORE THE GUN'S CURRENT DISPLAY POSITION BEFORE SINKING
		local StartCF = GunToGive:GetPivot()
		local SinkTarget = NeonBase:GetPivot().Position

		-- SINK THE GUN DOWN INTO THE BOX
		local CurrentTime = tick()
		while PromptTriggeredConnection and tick() - CurrentTime < 8 do
			local Elapsed = tick() - CurrentTime
			local t = Elapsed / 8

			-- LERP FROM CURRENT DISPLAY POSITION DOWN TO NEONBASE
			local StartPos = StartCF.Position
			local NewY = StartPos.Y + (SinkTarget.Y - StartPos.Y) * t

			-- KEEP THE SAME X/Z AND ROTATION, JUST LOWER THE Y
			GunToGive:PivotTo(CFrame.new(StartPos.X, NewY, StartPos.Z) * StartCF.Rotation)
			task.wait()
		end

		if not PlayerGotGun then
			-- TELEPORT GUN BACK
			GunToGive:PivotTo(OriginalCFrame)
			-- CLEANUP
			if PromptTriggeredConnection then
				PromptTriggeredConnection:Disconnect()
				PromptTriggeredConnection = nil
			end
			GiveGunPrompt:Destroy()
		end

		-- DISABLE PARTICLE EMITTERS
		for _, Descendant in pairs(NeonBase:GetDescendants()) do
			if Descendant:IsA("ParticleEmitter") then
				Descendant.Enabled = false
			end
		end
	end

	-- TWEEN BACK THE TOP
	local CloseTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local CloseTween = TweenService:Create(CFValue, CloseTweenInfo, { Value = OriginalTop })
	CloseTween.Completed:Connect(function()
		-- DESTROY CF VALUE NOW
		CFValue:Destroy()
		CloseTween:Destroy()
	end)
	CloseTween:Play()

	task.wait(OpenCD)
	IsOpening = false
	Prompt.Enabled = true
end)
