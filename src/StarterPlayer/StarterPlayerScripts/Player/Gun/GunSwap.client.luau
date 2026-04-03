-- SERVICES
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunEvents = Events:WaitForChild("GunEvents")


-- EVENTS
local GunSwapEvent = GunEvents:WaitForChild("GunSwap")



-- ON INPUT BEGAN
UIS.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then return end
	-- GRAB NUMBERS REQUIRED
	local Numbers = {		
		["One"] = 1,
		["Two"] = 2,
		["Three"] = 3,
	}
	
	-- CHECK IF THE INPUT IS IN NUMBERS
	if Numbers[Input.KeyCode.Name] then
		GunSwapEvent:FireServer(Input.KeyCode.Name)
	end
end)