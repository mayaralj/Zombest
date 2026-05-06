-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- MODULES
local Frameworks = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")
local PromptFunction = require(Frameworks:WaitForChild("Prompt"):WaitForChild("PromptFunction"))
local ClientGunData =
	require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client"):WaitForChild("ClientGunData"))

-- GUI
local PlayerGui = Player:WaitForChild("PlayerGui")
local PromptGui = PlayerGui:WaitForChild("Prompt"):WaitForChild("PromptGui")
local PromptText = PromptGui:WaitForChild("PromptText")
local ProgressBar = PromptText:WaitForChild("Progress")

-- FOLDERS
local GiveGunParts = workspace:WaitForChild("GiveGunParts")

-- VARIABLES
local CurrentPrompt = nil

-- CONNECTIONS
local Connections = {}

-- UPDATE GUN PROMPT
local function UpdateGunPrompt(PartContainingPrompt, Prompt)
	local Cost = PartContainingPrompt:FindFirstChild("Cost")
	if not Cost then
		return
	end
	Cost = Cost.Value -- get the value of the int value

	-- UPDATE TEXT
	if Player:GetAttribute("IsEquippingGun") and Player:GetAttribute("IsEquippingGun") == PartContainingPrompt.Name then
		-- EMPTY PROMPT TEXT IF STREAM
		if Player:GetAttribute("BulletType") == "Stream" then
			PromptText.Text = ""
			return
		end

		-- GET CURRENT CLIENT GUN DATA
		local CurrentGunData = ClientGunData:Get(Player)
		if not CurrentGunData then
			return
		end

		-- HALF COST
		local HalfCost = Cost / 2
		PromptText.Text = "Press E To Refill Ammo (" .. HalfCost .. ")"
	else
		PromptText.Text = Prompt.ActionText .. " (" .. Cost .. ")"
	end
end

-- UPDATE REVIVE PROMPT VISIBILITY
local function UpdateReviveVisibility(Prompt, DT)
	-- ENSURE PROGRESS BAR GETS RESET EVEN IF NOT SHOWING
	if not Player:GetAttribute("IsReviving") then
		local Decrement = (DT / Prompt.HoldDuration) * 10
		ProgressBar.Size = UDim2.new(math.clamp(ProgressBar.Size.X.Scale - Decrement, 0, 1), 0, 1, 0)
	end

	-- GET SOME PLAYER INFO
	local IsKnocked = Player:GetAttribute("IsKnocked") or false
	local IsShooting = Player:GetAttribute("IsShooting") or false
	local IsReloading = Player:GetAttribute("IsReloading") or false
	local IsCharging = Player:GetAttribute("IsCharging") or false

	-- PROMPT OWNER (PLAYER KNOCKED)
	local PromptOwner = Prompt:FindFirstChild("PromptOwner")
	if not PromptOwner then
		return
	end

	-- SET VISIBILITY DEPENDING ON PLAYER INFO
	if PromptOwner then
		if PromptOwner.Value == Player or Humanoid.Health <= 0 then
			PromptGui.Enabled = false
		else
			PromptGui.Enabled = not IsKnocked and not IsShooting and not IsReloading and not IsCharging
		end
	else
		PromptGui.Enabled = not IsKnocked and not IsShooting and not IsReloading and not IsCharging
	end
	if not PromptGui.Enabled then
		return
	end

	-- UPDATE PROMPT
	PromptText.Text = "Hold E to Revive"
	Prompt.Style = Enum.ProximityPromptStyle.Custom

	-- UPDATE BACKGROUND
	if Player:GetAttribute("IsReviving") then
		local Increment = DT / Prompt.HoldDuration
		ProgressBar.Size = UDim2.new(math.clamp(ProgressBar.Size.X.Scale + Increment, 0, 1), 0, 1, 0)
	else
		local Decrement = (DT / Prompt.HoldDuration) * 10
		ProgressBar.Size = UDim2.new(math.clamp(ProgressBar.Size.X.Scale - Decrement, 0, 1), 0, 1, 0)
	end
end

-- SHOW UI ON PROMPT SHOWN
Connections["PromptShown"] = ProximityPromptService.PromptShown:Connect(function(Prompt)
	-- DONT SHOW IF KNOCKED OR DEAD
	if Player:GetAttribute("IsKnocked") or Humanoid.Health <= 0 then
		PromptGui.Enabled = false
		return
	end

	-- UPDATE CURRENT PROMPT
	CurrentPrompt = Prompt

	-- ENABLE AND ENSURE THE DEFAULT PROMPT IS HIDDEN
	Prompt.Style = Enum.ProximityPromptStyle.Custom
	PromptGui.Enabled = true
end)

-- HIDE PROMPT ACCORDINGLY
Connections["PromptHidden"] = ProximityPromptService.PromptHidden:Connect(function(Prompt)
	-- REMOVE CURRENT PROMPT
	CurrentPrompt = nil

	-- DISABLE GUI
	PromptGui.Enabled = false
end)

-- FOR ALL PARTS IN GUN PARTS SET UP THE EVENT TO GIVE THE GUN
for _, Part in GiveGunParts:GetChildren() do
	local Prompt = Part:WaitForChild("GunPrompt")
	if not Prompt then
		continue
	end

	PromptFunction.GiveGun(Part, Prompt, PromptText)
end

-- GIVE FUTURE PARTS THAT GET ADDED
Connections["ChildAdded"] = GiveGunParts.ChildAdded:Connect(function(Part)
	local Prompt = Part:WaitForChild("GunPrompt")
	if not Prompt then
		return
	end

	PromptFunction.GiveGun(Part, Prompt, PromptText)
end)

-- CLEANUP ONHUMANOID DIED
Humanoid.Died:Connect(function()
	PromptGui.Enabled = false
	-- DISCONNECT ALL CONNECTIONS
	for i, Connection in Connections do
		Connection:Disconnect()
		Connections[i] = nil
	end
end)

-- RENDER STEPPED TO CONTINUOUSLY UPDATE THE PROMPTS
Connections["PromptHeartbeat"] = RunService.Heartbeat:Connect(function(DT)
	if not Player:GetAttribute("IsReviving") and ProgressBar.Size.X.Scale > 0 then
		local Decrement = (DT / 1.5) * 10
		ProgressBar.Size = UDim2.new(math.clamp(ProgressBar.Size.X.Scale - Decrement, 0, 1), 0, 1, 0)
	end

	if not CurrentPrompt then
		return
	end

	-- REVIVE UPDATE
	if CurrentPrompt.Name == "RevivePrompt" then
		UpdateReviveVisibility(CurrentPrompt, DT)
		return
	end

	-- GUN PROMPT UPDATE
	if CurrentPrompt.Parent.Parent == GiveGunParts then
		UpdateGunPrompt(CurrentPrompt.Parent, CurrentPrompt)
		return
	end
end)
