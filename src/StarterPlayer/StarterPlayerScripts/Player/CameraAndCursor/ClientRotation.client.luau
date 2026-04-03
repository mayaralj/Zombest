-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")


-- PLAYER AND CAMERA
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")



-- MODULES
local ClientUtilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local ClientPlayerData = require(ClientData:WaitForChild("ClientPlayerData"))
local ClientGunData = require(ClientData:WaitForChild("ClientGunData"))



local function GetRotationData(PlayerRotating)
	local PlayerDataTable = ClientPlayerData:Get(PlayerRotating)
	if not PlayerDataTable then return end
	local RotationSettings = PlayerDataTable.RotationSettings
	if not RotationSettings then return end

	return RotationSettings
end



-- GET ANGLE BETWEEN VECTORS
local function GetAngleBetween(v1, v2)
	local Dot = v1:Dot(v2)
	Dot = math.clamp(Dot, -1, 1)
	return math.acos(Dot)
end



-- GET GROUND POSITION FROM MOUSE
local function GetMouseGroundPosition(PlayerRotating)
	local MouseLocation = UIS:GetMouseLocation()
	local Ray = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

	local Origin = Ray.Origin
	local Direction = Ray.Direction
	local RootY = PlayerRotating.Character and PlayerRotating.Character:FindFirstChild("HumanoidRootPart") and PlayerRotating.Character.HumanoidRootPart.Position.Y or 0

	if Direction.Y == 0 then return end

	local T = (RootY - Origin.Y) / Direction.Y
	if T < 0 then return end

	return Origin + Direction * T
end



-- RIGHT CLICK DISABLES ROTATION
UIS.InputBegan:Connect(function(Input, GameProcessed)
	local RotationSettings = GetRotationData()
	if not RotationSettings then return end
	
	if GameProcessed then return end
	if Input.UserInputType == Enum.UserInputType.MouseButton2 then
		RotationSettings.RotationEnabled = true -- keep enabled forever, dont think it fits the game
	end
end)



UIS.InputEnded:Connect(function(Input, GameProcessed)
	local RotationSettings = GetRotationData()
	if not RotationSettings then return end
	
	if GameProcessed then return end
	if Input.UserInputType == Enum.UserInputType.MouseButton2 then
		RotationSettings.RotationEnabled = true
	end
end)



-- FUNCTION TO CREATE OR GET ALIGNORIENTATION ON ROOTPART
local function GetOrCreateAlignOrientation(Root)
	local Align = Root:FindFirstChild("LookAlign")
	if not Align then
		-- CREATE ATTACHMENT
		local Attachment = Instance.new("Attachment")
		Attachment.Name = "LookAttachment"
		Attachment.Parent = Root

		-- APPLY ATTACHMENT AND SETTINGS
		Align = Instance.new("AlignOrientation")
		Align.Name = "LookAlign"
		Align.Attachment0 = Attachment
		Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
		Align.RigidityEnabled = false
		Align.MaxTorque = math.huge
		Align.Responsiveness = 30
		Align.Parent = Root
	end
	return Align
end



