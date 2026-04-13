local StarterGui = game:GetService("StarterGui")

-- REMOVE PLAYER ABILITY TO MANUALLY RESPAWN
local Success, ErrorMessage
repeat
	Success, ErrorMessage = pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
	if not Success then
		task.wait()
	end
until Success
