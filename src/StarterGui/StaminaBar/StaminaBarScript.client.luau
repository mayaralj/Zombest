-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")



-- GUI
local PlayerGui = Player:WaitForChild("PlayerGui")
local StaminaBarGui = PlayerGui:WaitForChild("StaminaBar"):WaitForChild("StaminaBarGui")
local BarFrame = StaminaBarGui:WaitForChild("BarFrame")
local Bar = BarFrame:WaitForChild("Bar")



-- CHANGE HP BAR ON HEALTH CHANGED
StaminaBarGui.Enabled = true
local Connection
Connection = Player:GetAttributeChangedSignal("CurrentStamina"):Connect(function()
	local StaminaRatio = Player:GetAttribute("CurrentStamina") / Player:GetAttribute("MaxStamina")
	Bar.Size = UDim2.new(StaminaRatio, 0, 1, 0)
end)


-- ON HUMANOID DIED
Humanoid.Died:Connect(function()
	if Connection then
		Connection:Disconnect()
	end
	Bar.Size = UDim2.new(0, 0, 1, 0)
end)