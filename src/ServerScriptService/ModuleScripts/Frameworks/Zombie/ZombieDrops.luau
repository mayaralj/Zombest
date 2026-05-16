local ZombieDrops = {}

-- SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- MODULES
local GunFW = require(
	ServerScriptService:WaitForChild("ModuleScripts")
		:WaitForChild("Frameworks")
		:WaitForChild("Gun")
		:WaitForChild("GunFW")
)
local PlayerData =
	require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data"):WaitForChild("PlayerData"))

-- FOLDERS
local ZombieDropModels = ReplicatedStorage:WaitForChild("ZombieDropModels")

-- EVENTS
local ZombieDropEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZombieDropEvents")
local PlayDropSFX = ZombieDropEvents:WaitForChild("PlayDropSFX")

-- DROP MODELS
local DoublePoints = ZombieDropModels:WaitForChild("DoublePoints")
local InstaKill = ZombieDropModels:WaitForChild("InstaKill")
local MaxAmmo = ZombieDropModels:WaitForChild("MaxAmmo")
local BonusPoints = ZombieDropModels:WaitForChild("BonusPoints")

-- AVAILABLE DROPS
local Drops = {
	"InstaKill",
	"DoublePoints",
	"MaxAmmo",
	"BonusPoints",
}

-- VARS
local GlobalID = 0

-- HELPER TO CREATE PART
local function CreateDropModel(Zombie, DropType)
	local Model
	if DropType == "InstaKill" then
		Model = InstaKill:Clone()
	elseif DropType == "DoublePoints" then
		Model = DoublePoints:Clone()
	elseif DropType == "MaxAmmo" then
		Model = MaxAmmo:Clone()
	elseif DropType == "BonusPoints" then
		Model = BonusPoints:Clone()
	else
		return
	end
	-- PARENT AND POSITION
	Model.Parent = workspace:WaitForChild("ZombieDrops")
	Model:PivotTo(Zombie:GetPivot() + Vector3.new(0, 1.5, 0))
	return Model
end

-- ANIMATE PART UP AND DOWN, AND SPIN
local function AnimatePart(Model)
	task.spawn(function()
		local StartTime = tick()
		local Duration = 30
		local BlinkTime = 20
		local InitialY = Model:GetPivot().Y
		local RotationY = 0

		while tick() - StartTime < Duration do
			local Elapsed = tick() - StartTime
			local NewY = InitialY + math.sin(Elapsed * 2)
			RotationY = (RotationY + 1) % 360

			-- BLINK THE MODEL IN LAST 10 SECONDS
			if Elapsed > BlinkTime then
				local Alpha = (Elapsed - BlinkTime) / (Duration - BlinkTime)
				local BlinkRate = 20
				local Transparency = math.floor(Alpha * BlinkRate) % 2 == 0 and 0 or 1
				for _, Part in Model:GetDescendants() do
					if Part:IsA("BasePart") and Part ~= Model.PrimaryPart then
						Part.Transparency = Transparency
					end
					if Part:IsA("ParticleEmitter") then
						Part.Transparency = NumberSequence.new(Transparency)
					end
				end
			end

			Model:PivotTo(
				CFrame.new(Model:GetPivot().X, NewY, Model:GetPivot().Z) * CFrame.Angles(0, math.rad(RotationY), 0)
			)
			task.wait()
		end

		-- DESTROY IF MODEL HASNT BEEN TOUCHED
		if Model and Model.PrimaryPart and not Model.PrimaryPart:GetAttribute("Touched") then
			Model:Destroy()
		end
	end)
end

-- HELPER TO TWEEN MODEL SIZE
local function TweenModelSize(Model)
	local NumValue = Instance.new("NumberValue")
	NumValue.Value = Model:GetScale()
	NumValue.Changed:Connect(function()
		Model:ScaleTo(NumValue.Value)
	end)
	local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local SizeTween = TweenService:Create(NumValue, TweenInfo, { Value = 0.001 })
	SizeTween:Play()
	SizeTween.Completed:Wait()
	SizeTween:Destroy()
	NumValue:Destroy()
end

-- BONUS POINTS
function ZombieDrops.BonusPoints(Zombie)
	GlobalID = GlobalID + 1
	local CurrentID = GlobalID

	local Model = CreateDropModel(Zombie, "BonusPoints")
	AnimatePart(Model)
	local Conn
	local Flag = false
	Conn = Model.PrimaryPart.Touched:Connect(function(TouchingPart)
		if Flag then
			return
		end
		-- ONLY PLAYERS CAN TOUCH
		local Character = TouchingPart.Parent
		local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			return
		end
		local PlayerThatTouched = Players:GetPlayerFromCharacter(Character)
		if not PlayerThatTouched then
			return
		end
		Flag = true
		Model.PrimaryPart:SetAttribute("Touched", true)

		PlayDropSFX:FireAllClients("BonusPoints")
		for _, Player in pairs(Players:GetPlayers()) do
			local Data = PlayerData:Get(Player)
			if not Data then
				continue
			end
			Data.Points.CurrentPoints = Data.Points.CurrentPoints + 1000
			-- MORE POINTS FOR PLAYER THAT TOUCHED
			if Player == PlayerThatTouched then
				Data.Points.CurrentPoints = Data.Points.CurrentPoints + 1000
			end
			Player:SetAttribute("CurrentPoints", math.round(Data.Points.CurrentPoints))
			Player:SetAttribute("BonusPoints", CurrentID)
		end

		-- BONUS POINTS LASTS 10 SECONDS
		task.delay(10, function()
			for _, Player in pairs(Players:GetPlayers()) do
				if Player:GetAttribute("BonusPoints") ~= CurrentID then
					continue
				end

				Player:SetAttribute("BonusPoints", false)
			end
		end)

		-- TWEEN MODEL SIZE
		TweenModelSize(Model)

		-- CLEANUP
		Model:Destroy()
		Conn:Disconnect()
	end)