-- ROTATION UPDATER
local RotationPart = {}
local function OnCharacterAdded(CharacterRotating)
	local PlayerRotating = Players:GetPlayerFromCharacter(CharacterRotating)
	if not PlayerRotating then return end
	
	local RotationSettings = GetRotationData(PlayerRotating)
	if not RotationSettings then return end
	
	
	if RotationSettings.RenderConnection then
		RotationSettings.RenderConnection:Disconnect()
	end

	local RootPart = CharacterRotating:WaitForChild("HumanoidRootPart")
	local Humanoid = CharacterRotating:WaitForChild("Humanoid")
	if not RootPart or not Humanoid then return end
	
	-- TURN OFF AUTO ROTATE
	Humanoid.AutoRotate = false

	RotationSettings.IsDead = false

	Humanoid.Died:Connect(function()
		RotationSettings.IsDead = true
		if RotationSettings.RenderConnection then
			RotationSettings.RenderConnection:Disconnect()
			RotationSettings.RenderConnection = nil
		end
		if RotationPart[PlayerRotating] then
			RotationPart[PlayerRotating]:Destroy()
			RotationPart[PlayerRotating] = nil
		end
	end)
	
	if not RotationPart[PlayerRotating] then
		RotationPart[PlayerRotating] = GetOrCreateAlignOrientation(RootPart)
	end

	RotationSettings.RenderConnection = RunService.RenderStepped:Connect(function()
		if RotationSettings.IsDead then return end
		if not RotationSettings.RotationEnabled then return end

		local MousePos = GetMouseGroundPosition(PlayerRotating)
		if not MousePos then return end

		local RootPos = RootPart.Position
		local Direction = Vector3.new(MousePos.X - RootPos.X, 0, MousePos.Z - RootPos.Z)

		if Direction.Magnitude > 0.1 then
			local NewRotation = CFrame.new(RootPos, RootPos + Direction.Unit)
			local NewLookVector = NewRotation.LookVector
			RotationSettings.NewLookVector = NewLookVector

			if not RotationSettings.LastLookVector or GetAngleBetween(NewLookVector, RotationSettings.LastLookVector) > RotationSettings.AngleThreshold then
				local Align = RotationPart[PlayerRotating]
				
				-- DONT ALLOW ROTATION WHILE REVIVING
				if PlayerRotating:GetAttribute("IsReviving") and PlayerRotating:GetAttribute("RevivingPlayer") then 
					-- GET KNOCKED PLAYER
					local KnockedPlayerName = PlayerRotating:GetAttribute("RevivingPlayer")
					if not KnockedPlayerName then return end
					local KnockedPlayer = Players:FindFirstChild(KnockedPlayerName)
					if not KnockedPlayer then return end
					local KnockedRoot = KnockedPlayer.Character:FindFirstChild("HumanoidRootPart")
					if not KnockedRoot then return end

					-- CHANGE RIGIDITY TO TRUE
					Align.RigidityEnabled = true
					local DirectionToKnocked = (KnockedRoot.Position - RootPart.Position)
					local FlatDirection = Vector3.new(DirectionToKnocked.X, 0, DirectionToKnocked.Z).Unit

					local TargetCFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + FlatDirection)
					Align.CFrame = TargetCFrame
					
					RotationSettings.LastLookVector = NewLookVector
					return
				else
					Align.RigidityEnabled = false -- make sure its false since revive can set it to true
				end

				-- CHANGE ROOTPART LOOKVECTOR VIA ALIGNORIENTATION
				if typeof(NewLookVector) ~= "Vector3" or NewLookVector.Magnitude < 0.01 then return end
				local FlatLook = Vector3.new(NewLookVector.X, 0, NewLookVector.Z)

				local TargetCFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + FlatLook.Unit)
				
				
				if PlayerRotating:GetAttribute("IsEquippingGun") then
					local PlayerRotatingGunData = ClientGunData:Get(PlayerRotating)
					if not PlayerRotatingGunData then return end
					if PlayerRotating:GetAttribute("IsShooting") then
						Align.Responsiveness = PlayerRotatingGunData.Weight.ShotRotateWeight
					else
						Align.Responsiveness = PlayerRotatingGunData.Weight.RotateWeight
					end
				else
					Align.Responsiveness = 30
				end
				
				Align.CFrame = TargetCFrame 
				
				-- UPDATE LOOK VECTOR
				RotationSettings.LastLookVector = NewLookVector
			end
		end
	end)
end



-- RECIEVE SIGNAL TO LOAD DEFAULT ANIMATIONS FOR SPECIFIC CHARACTER
local function OnPlayerAdded(Player)
	ClientUtilities.BindToCharacter(Player, OnCharacterAdded)
end
-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(OnPlayerAdded)