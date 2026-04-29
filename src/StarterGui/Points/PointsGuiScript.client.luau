-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))

local function UpdatePoints()
	if not LocalPlayer:GetAttribute("CurrentPoints") then
		return
	end
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end

	-- UI
	local PointsGui = PlayerGui:WaitForChild("Points"):WaitForChild("PointsGui")
	local Frame = PointsGui:WaitForChild("Frame")
	local PointsText = Frame:WaitForChild("PointsText")
	local PointChangeText = Frame:WaitForChild("PointChangeText")

	-- ENABLE IF NOT ENABLED ALREADY
	if not PointsGui.Enabled then
		PointsGui.Enabled = true
	end

	-- UPDATE LAST POINTS
	local PointsDifference = LocalPlayer:GetAttribute("CurrentPoints") - CurrentPlayerData.Points.LastPoints
	-- ROUND
	PointsDifference = math.round(PointsDifference)
	local PointChangeClone = PointChangeText:Clone()
	PointChangeClone.Parent = PointChangeText.Parent
	PointChangeClone.Text = PointsDifference
	PointChangeClone.Visible = true
	Debris:AddItem(PointChangeClone, 1)

	-- TWEEN UPWARDS
	local TweenInfoUp = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TweenUp = TweenService:Create(
		PointChangeClone,
		TweenInfoUp,
		{ Position = PointChangeText.Position - UDim2.fromScale(math.random(-25, 25) / 100, 0.6) }
	)
	TweenUp:Play()
	Debris:AddItem(TweenUp, 2)

	-- TWEEN TEXT TRANSPARENCY
	local TweenInfoTransparency = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TweenTransparency = TweenService:Create(PointChangeClone, TweenInfoTransparency, { TextTransparency = 1 })
	TweenTransparency:Play()
	Debris:AddItem(TweenTransparency, 2)

	-- UPDATE POINTS TEXT
	PointsText.Text = math.round(LocalPlayer:GetAttribute("CurrentPoints"))
	-- UPDATE LAST POINTS
	CurrentPlayerData.Points.LastPoints = math.round(LocalPlayer:GetAttribute("CurrentPoints"))
end

-- HELPER SETUP
local MainConn
local function SetUp()
	-- TRACK LAST POINTS TO DETERMINE CHANGE IN POINTS
	MainConn = LocalPlayer:GetAttributeChangedSignal("CurrentPoints"):Connect(function()
		UpdatePoints()
	end)
end

-- INITIAL
SetUp()
-- STARTUP ON CHARACTER ADDED
LocalPlayer.CharacterAdded:Connect(function()
	if MainConn then
		MainConn:Disconnect()
		MainConn = nil
	end
	SetUp()
end)
