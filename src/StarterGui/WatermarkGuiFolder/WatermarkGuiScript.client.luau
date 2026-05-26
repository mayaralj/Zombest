-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- UI
local PlayerGui = LocalPlayer.PlayerGui
local WatermarkGui = PlayerGui:WaitForChild("WatermarkGuiFolder"):WaitForChild("WatermarkGui")
local WatermarkFrame = WatermarkGui:WaitForChild("Frame")

-- -- WATERMARK
-- if LocalPlayer.Name == "V0TEDS" then return end
-- for _, Gui in WatermarkFrame:GetDescendants() do
-- 	if Gui:IsA("TextLabel") then
-- 		Gui.Text = LocalPlayer.Name
-- 	end
-- end
-- WatermarkGui.Enabled = true
