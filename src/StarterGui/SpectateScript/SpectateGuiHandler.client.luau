-- PLAYER STUFF
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- PLAYER GUI
local SpectateGui = PlayerGui:WaitForChild("SpectateGuiFolder"):WaitForChild("SpectateGui")
local ToggleSpectateGui = PlayerGui:WaitForChild("SpectateGuiFolder"):WaitForChild("ToggleSpectateGui")
local Main = SpectateGui:WaitForChild("Main")
local Count = SpectateGui:WaitForChild("Count")
local ToggleSpectateFrame = ToggleSpectateGui:WaitForChild("ToggleSpectateFrame")
local ToggleSpectateButton = ToggleSpectateFrame:WaitForChild("ToggleSpectateButton")
local PlayerSpectating = Main:WaitForChild("PlayerSpectating")
local LeftArrow = Main:WaitForChild("LeftArrow")
local RightArrow = Main:WaitForChild("RightArrow")
local SpectateCountText = Count:WaitForChild("SpectateCount")

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SpectateEvents")
local SpectateUpdate = SpectateEvents:WaitForChild("SpectateUpdate")

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))

-- VARS
local SpectateList = {}
local CurrentIndex = 1

-- DISABLE SPECTATE MODE HELPER
local function ResetSpectate()
	CurrentIndex = 1
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = LocalPlayer
	LocalPlayer:SetAttribute("SpectatingId", nil)
end

-- IF NO PLAYERS TO SPECTATE, DISABLE SPECTATE MODE
local function IfNoPlayersToSpectate()
	SpectateGui.Enabled = false
	ResetSpectate()
end

-- UPDATE SPECTATE LIST
local function UpdateSpectateList()
	table.clear(SpectateList)
	-- LOOP THROUGH PLAYERS TO UPDATE SPECTATE LIST
	for _, Player in pairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer and Player.Team and Player.Team.Name == "InRound" then
			-- INSERT PLAYER IF NEEDED
			if not table.find(SpectateList, Player) then
				table.insert(SpectateList, Player)
			end
		end
	end
	-- ENSURE CURRENT INDEX IS VALID
	if CurrentIndex > #SpectateList then
		CurrentIndex = 1
	end
end

-- UPDATE SPECTATE COUNT TEXT
local function UpdateSpectateCountText()
	SpectateCountText.Text = "SPECTATE (" .. CurrentIndex .. "/" .. #SpectateList .. ")"
end

-- UPDATE SPECTATE PLAYER TEXT
local function UpdateSpectatePlayerText()
	local CurrentPlayerSpectating = SpectateList[CurrentIndex]
	if not CurrentPlayerSpectating then
		warn("No player spectating?")
		return
	end
	PlayerSpectating.Text = CurrentPlayerSpectating.DisplayName
end

-- ON SPECTATING PLAYER DIED
local SpectatingConnection
local function OnSpectatingPlayerDied()
	UpdateSpectateList()
	UpdateSpectateCountText()
	if #SpectateList == 0 then
		IfNoPlayersToSpectate()
		return
	end
	CurrentIndex = CurrentIndex + 1
	if CurrentIndex > #SpectateList then
		CurrentIndex = 1
	end
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = SpectateList[CurrentIndex]
	LocalPlayer:SetAttribute("SpectatingId", SpectateList[CurrentIndex].UserId)
	UpdateSpectateCountText()

	-- IF PLAYER SPECTATING DIES, MOVE INDEX
	local Character = SpectateList[CurrentIndex].Character
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	if SpectatingConnection and SpectatingConnection.Disconnect then
		SpectatingConnection:Disconnect()
	end
	SpectatingConnection = Humanoid.Died:Connect(function()
		OnSpectatingPlayerDied()
	end)
	UpdateSpectatePlayerText()
end

-- HANDLE DEAD SPECTATING PLAYER CONNECTION
local function HandleDeadConnection()
	-- IF PLAYER SPECTATING DIES, MOVE INDEX
	local Character = SpectateList[CurrentIndex].Character or SpectateList[CurrentIndex].CharacterAdded:Wait()
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end
	if SpectatingConnection and SpectatingConnection.Disconnect then
		SpectatingConnection:Disconnect()
	end
	SpectatingConnection = Humanoid.Died:Connect(function()
		OnSpectatingPlayerDied()
	end)
