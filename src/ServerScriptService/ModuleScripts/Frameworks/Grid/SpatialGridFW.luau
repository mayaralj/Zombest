local SpatialGridFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local DebrisService = game:GetService("Debris")

-- FOLDERS
local Modules = ServerScriptService:WaitForChild("ModuleScripts")
local Data = Modules:WaitForChild("Data")

-- MODULES
local ZombieData = require(Data:WaitForChild("ZombieData"))

-- CELL DATA
local CELL_SIZE = 5
local CellPart = {}
SpatialGridFW.SpatialGrid = {}

-- GET CELL CORRESPONDING TO THE POSITION OF PART
function SpatialGridFW.GetCells(Part)
	local CF = Part.CFrame
	local HalfSize = Part.Size * 0.5

	-- WORLD CORNERS OF PART
	local Corners = {
		CF * Vector3.new(-HalfSize.X, -HalfSize.Y, -HalfSize.Z),
		CF * Vector3.new(HalfSize.X, -HalfSize.Y, -HalfSize.Z),
		CF * Vector3.new(-HalfSize.X, -HalfSize.Y, HalfSize.Z),
		CF * Vector3.new(HalfSize.X, -HalfSize.Y, HalfSize.Z),
	}

	-- BOUNDING BOX
	local MinX, MaxX = math.huge, -math.huge
	local MinZ, MaxZ = math.huge, -math.huge
	for _, Corner in Corners do
		MinX, MaxX = math.min(MinX, Corner.X), math.max(MaxX, Corner.X)
		MinZ, MaxZ = math.min(MinZ, Corner.Z), math.max(MaxZ, Corner.Z)
	end

	-- GET GRID SPACE
	local MinCellX = math.floor(MinX / CELL_SIZE)
	local MaxCellX = math.floor(MaxX / CELL_SIZE)
	local MinCellZ = math.floor(MinZ / CELL_SIZE)
	local MaxCellZ = math.floor(MaxZ / CELL_SIZE)

	-- CREATE A SLIGHTLY LARGER BOX TO ENSURE EVERYTHING IS COVERED
	local Expanded = HalfSize + Vector3.new(CELL_SIZE * 0.5, 0, CELL_SIZE * 0.5)

	-- COLLECT CELLS INSIDE THE PART
	local Cells = {}
	for X = MinCellX, MaxCellX do
		for Z = MinCellZ, MaxCellZ do
			local WorldCellCenter = Vector3.new(X * CELL_SIZE + CELL_SIZE / 2, 0, Z * CELL_SIZE + CELL_SIZE / 2)

			-- GET LOCAL SPACE TO CHECK IF INSIDE
			local Local = CF:PointToObjectSpace(WorldCellCenter)
			if math.abs(Local.X) > Expanded.X or math.abs(Local.Z) > Expanded.Z then
				continue
			end
			table.insert(Cells, { X = X, Z = Z })
		end
	end

	return Cells
end

-- CREATE GRID WITH ALL PARTS
function SpatialGridFW.CreateGrid()
	SpatialGridFW.SpatialGrid = {}
	CellPart = {}

	for _, Part in workspace:GetDescendants() do
		if not Part:IsA("BasePart") or not Part:HasTag("PhaseTag") or not Part.CanCollide then
			continue
		end

		-- SKIP PLAYERS
		local Character = Part:FindFirstAncestorOfClass("Model")
		if Character and Character:FindFirstChildOfClass("Humanoid") then
			continue
		end

		-- ADD PART TO GRID
		SpatialGridFW.AddPartToGrid(Part)
	end
end

-- ADD PART TO GRID
function SpatialGridFW.AddPartToGrid(Part)
	local Cells = SpatialGridFW.GetCells(Part)
	CellPart[Part] = Cells
	local Grid = SpatialGridFW.SpatialGrid

	for _, Cell in Cells do
		local X, Z = Cell.X, Cell.Z

		Grid[X] = Grid[X] or {}
		Grid[X][Z] = Grid[X][Z] or {}
		Grid[X][Z][Part] = true
	end
end

