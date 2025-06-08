local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local quebecTypes = root.core.QuebecInstance
local managerTypes = root.types["manager.d"]
local serviceTypes = root.types["service.d"]

export type ServiceManager = managerTypes.Manager<serviceTypes.Service> & {
	folder: Folder,
	instance: quebecTypes.QuebecInstance,
	lifecyceMap: { [string]: { serviceTypes.Service } },
}

local logger = require(script.Parent.Parent.internal.logger)

local ServiceManager: ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager.new(instance, folder)
	local self = setmetatable({}, ServiceManager) :: ServiceManager

	self.loadedSingletons = {}
	self.instance = instance
	self.folder = folder
	self.lifecyceMap = {}

	return self
end

---Calls the specified lifecycle method on the specified service. Optionally, it can be ran in a new thread.
function ServiceManager:callLifecycle(service: serviceTypes.Service, useSpawn: boolean, name: string, ...)
	local lifecycles = service.lifecycles

	if not lifecycles then
		return
	end

	local method = nil

	if typeof(lifecycles) == "table" then
		method = lifecycles[name] or (table.find(lifecycles, name) and name)
	end

	if method and service[method] then
		logger:debug(
			"ServiceManager:callLifecycle",
			"invoking lifecycle method %q on %q (method = %q)",
			name,
			service.identifier,
			method
		)

		return useSpawn and task.spawn(service[method], service, ...) or service[method](service, ...)
	end
end

function ServiceManager:requireDependency(segments: { string }, instanceName: string?)
	if segments[1] == "quebec" then
		local module = root.modules:FindFirstChild(segments[2])

		if module then
			return module:IsA("ModuleScript") and require(module)
				or logger:criticalError(
					"ServiceManager:requireDependency",
					"module %q was not a ModuleScript",
					segments[2]
				)
		end

		return logger:criticalError(
			"ServiceManager:requireDependency",
			"unable to find module %q in quebec built-in",
			segments[2]
		)
	end

	if instanceName then
		local instance = self.instance:waitForSharedInstance(instanceName, 0)

		if not instance then
			logger:criticalError("ServiceManager:requireDependency", "invalid instance name (%q) in path", instanceName)

			return
		end

		if segments[1] == "services" then
			for _, singleton in instance.manager.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"ServiceManager:requireDependency",
				"unable to resolve service %q in instance %q",
				segments[2],
				instanceName
			)
		end
	else
		if segments[1] == "services" then
			for _, singleton in self.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"ServiceManager:requireDependency",
				"unable to resolve service %q in same instance",
				segments[2]
			)
		end
	end
end

function ServiceManager:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ServiceLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: serviceTypes.Service

		module.identifier = module.identifier or string.gsub(instance.Name, " ", "_")

		table.insert(self.loadedSingletons, module) -- TODO: Add topological sorting for a correct load order
	end

	for _, singleton in self.loadedSingletons do
		if singleton.dependencies then
			singleton.services = {}
			singleton.modules = {}

			for k, v in singleton.dependencies do
				if type(k) == "number" and type(v) == "string" then
					local result = self.instance.finder:find(v)

					singleton[if result.kind == "singleton" then "services" else "modules"][result.pathSegments[#result.pathSegments]] =
						self:requireDependency(result.pathSegments, result.instanceName)
				elseif type(k) == "string" and type(v) == "string" then
					local result = self.instance.finder:find(k)

					singleton[if result.kind == "singleton" then "services" else "modules"][v] =
						self:requireDependency(result.pathSegments, result.instanceName)
				end
			end
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

		self:callLifecycle(singleton, false, "init")
	end

	return true
end

function ServiceManager:run()
	for _, service in self.loadedSingletons do
		self:callLifecycle(service, true, "start")
	end

	game:BindToClose(function()
		for i = #self.loadedSingletons, 1, -1 do
			local service = self.loadedSingletons[i]

			self:callLifecycle(service, false, "onShutdown")
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, service in self.loadedSingletons do
			self:callLifecycle(service, true, "onStep", deltaTime)
		end
	end)

	RunService.PostSimulation:Connect(function(deltaTime)
		for _, service in self.loadedSingletons do
			self:callLifecycle(service, true, "onPhysics", deltaTime)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		for _, service in self.loadedSingletons do
			self:callLifecycle(service, true, "onPlayerJoin", player)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		for _, service in self.loadedSingletons do
			self:callLifecycle(service, true, "onPlayerLeave", player)
		end
	end)
end

return ServiceManager
