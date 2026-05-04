-- PLAYER STUFF
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- PLAYER GUI
local SpectateGui = PlayerGui:WaitForChild("SpectateGui")
local ToggleSpectateGui = PlayerGui:WaitForChild("ToggleSpectateGui")
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
local RunService = game:GetService("RunService")
local SpectateEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SpectateEvents")
local SpectateUpdate = SpectateEvents:WaitForChild("SpectateUpdate")

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))
local SpectateScriptFolder = script.Parent
local SpectateHelper = require(SpectateScriptFolder:WaitForChild("SpectateHelper"))

-- VARS
local SpectateList = {}
local BlackList = {}

-- DISABLE SPECTATE MODE HELPER

-- IF NO PLAYERS TO SPECTATE, DISABLE SPECTATE MODE
local function IfNoPlayersToSpectate()
	SpectateGui.Enabled = false
	SpectateHelper.ResetSpectate()
end

-- UPDATE SPECTATE LIST
local function UpdateSpectateList()
	table.clear(SpectateList)
	-- LOOP THROUGH PLAYERS TO UPDATE SPECTATE LIST
	for _, Player in pairs(Players:GetPlayers()) do
		if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then
			continue
		end
		if Player ~= LocalPlayer and Player.Team and Player.Team.Name == "InRound" then
			-- INSERT PLAYER IF NOT BLACKLISTED
			if not table.find(BlackList, Player) then
				table.insert(SpectateList, Player)
			end
		end
	end
	-- ENSURE CURRENT INDEX IS VALID
	if SpectateHelper.CurrentIndex > #SpectateList then
		SpectateHelper.CurrentIndex = 1
	end
end

-- UPDATE SPECTATE COUNT TEXT
local function UpdateSpectateCountText()
	SpectateCountText.Text = "SPECTATE (" .. SpectateHelper.CurrentIndex .. "/" .. #SpectateList .. ")"
end

-- UPDATE SPECTATE PLAYER TEXT
local function UpdateSpectatePlayerText()
	local CurrentPlayerSpectating = SpectateList[SpectateHelper.CurrentIndex]
	if not CurrentPlayerSpectating then
		warn("No player spectating?")
		return
	end
	PlayerSpectating.Text = CurrentPlayerSpectating.DisplayName
end

-- ON SPECTATING PLAYER DIED
local SpectatingConnection
local function OnSpectatingPlayerDied(DiedPlayer)
	-- iF EXTERNAL CAUSE, ENSURE INDEX MOVES TO NEXT PLAYER IN LIST
	if SpectateList[SpectateHelper.CurrentIndex] ~= DiedPlayer then
		return
	end
	-- BLACKLIST PLAYER WHO DIED TO PREVENT SPECTATING AGAIN
	if DiedPlayer then
		table.insert(BlackList, DiedPlayer)
		task.delay(3, function()
			table.remove(BlackList, table.find(BlackList, DiedPlayer))
		end)
	end
	UpdateSpectateList()
	UpdateSpectateCountText()
	if #SpectateList == 0 then
		IfNoPlayersToSpectate()
		return
	end
	SpectateHelper.CurrentIndex = SpectateHelper.CurrentIndex + 1
	if SpectateHelper.CurrentIndex > #SpectateList then
		SpectateHelper.CurrentIndex = 1
	end
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = SpectateList[SpectateHelper.CurrentIndex]
	LocalPlayer:SetAttribute("SpectatingId", SpectateList[SpectateHelper.CurrentIndex].UserId)
	UpdateSpectateCountText()

	-- IF PLAYER SPECTATING DIES, MOVE INDEX
	local Character = SpectateList[SpectateHelper.CurrentIndex].Character
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	if not Humanoid then
		warn("Missing Char or Humanoid")
		return
	end
	if SpectatingConnection and SpectatingConnection.Disconnect then
		SpectatingConnection:Disconnect()
	end
	SpectatingConnection = Humanoid.Died:Connect(function()
		-- PLAYER THAT DIED
		DiedPlayer = SpectateList[SpectateHelper.CurrentIndex]
		OnSpectatingPlayerDied(DiedPlayer)
	end)
	UpdateSpectatePlayerText()
end

-- HANDLE DEAD SPECTATING PLAYER CONNECTION
local function HandleDeadConnection()
	task.spawn(function()
		-- IF PLAYER SPECTATING DIES, MOVE INDEX
		local Character = SpectateList[SpectateHelper.CurrentIndex].Character
			or SpectateList[SpectateHelper.CurrentIndex].CharacterAdded:Wait()
		local Humanoid = Character and Character:FindFirstChild("Humanoid")
		if not Humanoid then
			warn("Missing Char or Humanoid")
			return
		end
		if SpectatingConnection and SpectatingConnection.Disconnect then
			SpectatingConnection:Disconnect()
		end
		SpectatingConnection = Humanoid.Died:Connect(function()
			-- PLAYER THAT DIED
			local DiedPlayer = SpectateList[SpectateHelper.CurrentIndex]
			OnSpectatingPlayerDied(DiedPlayer)
		end)
	end)
end

-- ON TOGGLE SPECTATE BUTTON CLICK
ToggleSpectateButton.MouseButton1Click:Connect(function()
	-- DO NOT ALLOW SPECTATING IF TELEPORTING OR NOT IN LOBBY TEAM
	if LocalPlayer:GetAttribute("Teleporting") or not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Lobby" then
		return
	end
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
		SpectateHelper.ResetSpectate()
		SpectateGui.Enabled = false
	else
		-- IF NOT SPECTATING, START SPECTATING FIRST PLAYER IN LIST
		CameraSettings.PlayerViewing = SpectateList[SpectateHelper.CurrentIndex]
		LocalPlayer:SetAttribute("SpectatingId", SpectateList[SpectateHelper.CurrentIndex].UserId)
		-- UPDATE SPECTATE PLAYER TEXT
		UpdateSpectatePlayerText()
		SpectateGui.Enabled = true

		-- HANDLE IF SPECTATING PLAYER DIES
		HandleDeadConnection()
	end
end)

-- HELPER TO HANDLE SPECTATING IN EITHER LEFT OR RIGHT
local function MoveSpectating(Direction)
	-- DO NOT ALLOW SPECTATING IF TELEPORTING OR NOT IN LOBBY TEAM
	if LocalPlayer:GetAttribute("Teleporting") or not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Lobby" then
		return
	end
	-- UPDATE SPECTATE LIST
	UpdateSpectateList()
	if #SpectateList == 0 then
		IfNoPlayersToSpectate()
		return
	end
	-- INCREMENT OR DECREMENT INDEX
	if Direction == "Left" then
		SpectateHelper.CurrentIndex = SpectateHelper.CurrentIndex - 1
		if SpectateHelper.CurrentIndex < 1 then
			SpectateHelper.CurrentIndex = #SpectateList
		end
	elseif Direction == "Right" then
		SpectateHelper.CurrentIndex = SpectateHelper.CurrentIndex + 1
		if SpectateHelper.CurrentIndex > #SpectateList then
			SpectateHelper.CurrentIndex = 1
		end
	end

	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = SpectateList[SpectateHelper.CurrentIndex]
	LocalPlayer:SetAttribute("SpectatingId", SpectateList[SpectateHelper.CurrentIndex].UserId)
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
		SpectateHelper.ResetSpectate()
	elseif LocalPlayer.Team.Name == "Lobby" then
		SpectateGui.Enabled = false
		ToggleSpectateGui.Enabled = true
		SpectateHelper.CurrentIndex = 1
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
		SpectateHelper.ResetSpectate()
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
