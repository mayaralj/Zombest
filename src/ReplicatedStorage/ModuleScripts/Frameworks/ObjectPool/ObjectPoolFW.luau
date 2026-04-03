local ObjectPoolFW = {}
-- FOLDERS
local PooledObjects = workspace:WaitForChild("PooledObjects")


-- CREATE POOLS
local PoolTable = {}
function ObjectPoolFW.Create(ObjectToCreate, Amount)
	if not PoolTable[ObjectToCreate.Name] then
		PoolTable[ObjectToCreate.Name] = {}
	end
	
	for i = 1, Amount do
		local Object = ObjectToCreate:Clone()
		Object.Parent = PooledObjects
		Object.Position = Vector3.new(-1000000, -10000, -1000000)
		table.insert(PoolTable[ObjectToCreate.Name], Object)
	end
end



-- GET METHOD
function ObjectPoolFW.Get(Object)
	local ObjectPool = PoolTable[Object.Name]
	if not ObjectPool then return end
	
	local ObjectToReturn = table.remove(ObjectPool, #ObjectPool)
	if not ObjectToReturn then return end
	
	return ObjectToReturn
end



-- RETURN TO POOL METHOD
function ObjectPoolFW.Return(Object)
	if not PoolTable[Object.Name] then return end
	Object.Position = Vector3.new(-1000000, -10000, -1000000)
	table.insert(PoolTable[Object.Name], Object)
end



-- CLEAR POOL METHOD
function ObjectPoolFW.Clear(Object)
	if not PoolTable[Object.Name] then return end
	for _, Obj in PoolTable[Object.Name] do
		Obj:Destroy()
	end
	PoolTable[Object.Name] = {}
end



-- RETURN
return ObjectPoolFW