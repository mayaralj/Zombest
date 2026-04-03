-- SERVICES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")

-- EVENTS
local DashEvent = Events:WaitForChild("PlayerEvents"):WaitForChild("DashEvent")

-- DASH INPUT
UIS.InputBegan:Connect(function(Input, GameProcessed)
	if not GameProcessed and Input.KeyCode == Enum.KeyCode.Q then
		DashEvent:FireServer()
	end
end)
