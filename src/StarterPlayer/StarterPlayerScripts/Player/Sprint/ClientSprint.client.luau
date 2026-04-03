-- SERVICES
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")


-- EVENTS
local SprintEvent = Events:WaitForChild("PlayerEvents"):WaitForChild("SprintEvent")



-- INPUT BEGAN: START SPRINTING
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and not (Player and Player:GetAttribute("IsKnocked")) and input.KeyCode == Enum.KeyCode.LeftShift then
		SprintEvent:FireServer(true)
	end
end)



-- INPUT ENDED: STOP SPRINTING
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		SprintEvent:FireServer(false)
	end
end)