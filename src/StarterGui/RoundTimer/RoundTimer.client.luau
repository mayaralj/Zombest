-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EVENTS
local Events = ReplicatedStorage:WaitForChild("Events")
local RoundEvents = Events:WaitForChild("RoundEvents")
local UpdateTimerEvent = RoundEvents:WaitForChild("UpdateTimerEvent")

-- GUI STUFF
local RoundTimerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RoundTimer"):WaitForChild("RoundTimerGui")
local Frame = RoundTimerGui:WaitForChild("Frame")
local RoundText = Frame:WaitForChild("RoundText")
local TimerText = Frame:WaitForChild("TimerText")

UpdateTimerEvent.OnClientEvent:Connect(function(EndTime)
	local TimeLeft = math.max(0, EndTime - workspace:GetServerTimeNow())
	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		TimeLeft = math.max(0, EndTime - workspace:GetServerTimeNow())
		-- ROUND TIME LEFT
		TimeLeft = math.ceil(TimeLeft)
		TimerText.Text = TimeLeft
		if TimeLeft <= 0 then
			TimerText.Text = "0"
			Connection:Disconnect()
		end
	end)
end)
