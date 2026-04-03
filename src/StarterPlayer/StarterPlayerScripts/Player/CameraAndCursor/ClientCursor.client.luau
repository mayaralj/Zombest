-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- PLAYER AND CAMERA
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()
local PlayerGUI = Player.PlayerGui

-- FOLDERS
local Events = ReplicatedStorage:WaitForChild("Events")
local ModuleScripts = ReplicatedStorage:WaitForChild("ModuleScripts")
local ClientData = ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Client")

-- MODULES
local CharacterUtilities = require(ModuleScripts:WaitForChild("Misc"):WaitForChild("ClientUtilities"))
local ClientGunDataModule = require(ClientData:WaitForChild("ClientGunData"))

-- VARIABLES
local CursorRender
local RegularBulletLabel
local CursorGUI

local ColorChangeConnection
local ExpandSizeConnection

-- FUNCTION TO CHANGE CURSOR
local function ChangeCursor(EquippedGun)
	PartialCleanup()
	local CurrentGunData = ClientGunDataModule:Get(Player)
	if not CurrentGunData then
		return
	end

	-- DISABLE REGULAR CURSOR
	UIS.MouseIconEnabled = false

	-- CREATE OR GET SCREENGUI
	if not CursorGUI then
		CursorGUI = Instance.new("ScreenGui")
		CursorGUI.Name = "CustomCursorGui"
		CursorGUI.ResetOnSpawn = false
		CursorGUI.DisplayOrder = 999
		CursorGUI.Parent = PlayerGUI
	end
	-- CLONE BULLET LABEL
	local CursorDefaultSize = CurrentGunData.Cursor.CursorDefaultSize
	local CursorMaxSize = CurrentGunData.Cursor.CursorMaxSize
	local RegularSize = UDim2.new(0, CursorDefaultSize, 0, CursorDefaultSize)
	local ExpandedSize = UDim2.new(0, CursorMaxSize, 0, CursorMaxSize)

	-- CLONE LABEL
	if RegularBulletLabel then
		RegularBulletLabel.Image = CurrentGunData.Cursor.CursorImage
		RegularBulletLabel.Size = RegularSize
	else
		RegularBulletLabel = Instance.new("ImageLabel")
		RegularBulletLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		RegularBulletLabel.BackgroundTransparency = 1
		RegularBulletLabel.Image = CurrentGunData.Cursor.CursorImage
		RegularBulletLabel.Size = RegularSize
		RegularBulletLabel.Parent = CursorGUI
	end

	-- IF STREAM BULLET KEEP AT MAX SIZE WHILE SHOOTING
	if Player:GetAttribute("BulletType") == "Stream" then
		ExpandSizeConnection = Player:GetAttributeChangedSignal("IsShooting"):Connect(function()
			local CursorSizeIncrease = CurrentGunData.Cursor.CursorSizeIncrease
			-- TWEEN SIZE
			if Player:GetAttribute("IsShooting") and Player:GetAttribute("BulletType") == "Stream" then
				local TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local TargetSize = ExpandedSize + UDim2.new(0, CursorSizeIncrease, 0, CursorSizeIncrease)
				local SizeTween = TweenService:Create(RegularBulletLabel, TweenInfo, { Size = TargetSize })
				SizeTween:Play()
			else
				local TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local TargetSize = RegularSize

				local SizeTween = TweenService:Create(RegularBulletLabel, TweenInfo, { Size = TargetSize })
				SizeTween:Play()
			end
		end)

	-- LISTEN FOR SHOT FIRED CHANGES (REGULAR BULLETS)
	else
		ExpandSizeConnection = Player:GetAttributeChangedSignal("ShotFired"):Connect(function()
			local CursorSizeIncrease = CurrentGunData.Cursor.CursorSizeIncrease
			-- TWEEN SIZE
			if Player:GetAttribute("ShotFired") then
				local TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local TargetSize = ExpandedSize + UDim2.new(0, CursorSizeIncrease, 0, CursorSizeIncrease)
				local SizeTween = TweenService:Create(RegularBulletLabel, TweenInfo, { Size = TargetSize })
				SizeTween:Play()
			else
				local TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local TargetSize = RegularSize

				local SizeTween = TweenService:Create(RegularBulletLabel, TweenInfo, { Size = TargetSize })
				task.wait()
				SizeTween:Play()
			end
		end)
	end

	-- LISTEN FOR SHOTHITZOMBIE CHANGES
	ColorChangeConnection = Player:GetAttributeChangedSignal("ShotHitZombie"):Connect(function()
		-- COLOR CHANGE
		local CursorHitColor = CurrentGunData.Cursor.CursorHitColor
		if not CursorHitColor then
			return
		end
		local TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local TargetColor

		if Player:GetAttribute("ShotHitZombie") then
			TargetColor = CursorHitColor
		else
			TargetColor = Color3.fromRGB(255, 255, 255)
		end

		local ColorTween = TweenService:Create(RegularBulletLabel, TweenInfo, { ImageColor3 = TargetColor })
		ColorTween:Play()
	end)

	-- UPDATE CURSOR IN RENDER STEPPED
	CursorRender = RunService.RenderStepped:Connect(function()
		if not Player or not Player:GetAttribute("IsEquippingGun") then
			RegularBulletLabel:Destroy()
			CursorRender:Disconnect()
			CursorRender = nil
			UIS.MouseIconEnabled = true
			return
		end

		-- CAP SIZE
		if RegularBulletLabel.Size.X.Offset >= CursorMaxSize then
			RegularBulletLabel.Size = UDim2.new(0, CursorMaxSize, 0, CursorMaxSize)
		end

		-- FOLLOW MOUSE POSITION
		RegularBulletLabel.Position = UDim2.new(0, PlayerMouse.X, 0, PlayerMouse.Y)
	end)
