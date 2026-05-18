-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")

-- MODULES
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))
local GunFW = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Gun"):WaitForChild("GunFW"))

-- EVENTS
local PromptEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PromptEvents")
local MysteryPrompt = PromptEvents:WaitForChild("MysteryPrompt")

-- FOLDERS
local MysteryBox = workspace:WaitForChild("MysteryBox")
local MysteryBoxModel = MysteryBox:WaitForChild("MysteryBoxModel")
local Top = MysteryBoxModel:WaitForChild("Top")
local NeonBase = MysteryBoxModel:WaitForChild("NeonBase")
local MysteryBoxGuns = MysteryBox:WaitForChild("MysteryBoxGuns")
local MysteryBoxLight = MysteryBoxModel:WaitForChild("LightEmitter"):WaitForChild("MysteryBoxLight")
local SpawnLocations = MysteryBox:WaitForChild("SpawnLocations")
local MysteryBoxVFX = ReplicatedStorage:WaitForChild("MysteryBoxVFX")
local MysteryBoxSFX = ReplicatedStorage:WaitForChild("MysteryBoxSFX")
local TPVFX = MysteryBoxVFX:WaitForChild("TPVFX")
local Concrete = MysteryBoxModel:WaitForChild("Concrete")

-- COST
local Cost = MysteryBox:WaitForChild("Cost").Value
-- CD
local OpenCD = 2
-- TOTAL ROLLS TO DISPLAY
local TotalRolls = 25

