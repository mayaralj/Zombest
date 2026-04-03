-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")


-- FOLDERS
local Modules = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = Modules:WaitForChild("Frameworks")
local Misc = Modules:WaitForChild("Misc")


-- MODULES
local PlayerHealthFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerHealthFW"))
local Utilities = require(Misc:WaitForChild("Utilities"))



-- BIND HEALTH REGEN STUFF TO CHARACTER
Utilities.BindToCharacter(function(Character)
	PlayerHealthFW.CleanUpHealthConns(Character)
	PlayerHealthFW.DetectHit(Character)
	PlayerHealthFW.StartRegen(Character)
end)