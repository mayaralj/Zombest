-- PLAYERS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SERVICES
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScoreboardGui = PlayerGui:WaitForChild("ScoreboardGui"):WaitForChild("ScoreboardGui")
local MVPFrame = ScoreboardGui:WaitForChild("MVPFrame")
local RoundOverFrame = ScoreboardGui:WaitForChild("RoundOverFrame")
local MVPPackage = ScoreboardGui:WaitForChild("MVPPackage")

-- SCORE BOARD GUI
local ScoreboardFrame = ScoreboardGui:WaitForChild("ScoreboardFrame")
local Categories = ScoreboardFrame:WaitForChild("Categories")
local PlayerRows = ScoreboardFrame:WaitForChild("PlayerRows")
local PlayerRowTemplate = PlayerRows:WaitForChild("PlayerRowTemplate")

-- ROUND OVER STUFF
local IsShowingRoundOver = false
local MVPAnimateTask = nil
local MVPPlayer = nil
local function BeginRoundOverSequence(MVPPlayer)
	-- SHOW ROUND OVER FRAME
	RoundOverFrame.Visible = true

	-- UPDATE MVP NAME
	local MVPNameLabel = MVPFrame:WaitForChild("MVPName")
	MVPNameLabel.Text = MVPPlayer.Name

	-- SHOW MVP FRAME
	MVPFrame.Visible = true

	-- CLONE MVP PACKAGE
	local ClonedMVPPackage = MVPPackage:Clone()
	local UIGradient = nil

	-- ANIMATE MVP FRAME
	task.spawn(function()
		if MVPAnimateTask then
			MVPAnimateTask:Cancel()
		end

		MVPAnimateTask = RunService.Heartbeat:Connect(function(DT)
			UIGradient.Rotation = (UIGradient.Rotation + 90 * DT) % 180
		end)
	end)

	IsShowingRoundOver = true

	-- ENABLE THE GUI
	ScoreboardGui.Enabled = true
end
local function EndRoundOverSequence()
	ScoreboardGui.Enabled = false
	-- HIDE ROUND OVER FRAME
	RoundOverFrame.Visible = false

	-- HIDE MVP FRAME
	MVPFrame.Visible = false

	-- STOP ANIMATING MVP FRAME
	if MVPAnimateTask then
		MVPAnimateTask:Cancel()
	end

	IsShowingRoundOver = false
end

-- REGULAR SCOREBOARD TOGGLE
local function ToggleScoreboard()
	if IsShowingRoundOver then
		return
	end
	RoundOverFrame.Visible = false
	MVPFrame.Visible = false
	ScoreboardGui.Enabled = not ScoreboardGui.Enabled
end
UIS.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.Tab then
		if IsShowingRoundOver then
			return
		else
			ToggleScoreboard()
		end
	end
end)
UIS.InputEnded:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.Tab then
		if IsShowingRoundOver then
			return
		else
			ToggleScoreboard()
		end
	end
end)

-- HELPER TO SET UP PLAYER ROW
local function SetUpPlayerRow(Player)
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if not PlayerRow then
		PlayerRow = PlayerRowTemplate:Clone()
		PlayerRow.Name = Player.Name
		PlayerRow.Parent = PlayerRows
	end
end
local StoredAttributes = {}
local function DeletePlayerRow(Player)
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if PlayerRow then
		PlayerRow:Destroy()
	end

	-- LOOP THROUGH ATTRIBUTES
	if StoredAttributes[Player] then
		for _, Connection in pairs(StoredAttributes[Player]) do
			if Connection and Connection.Disconnect then
				Connection:Disconnect()
			end
		end
		StoredAttributes[Player] = nil
	end
end
local function SetUpRowUpdater(Player)
	-- ENSURE PLAYER ROW EXISTS
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if not PlayerRow then
		return
	end

	-- SET UP NAME AND IMAGE
	local PlayerHolder = PlayerRow:FindFirstChild("PlayerHolder")
	if not PlayerHolder then
		return
	end
	PlayerHolder:FindFirstChild("Name").Text = Player.Name
	PlayerHolder:FindFirstChild("Image").Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=180&h=180"

	-- IF PLAYER ROW IS FOR LOCAL PLAYER
	if Player == LocalPlayer then
		for _, TextLabel in pairs(PlayerRow:GetDescendants()) do
			if not TextLabel:IsA("TextLabel") then
				continue
			end
			-- BOLD TEXT LABEL
			TextLabel.FontFace = Font.new(TextLabel.FontFace.Family, Enum.FontWeight.Bold)
		end
	end

	-- UPDATE FUNCTION
	local function UpdateRow()
		local Kills = Player:GetAttribute("Kills") or 0
		local Deaths = Player:GetAttribute("Deaths") or 0
		local Revives = Player:GetAttribute("Revives") or 0
		local Knockdowns = Player:GetAttribute("Knockdowns") or 0
		local CurrentPoints = Player:GetAttribute("CurrentPoints") or 0

		PlayerRow.Kills.Text = tostring(Kills)
		PlayerRow.Deaths.Text = tostring(Deaths)
		PlayerRow.Revives.Text = tostring(Revives)
		PlayerRow.Knockdowns.Text = tostring(Knockdowns)
		PlayerRow.Points.Text = tostring(CurrentPoints)
	end

	-- INITIAL UPDATE
	UpdateRow()

	-- UPDATE ON ATTRIBUTE CHANGE
	if not StoredAttributes[Player] then
		StoredAttributes[Player] = {}
	end
	StoredAttributes[Player]["Kills"] = Player:GetAttributeChangedSignal("Kills"):Connect(UpdateRow)
	StoredAttributes[Player]["Deaths"] = Player:GetAttributeChangedSignal("Deaths"):Connect(UpdateRow)
	StoredAttributes[Player]["Revives"] = Player:GetAttributeChangedSignal("Revives"):Connect(UpdateRow)
	StoredAttributes[Player]["Knockdowns"] = Player:GetAttributeChangedSignal("Knockdowns"):Connect(UpdateRow)
	StoredAttributes[Player]["CurrentPoints"] = Player:GetAttributeChangedSignal("CurrentPoints"):Connect(UpdateRow)

	-- MAKE IT VISIBLE
	PlayerRow.Visible = true
end

-- SET UP CURRENT PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	SetUpPlayerRow(Player)
	SetUpRowUpdater(Player)
end
-- FOR NEW PLAYERS
Players.PlayerAdded:Connect(function(Player)
	SetUpPlayerRow(Player)
	SetUpRowUpdater(Player)
end)
-- FOR LEAVING PLAYERS
Players.PlayerRemoving:Connect(function(Player)
	DeletePlayerRow(Player)
end)
