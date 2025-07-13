local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AuroraRemotes = ReplicatedStorage.Aurora:FindFirstChild("AuroraRemotes")
if not AuroraRemotes then
	AuroraRemotes = Instance.new("Folder")
	AuroraRemotes.Name = "AuroraRemotes"
	AuroraRemotes.Parent = ReplicatedStorage.Aurora
end

local EventsFolder = AuroraRemotes:FindFirstChild("Events")
if not EventsFolder then
	EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = AuroraRemotes
end

local FunctionsFolder = AuroraRemotes:FindFirstChild("Functions")
if not FunctionsFolder then
	FunctionsFolder = Instance.new("Folder")
	FunctionsFolder.Name = "Functions"
	FunctionsFolder.Parent = AuroraRemotes
end

local Messaging = {}
Messaging.__index = Messaging

function Messaging:Init(Aurora)
	self._events = {}
	self._functions = {}
	self._remoteEventsInitialized = {}
	self.Logger = Aurora.Modules.Logger
end

local function getOrCreateRemoteEvent(name)
	local remote = EventsFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = EventsFolder
	end
	return remote
end

local function getOrCreateRemoteFunction(name)
	local remote = FunctionsFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = FunctionsFolder
	end
	return remote
end

function Messaging:_SetupRemoteEventListener(eventName)
	local remote = getOrCreateRemoteEvent(eventName)
	if RunService:IsServer() then
		remote.OnServerEvent:Connect(function(player, ...)
			self:FireEvent(eventName, player, ...)
		end)
	else
		remote.OnClientEvent:Connect(function(...)
			self:FireEvent(eventName, ...)
		end)
	end
end

function Messaging:_SetupRemoteFunctionListener(name)
	local remote = getOrCreateRemoteFunction(name)
	if RunService:IsServer() then
		remote.OnServerInvoke = function(player, ...)
			local fn = self._functions[name]
			if fn then
				print("[Server] OnServerInvoke args:", ...)
				return fn(player, ...)
			else
				self.Logger:Warn("[Messaging] No server function registered for '" .. name .. "'")
				return nil
			end
		end
	end
end

function Messaging:RegisterFunction(name, fn)
	assert(type(name) == "string", "Function name must be string")
	assert(type(fn) == "function", "fn must be function")
	self._functions[name] = fn

	if RunService:IsServer() then
		self:_SetupRemoteFunctionListener(name)
	end
end

function Messaging:CallFunction(name, ...)
	local fn = self._functions[name]
	if fn then
		return fn(...)
	end

	local remote = getOrCreateRemoteFunction(name)
	if RunService:IsServer() then
		self.Logger:Warn("[Messaging] Server cannot call client function '" .. name .. "' without target player.")
		return nil
	else
		local args = {...}
		
		local success, result = pcall(function()
			return remote:InvokeServer(table.unpack(args))
		end)
		if success then
			return result
		else
			self.Logger:Warn("[Messaging] RemoteFunction call failed: " .. tostring(result))
			return nil
		end
	end
end

function Messaging:BindEvent(eventName, callback)
	assert(type(callback) == "function", "Callback must be a function")

	if not self._remoteEventsInitialized[eventName] then
		self:_SetupRemoteEventListener(eventName)
		self._remoteEventsInitialized[eventName] = true
	end

	if not self._events[eventName] then
		self._events[eventName] = {}
	end
	table.insert(self._events[eventName], callback)
end

function Messaging:FireEvent(eventName, ...)
	local listeners = self._events[eventName]
	if listeners then
		for _, cb in ipairs(listeners) do
			task.spawn(cb, ...)
		end
	end

	if RunService:IsServer() then
		local remote = getOrCreateRemoteEvent(eventName)
		remote:FireAllClients(...)
	else
		local remote = getOrCreateRemoteEvent(eventName)
		remote:FireServer(...)
	end
end

return Messaging