-- REMOVE PART FROM GRID
function SpatialGridFW.RemovePartFromGrid(Part)
	local OldCells = CellPart[Part]
	if not OldCells then
		return
	end
	local Grid = SpatialGridFW.SpatialGrid

	for _, Cell in OldCells do
		local X, Z = Cell.X, Cell.Z

		local GridX = Grid[X]
		if not GridX then
			continue
		end

		local CellParts = GridX[Z]
		if not CellParts then
			continue
		end

		CellParts[Part] = nil
		if next(CellParts) then
			continue
		end

		GridX[Z] = nil
		if next(GridX) then
			continue
		end

		Grid[X] = nil
	end

	CellPart[Part] = nil
end

-- UPDATE GRID WHEN PART MOVES
local LastUpdate = {}
function SpatialGridFW.UpdatePartPosition(Part)
	-- CHECK IF PART EXISTS
	if not Part or not Part.Parent then
		return
	end

	-- THROTTLE UPDATES
	local CurrentPosition = Part.Position
	local CurrentTime = tick()
	local LastUpdatedData = LastUpdate[Part]
	if LastUpdatedData then
		local TimeDifference = CurrentTime - LastUpdatedData.Time
		local Distance = (CurrentPosition - LastUpdatedData.Position).Magnitude

		if TimeDifference < 1 and Distance < 2 then
			return
		end
	end
	LastUpdate[Part] = { Position = CurrentPosition, Time = CurrentTime }

	-- REMOVE AND ADD PART TO GRID TO UPDATE
	if CellPart[Part] then
		SpatialGridFW.RemovePartFromGrid(Part)
	end
	SpatialGridFW.AddPartToGrid(Part)
end

-- GET CLOSEST POINT ON PART
local function GetClosestPointOnPart(Part, WorldPoint)
	-- LOCAL SPACE
	local LocalPoint = Part.CFrame:PointToObjectSpace(WorldPoint)
	local HalfSize = Part.Size * 0.5
	LocalPoint = Vector3.new(
		math.clamp(LocalPoint.X, -HalfSize.X, HalfSize.X),
		0,
		math.clamp(LocalPoint.Z, -HalfSize.Z, HalfSize.Z)
	)

	-- BACK TO WORLD SPACE
	local WorldClosest = Part.CFrame:PointToWorldSpace(LocalPoint)

	---- VISUALIZE
	--local sphere = Instance.new("Part")
	--sphere.Shape = Enum.PartType.Ball
	--sphere.Anchored = true
	--sphere.CanCollide = false
	--sphere.Size = Vector3.new(1, 1, 1)
	--sphere.Position = WorldClosest
	--sphere.Color = Color3.new(0.133333, 0.219608, 1)
	--sphere.Transparency = 0.5
	--sphere.Name = "ClosestPointVisual"
	--sphere.Parent = workspace:WaitForChild("GridVisuals")
	--game:GetService("Debris"):AddItem(sphere, 0.25)

	return WorldClosest
end

