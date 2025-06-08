local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local managerTypes = root.types["manager.d"]
local controllerTypes = root.types["controller.d"]
local quebecInstanceTypes = root.core.QuebecInstance

export type ControllerLoader = managerTypes.Manager<controllerTypes.Controller> & {
	folder: Folder,
	instance: quebecInstanceTypes.QuebecInstance,
	lifecyceMap: { [string]: { { controllerTypes.Controller } } },
}

local logger = require(script.Parent.Parent.internal.logger)

local ControllerLoader: ControllerLoader = {}
ControllerLoader.__index = ControllerLoader

function ControllerLoader.new(instance, folder)
	local self = setmetatable({}, ControllerLoader)

	self.instance = instance
	self.folder = folder
	self.loadedSingletons = {}
	self.lifecyceMap = {}

	return self
end

function ControllerLoader:callLifecycle(controller: controllerTypes.Controller, useSpawn: boolean, name: string, ...)
	local lifecycles = controller.lifecycles

	if not lifecycles then
		return
	end

	local method = nil

	if typeof(lifecycles) == "table" then
		method = lifecycles[name] or (table.find(lifecycles, name) and name)
	end

	if method and controller[method] then
		logger:debug(
			"ControllerLoader:callLifecycle",
			"invoking lifecycle method %q on %q (method = %q)",
			name,
			controller.identifier,
			method
		)

		return useSpawn and task.spawn(controller[method], controller, ...) or controller[method](controller, ...)
	end
end

function ControllerLoader:requireDependency(segments: { string }, instanceName: string?)
	if segments[1] == "quebec" then
		local module = root.modules:FindFirstChild(segments[2])

		if module then
			return module:IsA("ModuleScript") and require(module)
				or logger:criticalError(
					"ControllerLoader:requireDependency",
					"module %q was not a ModuleScript",
					segments[2]
				)
		end

		return logger:criticalError(
			"ControllerLoader:requireDependency",
			"unable to find module %q in quebec built-in",
			segments[2]
		)
	end

	if instanceName then
		local instance = self.instance:waitForSharedInstance(instanceName, 0)

		if not instance then
			logger:criticalError(
				"ControllerLoader:requireDependency",
				"invalid instance name (%q) in path",
				instanceName
			)

			return
		end

		if segments[1] == "controllers" then
			for _, singleton in instance.manager.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"ControllerLoader:requireDependency",
				"unable to resolve controller %q in instance %q",
				segments[2],
				instanceName
			)
		end
	else
		if segments[1] == "controllers" then
			for _, singleton in self.loadedSingletons do
				if singleton.identifier == segments[2] then
					return singleton
				end
			end

			return logger:criticalError(
				"ControllerLoader:requireDependency",
				"unable to resolve controller %q in same instance",
				segments[2]
			)
		end
	end
end

function ControllerLoader:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ControllerLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: controllerTypes.Controller

		module.identifier = module.identifier or string.gsub(instance.Name, " ", "_")

		table.insert(self.loadedSingletons, module) -- TODO: Add topological sort algorithm
	end

	for _, singleton in self.loadedSingletons do
		if singleton.dependencies then
			singleton.controllers = {}
			singleton.modules = {}

			for k, v in singleton.dependencies do
				if type(k) == "number" and type(v) == "string" then
					local result = self.instance.finder:find(v)

					singleton[if result.kind == "singleton" then "controllers" else "modules"][result.pathSegments[#result.pathSegments]] =
						self:requireDependency(result.pathSegments, result.instanceName)
				elseif type(k) == "string" and type(v) == "string" then
					local result = self.instance.finder:find(k)

					singleton[if result.kind == "singleton" then "controllers" else "modules"][v] =
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

function ControllerLoader:run()
	for _, controller in ipairs(self.loadedSingletons) do
		self:callLifecycle(controller, true, "start")
	end

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, controller in self.loadedSingletons do
			self:callLifecycle(controller, true, "onStep", deltaTime)
		end
	end)

	RunService.PostSimulation:Connect(function(deltaTime)
		for _, controller in self.loadedSingletons do
			self:callLifecycle(controller, true, "onPhysics", deltaTime)
		end
	end)
end

return ControllerLoader
