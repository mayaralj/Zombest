-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Events = ReplicatedStorage:WaitForChild("Events")
local ServerData = ModuleScripts:WaitForChild("Data")


-- MODULES
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("Utilities"))
local PlayerData = require(ServerData:WaitForChild("PlayerData"))
local PlayerStaminaFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerStaminaFW"))
local GunData = require(ServerData:WaitForChild("GunData"))


-- EVENTS
local DashEvent = Events:WaitForChild("PlayerEvents"):WaitForChild("DashEvent")



-- ON SERVER EVENT
DashEvent.OnServerEvent:Connect(function(PlayerDashing)
	-- DATA
	local CurrentPlayerData = PlayerData:Get(PlayerDashing)
	if not CurrentPlayerData then return end
	
	-- ENSURE ENOUGH STAMINA
	if CurrentPlayerData.Stamina.CurrentStamina < 20 then return end
	
	-- CURRENT GUN DATA IF EXISTS
	local CurrentGunData = GunData:Get(PlayerDashing)	
	
	
	-- CHARACTER STUFF
	local Character = PlayerDashing.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then return end
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then return end
	
	
	-- CHECK IF SHOOTING
	if PlayerDashing:GetAttribute("IsShooting") then return end
	
	-- CHECK IF EQUIPPING
	if PlayerDashing:GetAttribute("IsEquipping") then return end
	
	-- CHECK IF CHARGING
	if PlayerDashing:GetAttribute("IsCharging") then return end
	
	-- CHECK IF KNOCKED
	if PlayerDashing:GetAttribute("IsKnocked") then return end
	
	-- SEE IF CAN RELOAD CANCEL WITH DASH
	if PlayerDashing:GetAttribute("IsReloading") then
		-- CANCEL INSTA IF SHOTGUN
		if not PlayerDashing:GetAttribute("ShotgunReload") then
			if (tick() - PlayerDashing:GetAttribute("TimeSinceStartedReloading"))/CurrentGunData.Ammo.ReloadTime > 0.75 then return end
		end
	end
	
	
	
	-- DASH COOLDOWN
	if (tick() - CurrentPlayerData.Dash.DashTimer) <= CurrentPlayerData.Dash.DashCooldown then return end
	CurrentPlayerData.Dash.DashTimer = tick()
	if PlayerDashing:GetAttribute("IsDashing") then return end
	
	
	-- MOVEMENT DIRECTION
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)

	
	-- ABLE TO CHANGE DIRECTION WHILE DASHING
	local Direction = Humanoid.MoveDirection
	local DashStill = false
	if Direction.Magnitude < 0.1 then
		Direction = RootPart.CFrame.LookVector
		DashStill = true
	end
	local IsSprinting = PlayerDashing:GetAttribute("IsSprinting")
	
	
	-- CALCULATE WHICH DIRECTION IN LEFT, RIGHT, FRONT, OR BACK AND SET ATTRIBUTE
	if Direction:Dot(RootPart.CFrame.LookVector) > 0.75 then
		PlayerDashing:SetAttribute("DashDirection", "Front")
	elseif Direction:Dot(RootPart.CFrame.RightVector) > 0.5 then
		PlayerDashing:SetAttribute("DashDirection", "Right")
	elseif Direction:Dot(RootPart.CFrame.RightVector) < -0.5 then
		PlayerDashing:SetAttribute("DashDirection", "Left")
	elseif Direction:Dot(RootPart.CFrame.LookVector) < -0.2 then
		PlayerDashing:SetAttribute("DashDirection", "Back")
	else
		PlayerDashing:SetAttribute("DashDirection", "Front")
	end
	
	
	-- DASH BONUS
	local SpeedDashBonus
	if 	IsSprinting then
		SpeedDashBonus = CurrentPlayerData.Sprint.SprintSpeed * 2
	else
		SpeedDashBonus = 0
	end
	
	-- LOWER DASH FORCE IF SHOOTING
	local PlayerDataDashForce = CurrentPlayerData.Dash.DashForce
	--if PlayerDashing:GetAttribute("IsShooting") then
	--	PlayerDataDashForce *= 0.5
	--end
	
	
	-- ADD WEIGHT TO DASH FORCE
	local DashForce
	if CurrentGunData then
		if PlayerDashing:GetAttribute("IsSprinting") then
			DashForce = PlayerDataDashForce + SpeedDashBonus - CurrentGunData.Weight.RunDashWeight
		else
			DashForce = PlayerDataDashForce + SpeedDashBonus - CurrentGunData.Weight.WalkDashWeight
		end
	else
		DashForce = PlayerDataDashForce + SpeedDashBonus
	end
	
	
	-- DASH DURATION WITH WEIGHT
	local DashDuration
	if CurrentGunData then
		DashDuration = CurrentPlayerData.Dash.DashDuration - CurrentGunData.Weight.DashDurationWeight
	else
		DashDuration = CurrentPlayerData.Dash.DashDuration
	end
	-- END IF NO DASH DURATION
	if DashDuration <= 0 then return end
	
	
	-- DASH FORCE FALLOFF
	local DashForceFalloff
	if PlayerDashing:GetAttribute("IsSprinting") then
		DashForceFalloff = CurrentPlayerData.Sprint.SprintSpeed
	else
		DashForceFalloff = CurrentPlayerData.Sprint.WalkSpeed/5
	end


	
	-- RUN SERVICE TO SMOOTHLY UPDATE
	local RunConn
	RunConn = RunService.Heartbeat:Connect(function(DT)
		-- CHANGE DIRECTION AND DECREASE FORCE OVERTIME
		if not DashStill then
			Direction = Humanoid.MoveDirection
		else
			Direction = RootPart.CFrame.LookVector
		end
		DashForce = math.max(0, DashForce - (DashForceFalloff * 10 * DT))
		BodyVelocity.Velocity = Direction * DashForce
	end)
	
	
	-- ADD AND PARENT
	BodyVelocity.Parent = RootPart
	Debris:AddItem(BodyVelocity, DashDuration)
	
	
	-- UPDATE STAMINA
	CurrentPlayerData.Stamina.TimeSinceSprinted = tick()
	PlayerStaminaFW.DecreaseStamina(PlayerDashing, 20)
	
	
	-- PREVENT ANY MOVEMENT
	PlayerDashing:SetAttribute("IsDashing", true)
	PlayerDashing:SetAttribute("DashingVFX", true)
	
	-- AFTER DASH ENDS
	task.delay(DashDuration + 0.05, function()
		BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		task.wait()
		if RunConn then
			RunConn:Disconnect()
			RunConn = nil
		end
		PlayerDashing:SetAttribute("IsDashing", false)
	end)
	task.delay(DashDuration + 0.25, function()
		PlayerDashing:SetAttribute("DashingVFX", false)
	end)
end)