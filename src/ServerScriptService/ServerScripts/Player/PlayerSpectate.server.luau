-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- EVENTS
local Events = ReplicatedStorage:WaitForChild("Events")
local SpectateEvents = Events:WaitForChild("SpectateEvents")
local SpectateUpdate = SpectateEvents:WaitForChild("SpectateUpdate")

-- UPDATE ATTRIBUTE FOR SPECTATING ID
SpectateUpdate.OnServerEvent:Connect(function(Player, SpectatingId)
	if not SpectatingId then
		Player:SetAttribute("SpectatingId", false)
		return
	end
	Player:SetAttribute("SpectatingId", SpectatingId)
end)
