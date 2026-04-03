-- PLAYER
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


-- MODULES
local ReplicatedService = game:GetService("ReplicatedStorage")
local Utilities = require(ReplicatedService.ModuleScripts.Misc.ClientUtilities)
local ClientGunDataModule = require(ReplicatedService.ModuleScripts.Client.ClientGunData)
local ClientUtilities = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Misc"):WaitForChild("ClientUtilities"))



-- ADD CHARACTER OUTLINE
local Connections = ClientGunDataModule.Connections
local function AddCharacterOutline(Character)
	local PlayerToOutline = Players:GetPlayerFromCharacter(Character)
	if not PlayerToOutline then return end
	
	-- DEFINE
	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 0.75
	Highlight.OutlineColor = Color3.new(1, 1, 1)
	Highlight.Parent = Character
	
	if PlayerToOutline ~= LocalPlayer then
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 1
	end


	-- CHECK IF GUN
	if PlayerToOutline:GetAttribute("EquippedGun") or PlayerToOutline:GetAttribute("IsEquippingGun") then
		local CurrentGunData = ClientGunDataModule:Get(PlayerToOutline)
		if not CurrentGunData then return end
		Highlight.OutlineColor = CurrentGunData.About.OutlineColor
	end

	if not Connections[PlayerToOutline] then
		Connections[PlayerToOutline] = {}
	end
	
	if Connections[PlayerToOutline]["OutlineChangeGun"] then
		Connections[PlayerToOutline]["OutlineChangeGun"]:Disconnect()
		Connections[PlayerToOutline]["OutlineChangeGun"] = nil
	end

	
	-- CONNECT TO SEE IF GUN CHANGES
	Connections[PlayerToOutline]["OutlineChangeGun"] = PlayerToOutline:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		-- IF KNOCKED GIVE RED OUTLINE
		if PlayerToOutline:GetAttribute("IsKnocked") then
			Highlight.OutlineColor = Color3.new(1, 0, 0)
			
		-- ELSE	
		else
			if PlayerToOutline:GetAttribute("IsEquippingGun") then
				local CurrentGunData = ClientGunDataModule:Get(PlayerToOutline)
				if not CurrentGunData then return end
				Highlight.OutlineColor = CurrentGunData.About.OutlineColor
			else
				Highlight.Parent = nil
			end
		end
	end)
end


-- RECIEVE SIGNAL TO LOAD OUTLINE
local function OnPlayerAdded(Player)
	ClientUtilities.BindToCharacter(Player, AddCharacterOutline)
end
-- FOR ALL PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(Player)
end
-- SETUP NOW
Players.PlayerAdded:Connect(OnPlayerAdded)