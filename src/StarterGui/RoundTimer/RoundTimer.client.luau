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

-- GET WAVE GUI STUFF
local WaveGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("WaveGuiFolder"):WaitForChild("WaveGui")

UpdateTimerEvent.OnClientEvent:Connect(function(EndTime)
	-- DISABLE WAVE GUI FIRST SO IT DOESNT COLLIDE
	WaveGui.Enabled = false

	-- ROUND TIMER GUI ENABLE AND UPDATES
	local Connection
	local TimerEnded = false
	TimerText.Text = math.ceil(math.max(0, EndTime - workspace:GetServerTimeNow()))
	RoundTimerGui.Enabled = true

	Connection = RunService.Heartbeat:Connect(function()
		if TimerEnded then
			return
		end

		local TimeLeft = math.ceil(math.max(0, EndTime - workspace:GetServerTimeNow()))
		TimerText.Text = TimeLeft

		if TimeLeft <= 0 then
			TimerEnded = true
			TimerText.Text = ""

			task.delay(2, function()
				RoundTimerGui.Enabled = false
				Connection:Disconnect()
				Connection = nil
			end)

			-- STORE ORIGINAL GUI PROPERTIES BEFORE CHANGING
			local OriginalAnchor = RoundText.AnchorPoint
			local OriginalPosition = RoundText.Position

			RoundText.AnchorPoint = Vector2.new(0.5, 0.5)
			RoundText.Position = UDim2.fromScale(0.5, 0.5)

			local i = 0
			while Connection do
				i = (i % 4)
				RoundText.Text = "ROUND STARTING" .. string.rep(". ", i)
				i += 1
				task.wait(0.25)
			end

			-- RESET GUI PROPERTIES CHANGED
			RoundText.AnchorPoint = OriginalAnchor
			RoundText.Position = OriginalPosition
		end
	end)
end)