end

-- INSTA KILL
function ZombieDrops.InstaKill(Zombie)
	GlobalID = GlobalID + 1
	local CurrentID = GlobalID
	local Model = CreateDropModel(Zombie, "InstaKill")
	AnimatePart(Model)
	local Conn
	local Flag = false
	Conn = Model.PrimaryPart.Touched:Connect(function(TouchingPart)
		if Flag then
			return
		end
		-- ONLY PLAYERS CAN TOUCH
		local Character = TouchingPart.Parent
		local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			Flag = false
			return
		end
		Flag = true
		Model.PrimaryPart:SetAttribute("Touched", true)

		PlayDropSFX:FireAllClients("InstaKill")
		for _, Player in pairs(Players:GetPlayers()) do
			Player:SetAttribute("InstaKill", CurrentID)
		end

		-- ATTRIBUTE LASTS 30 SECONDS
		task.delay(30, function()
			for _, Player in pairs(Players:GetPlayers()) do
				if Player:GetAttribute("InstaKill") ~= CurrentID then
					continue
				end
				Player:SetAttribute("InstaKill", false)
			end
		end)

		-- TWEEN MODEL SIZE
		TweenModelSize(Model)

		-- CLEANUP
		Model:Destroy()
		Conn:Disconnect()
	end)
end

-- DOUBLE POINTS
function ZombieDrops.DoublePoints(Zombie)
	GlobalID = GlobalID + 1
	local CurrentID = GlobalID
	local Model = CreateDropModel(Zombie, "DoublePoints")
	AnimatePart(Model)
	local Conn
	local Flag = false
	Conn = Model.PrimaryPart.Touched:Connect(function(TouchingPart)
		if Flag then
			return
		end
		-- ONLY PLAYERS CAN TOUCH
		local Character = TouchingPart.Parent
		local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			Flag = false
			return
		end
		Flag = true
		Model.PrimaryPart:SetAttribute("Touched", true)

		PlayDropSFX:FireAllClients("DoublePoints")
		for _, Player in pairs(Players:GetPlayers()) do
			Player:SetAttribute("DoublePoints", CurrentID)
		end
		-- ATTRIBUTE LASTS 30 SECONDS
		task.delay(30, function()
			for _, Player in pairs(Players:GetPlayers()) do
				if Player:GetAttribute("DoublePoints") ~= CurrentID then
					continue
				end
				Player:SetAttribute("DoublePoints", false)
			end
		end)

		-- TWEEN MODEL SIZE
		TweenModelSize(Model)

		-- CLEANUP
		Model:Destroy()
		Conn:Disconnect()
	end)
end

-- MAX AMMO
function ZombieDrops.MaxAmmo(Zombie)
	GlobalID = GlobalID + 1
	local CurrentID = GlobalID
	local Model = CreateDropModel(Zombie, "MaxAmmo")
	AnimatePart(Model)
	local Conn
	local Flag = false
	Conn = Model.PrimaryPart.Touched:Connect(function(TouchingPart)
		if Flag then
			return
		end
		-- ONLY PLAYERS CAN TOUCH
		local Character = TouchingPart.Parent
		local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			Flag = false
			return
		end
		Flag = true
		Model.PrimaryPart:SetAttribute("Touched", true)

		PlayDropSFX:FireAllClients("MaxAmmo")
		for _, Player in pairs(Players:GetPlayers()) do
			GunFW.MaxAmmo(Player)
			Player:SetAttribute("MaxAmmo", CurrentID)
		end

		-- ATTRIBUTE LASTS 10 SECONDS
		task.delay(10, function()
			for _, Player in pairs(Players:GetPlayers()) do
				if Player:GetAttribute("MaxAmmo") ~= CurrentID then
					continue
				end
				Player:SetAttribute("MaxAmmo", false)
			end
		end)

		-- TWEEN MODEL SIZE
		TweenModelSize(Model)

		-- CLEANUP
		Model:Destroy()
		Conn:Disconnect()
	end)
end

-- DETERMINE IF SHOULD DROP ITEM
function ZombieDrops.DropItem(Zombie, WaveCount)
	-- CHANCE TO DROP, DECREASED THE HIGHER THE WAVE DUE TO MORE ZOMBIES
	local DropChance = 0.1 - (WaveCount * 0.005)
	DropChance = math.max(DropChance, 0.05)
	if math.random(1, 100) / 100 > DropChance then
		return
	end

	-- RANDOMLY SELECT A DROP TYPE
	local DropType = Drops[math.random(1, #Drops)]
	ZombieDrops[DropType](Zombie)

	return DropType
end

return ZombieDrops