-- GET NEARBY PARTS TO A PART VIA GRID AND DISTANCE
function SpatialGridFW.GetNearbyParts(Part, MaxDistance)
	-- TABLES
	local NearbyParts = {}
	local CheckedParts = {}

	-- PART POSITIONS
	local PartPos = Part.Position

	-- CELLS THE PART IS OCCUPYING
	local Cells = CellPart[Part]
	if not Cells then
		return NearbyParts
	end

	-- CHECK IF WALL NEARBY DETECTED
	local WallNearby = false

	-- GET GRID
	local Grid = SpatialGridFW.SpatialGrid

	-- Optimized function to mark a part's cells
	local function MarkPartCells(DetectedPart)
		--local DetectedCells = CellPart[DetectedPart]
		--if not DetectedCells then return end

		--for _, Cell in ipairs(DetectedCells) do
		--	local WorldX = Cell.X * CELL_SIZE + CELL_SIZE / 2
		--	local WorldZ = Cell.Z * CELL_SIZE + CELL_SIZE / 2
		--	local CellCenter = Vector3.new(WorldX, PartPos.Y, WorldZ)

		--	if (PartPos - CellCenter).Magnitude <= MaxDistance then
		--		-- Uncomment to visualize
		--		 local CellMarker = Instance.new("Part")
		--		 CellMarker.Size = Vector3.new(CELL_SIZE, 0.2, CELL_SIZE)
		--		 CellMarker.Position = Vector3.new(WorldX, 1, WorldZ)
		--		 CellMarker.Anchored = true
		--		 CellMarker.CanCollide = false
		--		 CellMarker.CanQuery = false
		--		 CellMarker.CanTouch = false
		--		 CellMarker.CastShadow = false
		--		 CellMarker.Transparency = 0
		--		 CellMarker.Color = Color3.fromRGB(0, 0, 0)
		--		 CellMarker.Parent = workspace:WaitForChild("GridVisuals")
		--		 DebrisService:AddItem(CellMarker, 0.25)
		--	end
		--end
	end

	-- CHECK EACH CELL FOR NEARBY PARTS

	local function CheckCell(X, Z)
		local Row = Grid[X]
		if not Row then
			return
		end
		local Cell = Row[Z]
		if not Cell then
			return
		end

		local ZombieChecked = 0
		local WallChecked = 0

		for OtherPart in Cell do
			if OtherPart == Part or CheckedParts[OtherPart] then
				continue
			end
			if WallChecked >= 2 and ZombieChecked >= 2 then
				return
			end
			if not OtherPart:HasTag("PhaseTag") and not OtherPart:HasTag("ServerZombieTag") then
				continue
			end

			-- DONT CHECK WALLS AND ZOMBIES MULTIPLE TIMES
			if OtherPart:HasTag("PhaseTag") then
				WallChecked += 1
				WallNearby = true
			end
			if OtherPart:HasTag("PhaseTag") and WallChecked >= 2 then
				continue
			end
			if OtherPart:HasTag("ServerZombieTag") then
				ZombieChecked += 1
			end
			if OtherPart:HasTag("ServerZombieTag") and ZombieChecked >= 2 then
				continue
			end

			-- COMPARE XZ DISTANCE
			local ClosestPoint = GetClosestPointOnPart(OtherPart, PartPos)
			local ClampedPartPos = Vector3.new(PartPos.X, 0, PartPos.Z)
			local Distance = (PartPos - ClosestPoint)
			Distance = Vector3.new(Distance.X, 0, Distance.Z).Magnitude
			if Distance > MaxDistance then
				continue
			end

			table.insert(NearbyParts, {
				OtherPart = OtherPart,
				Distance = Distance,
				ClosestPoint = ClosestPoint,
			})
			--MarkPartCells(OtherPart)
			CheckedParts[OtherPart] = true
		end
	end

	-- LOOP THROUGH CELLS WITHIN BOUNDING BOX
	local CellsChecked = 0
	for _, Cell in Cells do
		local X = Cell.X
		local Z = Cell.Z
		local WorldX = X * CELL_SIZE + CELL_SIZE / 2
		local WorldZ = Z * CELL_SIZE + CELL_SIZE / 2
		local CellCenter = Vector3.new(WorldX, PartPos.Y, WorldZ)

		-- CHECK FOR DISTANCE TO PREVENT CHECKING CELLS TOO FAR
		if (PartPos - CellCenter).Magnitude > MaxDistance + CELL_SIZE * math.sqrt(2) / 2 then
			continue
		end

		CheckCell(X, Z)
		--CellsChecked += 1
	end
	return NearbyParts, WallNearby
end

-- DETERMINE IF A PART IS INSIDE ANOTHER
local function IsInsidePart(Part, WorldPoint)
	local LocalPoint = Part.CFrame:PointToObjectSpace(WorldPoint)
	local HalfSize = Part.Size * 0.5
	local Extra = 0.3
	return LocalPoint.X >= -HalfSize.X - Extra
		and LocalPoint.X <= HalfSize.X + Extra
		and LocalPoint.Z >= -HalfSize.Z - Extra
		and LocalPoint.Z <= HalfSize.Z + Extra
end

