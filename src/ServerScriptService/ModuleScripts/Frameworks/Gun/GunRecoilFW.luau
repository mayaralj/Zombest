local GunRecoilFW = {}

-- SERVICES

-- FOLDERS

-- RECOIL BULLET SPREAD
function GunRecoilFW.GetRecoilSpread(Player, CurrentGunData, Direction)
	local RecoilSpreadData = CurrentGunData.RecoilSpread
	if not RecoilSpreadData then
		return Direction
	end

	local TimeSinceLastShot = tick() - RecoilSpreadData.LastShotTime
	-- DECAY THE SPREAD IF ENOUGH TIME PASSED
	if TimeSinceLastShot > RecoilSpreadData.RecoveryTime then
		-- RESET/DECAY SPREAD
		RecoilSpreadData.ConsecutiveShots = 0
		RecoilSpreadData.CurrentSpread =
			math.max(0, RecoilSpreadData.CurrentSpread - (RecoilSpreadData.RecoveryRate * TimeSinceLastShot))
	end

	-- TRACK SHOTS AND TIME
	RecoilSpreadData.ConsecutiveShots += 1
	RecoilSpreadData.LastShotTime = tick()

	-- CALCULATE NEW SPREAD
	local SpreadMultipliier = math.min(
		RecoilSpreadData.ConsecutiveShots * RecoilSpreadData.SpreadIncrease,
		RecoilSpreadData.MaxSpread - RecoilSpreadData.BaseSpread
	)
	RecoilSpreadData.CurrentSpread = RecoilSpreadData.BaseSpread + SpreadMultipliier

	-- GET SPREAD OFF SET
	local SpreadX = (math.random() - 0.5) * 2 * RecoilSpreadData.CurrentSpread
	local SpreadZ = (math.random() - 0.5) * 2 * RecoilSpreadData.CurrentSpread

	-- APPLY SPREAD OFFSET
	local SpreadDirection = Vector3.new(Direction.X + SpreadX, Direction.Y, Direction.Z + SpreadZ)

	-- SET CONSECUTIVE SHOT ATTRIBUTE
	Player:SetAttribute("ConsecutiveShots", RecoilSpreadData.ConsecutiveShots)
	-- RETURN NEW DIRECTION WITH OFFSET
	return SpreadDirection.Unit
end

return GunRecoilFW
