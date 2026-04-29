-- PLAYER STUFF
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- PLAYER GUI
local SpectateGui = PlayerGui:WaitForChild("SpectateGuiFolder"):WaitForChild("SpectateGui")
local Main = SpectateGui:WaitForChild("Main")
local Count = SpectateGui:WaitForChild("Count")
local PlayerSpectating = Main:WaitForChild("PlayerSpectating")
local LeftArrow = Main:WaitForChild("LeftArrow")
local RightArrow = Main:WaitForChild("RightArrow")
local SpectateCountText = Count:WaitForChild("SpectateCount")

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SpectateEvents")
local ToggleSpectateEvent = SpectateEvents:WaitForChild("ToggleSpectateEvent")

-- ON TOGGLE SPECTATE EVENT
ToggleSpectateEvent.OnClientEvent:Connect(function(Enable)
	if not Enable then
		SpectateGui.Enabled = false
	end

	SpectateGui.Enabled = true
end)

-- ON LEFT ARROW CLICK
LeftArrow.MouseButton1Click:Connect(function()
	print("hileft")
end)

-- ON RIGHT ARROW CLICK
RightArrow.MouseButton1Click:Connect(function()
	print("hiright")
end)