end

-- ON TOGGLE SPECTATE BUTTON CLICK
ToggleSpectateButton.MouseButton1Click:Connect(function()
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end

	local CameraSettings = CurrentPlayerData.CameraSettings
	if not CameraSettings then
		return
	end

	-- UPDATE SPECTATE LISTS
	UpdateSpectateList()
	UpdateSpectateCountText()

	-- IF NO PLAYERS TO SPECTATE, RETURN
	if #SpectateList == 0 then
		IfNoPlayersToSpectate()
		return
	end

	-- ENABLE OR DISABLE SPECTATE MODE
	if SpectateGui.Enabled then
		-- IF SPECTATING, STOP SPECTATING
		ResetSpectate()
		SpectateGui.Enabled = false
	else
		-- IF NOT SPECTATING, START SPECTATING FIRST PLAYER IN LIST
		CameraSettings.PlayerViewing = SpectateList[CurrentIndex]
		LocalPlayer:SetAttribute("SpectatingId", SpectateList[CurrentIndex].UserId)
		-- UPDATE SPECTATE PLAYER TEXT
		UpdateSpectatePlayerText()
		SpectateGui.Enabled = true

		-- HANDLE IF SPECTATING PLAYER DIES
		HandleDeadConnection()
	end
end)

-- HELPER TO HANDLE SPECTATING IN EITHER LEFT OR RIGHT
local function MoveSpectating(Direction)
	-- UPDATE SPECTATE LIST
	UpdateSpectateList()
	if #SpectateList == 0 then
		IfNoPlayersToSpectate()
		return
	end
	-- INCREMENT OR DECREMENT INDEX
	if Direction == "Left" then
		CurrentIndex = CurrentIndex - 1
		if CurrentIndex < 1 then
			CurrentIndex = #SpectateList
		end
	elseif Direction == "Right" then
		CurrentIndex = CurrentIndex + 1
		if CurrentIndex > #SpectateList then
			CurrentIndex = 1
		end
	end

	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = SpectateList[CurrentIndex]
	LocalPlayer:SetAttribute("SpectatingId", SpectateList[CurrentIndex].UserId)
	UpdateSpectateCountText()
	UpdateSpectatePlayerText()

	-- IF PLAYER SPECTATING DIES, MOVE INDEX
	HandleDeadConnection()
end

-- ON LEFT ARROW CLICK
LeftArrow.MouseButton1Click:Connect(function()
	MoveSpectating("Left")
end)

-- ON RIGHT ARROW CLICK
RightArrow.MouseButton1Click:Connect(function()
	MoveSpectating("Right")
end)

-- ON INITIAL
if LocalPlayer.Team.Name ~= "InRound" then
	UpdateSpectateList()
	UpdateSpectateCountText()
	ToggleSpectateGui.Enabled = true
end

-- ON PLAYER TREAM CHANGE, UPDATE SPECTATE LIST
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	if not LocalPlayer.Team then
		return
	end
	-- PRINT THE TEAM
	if LocalPlayer.Team.Name == "InRound" then
		SpectateGui.Enabled = false
		ToggleSpectateGui.Enabled = false
		ResetSpectate()
	else
		SpectateGui.Enabled = false
		ToggleSpectateGui.Enabled = true
		CurrentIndex = 1
		UpdateSpectateList()
		UpdateSpectateCountText()
	end
end)

-- ON TP ATTRIBUTE CHANGE, DISABLE SPECTATE GUI
LocalPlayer:GetAttributeChangedSignal("Teleporting"):Connect(function()
	local IsTeleporting = LocalPlayer:GetAttribute("Teleporting")
	if IsTeleporting then
		SpectateGui.Enabled = false
		ToggleSpectateGui.Enabled = false
		ResetSpectate()
	end
end)

-- ON SPECTATING ID CHANGE FIRE TO SERVER FOR UPDATE
LocalPlayer:GetAttributeChangedSignal("SpectatingId"):Connect(function()
	local SpectatingId = LocalPlayer:GetAttribute("SpectatingId")
	if not SpectatingId then
		SpectateUpdate:FireServer(false)
	else
		SpectateUpdate:FireServer(SpectatingId)
	end
end)
