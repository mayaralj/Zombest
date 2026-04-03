-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- VARIABLES
local ColorEffect = game.Lighting:WaitForChild("ColorCorrection")
local BlurEffect = game.Lighting:WaitForChild("Blur")

-- APPLY EFFECT
local HealthChangedConnection
local function ApplyBloodEffect()
	BlurEffect.Size = 0
	ColorEffect.TintColor = Color3.new(1, 1, 1)
	local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")

	-- CLEANUP
	if HealthChangedConnection then
		HealthChangedConnection:Disconnect()
		HealthChangedConnection = nil
	end
	-- CHANGE SCREEN BLUR AND COLOR BASED ON HEALTH
	local Lerping
	local LerpSize
	local LerpColor
	HealthChangedConnection = Humanoid.HealthChanged:Connect(function()
		-- DONT CHANGE IF HEALTH ABOVE 60
		if
			(Humanoid.Health <= Humanoid.MaxHealth and Humanoid.Health > Humanoid.MaxHealth * 0.6)
			or Humanoid.Health <= 0
		then
			if Lerping then
				return
			end
			if LerpColor then
				LerpColor:Cancel()
				LerpColor:Destroy()
				LerpColor = nil
			end
			if LerpSize then
				LerpSize:Cancel()
				LerpSize:Destroy()
				LerpSize = nil
			end
			LerpSize = TweenService:Create(
				BlurEffect,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = 0 }
			)
			LerpColor = TweenService:Create(
				ColorEffect,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TintColor = Color3.new(1, 1, 1) }
			)
			LerpSize:Play()
			LerpColor:Play()
			Lerping = true
			return
		end
		-- REMOVE TWEENS
		Lerping = false
		if LerpColor then
			LerpColor:Cancel()
			LerpColor:Destroy()
			LerpColor = nil
		end
		if LerpSize then
			LerpSize:Cancel()
			LerpSize:Destroy()
			LerpSize = nil
		end

		-- CALCULATE BLUR AND COLOR INTENSITY
		local HealthRatio = (Humanoid.Health / (Humanoid.MaxHealth * 0.6))
		local ColorIntensity
		if LocalPlayer:GetAttribute("IsKnocked") then
			BlurEffect.Size = 9 * (1 - HealthRatio)
			ColorIntensity = 0.55
		else
			BlurEffect.Size = 7 * (1 - HealthRatio)
			ColorIntensity = 0.3
		end

		-- TWEEN TINT
		local TweenTintColorInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local TintColor = Color3.new(1, 1 - (1 - HealthRatio) * ColorIntensity, 1 - (1 - HealthRatio) * ColorIntensity)
		LerpColor = TweenService:Create(ColorEffect, TweenTintColorInfo, { TintColor = TintColor })
		LerpColor:Play()
	end)
end

-- IF CHARACTER ALREADY EXISTS APPLY EFFECT
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
if Character then
	ApplyBloodEffect()
end

-- APPLY ON EVERY CHARACTER ADDED FOR LOCAL PLAYER
LocalPlayer.CharacterAdded:Connect(function()
	ApplyBloodEffect()
end)
