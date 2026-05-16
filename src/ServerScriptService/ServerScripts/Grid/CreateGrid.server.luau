-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- FOLDERS
local Frameworks = ServerScriptService:WaitForChild("ModuleScripts"):WaitForChild("Frameworks")

-- MODULES
local SpatialGridFW = require(Frameworks:WaitForChild("Grid"):WaitForChild("SpatialGridFW"))

-- CREATE GRID
task.wait(1)
task.delay(3, function()
	SpatialGridFW.CreateGrid()
end)

-- VISUALIZE GRID
task.wait(1)
while true do
	task.wait(60)
	--SpatialGridFW.VisualizeGrid()
	SpatialGridFW.CreateGrid()
end
