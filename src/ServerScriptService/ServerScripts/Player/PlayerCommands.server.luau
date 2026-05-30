-- SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local GunFW = require(Frameworks:WaitForChild("Gun"):WaitForChild("GunFW"))
local PlayerData = require(ModuleScripts:WaitForChild("Data"):WaitForChild("PlayerData"))
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))

-- VARS
local AllowedPlayers = {
	"V0TEDS",
	"Player1",
	"Player2",
}
local Connected = {}

-- HELPER TO CONNECT TO COMMAND
local function ConnectCommand(Player)
	if Connected[Player] then
		return
	end
	Connected[Player] = true
	Player.Chatted:Connect(function(Message)
		local Args = string.split(Message, " ")
		if Args[1] == "/GiveGun" then
			local GunName = Args[3]
			if Args[2] == "-a" then
				for _, PlayerToGive in pairs(Players:GetPlayers()) do
					if PlayerToGive:GetAttribute("IsKnocked") then
						continue
					end
					task.spawn(function()
						-- ATTRIBUTE CHECKS
						while
							PlayerToGive:GetAttribute("IsShooting")
							or PlayerToGive:GetAttribute("IsReloading")
							or PlayerToGive:GetAttribute("IsCharging")
							or PlayerToGive:GetAttribute("IsEquipping")
							or PlayerToGive:GetAttribute("IsDashing")
							or PlayerToGive:GetAttribute("IsReviving")
							or PlayerToGive:GetAttribute("IsSprinting")
						do
							task.wait()
						end
						GunFW.GiveWeapon(PlayerToGive, GunName, true)
					end)
				end
			else
				local PlayerToGive = Players:FindFirstChild(Args[2])
				if PlayerToGive then
					if PlayerToGive:GetAttribute("IsKnocked") then
						return
					end
					task.spawn(function()
						-- ATTRIBUTE CHECKS
						while
							PlayerToGive:GetAttribute("IsShooting")
							or PlayerToGive:GetAttribute("IsReloading")
							or PlayerToGive:GetAttribute("IsCharging")
							or PlayerToGive:GetAttribute("IsEquipping")
							or PlayerToGive:GetAttribute("IsDashing")
							or PlayerToGive:GetAttribute("IsReviving")
							or PlayerToGive:GetAttribute("IsSprinting")
						do
							task.wait()
						end
						GunFW.GiveWeapon(PlayerToGive, GunName, true)
					end)
				end
			end
		elseif Args[1] == "/GivePoints" then
			local Amount = tonumber(Args[3])
			if not Amount then
				return
			end
			if Args[2] == "-a" then
				for _, PlayerToGive in pairs(Players:GetPlayers()) do
					local CurrentPlayerData = PlayerData:Get(PlayerToGive)
					if not CurrentPlayerData then
						continue
					end
					CurrentPlayerData.Points.CurrentPoints += Amount
					PlayerToGive:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
				end
			else
				local PlayerToGive = Players:FindFirstChild(Args[2])
				if PlayerToGive then
					local CurrentPlayerData = PlayerData:Get(PlayerToGive)
					if not CurrentPlayerData then
						return
					end
					CurrentPlayerData.Points.CurrentPoints = CurrentPlayerData.Points.CurrentPoints + Amount
					PlayerToGive:SetAttribute("CurrentPoints", math.round(CurrentPlayerData.Points.CurrentPoints))
				end
			end
		elseif Args[1] == "/Kill" then
			if Args[2] == "-a" then
				for _, PlayerToKill in pairs(Players:GetPlayers()) do
					PlayerHealthFW.ForceKill(PlayerToKill)
				end
			else
				local PlayerToKill = Players:FindFirstChild(Args[2])
				if PlayerToKill then
					PlayerHealthFW.ForceKill(PlayerToKill)
				end
			end
		end
	end)
end

-- EXISTING PLAYERS
for _, Player in pairs(Players:GetPlayers()) do
	if not table.find(AllowedPlayers, Player.Name) then
		continue
	end
	ConnectCommand(Player)
end

-- ON NEW PLAYERS
Players.PlayerAdded:Connect(function(Player)
	if not table.find(AllowedPlayers, Player.Name) then
		return
	end
	ConnectCommand(Player)
end)

-- CLEANUP ON LEAVE
Players.PlayerRemoving:Connect(function(Player)
	Connected[Player] = nil
end)
