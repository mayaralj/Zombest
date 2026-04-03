-- SERVICES
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- EVENTS
local Events = ReplicatedStorage:WaitForChild("Events")
local MapEvents = Events:WaitForChild("MapEvents")
local TimeChange = MapEvents:WaitForChild("TimeChange")


-- SETTINGS
local START_TIME = 12
local MinutesAfterMidnight = START_TIME * 60

local LastServerTime = nil
local TaskLoop = nil
local IsChanging = false


-- SERVER EVENT TO CHANGE TIME
TimeChange.OnServerEvent:Connect(function(Player, ChangeTheTime, NewTime, Rate)
	-- CHANGE SERVER TIME
	if ChangeTheTime then
		LastServerTime = MinutesAfterMidnight
		if TaskLoop then task.cancel(TaskLoop) end
		TaskLoop = task.spawn(function()
			local TargetTime = NewTime*60
			while math.abs(MinutesAfterMidnight - TargetTime) > 0.1 do
				IsChanging = true
				MinutesAfterMidnight = math.lerp(MinutesAfterMidnight, NewTime*60, 0.01)
				task.wait(Rate)
			end
			IsChanging = false
		end)
		
		
	-- RESET BACK
	else
		if not LastServerTime then return end
		if TaskLoop then task.cancel(TaskLoop)  end
		TaskLoop = task.spawn(function()
			IsChanging = true
			while math.abs(MinutesAfterMidnight - LastServerTime) > 0.1 do
				MinutesAfterMidnight = math.lerp(MinutesAfterMidnight, LastServerTime, 0.01)
				task.wait(Rate)
			end
			IsChanging = false
		end)
	end
end)



-- WHILE LOOP TO APPLY CYCLE
while true do
	--MinutesAfterMidnight = (MinutesAfterMidnight + 1) % 1440
	Lighting:SetMinutesAfterMidnight(MinutesAfterMidnight)
	
	-- KEEP IT SMOOTH WHEN NEEDS TO RAPID CHANGE
	if IsChanging then
		task.wait(0.025)
	else
		task.wait(0.25)
	end
end