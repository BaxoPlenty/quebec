local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local quebecTypes = script.Parent.Parent.core.QuebecInstance
local managerTypes = script.Parent.Parent.types["manager.d"]
local serviceTypes = script.Parent.Parent.types["service.d"]

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

function ServiceManager:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ServiceLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: serviceTypes.Service
		local lifecycles = module.lifecycles or {}

		module.identifier = module.identifier or string.gsub(instance.Name, " ", "_")

		if module.dependencies then
			-- TODO: Implement this
		end

		for k, v in next, lifecycles do
			if typeof(k) == "string" then
				if not self.lifecyceMap[k] then
					self.lifecyceMap[k] = {}
				end

				table.insert(self.lifecyceMap[k], { service = module, method = v })
			else
				if not self.lifecyceMap[v] then
					self.lifecyceMap[v] = {}
				end

				table.insert(self.lifecyceMap[v], { service = module, method = v })
			end
		end

		self:callLifecycle(module, false, "init")

		table.insert(self.loadedSingletons, module) -- TODO: Add topological sorting for a correct load order
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
