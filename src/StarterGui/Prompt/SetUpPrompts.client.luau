-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

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
	Cost = Cost.Value

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
		PromptText.Text = "Press E To Refill Ammo [" .. HalfCost .. "]"
	else
		PromptText.Text = Prompt.ActionText .. " [" .. Cost .. "]"
	end
end

-- UPDATE MYSTERY BOX PROMPT
local MysteryBoxCost = workspace:WaitForChild("MysteryBox"):WaitForChild("Cost").Value
local function UpdateMysteryBoxPrompt()
	-- UPDATE TEXT
	PromptText.Text = "Press E for Mystery Box [" .. MysteryBoxCost .. "]"
end

-- UPDATE MYSTERY GIVE GUN PROMPT
local function UpdateMysteryGiveGunPrompt(Prompt)
	-- CHECK FOR PLAYER STATES
	local IsRunning = Player:GetAttribute("IsRunning")
	local IsDashing = Player:GetAttribute("IsDashing")
	local IsShooting = Player:GetAttribute("IsShooting")
	local IsReloading = Player:GetAttribute("IsReloading")
	local IsCharging = Player:GetAttribute("IsCharging")
	local IsEquipping = Player:GetAttribute("IsEquipping")
	if IsRunning or IsDashing or IsShooting or IsReloading or IsCharging or IsEquipping then
		PromptGui.Enabled = false
		return
	end
	-- UPDATE TEXT
	local GunToGive = Prompt:GetAttribute("GunToGive")
	if not GunToGive then
		return
	end
	-- IF SAME GUN AS CURRENTLY EQUIPPING, THEN SHOW REFILL OPTION
	local PlayerGun = Player:GetAttribute("IsEquippingGun")
	if PlayerGun and PlayerGun == GunToGive then
		PromptText.Text = "Press E To Refill Ammo"
		return
	else
		PromptText.Text = "Press E To Equip " .. GunToGive
	end
	PromptGui.Enabled = true
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
Connections["PromptShown"] = ProximityPromptService.PromptShown:Connect(function(Prompt: ProximityPrompt)
	-- DONT SHOW IF KNOCKED OR DEAD
	if Player:GetAttribute("IsKnocked") or Humanoid.Health <= 0 then
		PromptGui.Enabled = false
		return
	end

	-- ONLY PLAYER THAT BOUGHT MYSTERY BOX SHOULD SEE OPTION TO GRAB GUN
	if Prompt.Name == "MysteryGiveGun" then
		local PlayerToEnablePrompt = Prompt:GetAttribute("Player")
		if not PlayerToEnablePrompt or PlayerToEnablePrompt ~= Player.Name then
			Prompt.Enabled = false
			return
		end
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

	PromptFunction.GiveGun(Part, Prompt)
end

-- GIVE FUTURE PARTS THAT GET ADDED
Connections["ChildAdded"] = GiveGunParts.ChildAdded:Connect(function(Part)
	local Prompt = Part:WaitForChild("GunPrompt")
	if not Prompt then
		return
	end

	PromptFunction.GiveGun(Part, Prompt)
end)

-- SETUP MYSTERY BOX PROMPT
for _, Part in workspace:WaitForChild("MysteryBox"):GetDescendants() do
	local Prompt = Part:FindFirstChild("MysteryPrompt")
	if not Prompt then
		continue
	end

	PromptFunction.MysteryBox(Prompt)
end

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

	-- RAYCAST FROM PLAYER TO PART CONTAINING PROMPT TO CHECK IF VISIBLE
	local Direction = (CurrentPrompt.Parent.Position - RootPart.Position).Unit
	local Distance = (CurrentPrompt.Parent.Position - RootPart.Position).Magnitude
	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterDescendantsInstances = { workspace:FindFirstChild("PhaseParts") }
	RaycastParams.FilterType = Enum.RaycastFilterType.Include
	local RaycastResult = workspace:Raycast(RootPart.Position, Direction * Distance, RaycastParams)
	if RaycastResult then
		PromptGui.Enabled = false
		return
	else
		PromptGui.Enabled = true
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

	-- MYSTERY GIVE GUN PROMPT UPDATE
	if CurrentPrompt.Name == "MysteryGiveGun" then
		UpdateMysteryGiveGunPrompt(CurrentPrompt)
		return
	end

	-- MYSTERY BOX PROMPT UPDATE
	if CurrentPrompt.Name == "MysteryPrompt" then
		UpdateMysteryBoxPrompt()
		return
	end
end)
