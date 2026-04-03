-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local Frameworks = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")

-- MODULES
local ObjectPoolFW = require(Frameworks:WaitForChild("ObjectPool"):WaitForChild("ObjectPoolFW"))

-- OBJECT POOL BLOOD VFX
--ObjectPoolFW.Create(ReplicatedStorage:WaitForChild("GunVFX"):WaitForChild("BloodVFX"):WaitForChild("ZombieBlood"), 10000)