-- MOVEMENT WITH COLLISIONS
function SpatialGridFW.MoveWithCollisions(Part, TargetPos)
	-- SOME STATS
	local COLLISION_RADIUS = 3
	local MaxDistance = 15

	-- DIRECTION AND GROUND
	local PreviousPos = Part.Position
	local Direction = (TargetPos - Part.Position)
	if Direction.Magnitude <= 0.1 then
		return Part.Position, Part.CFrame.LookVector
	end
	Direction = Vector3.new(Direction.X, 0, Direction.Z).Unit

	local Data = ZombieData:Get(Part)
	if not Data then
		return Part.Position, Direction
	end

	-- UPDATE POSITION ON GRID AND GET NEARBY PARTS
	SpatialGridFW.UpdatePartPosition(Part)
	local WallNearby = false
	Data.Grid.NearbyParts, WallNearby = SpatialGridFW.GetNearbyParts(Part, MaxDistance)
	if not Data.Grid.NearbyParts then
		return Part.Position, Direction
	end

	-- CHECK FOR NEARBY OBSTACLES
	Data.Grid.ObstacleNearby = WallNearby

	-- GET THE FINALPOS EARLY INCASE NO COLLISION IS NEEDED
	local FinalPos = Vector3.new(TargetPos.X, Data.Position.GroundPos, TargetPos.Z)
	local IsCollidingWithWall = false

	-- LOOP THROUGH NEARBY PARTS
	if Data.Grid.ObstacleNearby then
		for _, Info in Data.Grid.NearbyParts do
			local OtherPart = Info.OtherPart
			local DistanceToPoint = Info.Distance
			local ClosestPoint = Info.ClosestPoint
			if DistanceToPoint >= COLLISION_RADIUS then
				continue
			end

			-- CHECK IF OTHER PART IS ZOMBIE OR NOT
			if OtherPart:HasTag("ServerZombieTag") then
				continue
			end
			IsCollidingWithWall = true

			-- DIRECTION TO CLOSEST POINT ON WALL
			local DirectionToPoint = (Part.Position - ClosestPoint).Unit
			-- ENSURE DIRECTION HAS NO Y
			DirectionToPoint = Vector3.new(DirectionToPoint.X, 0, DirectionToPoint.Z).Unit

			local RepelledPos
			-- INCASE
			if DistanceToPoint <= 0.1 then
				RepelledPos = Part.Position - Direction * 5
				--local RandomOffset = Vector3.new(
				--	(math.random() - 0.5) * 0.2,
				--	0,
				--	(math.random() - 0.5) * 0.2
				--)
				FinalPos = Vector3.new(RepelledPos.X, Data.Position.GroundPos, RepelledPos.Z)
				break
			end

			-- REPEL OUT IF INSIDE WALL
			if IsInsidePart(OtherPart, Part.Position) then
				RepelledPos = Part.Position - Direction * 5
			-- ELSE WEAKER REPULSION
			else
				RepelledPos = Part.Position + DirectionToPoint * 1
			end

			local MovementDistance = (RepelledPos - Part.Position).Magnitude
			FinalPos = Vector3.new(RepelledPos.X, Data.Position.GroundPos, RepelledPos.Z)
		end
	end

	-- COLLISION STATE
	Data.Collision.CanCollideOthers = not IsCollidingWithWall

	-- EXTRA CHECK IF ZOMBIE IS MOVING TOO FAR
	if (PreviousPos - FinalPos).Magnitude > 20 then
		return Vector3.new(TargetPos.X, Data.Position.GroundPos, TargetPos.Z), Direction
	end

	return FinalPos, Direction
end

-- VISUAL GRID ON MAP
function SpatialGridFW.VisualizeGrid()
	for X, Row in SpatialGridFW.SpatialGrid do
		for Z, Parts in Row do
			local WorldX = X * CELL_SIZE + CELL_SIZE / 2
			local WorldZ = Z * CELL_SIZE + CELL_SIZE / 2
			local WorldY = 0

			local Cell = Instance.new("Part")
			Cell.Size = Vector3.new(CELL_SIZE, 0.2, CELL_SIZE)
			Cell.Position = Vector3.new(WorldX, WorldY, WorldZ)
			Cell.Anchored = true
			Cell.CanCollide = false
			Cell.CanQuery = false
			Cell.CanTouch = false
			Cell.CastShadow = false
			Cell.Transparency = 0.8

			-- COUNT PARTS
			local PartCount = 0
			for _ in pairs(Parts) do
				PartCount += 1
			end
			if PartCount <= 0 then
				continue
			end

			-- CHANGE COLOR BASED ON PART AMOUNT
			local Intensity = math.min(PartCount / 5, 1)
			Cell.Color = Color3.fromRGB(255 * Intensity, 0, 0)

			Cell.Parent = workspace:WaitForChild("GridVisuals")

			local Billboard = Instance.new("BillboardGui")
			Billboard.Size = UDim2.new(2, 0, 1, 0)
			Billboard.StudsOffset = Vector3.new(0, 1, 0)
			Billboard.Parent = Cell

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.BackgroundTransparency = 1
			Label.Text = tostring(PartCount)
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.TextScaled = true
			Label.Font = Enum.Font.SourceSansBold
			Label.Parent = Billboard

			DebrisService:AddItem(Cell, 10)
		end
	end
end

return SpatialGridFW
