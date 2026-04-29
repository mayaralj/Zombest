-- PLAYERS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GET THE WAVE GUI
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local waveGui = playerGui:WaitForChild("WaveGuiFolder"):WaitForChild("WaveGui")
local Frame = waveGui:WaitForChild("Frame")
local WaveText = Frame:WaitForChild("WaveText")
local WaveCount = Frame:WaitForChild("WaveCount")

-- GET ROUND TIMER GUI
local RoundTimerGui = playerGui:WaitForChild("RoundTimer"):WaitForChild("RoundTimerGui")

-- EVENTS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Events = ReplicatedStorage:WaitForChild("Events")
local WaveEvents = Events:WaitForChild("WaveEvents")
local UpdateWaveEvent = WaveEvents:WaitForChild("UpdateWaveEvent")

-- ENABLE AND UPDATE GUI ON EVENT
UpdateWaveEvent.OnClientEvent:Connect(function(CurrentWave)
	RoundTimerGui.Enabled = false
	WaveCount.Text = CurrentWave
	waveGui.Enabled = true

	-- DONT TWEEN SIZE AND COLOR IF FIRST WAVE
	if CurrentWave <= 1 then
		return
	end

	-- TWEEN THE COLOR TO RED FOR A BRIEF MOMENT
	local ColorTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local ColorWaveTween = TweenService:Create(WaveText, ColorTweenInfo, { TextColor3 = Color3.new(1, 0, 0) })
	local ColorCountTween = TweenService:Create(WaveCount, ColorTweenInfo, { TextColor3 = Color3.new(1, 0, 0) })
	ColorWaveTween:Play()
	ColorCountTween:Play()

	-- TWEEN FRAME SIZE KEEPING IT CENTERED
	local OriginalSize = Frame.Size
	local TargetSize =
		UDim2.new(OriginalSize.X.Scale * 1.5, OriginalSize.X.Offset, OriginalSize.Y.Scale * 1.5, OriginalSize.Y.Offset)
	local SizeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local SizeTween = TweenService:Create(Frame, SizeTweenInfo, { Size = TargetSize })
	SizeTween:Play()

	-- WAIT AND TWEEN EVERYTHING BACK
	task.wait(3)
	ColorWaveTween:Destroy()
	ColorCountTween:Destroy()
	SizeTween:Destroy()
	-- TWEEN THE COLOR BACK TO WHITE
	local ReturnColorTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local ReturnColorWaveTween =
		TweenService:Create(WaveText, ReturnColorTweenInfo, { TextColor3 = Color3.new(1, 1, 1) })
	local ReturnColorCountTween =
		TweenService:Create(WaveCount, ReturnColorTweenInfo, { TextColor3 = Color3.new(1, 1, 1) })
	ReturnColorWaveTween:Play()
	ReturnColorCountTween:Play()
	-- TWEEN SIZE BACK
	local ReturnSizeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local ReturnSizeTween = TweenService:Create(Frame, ReturnSizeTweenInfo, { Size = OriginalSize })
	ReturnSizeTween:Play()
end)
