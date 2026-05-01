-- SERVICES
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")

-- MODULES
local CharacterUtilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local ClientPlayerData = require(ClientData:WaitForChild("ClientPlayerData"))

-- PLAYER AND CAMERA
local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CAMERA DATA FROM CLIENT DATA TABLE
local function GetCameraData()
	local PlayerDataTable = ClientPlayerData:Get(LocalPlayer)
	if not PlayerDataTable then
		return
	end
	local CameraSettings = PlayerDataTable.CameraSettings
	if not CameraSettings then
		return
	end

	return CameraSettings
end

local function DetermineOffset(Count, Offset)
	if Count == 0 or Count == 1 then
		return Offset
	elseif Count == 2 then
		return CFrame.Angles(0, math.rad(20), 0) * Offset
	elseif Count == 3 then
		return CFrame.Angles(0, math.rad(-20), 0) * Offset
	elseif Count == 4 then
		return CFrame.Angles(math.rad(20), 0, 0) * Offset
	elseif Count == 5 then
		return CFrame.Angles(math.rad(-20), 0, 0) * Offset
	end

	return
end

-- APPLY CAMERA MOVEMENT
local TeamConn
local TeleportConn
local function SetupCamera()
	local CameraSettings = GetCameraData()
	if not CameraSettings then
		return
	end

	-- RESET CAMERA BACK TO LOCAL PLAYER
	CameraSettings.PlayerViewing = LocalPlayer
	if TeamConn then
		TeamConn:Disconnect()
	end
	TeamConn = LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
		CameraSettings.PlayerViewing = LocalPlayer
	end)
	-- ON TELEPORTING DO THE SAME
	if TeleportConn then
		TeleportConn:Disconnect()
	end
	TeleportConn = LocalPlayer:GetAttributeChangedSignal("Teleporting"):Connect(function()
		local IsTeleporting = LocalPlayer:GetAttribute("Teleporting")
		if IsTeleporting then
			CameraSettings.PlayerViewing = LocalPlayer
		end
	end)

	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end

	local RootPart = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	-- EXCLUDE PLAYER ACCESSORIES IN THE RAYCAST CHECK
	local CharacterParts = {}

	if CameraSettings.RenderConnection then
		CameraSettings.RenderConnection:Disconnect()
	end

	-- COLLISION RAY SETUP
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Exclude

	local TransparencyTask = {}
	local OriginalTransparency = {}
	local ExcludedParts = {}
	local LastRayTime = 0
	local LastPlayer = CameraSettings.PlayerViewing
	CameraSettings.RenderConnection = RunService.RenderStepped:Connect(function(DT)
		local Player = CameraSettings.PlayerViewing
		if not Player then
			return
		end
		local PlayerRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not PlayerRootPart then
			return
		end
		-- KEEP ATTEMPTING TO GET DATA
		local SprintingFlag = Player:GetAttribute("IsSprinting")
		if SprintingFlag then
			CameraSettings.TargetSprintZoom = 5
		else
			CameraSettings.TargetSprintZoom = 0
		end

		-- LERP ZOOM
		CameraSettings.SprintZoomOffset = math.lerp(
			CameraSettings.SprintZoomOffset,
			CameraSettings.TargetSprintZoom,
			math.clamp(CameraSettings.ZoomLerpSpeed * DT, 0, 1)
		)

		-- SCREENSHAKE
		if CurrentPlayerData then
			CurrentPlayerData.CameraSettings.ShakeOffset = CurrentPlayerData.CameraSettings.ShakeOffset:lerp(
				Vector3.new(0, 0, 0),
				math.clamp(CurrentPlayerData.CameraSettings.DecayToOriginSpeed * DT, 0, 1)
			)
		end

		-- MATH
		local EffectiveRadius = CameraSettings.Radius + CameraSettings.SprintZoomOffset
		local FlatDistance = math.cos(CameraSettings.TiltAngle) * EffectiveRadius
		local Height = math.sin(CameraSettings.TiltAngle) * EffectiveRadius

		local OffSetX = math.sin(CameraSettings.CameraAngle) * FlatDistance
		local OffSetZ = math.cos(CameraSettings.CameraAngle) * FlatDistance

		local Offset = Vector3.new(OffSetX, Height, OffSetZ)

		-- TARGET CAMERA CFRAME
		local TargetCFrame = CFrame.lookAt(PlayerRootPart.Position + Offset, PlayerRootPart.Position)

		-- UPDATE CHARACTER PARTS TO EXCLUDE IF VIEWING NEW PLAYER
		if LastPlayer ~= Player then
			LastPlayer = Player
			table.clear(CharacterParts)
			for _, Descendant in ipairs(Player.Character:GetDescendants()) do
				if Descendant:IsA("BasePart") then
					table.insert(CharacterParts, Descendant)
				end
			end
		end

		local RayResult
		if tick() - LastRayTime >= 0.1 then
			-- CLEAR TABLE
			table.clear(ExcludedParts)
			-- UPDATE TIME
			LastRayTime = tick()

			-- REPEAT RAYCAST
			for Count = 0, 5 do
				RayParams.FilterDescendantsInstances =
					{ Player.Character, unpack(CharacterParts), unpack(ExcludedParts) }
				local NewOffset = DetermineOffset(Count, Offset)
				RayResult = workspace:Raycast(PlayerRootPart.Position, NewOffset, RayParams)
				if RayResult then
					-- INSTANCE
					local RayInstance = RayResult.Instance
					-- ENSURE PART HAS PHASE TAG
					if not RayInstance:HasTag("PhaseTag") then
						continue
					end

					table.insert(ExcludedParts, RayInstance)

					-- ENSURE PART TRANSPARENCY IS NOT ALREADY HIGH
					if OriginalTransparency[RayInstance] and OriginalTransparency[RayInstance] >= 0.5 then
						continue
					end
					if not OriginalTransparency[RayInstance] and RayInstance.Transparency >= 0.5 then
						continue
					end

					-- TRANSPARENCY
					if not OriginalTransparency[RayInstance] then
						OriginalTransparency[RayInstance] = RayInstance.Transparency
					end

					RayInstance.Transparency = 0.5
					if TransparencyTask[RayResult.Instance] then
						task.cancel(TransparencyTask[RayResult.Instance])
					end

					-- FLAG RAY AS EXCLUDED AND SET UP TRANSPARENCY REVERT
					TransparencyTask[RayResult.Instance] = task.delay(0.1, function()
						RayInstance.Transparency = OriginalTransparency[RayInstance]
					end)
				end
			end
		end

		-- SCREENSHAKE IF MODIFIED
		local ShakeOffset = CurrentPlayerData and CurrentPlayerData.CameraSettings.ShakeOffset or Vector3.new(0, 0, 0)
		TargetCFrame += ShakeOffset

		-- TWEEN CFRAME TO TARGET
		Camera.CFrame = TargetCFrame
		-- FOCUS CAMERA
		Camera.Focus = PlayerRootPart.CFrame
	end)
