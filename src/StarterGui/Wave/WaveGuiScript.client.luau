-- PLAYERS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GET THE WAVE GUI
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local waveGui = playerGui:WaitForChild("WaveGuiFolder"):WaitForChild("WaveGui")
local Frame = waveGui:WaitForChild("Frame")
local WaveText = Frame:WaitForChild("WaveText")
local WaveCount = Frame:WaitForChild("WaveCount")

-- GET ROUND TIMER GUI
local RoundTimerGui = playerGui:WaitForChild("RoundTimer"):WaitForChild("RoundTimerGui")

-- EVENTS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local WaveEvents = Events:WaitForChild("WaveEvents")
local UpdateWaveEvent = WaveEvents:WaitForChild("UpdateWaveEvent")

-- ENABLE AND UPDATE GUI ON EVENT
UpdateWaveEvent.OnClientEvent:Connect(function(CurrentWave)
	RoundTimerGui.Enabled = false
	WaveCount.Text = CurrentWave
	waveGui.Enabled = true
end)
