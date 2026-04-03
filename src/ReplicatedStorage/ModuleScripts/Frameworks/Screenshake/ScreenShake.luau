local ScreenShake = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FOLDERS
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")

-- MODULES
local ClientPlayerData = require(ModuleScripts:WaitForChild("Client"):WaitForChild("ClientPlayerData"))

-- APPLY SCREENSHAKE FUNCTION
function ScreenShake.ApplyScreenShake(LocalOnly, PlayerViewing, PlayerShaking, Intensity, Range, RepeatCount)
	local PlayerViewingData = ClientPlayerData:Get(PlayerViewing)
	if not PlayerViewing then
		return
	end

	-- PLAYER VIEWING CHARACTER
	local CharacterViewing = PlayerViewing.Character
	if not CharacterViewing then
		return
	end
	local RootPartViewing = CharacterViewing:FindFirstChild("HumanoidRootPart")
	if not RootPartViewing then
		return
	end

	-- CHECK IF SCREENSHAKE ONLY MEANT FOR LOCAL PLAYER
	if LocalOnly and PlayerViewing ~= PlayerShaking then
		return
	end

	-- REPEAT BASED ON REPEATCOUNT
	if not RepeatCount then
		RepeatCount = 1
	end
	for i = 1, RepeatCount do
		local FinalIntensity = nil
		-- PLAYER SHAKING CHARACTER
		local CharacterShaking = PlayerShaking.Character
		if not CharacterShaking then
			return
		end
		local RootPartShaking = CharacterShaking:WaitForChild("HumanoidRootPart")
		if not RootPartShaking then
			return
		end

		-- CHECK IF IN RANGE
		local DistancePlayers = (RootPartViewing.Position - RootPartShaking.Position).Magnitude
		if DistancePlayers > Range then
			return
		end

		-- DECREASE BASED ON RANGE
		FinalIntensity = Intensity / (DistancePlayers / 10)
		if FinalIntensity > Intensity then
			FinalIntensity = Intensity
		end

		-- RANDOMIZE SCREENSHAKE
		local RNG = Random.new()
		local XRandom = RNG:NextNumber(-FinalIntensity, FinalIntensity)
		local YRandom = RNG:NextNumber(-FinalIntensity, FinalIntensity)
		local ZRandom = RNG:NextNumber(-FinalIntensity, FinalIntensity)
		FinalIntensity = Vector3.new(XRandom, YRandom, ZRandom)

		-- APPLY SHAKE OFFSET
		PlayerViewingData.CameraSettings.ShakeOffset += FinalIntensity
	end
end

return ScreenShake
