-- PLAYERS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- EVENTS
local MVPEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WaveEvents"):WaitForChild("MVPEvent")

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScoreboardGui = PlayerGui:WaitForChild("ScoreboardGui")
local MVPFrame = ScoreboardGui:WaitForChild("MVPFrame")
local RoundOverFrame = ScoreboardGui:WaitForChild("RoundOverFrame")
local MVPPackage = ScoreboardGui:WaitForChild("MVPPackage")
local WaveOver = RoundOverFrame:WaitForChild("WaveOver")

-- SCORE BOARD GUI
local ScoreboardFrame = ScoreboardGui:WaitForChild("ScoreboardFrame")
local PlayerRows = ScoreboardFrame:WaitForChild("PlayerRows")
local PlayerRowTemplate = PlayerRows:WaitForChild("PlayerRowTemplate")

-- ROUND OVER STUFF
local IsShowingRoundOver = false
local MVPAnimateTask = nil
local MVPPlayer = nil
local FreezeStats = false
local function BeginRoundOverSequence(NewMVPPlayer)
	MVPPlayer = NewMVPPlayer

	-- POSITION LABEL TO LEFT OF MVP PLAYER
	local MVPPlayerRow: Frame = PlayerRows:FindFirstChild(MVPPlayer.Name)
	if MVPPlayerRow then
		-- CLONE MVP PACKAGE
		local ClonedMVPPackage = MVPPackage:Clone()
		for _, Child in pairs(ClonedMVPPackage:GetChildren()) do
			Child.Parent = MVPPlayerRow
		end
		-- DESTROY FOLDER OF PACKAGE
		ClonedMVPPackage:Destroy()

		-- POSITION MVP TEXT
		local AbsPos = MVPPlayerRow.AbsolutePosition
		MVPFrame.Position = UDim2.fromOffset(AbsPos.X - MVPFrame.AbsoluteSize.X - 8, AbsPos.Y)
		MVPFrame.Visible = true

		-- MAKE THE PLAYER ROW BORDER SIZE 0
		MVPPlayerRow.BorderSizePixel = 0
	else
		MVPFrame.Visible = false
	end

	-- TOGGLE FLAG
	IsShowingRoundOver = true

	-- SHOW ROUND OVER FRAME
	RoundOverFrame.Visible = true

	-- MAKE SCOREBOARD VISIBLE
	ScoreboardFrame.Visible = true
end

local function EndRoundOverSequence()
	ScoreboardFrame.Visible = false
	-- HIDE ROUND OVER FRAME
	RoundOverFrame.Visible = false

	-- HIDE MVP FRAME
	MVPFrame.Visible = false

	-- STOP ANIMATING MVP FRAME
	if MVPAnimateTask then
		MVPAnimateTask:Disconnect()
		MVPAnimateTask = nil
	end

	-- DESTROY GRADIENT IN MVP PLAYER ROW
	if MVPPlayer then
		local MVPPlayerRow: Frame = PlayerRows:FindFirstChild(MVPPlayer.Name)
		if not MVPPlayerRow then
			return
		end
		local UIStroke = MVPPlayerRow:FindFirstChild("UIStroke")
		if UIStroke then
			UIStroke:Destroy()
		end
		local UICorner = MVPPlayerRow:FindFirstChild("UICorner")
		if UICorner then
			UICorner:Destroy()
		end

		-- MAKE THE PLAYER ROW BORDER SIZE 1
		MVPPlayerRow.BorderSizePixel = 1
	end

	-- TOGGLE FLAG
	IsShowingRoundOver = false
end

-- UPDATE FUNCTION
local function UpdateRow(Player)
	if FreezeStats then
		return
	end
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if not PlayerRow then
		return
	end
	local Kills = Player:GetAttribute("Kills") or 0
	local Deaths = Player:GetAttribute("Deaths") or 0
	local Revives = Player:GetAttribute("Revives") or 0
	local Knockdowns = Player:GetAttribute("Knockdowns") or 0
	local CurrentPoints = Player:GetAttribute("CurrentPoints") or 0
	CurrentPoints = math.round(CurrentPoints)

	PlayerRow.Kills.Text = tostring(Kills)
	PlayerRow.Deaths.Text = tostring(Deaths)
	PlayerRow.Revives.Text = tostring(Revives)
	PlayerRow.Knockdowns.Text = tostring(Knockdowns)
	PlayerRow.Points.Text = tostring(CurrentPoints)
end

-- SET ROUND OVER SEQUENCE TO MVP EVENT
MVPEvent.OnClientEvent:Connect(function(Player, WaveNumber)
	FreezeStats = true
	BeginRoundOverSequence(Player)
	if WaveNumber == 1 then
		WaveOver.Text = "YOU SURVIVED " .. WaveNumber .. " WAVE"
	else
		WaveOver.Text = "YOU SURVIVED " .. WaveNumber .. " WAVES"
	end
	task.delay(10, function()
		FreezeStats = false
		UpdateRow(Player)
		EndRoundOverSequence()
	end)
end)

-- REGULAR SCOREBOARD TOGGLE
local function ToggleScoreboard(On, ForceDisable)
	if IsShowingRoundOver then
		return
	end
	RoundOverFrame.Visible = false
	MVPFrame.Visible = false
	if ForceDisable then
		ScoreboardFrame.Visible = false
	else
		ScoreboardFrame.Visible = On
	end
end

UIS.InputBegan:Connect(function(Input, GameProcessed)
	-- ON ESCAPE KEY FORCE DISABLE SCOREBOARD
	if Input.KeyCode == Enum.KeyCode.Escape then
		if IsShowingRoundOver then
			return
		else
			ToggleScoreboard(false, true)
		end
	end
	if GameProcessed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.Tab then
		if IsShowingRoundOver then
			return
		else
			ToggleScoreboard(true)
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
			ToggleScoreboard(false)
		end
	end
end)

-- HELPER TO SET UP PLAYER ROW
local function SetUpPlayerRow(Player)
	-- ENSURE PLAYER ROW DOESNT GET EXIST
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if PlayerRow then
		return
	end
	-- CREATE NEW PLAYER ROW
	PlayerRow = PlayerRowTemplate:Clone()
	PlayerRow.Name = Player.Name
	PlayerRow.Parent = PlayerRows

	-- CHECK TO BOLD THE FRAME DEPENDING ON HOW MANY PLAYER ROWS THERE ARE
	if #PlayerRows:GetChildren() % 2 == 0 then
		PlayerRow.BackgroundColor3 = Color3.fromRGB(87, 87, 87)
	else
		PlayerRow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local StoredAttributes = {}
local function DeletePlayerRow(Player)
	local PlayerRow = PlayerRows:FindFirstChild(Player.Name)
	if PlayerRow then
		PlayerRow.Visible = false
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

	-- INITIAL UPDATE
	UpdateRow(Player)

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
