local GunMiscFW = {}

-- SERVICES
local Players = game:GetService("Players")

-- FOLDERS

-- EVENTS

-- LIST TO EXCLUDE THINGS FROM RAYCAST
function GunMiscFW.GetListToExclude(LocalPlayer, ExcludeLocal, ExcludePlayers)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if not Character then
		return {}
	end

	local GunModel = Character:FindFirstChild("EquippedGun")
	local BulletEffects = workspace:WaitForChild("BulletsFolder"):WaitForChild("BulletEffects")
	local DeadCharacters = workspace:WaitForChild("DeadCharacters")
	local Excluded = { BulletEffects, DeadCharacters }

	if GunModel then
		table.insert(Excluded, GunModel)
	end

	if BulletEffects then
		table.insert(Excluded, BulletEffects)
	end

	if ExcludePlayers then
		for _, Player in ipairs(Players:GetPlayers()) do
			if Player ~= LocalPlayer and Player.Character then
				table.insert(Excluded, Player.Character)
			end
		end
	end

	if ExcludeLocal and LocalPlayer.Character then
		table.insert(Excluded, LocalPlayer.Character)
	end

	return Excluded
end

-- LIST TO EXCLUDE THINGS FROM RAYCAST
function GunMiscFW.GetListToInclude(LocalPlayer)
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if not Character then
		return {}
	end

	local ServerZombies = workspace:WaitForChild("ServerZombies")
	local PhaseParts = workspace:WaitForChild("PhaseParts")
	local Included = { ServerZombies, PhaseParts }

	return Included
end

return GunMiscFW
