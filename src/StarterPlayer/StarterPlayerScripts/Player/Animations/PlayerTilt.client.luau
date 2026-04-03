-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- FOLDERS

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientUtilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local ClientGunData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientGunData"))

-- TABLES
local Connections = {}

-- FUNCTION TO TILT CHARACTER
local function ActivateTilt(CharacterToTilt)
	-- CHARACTER
	local PlayerToTilt = Players:GetPlayerFromCharacter(CharacterToTilt)
	local Humanoid = CharacterToTilt:WaitForChild("Humanoid")
	local RootPart = CharacterToTilt:WaitForChild("HumanoidRootPart")

	-- ROOTJOINT AND BASE TILT
	local RootJoint = RootPart:FindFirstChild("RootJoint")
	if not RootJoint then
		return
	end
	local BaseTilt = RootJoint.C0

	-- CLEANUP
	if Connections[PlayerToTilt] then
		Connections[PlayerToTilt]:Disconnect()
		Connections[PlayerToTilt] = nil
	end
	-- HEARTBEAT
	Connections[PlayerToTilt] = RunService.Heartbeat:Connect(function(DT)
		local GunData = ClientGunData:Get(PlayerToTilt)
		local TiltMultiplier = 1
		if GunData and GunData.Weight and GunData.Weight.TiltMultiplier then
			TiltMultiplier = GunData.Weight.TiltMultiplier
		end

		-- GET SPEED
		local MoveDirection = Humanoid.MoveDirection
		local Speed = Humanoid.WalkSpeed * MoveDirection.Magnitude

		-- CHECK IF MOVING
		if Speed > 0.1 and not PlayerToTilt:GetAttribute("IsShooting") then
			local RelativeDirection = RootPart.CFrame:VectorToObjectSpace(MoveDirection)

			local ForwardTilt = -RelativeDirection.Z * 0.075 * TiltMultiplier
			local SideTilt = -RelativeDirection.X * 0.075 * TiltMultiplier

			local TargetTilt = BaseTilt * CFrame.Angles(ForwardTilt, SideTilt, 0)
			RootJoint.C0 = RootJoint.C0:Lerp(TargetTilt, 10 * DT)
		else
			RootJoint.C0 = RootJoint.C0:Lerp(BaseTilt, 10 * DT)
		end
	end)
end

-- RECIEVE SIGNAL TO LOAD DEFAULT ANIMATIONS FOR SPECIFIC CHARACTER
local function OnPlayerAdded(Player)
	ClientUtilities.BindToCharacter(Player, ActivateTilt)
end
-- FOR ALL CURRENT PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(OnPlayerAdded)
