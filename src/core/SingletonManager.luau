local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local root = script.Parent.Parent
local singletonKind = if RunService:IsClient() then "controller" else "service"
local singletonKindPlural = singletonKind .. "s"

local quebecTypes = root.core.QuebecInstance
local managerTypes = root.types["manager.d"]
local singletonTypes = root.types["singleton.d"]

export type SingletonManager = managerTypes.Manager<singletonTypes.Singleton> & {
	folder: Folder,
	instance: quebecTypes.QuebecInstance,
	lifecyceMap: { [string]: { singletonTypes.Singleton } },
}

local logger = require(root.internal.logger)

local SingletonManager: SingletonManager = {}
SingletonManager.__index = SingletonManager

function SingletonManager.new(instance, folder)
	local self = setmetatable({}, SingletonManager) :: SingletonManager

	self.loadedSingletons = {}
	self.instance = instance
	self.folder = folder
	self.lifecyceMap = {}

	return self
end

---Calls the specified lifecycle method on the specified singleton. Optionally, it can be ran in a new thread.
function SingletonManager:callLifecycle(singleton: singletonTypes.Singleton, useSpawn: boolean, name: string, ...)
	local lifecycles = singleton.lifecycles

	if not lifecycles then
		return
	end

	local method = nil

	if typeof(lifecycles) == "table" then
		method = lifecycles[name] or (table.find(lifecycles, name) and name)
	end

	if method and singleton[method] then
		logger:debug(
			"SingletonManager:callLifecycle",
			"invoking lifecycle method %q on %q (method = %q)",
			name,
			singleton.identifier,
			method
		)

		return useSpawn and task.spawn(singleton[method], singleton, ...) or singleton[method](singleton, ...)
	end
end

function SingletonManager:requireDependency(segments: { string }, instanceName: string?)
	if segments[1] == "quebec" then
		local module = root.modules:FindFirstChild(segments[2])

		if module then
			return module:IsA("ModuleScript") and require(module)
				or logger:criticalError(
					"SingletonManager:requireDependency",
					"module %q was not a ModuleScript",
					segments[2]
				)
		end

		return logger:criticalError(
			"SingletonManager:requireDependency",
			"unable to find module %q in quebec built-in",
			segments[2]
		)
	end

	if instanceName then
		local instance = self.instance:waitForSharedInstance(instanceName, 0)

		if not instance then
			logger:criticalError(
				"SingletonManager:requireDependency",
				"invalid instance name (%q) in path",
				instanceName
			)

			return
		end

		if segments[1] == singletonKindPlural then
			for _, singleton in instance.manager.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"SingletonManager:requireDependency",
				"unable to resolve %s %q in instance %q",
				singletonKind,
				segments[2],
				instanceName
			)
		end
	else
		if segments[1] == singletonKindPlural then
			for _, singleton in self.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"SingletonManager:requireDependency",
				"unable to resolve %s %q in same instance",
				singletonKind,
				segments[2]
			)
		end
	end
end

function SingletonManager:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("SingletonManager:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: singletonTypes.Singleton

		module.identifier = module.identifier or string.gsub(instance.Name, " ", "_")

		table.insert(self.loadedSingletons, module) -- TODO: Add topological sorting for a correct load order
	end

	for _, singleton in self.loadedSingletons do
		--[==[ if singleton.dependencies then
			singleton[singletonKindPlural] = {}
			singleton.modules = {}

			for k, v in singleton.dependencies do
				if type(k) == "number" and type(v) == "string" then
					local result = self.instance.finder:find(v)

					singleton[if result.kind == "singleton" then singletonKindPlural else "modules"][result.pathSegments[#result.pathSegments]] =
						self:requireDependency(result.pathSegments, result.instanceName)
				elseif type(k) == "string" and type(v) == "string" then
					local result = self.instance.finder:find(k)

					singleton[if result.kind == "singleton" then singletonKindPlural else "modules"][v] =
						self:requireDependency(result.pathSegments, result.instanceName)
				end
			end
		end ]==]
		if singleton.init and type(singleton.init) == "function" then
            -- used to later track these for topological sort
			local requestedDependencies = {}

			local resolverFunction = function(path)
				table.insert(requestedDependencies, path)

				local result = self.instance.resolver:resolve(path)

				if result then
					return self:requireDependency(result.pathSegments, result.instanceName)
				else
					logger:criticalError(
						"SingletonManager:load",
						"unable to load dependency %q in singleton %q",
						path,
						singleton.identifier
					)
				end
			end

			singleton:init(resolverFunction)
		end
	end

	for _, singleton in self.loadedSingletons do
		local lifecycles = singleton.lifecycles or {}

		for k, v in next, lifecycles do
			if typeof(k) == "string" then
				if not self.lifecyceMap[k] then
					self.lifecyceMap[k] = {}
				end

				table.insert(self.lifecyceMap[k], singleton)
			else
				if not self.lifecyceMap[v] then
					self.lifecyceMap[v] = {}
				end

				table.insert(self.lifecyceMap[v], singleton)
			end
		end
	end

	return true
end

function SingletonManager:run()
	for _, singleton in self.loadedSingletons do
		self:callLifecycle(singleton, true, "start")
	end

	if self.lifecyceMap.onStep then
		RunService.Heartbeat:Connect(function(deltaTime)
			for _, singleton in self.lifecyceMap.onStep do
				self:callLifecycle(singleton, true, "onStep", deltaTime)
			end
		end)
	end

	if self.lifecyceMap.onPhysics then
		RunService.PostSimulation:Connect(function(deltaTime)
			for _, singleton in self.lifecyceMap.onPhysics do
				self:callLifecycle(singleton, true, "onPhysics", deltaTime)
			end
		end)
	end

	-- Server-only lifecycles
	if RunService:IsServer() then
		game:BindToClose(function()
			-- Backwards due to load order
			for i = #self.loadedSingletons, 1, -1 do
				local singleton = self.loadedSingletons[i]

				self:callLifecycle(singleton, false, "onShutdown")
			end
		end)

		if self.lifecyceMap.onPlayerJoin then
			Players.PlayerAdded:Connect(function(player)
				for _, singleton in self.lifecyceMap.onPlayerJoin do
					self:callLifecycle(singleton, true, "onPlayerJoin", player)
				end
			end)
		end

		if self.lifecyceMap.onPlayerLeave then
			Players.PlayerRemoving:Connect(function(player)
				for _, singleton in self.lifecyceMap.onPlayerLeave do
					self:callLifecycle(singleton, true, "onPlayerLeave", player)
				end
			end)
		end
	end
end

return SingletonManager
