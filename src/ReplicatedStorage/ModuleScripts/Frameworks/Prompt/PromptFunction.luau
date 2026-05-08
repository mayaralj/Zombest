local PromptFunction = {}
-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- EVENTS
local PromptEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PromptEvents")
local GiveGunPrompt = PromptEvents:WaitForChild("GiveGunPrompt")
local MysteryPrompt = PromptEvents:WaitForChild("MysteryPrompt")

-- GIVE GUN FROM PROMPT
function PromptFunction.GiveGun(Part, Prompt)
	-- ON TRIGGER FIRE EVENT TO SERVER
	Prompt.Triggered:Connect(function(Player)
		-- GUI
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local PromptGui = PlayerGui:WaitForChild("Prompt"):WaitForChild("PromptGui")
		-- SINK IF PROMPT GUI NOT ENABLED (SIGHT IS BLOCKED)
		if not PromptGui.Enabled then
			return
		end
		-- FOR YOUSIF SPEC
		local EquippingGun = Player:GetAttribute("IsEquippingGun")
		if
			Part.Name == "LightningFist"
			and Player.Name ~= "Yousif86"
			and (EquippingGun and EquippingGun ~= Part.Name)
		then
			local PlayerGui = Player:FindFirstChild("PlayerGui")
			if not PlayerGui then
				return
			end
			local YousifSpecGui = PlayerGui:FindFirstChild("YousifSpecGuiFolder"):FindFirstChild("YousifSpecGui")
			if not YousifSpecGui then
				return
			end

			-- ADD SFX
			local NewSFX = Instance.new("Sound")
			NewSFX.SoundId = "rbxassetid://139421760850946"
			NewSFX.Parent = YousifSpecGui
			NewSFX.PlaybackRegionsEnabled = true
			NewSFX.PlaybackRegion = NumberRange.new(0.24, 5)
			NewSFX.Volume = 10
			NewSFX:Play()
			Debris:AddItem(NewSFX, 5)

			YousifSpecGui.Enabled = true
			task.delay(5, function()
				if not YousifSpecGui then
					return
				end
				YousifSpecGui.Enabled = false
			end)
		end

		local CurrentGun = Player:GetAttribute("IsEquippingGun")
		GiveGunPrompt:FireServer(Part)
		task.wait(0.05)
	end)
end

-- MYSTERY BOX PROMPT
function PromptFunction.MysteryBox(Prompt)
	Prompt.Triggered:Connect(function(Player)
		-- GUI
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local PromptGui = PlayerGui:WaitForChild("Prompt"):WaitForChild("PromptGui")
		-- SINK IF PROMPT GUI NOT ENABLED (SIGHT IS BLOCKED)
		if not PromptGui.Enabled then
			return
		end

		MysteryPrompt:FireServer(Prompt)
	end)
end

-- RETURN
return PromptFunction
