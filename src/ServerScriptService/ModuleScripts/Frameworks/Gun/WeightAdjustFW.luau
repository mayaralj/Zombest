local WeightAdjustFW = {}

-- SERVICES

-- FOLDERS

-- MODULES

-- ADJUST MOVE WEIGHT IF SHOOTING OR NOT
function WeightAdjustFW.MoveWeightAdjust(Player, CurrentGunData)
	if
		not Player:GetAttribute("IsReloading")
		and not Player:GetAttribute("IsCharging")
		and not Player:GetAttribute("VisuallyCharging")
	then
		if Player:GetAttribute("IsShooting") then
			CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.ShootMoveWeight
		else
			if Player:GetAttribute("IsSprinting") then
				CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.RunMoveWeight
			else
				CurrentGunData.Weight.MoveWeight = CurrentGunData.Weight.WalkMoveWeight
			end
		end
	end
end

return WeightAdjustFW
