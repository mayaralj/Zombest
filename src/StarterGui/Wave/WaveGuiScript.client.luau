-- PLAYERS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GET THE WAVE GUI
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local waveGui = playerGui:WaitForChild("Wave"):WaitForChild("WaveGui")
waveGui.Enabled = true