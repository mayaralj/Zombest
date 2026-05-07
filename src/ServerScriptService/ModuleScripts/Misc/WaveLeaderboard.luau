-- SERVICES
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- DATASTORE
local WaveDataStore = DataStoreService:GetOrderedDataStore("WaveDataStore")

-- MODELS
local WaveLBModel = workspace:WaitForChild("WaveLBModel")
local Scriptable = WaveLBModel:WaitForChild("Scriptable")
local MainPart = Scriptable:WaitForChild("Main")
local MainGui = MainPart:WaitForChild("MainGui")
local MainFrame = MainGui:WaitForChild("MainFrame")
local Template = MainPart:WaitForChild("Template")

local WaveLeaderboard = {}
WaveLeaderboard.LowestWave = 0

-- UPDATE LEADERBOARD
function WaveLeaderboard.UpdateLeaderboard()
	-- WRAP IN PCALL TO ENSURE SAFE DATA RETRIEVAL
	local Success, Data = pcall(function()
		return WaveDataStore:GetSortedAsync(false, 10)
	end)
	if not Success then
		warn("Where the leaderboard data at")
		return
	end

	-- CLEAR CURRENT LEADERBOARD ENTRIES
	for _, Child in pairs(MainFrame:GetChildren()) do
		if Child.Name == "UIListLayout" then
			continue
		end
		Child:Destroy()
	end

	-- LOOP THROUGH FIRST PAGE OF LEADERBOARD DATA
	local Entries = Data:GetCurrentPage()
	for Rank, Entry in ipairs(Entries) do
		-- GET DATA
		local ID = Entry.key
		local PlayerPFF = "rbxthumb://type=AvatarHeadShot&id=" .. ID .. "&w=180&h=180"
		local PlayerName = Players:GetNameFromUserIdAsync(ID)
		local WaveReached = Entry.value

		-- CREATE LEADERBOARD ENTRY
		local NewEntry = Template:Clone()
		NewEntry.Name = PlayerName
		NewEntry.Parent = MainFrame
		local PlayerFrame = NewEntry:WaitForChild("PlayerFrame")
		local PlayerImageLabel = PlayerFrame:WaitForChild("PFP")
		local PlayerNameLabel = PlayerFrame:WaitForChild("Name")
		local RankLabel = NewEntry:WaitForChild("#")
		local WaveLabel = NewEntry:WaitForChild("Wave#")

		-- UPDATE ENTRY INFO
		PlayerImageLabel.Image = PlayerPFF
		PlayerNameLabel.Text = PlayerName
		RankLabel.Text = Rank
		WaveLabel.Text = WaveReached
	end

	-- UPDATE LOWEST WAVE ON LEADERBOARD
	if #Entries > 0 then
		WaveLeaderboard.LowestWave = Entries[#Entries].value
	end
end

-- CHECK FOR LEADERBOARD UPDATE
function WaveLeaderboard.CheckForUpdate(CurrentWave, PlayerList)
	if CurrentWave <= WaveLeaderboard.LowestWave then
		return
	end
	-- LOOP THROUGH PLAYER LIST AND SET ASYNC
	for _, Player in ipairs(PlayerList) do
		-- CHECK IF PREVIOUS RECORD IS BETTER
		local Success, Err = pcall(function()
			WaveDataStore:UpdateAsync(Player.UserId, function(OldWave)
				if OldWave and OldWave >= CurrentWave then
					return OldWave
				else
					return CurrentWave
				end
			end)
		end)
		if not Success then
			warn("LEADERBOARD UPDATE FAILED for " .. Player.Name)
		end
	end

	-- UPDATE LEADERBOARD AFTER SETTING NEW SCORES
	WaveLeaderboard.UpdateLeaderboard()
end

return WaveLeaderboard
