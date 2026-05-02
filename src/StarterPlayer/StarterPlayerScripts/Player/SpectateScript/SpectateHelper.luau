local SpectateHelper = {}
-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- MODULES
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")
local ClientPlayerData = require(ClientData:WaitForChild("ClientPlayerData"))

-- VARS
SpectateHelper.CurrentIndex = 1

function SpectateHelper.ResetSpectate()
	SpectateHelper.CurrentIndex = 1
	local CurrentPlayerData = ClientPlayerData:Get(LocalPlayer)
	if not CurrentPlayerData then
		return
	end
	CurrentPlayerData.CameraSettings.PlayerViewing = LocalPlayer
	LocalPlayer:SetAttribute("SpectatingId", nil)
end

return SpectateHelper
