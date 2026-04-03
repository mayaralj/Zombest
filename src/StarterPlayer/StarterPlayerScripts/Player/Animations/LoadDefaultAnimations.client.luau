-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- FOLDERS

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientUtilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local RockModule = require(ModuleScripts:WaitForChild("Frameworks"):WaitForChild("Rock"):WaitForChild("RockModule"))

-- TABLES
local Tracks = {}
local Connections = {}

-- MAIN CHARACTER SETUP FUNCTION
local function SetupCharacterAnimations(CharacterToAnimate)
	-- GET PLAYER
	local PlayerToAnimate = Players:GetPlayerFromCharacter(CharacterToAnimate)
	if not PlayerToAnimate then
		return
	end

	-- HUMANOID
	local Humanoid = CharacterToAnimate:WaitForChild("Humanoid")
	-- ANIMATION
	local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)

	-- INITIALIZE PLAYER TRACKS
	if not Tracks[PlayerToAnimate] then
		Tracks[PlayerToAnimate] = {}
	end
	if not Connections[PlayerToAnimate] then
		Connections[PlayerToAnimate] = {}
	end

	-- PARTIAL CLEANUP FUNCTION
	local function PartialCleanup()
		if Tracks[PlayerToAnimate] then
			if Tracks[PlayerToAnimate]["WalkTrack"] and Tracks[PlayerToAnimate]["WalkTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["WalkTrack"]:Stop()
			end
			if Tracks[PlayerToAnimate]["IdleTrack"] and Tracks[PlayerToAnimate]["IdleTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["IdleTrack"]:Stop()
			end
			if Tracks[PlayerToAnimate]["RunTrack"] and Tracks[PlayerToAnimate]["RunTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["RunTrack"]:Stop()
			end

			if Tracks[PlayerToAnimate]["FrontDashTrack"] and Tracks[PlayerToAnimate]["FrontDashTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["FrontDashTrack"]:Stop()
			end
			if Tracks[PlayerToAnimate]["BackDashTrack"] and Tracks[PlayerToAnimate]["BackDashTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["BackDashTrack"]:Stop()
			end
			if Tracks[PlayerToAnimate]["LeftDashTrack"] and Tracks[PlayerToAnimate]["LeftDashTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["LeftDashTrack"]:Stop()
			end
			if Tracks[PlayerToAnimate]["RightDashTrack"] and Tracks[PlayerToAnimate]["RightDashTrack"].IsPlaying then
				Tracks[PlayerToAnimate]["RightDashTrack"]:Stop()
			end

			if Tracks[PlayerToAnimate]["RunSFX"] and Tracks[PlayerToAnimate]["RunSFX"].IsPlaying then
				Tracks[PlayerToAnimate]["RunSFX"]:Stop()
			end
			if Tracks[PlayerToAnimate]["WalkSFX"] and Tracks[PlayerToAnimate]["WalkSFX"].IsPlaying then
				Tracks[PlayerToAnimate]["WalkSFX"]:Stop()
			end
			if Tracks[PlayerToAnimate]["DashSFX"] and Tracks[PlayerToAnimate]["DashSFX"].IsPlaying then
				Tracks[PlayerToAnimate]["DashSFX"]:Stop()
			end

			if Tracks[PlayerToAnimate]["MoveAnimationConnection"] then
				Tracks[PlayerToAnimate]["MoveAnimationConnection"]:Disconnect()
				Tracks[PlayerToAnimate]["MoveAnimationConnection"] = nil
			end
			if Tracks[PlayerToAnimate]["DashAnimationConnection"] then
				Tracks[PlayerToAnimate]["DashAnimationConnection"]:Disconnect()
				Tracks[PlayerToAnimate]["DashAnimationConnection"] = nil
			end
		end

		if Connections[PlayerToAnimate] then
			if Connections[PlayerToAnimate]["MoveHeartbeat"] then
				Connections[PlayerToAnimate]["MoveHeartbeat"]:Disconnect()
				Connections[PlayerToAnimate]["MoveHeartbeat"] = nil
			end

			if Connections[PlayerToAnimate]["WalkLeft"] then
				Connections[PlayerToAnimate]["WalkLeft"]:Disconnect()
				Connections[PlayerToAnimate]["WalkLeft"] = nil
			end
			if Connections[PlayerToAnimate]["WalkRight"] then
				Connections[PlayerToAnimate]["WalkRight"]:Disconnect()
				Connections[PlayerToAnimate]["WalkRight"] = nil
			end
			if Connections[PlayerToAnimate]["RunLeft"] then
				Connections[PlayerToAnimate]["RunLeft"]:Disconnect()
				Connections[PlayerToAnimate]["RunLeft"] = nil
			end
			if Connections[PlayerToAnimate]["RunRight"] then
				Connections[PlayerToAnimate]["RunRight"]:Disconnect()
				Connections[PlayerToAnimate]["RunRight"] = nil
			end

			if Connections[PlayerToAnimate]["StopDebounce"] then
				task.cancel(Connections[PlayerToAnimate]["StopDebounce"])
				Connections[PlayerToAnimate]["StopDebounce"] = nil
			end
		end
	end

	-- FULL CLEANUP FUNCTION
	local function FullCleanup()
		if Tracks[PlayerToAnimate] then
			if Tracks[PlayerToAnimate]["WalkTrack"] then
				Tracks[PlayerToAnimate]["WalkTrack"]:Stop()
				Tracks[PlayerToAnimate]["WalkTrack"]:Destroy()
				Tracks[PlayerToAnimate]["WalkTrack"] = nil
			end
			if Tracks[PlayerToAnimate]["IdleTrack"] then
				Tracks[PlayerToAnimate]["IdleTrack"]:Stop()
				Tracks[PlayerToAnimate]["IdleTrack"]:Destroy()
				Tracks[PlayerToAnimate]["IdleTrack"] = nil
			end
			if Tracks[PlayerToAnimate]["RunTrack"] then
				Tracks[PlayerToAnimate]["RunTrack"]:Stop()
				Tracks[PlayerToAnimate]["RunTrack"]:Destroy()
				Tracks[PlayerToAnimate]["RunTrack"] = nil
			end

			if Tracks[PlayerToAnimate]["WalkSFX"] then
				Tracks[PlayerToAnimate]["WalkSFX"]:Stop()
				Tracks[PlayerToAnimate]["WalkSFX"]:Destroy()
				Tracks[PlayerToAnimate]["WalkSFX"] = nil
			end
			if Tracks[PlayerToAnimate]["RunSFX"] then
				Tracks[PlayerToAnimate]["RunSFX"]:Stop()
				Tracks[PlayerToAnimate]["RunSFX"]:Destroy()
				Tracks[PlayerToAnimate]["RunSFX"] = nil
			end
			if Tracks[PlayerToAnimate]["DashSFX"] then
				Tracks[PlayerToAnimate]["DashSFX"]:Stop()
				Tracks[PlayerToAnimate]["DashSFX"]:Destroy()
				Tracks[PlayerToAnimate]["DashSFX"] = nil
			end

			if Tracks[PlayerToAnimate]["FrontDashTrack"] then
				Tracks[PlayerToAnimate]["FrontDashTrack"]:Stop()
				Tracks[PlayerToAnimate]["FrontDashTrack"]:Destroy()
				Tracks[PlayerToAnimate]["FrontDashTrack"] = nil
			end
			if Tracks[PlayerToAnimate]["BackDashTrack"] then
				Tracks[PlayerToAnimate]["BackDashTrack"]:Stop()
				Tracks[PlayerToAnimate]["BackDashTrack"]:Destroy()
				Tracks[PlayerToAnimate]["BackDashTrack"] = nil
			end
			if Tracks[PlayerToAnimate]["LeftDashTrack"] then
				Tracks[PlayerToAnimate]["LeftDashTrack"]:Stop()
				Tracks[PlayerToAnimate]["LeftDashTrack"]:Destroy()
				Tracks[PlayerToAnimate]["LeftDashTrack"] = nil
			end
			if Tracks[PlayerToAnimate]["RightDashTrack"] then
				Tracks[PlayerToAnimate]["RightDashTrack"]:Stop()
				Tracks[PlayerToAnimate]["RightDashTrack"]:Destroy()
				Tracks[PlayerToAnimate]["RightDashTrack"] = nil
			end

			if Tracks[PlayerToAnimate]["MoveAnimationConnection"] then
				Tracks[PlayerToAnimate]["MoveAnimationConnection"]:Disconnect()
				Tracks[PlayerToAnimate]["MoveAnimationConnection"] = nil
			end
			if Tracks[PlayerToAnimate]["DashAnimationConnection"] then
				Tracks[PlayerToAnimate]["DashAnimationConnection"]:Disconnect()
				Tracks[PlayerToAnimate]["DashAnimationConnection"] = nil
			end

			if Tracks[PlayerToAnimate]["DustVFX"] then
				Tracks[PlayerToAnimate]["DustVFX"]:Destroy()
				Tracks[PlayerToAnimate]["DustVFX"] = nil
			end
		end

		if Connections[PlayerToAnimate] then
			if Connections[PlayerToAnimate]["WalkLeft"] then
				Connections[PlayerToAnimate]["WalkLeft"]:Disconnect()
				Connections[PlayerToAnimate]["WalkLeft"] = nil
			end
			if Connections[PlayerToAnimate]["WalkRight"] then
				Connections[PlayerToAnimate]["WalkRight"]:Disconnect()
				Connections[PlayerToAnimate]["WalkRight"] = nil
			end
			if Connections[PlayerToAnimate]["RunLeft"] then
				Connections[PlayerToAnimate]["RunLeft"]:Disconnect()
				Connections[PlayerToAnimate]["RunLeft"] = nil
			end
			if Connections[PlayerToAnimate]["RunRight"] then
				Connections[PlayerToAnimate]["RunRight"]:Disconnect()
				Connections[PlayerToAnimate]["RunRight"] = nil
			end

			if Connections[PlayerToAnimate]["EquippedGunConnection"] then
				Connections[PlayerToAnimate]["EquippedGunConnection"]:Disconnect()
				Connections[PlayerToAnimate]["EquippedGunConnection"] = nil
			end
			if Connections[PlayerToAnimate]["DiedConnection"] then
				Connections[PlayerToAnimate]["DiedConnection"]:Disconnect()
				Connections[PlayerToAnimate]["DiedConnection"] = nil
			end

			if Connections[PlayerToAnimate]["MoveHeartbeat"] then
				Connections[PlayerToAnimate]["MoveHeartbeat"]:Disconnect()
				Connections[PlayerToAnimate]["MoveHeartbeat"] = nil
			end

			if Connections[PlayerToAnimate]["StopDebounce"] then
				task.cancel(Connections[PlayerToAnimate]["StopDebounce"])
				Connections[PlayerToAnimate]["StopDebounce"] = nil
			end
		end
	end

	-- INCASE
	FullCleanup()

	-- IDLE ANIMATION
	local IdleAnimationID = "rbxassetid://138016804674308"
	local IdleAnimation = Instance.new("Animation")
	ContentProvider:PreloadAsync({ IdleAnimation })
	IdleAnimation.AnimationId = IdleAnimationID
	local IdleTrack = Animator:LoadAnimation(IdleAnimation)
	IdleTrack.Priority = Enum.AnimationPriority.Core
	IdleTrack.Looped = true
	IdleTrack:Play()
	Tracks[PlayerToAnimate]["IdleTrack"] = IdleTrack

	-- WALK ANIMATION
	local WalkAnimationID = "rbxassetid://128853548878831"
	local WalkAnimation = Instance.new("Animation")
	WalkAnimation.AnimationId = WalkAnimationID
	ContentProvider:PreloadAsync({ WalkAnimation })
	local WalkTrack = Animator:LoadAnimation(WalkAnimation)
	WalkTrack.Priority = Enum.AnimationPriority.Movement
	WalkTrack.Looped = true
	Tracks[PlayerToAnimate]["WalkTrack"] = WalkTrack

	-- RUN ANIMATION
	local RunAnimationID = "rbxassetid://130028395674777"
	local RunAnimation = Instance.new("Animation")
	RunAnimation.AnimationId = RunAnimationID
	local RunTrack = Animator:LoadAnimation(RunAnimation)
	RunTrack.Priority = Enum.AnimationPriority.Movement
	RunTrack.Looped = true
	Tracks[PlayerToAnimate]["RunTrack"] = RunTrack

	-- WALK FOOTSTEP SOUND
	local WalkSFXID = "rbxassetid://6563562192"
	local WalkSFX = Instance.new("Sound")
	WalkSFX.SoundId = WalkSFXID
	WalkSFX.Name = "WalkSFX"
	WalkSFX.Volume = 0.25
	WalkSFX.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
	Tracks[PlayerToAnimate]["WalkSFX"] = WalkSFX

	-- WALK
	local DustVFX = ReplicatedStorage.DefaultVFX:FindFirstChild("Dust"):FindFirstChild("Dust"):Clone()
	DustVFX.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
	Tracks[PlayerToAnimate]["DustVFX"] = DustVFX

	-- RUN FOOTSTEP SOUND
	local RunSFXID = "rbxassetid://6563562192"
	local RunSFX = Instance.new("Sound")
	RunSFX.SoundId = RunSFXID
	RunSFX.Name = "RunSFX"
	RunSFX.Volume = 0.25
	RunSFX.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
	Tracks[PlayerToAnimate]["RunSFX"] = RunSFX

	-- DASH ANIMATIONS
	local FrontDashAnimation = Instance.new("Animation")
	FrontDashAnimation.AnimationId = "rbxassetid://97315657297321"
	local FrontDashTrack = Animator:LoadAnimation(FrontDashAnimation)
	FrontDashTrack.Priority = Enum.AnimationPriority.Action2
	FrontDashTrack.Looped = false
	Tracks[PlayerToAnimate]["FrontDashTrack"] = FrontDashTrack

	local BackDashAnimation = Instance.new("Animation")
	BackDashAnimation.AnimationId = "rbxassetid://134671841975119"
	local BackDashTrack = Animator:LoadAnimation(BackDashAnimation)
	BackDashTrack.Priority = Enum.AnimationPriority.Action2
	BackDashTrack.Looped = false
	Tracks[PlayerToAnimate]["BackDashTrack"] = BackDashTrack

	local LeftDashAnimation = Instance.new("Animation")
	LeftDashAnimation.AnimationId = "rbxassetid://127806576383996"
	local LeftDashTrack = Animator:LoadAnimation(LeftDashAnimation)
	LeftDashTrack.Priority = Enum.AnimationPriority.Action2
	LeftDashTrack.Looped = false
	Tracks[PlayerToAnimate]["LeftDashTrack"] = LeftDashTrack

	local RightDashAnimation = Instance.new("Animation")
	RightDashAnimation.AnimationId = "rbxassetid://98340978361964"
	local RightDashTrack = Animator:LoadAnimation(RightDashAnimation)
	RightDashTrack.Priority = Enum.AnimationPriority.Action2
	RightDashTrack.Looped = false
	Tracks[PlayerToAnimate]["RightDashTrack"] = RightDashTrack

	-- DASH SOUNDFX
	local DashSFX = Instance.new("Sound")
	DashSFX.SoundId = "rbxassetid://6128977275"
	DashSFX.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
	DashSFX.Volume = 4
	DashSFX.Looped = false
	Tracks[PlayerToAnimate]["DashSFX"] = DashSFX

	-- START MOVE ANIMATIONS FUNCTION
	local function StartMoveAnimations()
		-- CLEANUP
		if
			Tracks[PlayerToAnimate]
			and (
				Tracks[PlayerToAnimate]["DashAnimationConnection"] or Tracks[PlayerToAnimate]["MoveAnimationConnection"]
			)
		then
			PartialCleanup()
		end

		-- PLAY IDLE ANIMATION
		if Tracks[PlayerToAnimate]["IdleTrack"] then
			Tracks[PlayerToAnimate]["IdleTrack"]:Play()
		end

		-- DASH ANIMATION
		Tracks[PlayerToAnimate]["DashAnimationConnection"] = PlayerToAnimate:GetAttributeChangedSignal("IsDashing")
			:Connect(function()
				if PlayerToAnimate:GetAttribute("IsDashing") then
					local DashDirection = PlayerToAnimate:GetAttribute("DashDirection")

					-- RESET INDEX (TO ALLOW FOR PROPER DASH SHAPE)
					task.spawn(function()
						while
							(PlayerToAnimate == LocalPlayer and PlayerToAnimate:GetAttribute("IsDashing"))
							or (PlayerToAnimate ~= LocalPlayer and PlayerToAnimate:GetAttribute("DashingVFX"))
						do
							RockModule.PlayDustVFX(CharacterToAnimate, Tracks[PlayerToAnimate]["DustVFX"], nil, 1)

							RockModule.PlayRockTrailVFX(CharacterToAnimate, 2)
							task.wait(0.05)
						end
					end)

					if DashDirection == "Front" then
						Tracks[PlayerToAnimate]["FrontDashTrack"]:Play()
						Tracks[PlayerToAnimate]["FrontDashTrack"]:AdjustSpeed(2)
					elseif DashDirection == "Back" then
						Tracks[PlayerToAnimate]["BackDashTrack"]:Play()
						Tracks[PlayerToAnimate]["BackDashTrack"]:AdjustSpeed(1.5)
					elseif DashDirection == "Left" then
						Tracks[PlayerToAnimate]["LeftDashTrack"]:Play()
					elseif DashDirection == "Right" then
						Tracks[PlayerToAnimate]["RightDashTrack"]:Play()
					end

					if Tracks[PlayerToAnimate]["DashSFX"] then
						local ClonedSFX = Tracks[PlayerToAnimate]["DashSFX"]:Clone()
						ClonedSFX.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
						ClonedSFX:Play()
						Debris:AddItem(ClonedSFX, 2)
					end
				else
					Tracks[PlayerToAnimate]["FrontDashTrack"]:Stop(0.25)
					Tracks[PlayerToAnimate]["LeftDashTrack"]:Stop(0.25)
					Tracks[PlayerToAnimate]["BackDashTrack"]:Stop(0.25)
					Tracks[PlayerToAnimate]["RightDashTrack"]:Stop(0.25)
				end
			end)

		-- WALK TRACK MARKER SIGNALS
		Connections[PlayerToAnimate]["WalkLeft"] = Tracks[PlayerToAnimate]["WalkTrack"]
			:GetMarkerReachedSignal("LeftStep")
			:Connect(function()
				RockModule.PlayDustVFX(CharacterToAnimate, Tracks[PlayerToAnimate]["DustVFX"], "Left", 1)
				if Tracks[PlayerToAnimate] and Tracks[PlayerToAnimate]["WalkSFX"] then
					local ClonedTrack = Tracks[PlayerToAnimate]["WalkSFX"]:Clone()
					ClonedTrack.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
					ClonedTrack:Play()
					Debris:AddItem(ClonedTrack, 1)
				end
			end)
		Connections[PlayerToAnimate]["WalkRight"] = Tracks[PlayerToAnimate]["WalkTrack"]
			:GetMarkerReachedSignal("RightStep")
			:Connect(function()
				RockModule.PlayDustVFX(CharacterToAnimate, Tracks[PlayerToAnimate]["DustVFX"], "Right", 1)
				if Tracks[PlayerToAnimate] and Tracks[PlayerToAnimate]["WalkSFX"] then
					local ClonedTrack = Tracks[PlayerToAnimate]["WalkSFX"]:Clone()
					ClonedTrack.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
					ClonedTrack:Play()
					Debris:AddItem(ClonedTrack, 1)
				end
			end)
		Connections[PlayerToAnimate]["RunLeft"] = Tracks[PlayerToAnimate]["RunTrack"]
			:GetMarkerReachedSignal("LeftStep")
			:Connect(function()
				RockModule.PlayDustVFX(CharacterToAnimate, Tracks[PlayerToAnimate]["DustVFX"], "Left", 1)
				if Tracks[PlayerToAnimate] and Tracks[PlayerToAnimate]["RunSFX"] then
					local ClonedTrack = Tracks[PlayerToAnimate]["RunSFX"]:Clone()
					ClonedTrack.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
					ClonedTrack:Play()
					Debris:AddItem(ClonedTrack, 1)
				end
			end)
		Connections[PlayerToAnimate]["RunRight"] = Tracks[PlayerToAnimate]["RunTrack"]
			:GetMarkerReachedSignal("RightStep")
			:Connect(function()
				RockModule.PlayDustVFX(CharacterToAnimate, Tracks[PlayerToAnimate]["DustVFX"], "Right", 1)
				if Tracks[PlayerToAnimate] and Tracks[PlayerToAnimate]["RunSFX"] then
					local ClonedTrack = Tracks[PlayerToAnimate]["RunSFX"]:Clone()
					ClonedTrack.Parent = CharacterToAnimate:FindFirstChild("HumanoidRootPart")
					ClonedTrack:Play()
					Debris:AddItem(ClonedTrack, 1)
				end
			end)

		-- WALK AND RUN ANIMATIONS
		Connections[PlayerToAnimate]["MoveHeartbeat"] = RunService.Heartbeat:Connect(function()
			if not PlayerToAnimate or not Humanoid or not Humanoid.Parent then
				if Connections[PlayerToAnimate]["MoveAnimationConnection"] then
					Connections[PlayerToAnimate]["MoveAnimationConnection"]:Disconnect()
				end
				return
			end
			local Speed = Humanoid.WalkSpeed * Humanoid.MoveDirection.Magnitude
			local IsRunning = PlayerToAnimate:GetAttribute("IsSprinting")

			Tracks[PlayerToAnimate]["WalkTrack"]:AdjustSpeed(Humanoid.WalkSpeed / 20)
			Tracks[PlayerToAnimate]["RunTrack"]:AdjustSpeed(Humanoid.WalkSpeed / 20)

			if Speed > 0.01 then
				if Connections[PlayerToAnimate]["StopDebounce"] then
					task.cancel(Connections[PlayerToAnimate]["StopDebounce"])
					Connections[PlayerToAnimate]["StopDebounce"] = nil
				end

				if IsRunning then
					if Tracks[PlayerToAnimate]["WalkTrack"].IsPlaying then
						Tracks[PlayerToAnimate]["WalkTrack"]:Stop(0.25)
					end
					if not Tracks[PlayerToAnimate]["RunTrack"].IsPlaying then
						Tracks[PlayerToAnimate]["RunTrack"]:Play(0.25)
					end
				else
					if Tracks[PlayerToAnimate]["RunTrack"].IsPlaying then
						Tracks[PlayerToAnimate]["RunTrack"]:Stop(0.1)
					end
					if not Tracks[PlayerToAnimate]["WalkTrack"].IsPlaying then
						Tracks[PlayerToAnimate]["WalkTrack"]:Play(0.25)
					end
				end
			else
				if not Connections[PlayerToAnimate]["StopDebounce"] then
					Connections[PlayerToAnimate]["StopDebounce"] = task.delay(0.15, function()
						if Tracks[PlayerToAnimate]["RunTrack"].IsPlaying then
							Tracks[PlayerToAnimate]["RunTrack"]:Stop(0.1)
						end
						if Tracks[PlayerToAnimate]["WalkTrack"].IsPlaying then
							Tracks[PlayerToAnimate]["WalkTrack"]:Stop(0.25)
						end
						Connections[PlayerToAnimate]["StopDebounce"] = nil
					end)
				end
			end
		end)
	end

	-- START ANIMATIONS IF NO EQUIPPED GUN
	if not PlayerToAnimate:GetAttribute("IsEquippingGun") then
		StartMoveAnimations()
	end

	-- EQUIPPED GUN HANDLER
	Connections[PlayerToAnimate]["EquippedGunConnection"] = PlayerToAnimate:GetAttributeChangedSignal("IsEquippingGun")
		:Connect(function()
			if PlayerToAnimate:GetAttribute("IsEquippingGun") then
				PartialCleanup()
			else
				StartMoveAnimations()
			end
		end)

	-- CLEANUP ON DEATH
	Connections[PlayerToAnimate]["DiedConnection"] = Humanoid.Died:Connect(function()
		FullCleanup()
	end)
end

-- RECIEVE SIGNAL TO LOAD DEFAULT ANIMATIONS FOR SPECIFIC CHARACTER
local function OnPlayerAdded(Player)
	ClientUtilities.BindToCharacter(Player, SetupCharacterAnimations)
end
-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(OnPlayerAdded)
