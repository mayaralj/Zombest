-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- MODULES
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))

-- UI
local PlayerGui = LocalPlayer.PlayerGui
local PointsGui = PlayerGui:WaitForChild("Points"):WaitForChild("PointsGui")
local Frame = PointsGui:WaitForChild("Frame")
local PointsText = Frame:WaitForChild("PointsText")
local PointChangeText = Frame:WaitForChild("PointChangeText")

-- CONNECTIONS
local CurrentPointsConn = nil
Humanoid.Died:Connect(function()
	if CurrentPointsConn then
		CurrentPointsConn:Disconnect()
		CurrentPointsConn = nil
	end
end)

-- TRACK LAST POINTS TO DETERMINE CHANGE IN POINTS
-- UPDATE CURRENT POINTS TEXT
if LocalPlayer:GetAttribute("CurrentPoints") then
	-- UPDATE POINTS TEXT
	PointsText.Text = LocalPlayer:GetAttribute("CurrentPoints")
else
	-- SET POINTS TEXT
	PointsText.Text = 0
end
PointsGui.Enabled = true
CurrentPointsConn = LocalPlayer:GetAttributeChangedSignal("CurrentPoints"):Connect(function()
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end

	-- IF NO POINTS THEN RETURN END
	if not LocalPlayer:GetAttribute("CurrentPoints") then
		return
	end

	-- UPDATE LAST POINTS
	local PointsDifference = LocalPlayer:GetAttribute("CurrentPoints") - CurrentPlayerData.Points.LastPoints
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
	PointsText.Text = LocalPlayer:GetAttribute("CurrentPoints")
	-- UPDATE LAST POINTS
	CurrentPlayerData.Points.LastPoints = LocalPlayer:GetAttribute("CurrentPoints")
end)
