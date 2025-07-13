local Aurora = {}
Aurora.__index = Aurora

local RunService = game:GetService("RunService")

Aurora.Modules = {}

-- You can organize modules into these folders
local modulesFolder = script:FindFirstChild("Modules")
local serverModulesFolder = modulesFolder:FindFirstChild("Server") -- optional
local clientModulesFolder = modulesFolder:FindFirstChild("Client") -- optional

function Aurora:Init(settings)
	print("[Aurora] Initializing on", RunService:IsServer() and "Server" or "Client")

	-- Load shared modules
	for _, moduleScript in ipairs(modulesFolder.Shared:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			local name = module.Name or moduleScript.Name
			Aurora.Modules[name] = module
		end
	end

	-- Load server-only modules
	if RunService:IsServer() and serverModulesFolder then
		for _, moduleScript in ipairs(serverModulesFolder:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				local module = require(moduleScript)
				local name = module.Name or moduleScript.Name
				Aurora.Modules[name] = module
			end
		end
	end

	-- Load client-only modules
	if RunService:IsClient() and clientModulesFolder then
		for _, moduleScript in ipairs(clientModulesFolder:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				local module = require(moduleScript)
				local name = module.Name or moduleScript.Name
				Aurora.Modules[name] = module
			end
		end
	end

	-- Initialize modules
	for name, module in pairs(Aurora.Modules) do
		if type(module.Init) == "function" then
			local moduleSettings = settings and settings[name]
			module:Init(Aurora, moduleSettings)
		end
	end

	print("[Aurora] Initialization complete.")
end

return Aurora
