-- SERVICES
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")


-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local GunEvents = Events:WaitForChild("GunEvents")
local Data = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Data")


-- EVENTS
local GunSwapEvent = GunEvents:WaitForChild("GunSwap")


-- MODULES
local PlayerData = require(Data:WaitForChild("PlayerData"))
local GunData = require(Data:WaitForChild("GunData"))
local GunFW = require(ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks"):WaitForChild("Gun"):WaitForChild("GunFW"))



-- ON SERVER EVENT TO GUN SWAP
GunSwapEvent.OnServerEvent:Connect(function(Player, Input)
	-- DONT ALLOW IF:
	if Player:GetAttribute("IsEquipping") then return end
	if Player:GetAttribute("IsShooting") then return end
	if Player:GetAttribute("InWindup") then return end
	if Player:GetAttribute("IsDashing") then return end
	if Player:GetAttribute("IsReloading") then return end
	if Player:GetAttribute("IsCharging") then return end
	if Player:GetAttribute("IsRevived") then return end
	if Player:GetAttribute("IsKnocked") then return end
	
	-- PLAYER DATA
	local CurrentPlayerData = PlayerData:Get(Player)
	if not CurrentPlayerData then return end
	local WeaponSlotData = CurrentPlayerData.WeaponSlots
	if not WeaponSlotData then return end
	
	-- CONVERT INPUT TO NUMBER
	if Input == "One" then
		Input = 1
	elseif Input == "Two" then
		Input = 2
	else  
		Input = 3
	end
	
	-- LOOP AND ATTEMPT TO GIVE WEAPON AT SLOT
	for i, WeaponStoredName in WeaponSlotData do
		if i == Input and WeaponStoredName ~= "Empty" then
			--print(i , WeaponStoredName)
			
			-- GIVE GUN
			GunFW.GiveWeapon(Player, WeaponStoredName, false)
			return
		end
	end	
end)