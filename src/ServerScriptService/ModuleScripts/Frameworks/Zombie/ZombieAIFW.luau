local ZombieAIFW = {}

-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- FOLDERS
local Modules = ServerScriptService:WaitForChild("ModuleScripts")
local Frameworks = Modules:WaitForChild("Frameworks")

-- MODULES
local PlayerData = require(Modules:WaitForChild("Data"):WaitForChild("PlayerData"))
local ZombieData = require(Modules:WaitForChild("Data"):WaitForChild("ZombieData"))

-- RAYCAST PARAMS
local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Include

-- CREATE PATH TO PLAYER
function ZombieAIFW.CreatePath(ZombiePart, Player)
	-- INCASE
	if not ZombiePart or not Player then
		return nil
	end

	-- CHARACTER
	local Character = Player.Character
	if not Character or not Character.Parent then
		return nil
	end
	local PlayerRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not PlayerRootPart then
		return nil
	end

	-- POSITIONS
	local ZombiePos = ZombiePart.Position
	local PlayerPos = PlayerRootPart.Position

	-- DISTANCE
	local Distance = (ZombiePos - PlayerPos).Magnitude
	if not Distance then
		return
	end

	-- CREATE PATH
	local Path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentJumpHeight = 0,
		AgentMaxSlope = 45,
	})

	-- COMPUTE PATH
	Path:ComputeAsync(ZombiePos, PlayerPos)

	-- RETURN PATH
	return Path
end

-- GET CLOSEST PLAYER TO ZOMBIE (IGNORE KNOCKED PLAYERS)
function ZombieAIFW.GetClosestPlayer(ZombiePart, Any)
	local Target = nil
	local PriorityTarget = nil
	local ClosestDistance = math.huge

	for _, Player in Players:GetPlayers() do
		-- CHARACTER STUFF
		local Character = Player.Character
		if not Character then
			continue
		end
		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			continue
		end
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not Humanoid then
			continue
		end

		-- IF IN LOBBY TEAM SKIP
		if Player.Team == Teams:FindFirstChild("Lobby") then
			continue
		end

		-- IF DEAD SKIP
		if Humanoid.Health <= 0 then
			continue
		end

		-- DISTANCE
		local Distance = (RootPart.Position - ZombiePart.Position).Magnitude

		-- GET ANY PLAYER (including knocked)
		if Any then
			if Distance < ClosestDistance then
				Target = Player
				if not Player:GetAttribute("IsKnocked") then
					PriorityTarget = Player
				end
				ClosestDistance = Distance
			end

		-- GET NON KNOCKED PLAYERS ONLY
		elseif Player and not Player:GetAttribute("IsKnocked") and not Player:GetAttribute("IsRevived") then
			if Distance < ClosestDistance then
				Target = Player
				ClosestDistance = Distance
			end
		end
	end
	return PriorityTarget or Target, ClosestDistance
end

-- CHECK OBSTACLE BETWEEN TARGET AND ZOMBIE VIA RAYCAST
function ZombieAIFW.NoObstacleBetweenTargetAndZombie(Target, Zombie)
	if not Target or not Zombie then
		return true
	end

	local TargetCharacter = Target.Character
	if not TargetCharacter or not TargetCharacter.Parent then
		return true
	end

	local TargetRootPart = TargetCharacter:FindFirstChild("HumanoidRootPart")
	if not TargetRootPart then
		return true
	end

	local Direction = TargetRootPart.Position - Zombie.Position
	local Origin = Zombie.Position
	local TargetPos = TargetRootPart.Position

	-- FINAL DIRECTION
	local FinalDirection = Direction.Magnitude > 50 and Direction.Unit * 50 or Direction

	-- RAYCAST
	local FilterList = { workspace:FindFirstChild("PhaseParts") }
	RaycastParamsCache.FilterDescendantsInstances = FilterList

	local Result = workspace:Raycast(Origin, FinalDirection, RaycastParamsCache)
	if Result then
		-- WALL DETECTED
		return false
	end

	return true
end

-- ZOMBIE ATTACK FUNCTION
function ZombieAIFW.ZombieAttack(ZombiePart, Target, ClosestDistance)
	-- PLAYER DATA
	local PlayerCurrentData = PlayerData:Get(Target)
	if not PlayerCurrentData then
		return
	end

	-- IF KNOCKED SKIP
	if PlayerCurrentData.Knockdown.IsKnocked then
		return
	end

	-- ZOMBIE DATA
	local ZombieCurrentData = ZombieData:Get(ZombiePart)
	if not ZombieCurrentData then
		return
	end

	-- TIMER
	local Now = tick()
	local LastAttack = ZombieCurrentData.Cooldowns.ZombieAttackCooldown or 0
	local LastHit = PlayerCurrentData.Cooldowns.PlayerHitCooldown or 0
	if Now - LastAttack < 1 then
		return
	end
	if Now - LastHit < 0.25 then
		return
	end

	-- CHARACTER STUFF
	local TargetCharacter = Target.Character
	local TargetRoot = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
	local TargetHumanoid = TargetCharacter and TargetCharacter:FindFirstChild("Humanoid")
	if not TargetHumanoid or not TargetRoot then
		return
	end

	if ClosestDistance <= 3 then
		-- DAMAGE PLAYER
		TargetHumanoid:TakeDamage(ZombieCurrentData.Damage.DamagePerHit)

		-- COOLDOWNS
		ZombieCurrentData.Cooldowns.ZombieAttackCooldown = Now
		PlayerCurrentData.Cooldowns.PlayerHitCooldown = Now
	end
end

return ZombieAIFW
