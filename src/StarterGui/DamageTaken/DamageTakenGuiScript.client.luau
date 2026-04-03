-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")


-- PLAYER
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")


-- PLAYER GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local DamageTakenGui = PlayerGui:WaitForChild("DamageTaken"):WaitForChild("DamageTakenGui")
local BloodVignette = DamageTakenGui:WaitForChild("BloodVignette")
local InstantBlood = DamageTakenGui:WaitForChild("InstantBlood")



-- ON HUMANOID HP CHANGED
local Connection
local TweenBack
local InstantTween
local KnockedActivated = false
local LastHealth = Humanoid.Health
Connection = Humanoid.HealthChanged:Connect(function(NewHealth)
	-- RESET KNOCKED ACTIVATED
	if not LocalPlayer:GetAttribute("IsKnocked") then
		KnockedActivated = false
	end
	
	-- TOOK DAMAGE
	if NewHealth < LastHealth or (LocalPlayer:GetAttribute("IsKnocked") and not KnockedActivated) then
		-- DAMGE TAKEN
		local DamageTakenPercent = ((LastHealth - NewHealth)/Humanoid.MaxHealth) * 100
		
		-- INSTANT BLOOD EFFECT
		if DamageTakenPercent >= 5 or (LocalPlayer:GetAttribute("IsKnocked") and not KnockedActivated) then
			-- INSTANT SET
			local Intensity = math.clamp(0.25 + (DamageTakenPercent / 100), 0.25, 0.5)
			InstantBlood.ImageTransparency = 1 - Intensity
			
			-- ONE TIME KNOCKED
			if (LocalPlayer:GetAttribute("IsKnocked") and not KnockedActivated) then
				Intensity = 0.5
				KnockedActivated = true
			end
			
			-- TWEEN
			if InstantTween then
				InstantTween:Cancel()
			end
			InstantTween = TweenService:Create(
				InstantBlood, 
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
				{ImageTransparency = 1}
			)
			InstantTween:Play()
			Debris:AddItem(InstantTween, 0.4)
		end
	end
	
	-- TRACK LAST HEALTH
	LastHealth = NewHealth
	
	-- ONLY START AFTER HP IS LESS THAN 60
	if NewHealth > 60 then 
		if TweenBack then
			TweenBack:Cancel()
		end
		-- TWEEN TRANSPARENCY
		TweenBack = TweenService:Create(BloodVignette, TweenInfo.new(0.5), {ImageTransparency = 1})
		TweenBack:Play()
		Debris:AddItem(TweenBack, 0.5)
		return 
	end
	-- ENSURE TWEEN BACK GETS CANCELLED
	if TweenBack then
		TweenBack:Cancel()
	end
	
	-- BLOOD VIGNETTE TRANSPARENCY
	BloodVignette.ImageTransparency = math.max((Humanoid.Health - Humanoid.MaxHealth * 0.3) / (Humanoid.MaxHealth * 0.7), 0.85)
end)



-- DISCONNECT CONNECTION
Humanoid.Died:Connect(function()
	if Connection then
		Connection:Disconnect()
	end
	if TweenBack then
		TweenBack:Cancel()
	end
	if InstantTween then
		InstantTween:Cancel()
	end
	InstantBlood.ImageTransparency = 1
	BloodVignette.ImageTransparency = 1
end)