end

function PartialCleanup()
	if ColorChangeConnection then
		ColorChangeConnection:Disconnect()
		ColorChangeConnection = nil
	end
	if ExpandSizeConnection then
		ExpandSizeConnection:Disconnect()
		ExpandSizeConnection = nil
	end
	if CursorRender then
		CursorRender:Disconnect()
		CursorRender = nil
	end
	if RegularBulletLabel then
		RegularBulletLabel:Destroy()
		RegularBulletLabel = nil
	end
	UIS.MouseIconEnabled = true
end

-- ROTATION UPDATER
local CursorConnection
local function OnCharacterAdded(Character)
	if Player:GetAttribute("IsEquippingGun") or Player:GetAttribute("EquippedGun") then
		ChangeCursor()
	end

	-- ATTRIBUTE CHANGE
	CursorConnection = Player:GetAttributeChangedSignal("IsEquippingGun"):Connect(function()
		if Player:GetAttribute("IsEquippingGun") or Player:GetAttribute("EquippedGun") then
			ChangeCursor()
		end
	end)
end

-- CLEANUP FUNCTION
local function FullCleanup()
	if CursorConnection then
		CursorConnection:Disconnect()
		CursorConnection = nil
	end
	if ColorChangeConnection then
		ColorChangeConnection:Disconnect()
		ColorChangeConnection = nil
	end
	if ExpandSizeConnection then
		ExpandSizeConnection:Disconnect()
		ExpandSizeConnection = nil
	end
	if CursorRender then
		CursorRender:Disconnect()
		CursorRender = nil
	end
	if RegularBulletLabel then
		RegularBulletLabel:Destroy()
		RegularBulletLabel = nil
	end
	if CursorGUI then
		CursorGUI:Destroy()
		CursorGUI = nil
	end
	UIS.MouseIconEnabled = true
end

-- CLEANUP WHEN CHARACTER DEAD
Player.CharacterRemoving:Connect(function()
	FullCleanup()
end)
-- INITIALIZE
CharacterUtilities.BindToCharacter(Player, OnCharacterAdded)
