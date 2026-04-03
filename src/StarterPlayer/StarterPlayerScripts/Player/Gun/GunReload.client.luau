-- SERVICES
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunEvents = Events:WaitForChild("GunEvents")


-- EVENTS
local StartReloading = GunEvents:WaitForChild("StartReloading")



-- BEGIN ATTEMPT TO RELOAD
UIS.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then return end
	if Input.KeyCode == Enum.KeyCode.R then
		StartReloading:FireServer(true)
	end
end)



-- STOP ATTEMPT TO RELOAD
UIS.InputEnded:Connect(function(Input, GameProcessed)
	if GameProcessed then return end
	if Input.KeyCode == Enum.KeyCode.R then
		StartReloading:FireServer(false)
	end
end)