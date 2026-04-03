local TableClone = {}

function TableClone.DeepClone(T)
	if type(T) ~= "table" then return T end
	local Copy = {}
	for i, v in pairs(T) do
		Copy[i] = TableClone.DeepClone(v)
	end
	return Copy
end

return TableClone