-- RATES
local TeddyBearRate = 0
local Rates = {
	Common = {
		Rarity = 43,
		Weapons = {
			"Rifle",
			"SemiPistol",
			"Silencer",
		},
	},
	Uncommon = {
		Rarity = 30,
		Weapons = {
			"AK47",
			"AR",
			"Deagle",
			"PumpShotgun",
			"TommyGun",
		},
	},
	Rare = {
		Rarity = 20,
		Weapons = {
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
			"RicochetSniper",
			"Minigun",
			"PhaseSniper",
		},
	},
	Legendary = {
		Rarity = 2,
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

local function DisplayGun(GunModel)
	local CurrentPivot = GunModel:GetPivot()
	local BoundingCF = GetModelCenter(GunModel)

	-- POSITION OFFSET FROM PIVOT TO BOUNDING CENTER (NO ROTATION)
	local PivotToBoundingOffset = CFrame.new(CurrentPivot:ToObjectSpace(BoundingCF).Position)

	-- TARGET POSITION ABOVE NEON BASE
	local TargetCF = NeonBase:GetPivot() * CFrame.new(0, 4, 0)

	-- NEONBASE ROTATION * GUN'S OWN ROTATION = follows box orientation + keeps gun's own facing
	local CombinedRotation = NeonBase:GetPivot().Rotation * CurrentPivot.Rotation

	GunModel:PivotTo(CFrame.new(TargetCF.Position) * CombinedRotation * PivotToBoundingOffset:Inverse())
end

-- HELPER TO TELEPORT MYSTERY BOX MODEL TO ONE OF THE SPAWN LOCATIONS ITS NOT CURRENTLY AT
local FirstSwap = true
local LocationsLookup = {}
local function TeleportMysteryBox()
	local Locations = {}
	for _, Location in pairs(SpawnLocations:GetChildren()) do
		-- EXCLUDE MYSTERY BOX
		if Location == MysteryBoxModel then
			continue
		end
		table.insert(Locations, Location)
	end

	-- PICK A RANDOM LOCATION
	local Location = Locations[math.random(1, #Locations)]

	-- TELEPORT MYSTERY BOX MODEL TO NEW LOCATION
	MysteryBoxModel:PivotTo(LocationsLookup[Location].SpawnPivot)

	if FirstSwap then
		-- DESTROY THE FIRST LOCATION
		Location:Destroy()
		LocationsLookup[MysteryBoxModel] = LocationsLookup[Location]
		LocationsLookup[Location] = nil
		MysteryBoxModel.Parent = SpawnLocations

		-- TURN OFF FIRST SWAP
		FirstSwap = false
	else
		-- SWAP LOCATIONS BETWEEN NO MYSTERY BOX MODEL AND MYSTERY BOX
		Location:PivotTo(LocationsLookup[MysteryBoxModel].ModelPivot)

		-- UPDATE LOCATIONS LOOKUP
		local Temp = LocationsLookup[MysteryBoxModel]
		LocationsLookup[MysteryBoxModel] = LocationsLookup[Location]
		LocationsLookup[Location] = Temp
	end
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
	local OpenTopCFValue = Instance.new("CFrameValue")
	OpenTopCFValue.Value = Top:GetPivot()
	OpenTopCFValue.Changed:Connect(function(NewCF)
		Top:PivotTo(NewCF)
	end)

	-- PLAY OPENING SFX
	local RollSFX = NeonBase:FindFirstChild("RollSFX")
	RollSFX:Play()

	-- TWEEN POSITION BACK AND ROTATE IT
	local OpenTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local Goal = Top:GetPivot() * CFrame.new(0, 2, 2) * CFrame.Angles(math.rad(90), 0, 0)
	local OpenTween = TweenService:Create(OpenTopCFValue, OpenTweenInfo, { Value = Goal })
	OpenTween.Completed:Connect(function()
		OpenTween:Destroy()
		OpenTopCFValue:Destroy()
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

	-- ROLL FOR TEDDY BEAR
	local TeddyBearRoll = math.random(1, 100)
	if TeddyBearRoll <= TeddyBearRate then
		FinalGun = "TeddyBear"
	else
		-- ROLL FOR GUN
		local Roll = math.random(1, 100)
		if Roll <= Rates.Legendary.Rarity then
			FinalGun = Rates.Legendary.Weapons[math.random(1, #Rates.Legendary.Weapons)]
		elseif Roll <= Rates.Epic.Rarity + Rates.Legendary.Rarity then
			FinalGun = Rates.Epic.Weapons[math.random(1, #Rates.Epic.Weapons)]
		elseif Roll <= Rates.Rare.Rarity + Rates.Epic.Rarity + Rates.Legendary.Rarity then
			FinalGun = Rates.Rare.Weapons[math.random(1, #Rates.Rare.Weapons)]
		elseif Roll <= Rates.Uncommon.Rarity + Rates.Rare.Rarity + Rates.Epic.Rarity + Rates.Legendary.Rarity then
			FinalGun = Rates.Uncommon.Weapons[math.random(1, #Rates.Uncommon.Weapons)]
		else
			FinalGun = Rates.Common.Weapons[math.random(1, #Rates.Common.Weapons)]
		end
	end

	-- WAIT TILL TOP FULLY OPENS BEFORE DISPLAYING GUNS
	OpenTween.Completed:Wait()

	local StartingWait = 0.1
	local MaxWait = 0.4

	local LastGun
	for i = 1, TotalRolls do
		-- CALCULATE WAIT TIME
		local t = i / TotalRolls
		local WaitTime = StartingWait + (MaxWait - StartingWait) * (t * t * t * t)

		-- PICK A RANDOM GUN, ENSURE NOT SAME AS LAST, NOT TEDDY BEAR, AND NOT THE FINAL GUN ON THE LAST ROLL
		local RandomGun = MysteryBoxGuns:GetChildren()[math.random(1, #MysteryBoxGuns:GetChildren())]
		while RandomGun.Name == "TeddyBear" or RandomGun == LastGun or (i == TotalRolls and RandomGun == FinalGun) do
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

	-- IF TEDDY BEAR
	local OriginalBrightness
	if FinalGun == "TeddyBear" then
		-- RESET TEDDY BEAR RATE
		TeddyBearRate = 0

		-- TWEEN BRIGHTNESS
		OriginalBrightness = MysteryBoxLight.Brightness
		-- TWEEN BRIGHTNESS TO OFF
		local BrightnessTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		local BrightnessTween = TweenService:Create(MysteryBoxLight, BrightnessTweenInfo, { Brightness = 0 })
		BrightnessTween:Play()

		-- DISABLE PARTICLE EMITTERS
		for _, Descendant in pairs(NeonBase:GetDescendants()) do
			if Descendant:IsA("ParticleEmitter") then
				Descendant.Enabled = false
			end
		end

		-- PLAY SFX
		local ByeByeSFXClone = MysteryBoxSFX:WaitForChild("ByeBye"):Clone()
		ByeByeSFXClone.Parent = workspace:FindFirstChild("ActiveSFX")
		ByeByeSFXClone:Play()
		ByeByeSFXClone.Ended:Once(function()
			ByeByeSFXClone:Destroy()
		end)

		task.wait(2)

		local TeddyBearCFValue = Instance.new("CFrameValue")
		TeddyBearCFValue.Value = GunToGive:GetPivot()
		TeddyBearCFValue.Changed:Connect(function(NewCF)
			GunToGive:PivotTo(NewCF)
		end)
		-- MOVE TEDDY BEAR UPWARDS
		local TeddyBearRiseTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local StartCF = GunToGive:GetPivot()
		local TeddyBearRiseTween =
			TweenService:Create(TeddyBearCFValue, TeddyBearRiseTweenInfo, { Value = StartCF * CFrame.new(0, 50, 0) })
		TeddyBearRiseTween.Completed:Once(function()
			TeddyBearCFValue:Destroy()
			TeddyBearRiseTween:Destroy()
		end)
		TeddyBearRiseTween:Play()

		task.wait(4.5)

		local OriginalBoxCF = MysteryBoxModel:GetPivot()
		local WiggleAngle = math.rad(12)
		local WiggleDuration = 0.2

		-- UNPARENT CONCRETE FROM MYSTERY BOX MODEL
		Concrete.Parent = MysteryBox

		-- TWEEN THE Y
		local RiseValue = Instance.new("NumberValue")
		RiseValue.Value = 0
		local BoxRiseTweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local BoxRiseTween = TweenService:Create(RiseValue, BoxRiseTweenInfo, { Value = 8 })
		BoxRiseTween:Play()
		BoxRiseTween.Completed:Once(function()
			RiseValue:Destroy()
			BoxRiseTween:Destroy()
			BoxRiseTween = nil
		end)
		task.wait(0.1)

		-- WIGGLE + RISE APPLIED TOGETHER IN ONE LOOP
		local StartTime = tick()
		while BoxRiseTween do
			local Elapsed = tick() - StartTime
			local WiggleOffset = CFrame.Angles(0, 0, math.sin(Elapsed / WiggleDuration * math.pi) * WiggleAngle)
			MysteryBoxModel:PivotTo(OriginalBoxCF * CFrame.new(0, RiseValue.Value, 0) * WiggleOffset)
			task.wait()
		end

		-- RESET MYSTERY BOX ORIENTATION
		MysteryBoxModel:PivotTo(OriginalBoxCF * CFrame.new(0, RiseValue.Value, 0))

		-- TELEPORT MYSTERY BOX FAR AWAY
		local DummyPart = Instance.new("Part")
		DummyPart.Size = Vector3.new(1, 1, 1)
		DummyPart.Transparency = 1
		DummyPart.Anchored = true
		DummyPart.CanCollide = false
		DummyPart.CFrame = MysteryBoxModel:GetPivot() * CFrame.new(0, -4, 0)
		DummyPart.Parent = workspace:FindFirstChild("ActiveVFX")

		-- PARENT CONCRETE BACK
		Concrete.Parent = MysteryBoxModel
		Concrete:PivotTo(Concrete:GetPivot() * CFrame.new(0, 8, 0))
		-- HIDE MYSTER BOX MODEL
		MysteryBoxModel:PivotTo(MysteryBoxModel:GetPivot() * CFrame.new(0, 100, 0))

		-- TELEPORT SFX
		local ChargeSFXClone = MysteryBoxSFX:WaitForChild("Charge"):Clone()
		ChargeSFXClone.Parent = DummyPart
		ChargeSFXClone:Play()

		-- TELEPORT VFX
		local TPVFXClone = TPVFX:Clone()
		TPVFXClone.Parent = DummyPart
		for _, Emitter in pairs(TPVFXClone:GetDescendants()) do
			if Emitter:IsA("ParticleEmitter") then
				Emitter:Emit(Emitter.Rate)
			end
		end

		-- RETURN TEDDY BEAR
		GunToGive:PivotTo(OriginalCFrame)

		-- SOME WAITS FOR CLEANUP
		task.delay(1, function()
			DummyPart:Destroy()
			TPVFXClone:Destroy()
			ChargeSFXClone:Destroy()
		end)
	else
		-- INCREASE TEDDY BEAR RATE FOR NEXT ROLL
		TeddyBearRate += 10
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

		-- GET DEFAULT DATA FOR THIS GUN
		local GameName = GunToGive:FindFirstChild("GameName").Value
		-- SET PROMPT ATTRIBUTES
		GiveGunPrompt:SetAttribute("GunToGive", GameName)
		GiveGunPrompt:SetAttribute("Player", Player.Name)

		-- ON PROMPT TRIGGERED
		local PromptTriggeredConnection
		local PlayerGotGun = false
		PromptTriggeredConnection = GiveGunPrompt.Triggered:Connect(function(TriggeringPlayer)
			if TriggeringPlayer ~= Player then
				return
			end
			-- CHECK FOR PLAYER STATES
			local IsRunning = Player:GetAttribute("IsRunning")
			local IsDashing = Player:GetAttribute("IsDashing")
			local IsShooting = Player:GetAttribute("IsShooting")
			local IsReloading = Player:GetAttribute("IsReloading")
			local IsCharging = Player:GetAttribute("IsCharging")
			local IsEquipping = Player:GetAttribute("IsEquipping")
			if IsRunning or IsDashing or IsShooting or IsReloading or IsCharging or IsEquipping then
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

			-- PLAY CLOSING SFX
			local CloseSFX = NeonBase:FindFirstChild("CloseSFX")
			CloseSFX:Play()
		end

		-- DISABLE PARTICLE EMITTERS
		for _, Descendant in pairs(NeonBase:GetDescendants()) do
			if Descendant:IsA("ParticleEmitter") then
				Descendant.Enabled = false
			end
		end
	end

	-- TWEEN BACK THE TOP
	local CloseTopCFValue = Instance.new("CFrameValue")
	CloseTopCFValue.Value = Top:GetPivot()
	CloseTopCFValue.Changed:Connect(function(NewCF)
		-- KEEP TOP RELATIVE TO THE BOX WHILE CLOSING
		Top:PivotTo(NewCF)
	end)

	-- CLOSE INSTANTLY IF NEEDS TO TP ANYWAYS
	local TimeToClose = FinalGun == "TeddyBear" and 0 or 0.25
	local CloseTweenInfo = TweenInfo.new(TimeToClose, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	Goal = Top:GetPivot() * CFrame.new(0, -2, 2) * CFrame.Angles(math.rad(-90), 0, 0)
	local CloseTween = TweenService:Create(CloseTopCFValue, CloseTweenInfo, { Value = Goal })
	CloseTween.Completed:Connect(function()
		-- DESTROY CF VALUE NOW
		CloseTopCFValue:Destroy()
		CloseTween:Destroy()
	end)
	CloseTween:Play()

	-- ENSURE LIGHT IS BACK ON
	if OriginalBrightness then
		MysteryBoxLight.Brightness = OriginalBrightness
	end

	-- SWAP MYSTERY BOX LOCATION
	if FinalGun == "TeddyBear" then
		CloseTween.Completed:Wait()
		TeleportMysteryBox()
	end

	task.wait(OpenCD)
	IsOpening = false
	Prompt.Enabled = true
end)

-- LOOP THROUGH SPAWN LOCATIONS AND STORE THEIR CF IN A TABLE FOR EASY ACCESS LATER
for _, Location in pairs(SpawnLocations:GetChildren()) do
	local SpawnPart = Location:FindFirstChild("Spawn")
	LocationsLookup[Location] = {
		SpawnPivot = SpawnPart:GetPivot(),
		ModelPivot = Location:GetPivot(),
	}
end

-- TELEPORT MYSTERY BOX ON SERVER START
TeleportMysteryBox()
