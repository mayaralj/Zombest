-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


-- FOLDERS
local ModuleScripts = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = ModuleScripts:WaitForChild("Frameworks")
local Events = ReplicatedStorage:WaitForChild("Events")
local ServerData = ModuleScripts:WaitForChild("Data")


-- MODULES
local PlayerStaminaFW = require(Frameworks:WaitForChild("Player"):WaitForChild("PlayerStaminaFW"))
local Utilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("Utilities"))
local PlayerData = require(ServerData:WaitForChild("PlayerData"))
local GunData = require(ServerData:WaitForChild("GunData"))



RunService.Heartbeat:Connect(function()
	task.wait(5)
	for _, Player in ipairs(Players:GetChildren()) do
		local Character = Player.Character
		if not Character then continue end
		local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then continue end
		local YPos = Character and Character.PrimaryPart and Character.PrimaryPart.Position.Y
		
		-- GROUND PLAYER
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		RayParams.FilterDescendantsInstances = {Character}
		
		local RayResult = workspace:Raycast(RootPart.Position, Vector3.new(0, -100, 0), RayParams)
		
		if RayResult then
			local Distance = (RootPart.Position - RayResult.Position).Magnitude
			if Distance > 10 then
				RootPart.Position = RayResult.Position + Vector3.new(0, 2, 0)
				warn("Player Above intended distance")
			end
		end
	end
end)