end

-- RIGHT CLICK START
UIS.InputBegan:Connect(function(input, gameProcessed)
	local CameraSettings = GetCameraData()
	if not CameraSettings then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		CameraSettings.Rotating = true
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

-- RIGHT CLICK END
UIS.InputEnded:Connect(function(input)
	local CameraSettings = GetCameraData()
	if not CameraSettings then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		CameraSettings.Rotating = false
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

-- MOUSE MOVEMENT
UIS.InputChanged:Connect(function(input)
	local CameraSettings = GetCameraData()
	if not CameraSettings then
		return
	end

	if CameraSettings.Rotating and input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = input.Delta
		-- Rotate horizontally
		if Delta.X ~= 0 then
			CameraSettings.CameraAngle -= Delta.X * CameraSettings.RotateSensitivity
		end

		-- Tilt vertically ONLY if no left/right movement
		--if Delta.Y ~= 0 and Delta.X <= 0.05 then
		--	local NewTilt = CameraSettings.TiltAngle + (Delta.Y * 0.1 * math.rad(1))
		--	CameraSettings.TiltAngle = math.clamp(NewTilt, math.rad(50), math.rad(70))
		--end
	end
end)

-- SCROLLING ZOOM
UIS.InputChanged:Connect(function(input)
	local CameraSettings = GetCameraData()
	if not CameraSettings then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseWheel then
		CameraSettings.Radius = math.clamp(
			CameraSettings.Radius - input.Position.Z * CameraSettings.ZoomSensitivity,
			CameraSettings.MinRadius,
			CameraSettings.MaxRadius
		)
	end
end)

-- CHARACTER ADDED
CharacterUtilities.BindToCharacter(LocalPlayer, SetupCamera)
