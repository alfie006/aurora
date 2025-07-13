local DataService = {}
DataService.__index = DataService

local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local Players = game:GetService("Players")

local AUTOSAVE_INTERVAL = 300 -- 5 minutes

function DataService:Init(Aurora, defaultData)
	self._cache = {}
	self._saving = {}
	self._autosaveRunning = false
	self._defaultData = defaultData or {}
	self.Logger = Aurora.Modules.Logger

	-- Start autosave loop
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			self:AutoSaveAll()
		end
	end)

	-- Save data on player removing
	Players.PlayerRemoving:Connect(function(player)
		self:Save(player)
		self._cache[player.UserId] = nil
	end)

	return self
end

function DataService:Load(player)
	local userId = player.UserId
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(tostring(userId))
	end)

	if success then
		if data == nil then
			data = table.clone(self._defaultData)
		end
		self._cache[userId] = data
		return data
	else
		self.Logger:Warn("[DataService] Failed to load data for", userId)
		return nil
	end
end

function DataService:Get(player)
	return self._cache[player.UserId]
end

local SAVE_COOLDOWN = 10 -- seconds between saves per player

function DataService:Save(player)
	local userId = player.UserId
	if not userId then return end

	-- If a save is already scheduled or running, ignore this request
	if self._saving[userId] then
		-- Already saving or queued, skip
		return
	end

	self._saving[userId] = true

	-- Schedule the actual save after cooldown (debounce)
	task.delay(SAVE_COOLDOWN, function()
		local data = self._cache[userId]
		if data then
			local success, err = pcall(function()
				PlayerDataStore:SetAsync(tostring(userId), data)
			end)
			if not success then
				self.Logger:Warn("[DataService] Failed to save data for", userId, err)
			end
		end

		self._saving[userId] = nil
	end)
end


function DataService:AutoSaveAll()
	for userId, _ in pairs(self._cache) do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			self:Save(player) -- uses throttled Save now
		end
	end
end

return DataService
