local PlayerStaminaFW = {}


-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")


-- MODULES
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))



-- FUNCTION TO DECREASE STAMINA
function PlayerStaminaFW.DecreaseStamina(Player, Rate)
	local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	if not Humanoid then return end

	local Data = PlayerData:Get(Player)
	if not Data then return end

	
	-- UPDATE STAM
	Data.Stamina.CurrentStamina = (Data.Stamina.CurrentStamina or 100) - Rate
	Player:SetAttribute("CurrentStamina", Data.Stamina.CurrentStamina)
	Player:SetAttribute("MaxStamina", Data.Stamina.MaxStamina)
end



-- FUNCTION TO REGEN STAMINA
function PlayerStaminaFW.RegenStamina(Player, Rate)
	local Character = Player.Character
	if not Character then return end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then return end

	local Data = PlayerData:Get(Player)
	if not Data then return end

	local Now = tick()
	local LastSprintTime = Data.Stamina.TimeSinceSprinted or 0

	if Data.Stamina.CurrentStamina < Data.Stamina.MaxStamina and (Now - LastSprintTime) > 2.5 then
		Data.Stamina.CurrentStamina += Rate
		Player:SetAttribute("CurrentStamina", Data.Stamina.CurrentStamina)
		Player:SetAttribute("MaxStamina", Data.Stamina.MaxStamina)
	end
end



return PlayerStaminaFW