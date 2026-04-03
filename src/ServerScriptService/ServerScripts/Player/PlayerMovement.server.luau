-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Events = ReplicatedStorage:WaitForChild("Events")
local ServerData = ModuleScripts:WaitForChild("Data")


-- MODULES
local PlayerStaminaFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerStaminaFW"))
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("Utilities"))
local PlayerData = require(ServerData:WaitForChild("PlayerData"))
local GunData = require(ServerData:WaitForChild("GunData"))
local WeightAdjustFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("WeightAdjustFW"))


-- EVENTS
local SprintEvent = Events:WaitForChild("PlayerEvents"):WaitForChild("SprintEvent")



-- GET GUN-BASED SPEED MODIFIERS
local function GetSpeeds(Player, CurrentGunData)
	local FallBackWalkSpeed = 16
	local FallBackSprintSpeed = 24
	
	
	-- PLAYER DATA
	local Data = PlayerData:Get(Player)
	if not Data then return end
		

	-- GUN STUFF
	local GunName = Player:GetAttribute("EquippedGun")
	local CurrentGunData = GunData:Get(Player)
	if not CurrentGunData then return Data.Sprint.WalkSpeed, Data.Sprint.SprintSpeed end
	
	-- ADJUST WEIGHT ACCORDINGLY
	WeightAdjustFW.MoveWeightAdjust(Player, CurrentGunData)

	-- GET MOVE SUBTRACT
	local MoveWeight = CurrentGunData.Weight.MoveWeight
	if not MoveWeight then return Data.Sprint.WalkSpeed, Data.Sprint.SprintSpeed end

	-- FINAL SPEEDS
	local Walk = Data.Sprint.WalkSpeed or FallBackWalkSpeed
	local Sprint = Data.Sprint.SprintSpeed or FallBackSprintSpeed

	Walk = Walk - (Walk * MoveWeight)
	Sprint = Sprint - (Sprint * MoveWeight)

	if Walk < 0 then Walk = 0 end
	if Sprint < 0 then Sprint = 0 end

	return Walk, Sprint
end



-- SET INITIAL STAMINA VALUES WHEN CHARACTER ADDED
Utilities.BindToCharacter(function(Character)
	local Player = game.Players:GetPlayerFromCharacter(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	if not Player or not Humanoid then return end

	local Data = PlayerData:Get(Player)
	if not Data then return end
	
	Player:SetAttribute("IsSprinting", false)
	
	-- SET JUMP STATE
	Humanoid.UseJumpPower = true
	Humanoid.JumpPower = 0	
end)



-- CLEANUP ON PLAYER LEAVE
game.Players.PlayerRemoving:Connect(function(Player)
	local Data = PlayerData:Get(Player)
	if not Data then return end

	Data.Stamina.CurrentStamina = nil
	Data.Stamina.CurrentlySprinting = nil
	Data.Stamina.TimeSinceSprinted = nil
	if Data.Sprint.SprintLoop then 
		Data.Sprint.SprintLoop:Disconnect()
		Data.Sprint.SprintLoop = nil
	end
end)



-- HANDLE SPRINTING
SprintEvent.OnServerEvent:Connect(function(Player, IsSprinting)
	Player:SetAttribute("WantsToSprint", IsSprinting)
end)



-- ONE HEARTBEAT FOR ALL PLAYERS
RunService.Heartbeat:Connect(function(DT)
	for _, Player in ipairs(game.Players:GetPlayers()) do
		-- GET DATA
		local Data = PlayerData:Get(Player)
		if not Data then continue end
		local CurrentGunData = GunData:Get(Player)

		local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
		if not Humanoid then continue end
		if Humanoid.Health <= 0 then return end
		

		-- SLOW MOVEMENT WHILE PLAYER IS REVIVING
		if Player:GetAttribute("IsReviving") then
			Humanoid.WalkSpeed = 4
			Player:SetAttribute("IsSprinting", false)
			continue
		end
		

		-- GET WALK AND SPRINT SPEED
		local Walk, Sprint = GetSpeeds(Player, CurrentGunData)
		if not Walk or not Sprint then continue end


		-- 0.1 SECOND COOLDOWN FOR SPRINTING AND STAMINA
		--Data.Sprint.WaitToSprint = (Data.Sprint.WaitToSprint or 0) + DT
		--if Data.Sprint.WaitToSprint < 0.1 then continue end
		--Data.Sprint.WaitToSprint = 0
		
		-- GET ATTRIBUTE
		local WantsToSprint = Player:GetAttribute("WantsToSprint")
		local HasStamina = (Data.Stamina.CurrentStamina or 0) > 0
		
		
		-- CANT SPRINT WHILE RELOADING
		if Player:GetAttribute("IsReloading") then WantsToSprint = false end
		if Player:GetAttribute("IsCharging") then WantsToSprint = false end
		if Player:GetAttribute("IsEquipping") then WantsToSprint = false end
		if Player:GetAttribute("IsDashing") then WantsToSprint = false end
		
		-- LOWER SPEED IF SHOOTING
		if Player:GetAttribute("IsShooting") then
			Sprint = Sprint * 0.9
		end
		
		
		-- APPLY SPEEDS AND STAMINA
		if WantsToSprint and not Player:GetAttribute("IsKnocked") then
			if HasStamina then
				Humanoid.WalkSpeed = Sprint
				Player:SetAttribute("IsSprinting", true)
				PlayerStaminaFW.DecreaseStamina(Player, 15 * DT)
				Data.Stamina.TimeSinceSprinted = nil
			else
				Humanoid.WalkSpeed = Walk
				Player:SetAttribute("IsSprinting", false)
				Data.Stamina.TimeSinceSprinted = Data.Stamina.TimeSinceSprinted or tick()
				PlayerStaminaFW.RegenStamina(Player, 20 * DT)
			end
		else
			Player:SetAttribute("IsSprinting", false)
			Data.Stamina.TimeSinceSprinted = Data.Stamina.TimeSinceSprinted or tick()

			if not Data.Knockdown.IsKnocked then
				Humanoid.WalkSpeed = Walk
			end
			PlayerStaminaFW.RegenStamina(Player, 20 * DT)
		end
	end
end)
