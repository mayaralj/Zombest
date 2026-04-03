-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")


-- MODULES
local ClientPlayerDataModule = require(ClientData:WaitForChild("ClientPlayerData"))
local ClientGunDataModule = require(ClientData:WaitForChild("ClientGunData"))
local RockModule = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks"):WaitForChild("Rock"):WaitForChild("RockModule"))



-- KNOCKED ASSETS
local function PlayKnockedAnims()
	-- CHARACTER
	local Character = Player.Character
	local Humanoid = Character:FindFirstChild("Humanoid")
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart or not Player then return end

	-- DATA
	local ClientPlayerData = ClientPlayerDataModule:Get(Player)
	if not ClientPlayerData then return end


	-- SFX
	local OnKnockSFX = Instance.new("Sound")
	OnKnockSFX.SoundId = ClientPlayerData.Knockdown.OnKnockSFX
	OnKnockSFX.Volume = 1
	OnKnockSFX.Looped = false
	OnKnockSFX.Parent = workspace:FindFirstChild("Camera")
	OnKnockSFX:Play()

	local MovingSFX = Instance.new("Sound")
	MovingSFX.SoundId = ClientPlayerData.Knockdown.MovingSFX
	MovingSFX.Volume = 0.2
	MovingSFX.Looped = false
	MovingSFX.Parent = RootPart


	-- ANIMATION
	local KnockedIdle = Instance.new("Animation")
	local KnockedMoving = Instance.new("Animation")
	local KnockedShooting = Instance.new("Animation")

	
	-- VFX
	local DustVFX = ReplicatedStorage:FindFirstChild("GunVFX"):FindFirstChild("Dust"):FindFirstChild("Dust"):Clone()
	
	
	-- ANIMATION IDS
	KnockedIdle.AnimationId = ClientPlayerData.Knockdown.IdleAnimation
	KnockedMoving.AnimationId = ClientPlayerData.Knockdown.MovingAnimation
	KnockedShooting.AnimationId = ClientPlayerData.Knockdown.KnockedShooting
	
	-- PRE LOAD
	ContentProvider:PreloadAsync({KnockedIdle, KnockedMoving, KnockedShooting})

	-- LOAD ANIMATIONS
	local IdleTrack = Humanoid:LoadAnimation(KnockedIdle)
	local WalkTrack = Humanoid:LoadAnimation(KnockedMoving)
	local ShootingTrack = Humanoid:LoadAnimation(KnockedShooting)
	
	-- SET TRACKS
	ShootingTrack.Looped = false
	ShootingTrack.Priority = Enum.AnimationPriority.Action4
	
	IdleTrack.Looped = true
	IdleTrack.Priority = Enum.AnimationPriority.Action
	
	WalkTrack.Looped = true
	WalkTrack.Priority = Enum.AnimationPriority.Action2


	local function PlayIdle()
		if not IdleTrack.IsPlaying then
			WalkTrack:Stop()
			IdleTrack:Play()
		end
	end

	local function PlayWalk()
		if not WalkTrack.IsPlaying then
			IdleTrack:Stop()
			WalkTrack:Play()
			WalkTrack:AdjustSpeed(0.5)
		end
	end
	
	-- GET PLAYSFXVFX ANIMATION MARKER FROM WALK TRACK
	local AnimationSignal
	AnimationSignal= WalkTrack:GetMarkerReachedSignal("PlaySFXVFX"):Connect(function()
		RockModule.PlayDustVFX(Character, DustVFX, "Left")
		MovingSFX:Play()
	end)
	
	
	-- MOVING CONNECTION
	local KnockedAnimConnection = RunService.Heartbeat:Connect(function()
		if not Character.Parent then return end
		local Velocity = RootPart.Velocity
		local FlatSpeed = Vector3.new(Velocity.X, 0, Velocity.Z).Magnitude
		if FlatSpeed > 1 then
			PlayWalk()
		else
			PlayIdle()
		end
	end)
	
	
	-- SHOOTING CONNECTION
	local StartShootingConnection
	StartShootingConnection = Player:GetAttributeChangedSignal("ShotFired"):Connect(function()
		if Player:GetAttribute("ShotFired") then
			ShootingTrack:Play()
		end
	end)
	
	return function()
		if IdleTrack then IdleTrack:Stop() IdleTrack:Destroy() end
		if WalkTrack then WalkTrack:Stop() WalkTrack:Destroy() end
		if ShootingTrack then ShootingTrack:Stop() ShootingTrack:Destroy() end
		if StartShootingConnection then StartShootingConnection:Disconnect() StartShootingConnection = nil end
		if KnockedAnimConnection then KnockedAnimConnection:Disconnect() KnockedAnimConnection = nil end
		if AnimationSignal then AnimationSignal:Disconnect() AnimationSignal = nil end
	end
end



-- ON CLIENT EVENT TO DETERMINE TO PLAY OR STOP ANIMS
local KnockedSignal
local StopKnockedAnims -- store the cleanup function outside
KnockedSignal = Player:GetAttributeChangedSignal("IsKnocked"):Connect(function()
	if Player:GetAttribute("IsKnocked") then
		if StopKnockedAnims then
			StopKnockedAnims()
		end
		StopKnockedAnims = PlayKnockedAnims()
	else
		if StopKnockedAnims then
			StopKnockedAnims()
			StopKnockedAnims = nil
		end
	end
end)