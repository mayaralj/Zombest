-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")



-- GUI
local PlayerGui = Player:WaitForChild("PlayerGui")
local HealthBarGui = PlayerGui:WaitForChild("HealthBar"):WaitForChild("HealthBarGui")
local BarFrame = HealthBarGui:WaitForChild("BarFrame")
local Bar = BarFrame:WaitForChild("Bar")



-- CHANGE HP BAR ON HEALTH CHANGED
HealthBarGui.Enabled = true
local Connection
Connection = Humanoid.HealthChanged:Connect(function()
	local HealthRatio = Humanoid.Health / Humanoid.MaxHealth
	Bar.Size = UDim2.new(HealthRatio, 0, 1, 0)
end)



-- ON HUMANOID DIED
Humanoid.Died:Connect(function()
	if Connection then
		Connection:Disconnect()
	end
	Bar.Size = UDim2.new(0, 0, 1, 0)
end)