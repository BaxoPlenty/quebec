local RunService = game:GetService("RunService")
local managerTypes = script.Parent.Parent.types["manager.d"]
local controllerTypes = script.Parent.Parent.types["controller.d"]

export type ControllerLoader = managerTypes.Manager & {
	folder: Folder,
	loadedControllers: { controllerTypes.Controller },
	lifecyceMap: { [string]: { controllerTypes.Controller } },
}

local logger = require(script.Parent.Parent.internal.logger)

local ControllerLoader: ControllerLoader = {}
ControllerLoader.__index = ControllerLoader

function ControllerLoader.new(folder)
	local self = setmetatable({}, ControllerLoader)

	self.folder = folder
	self.loadedControllers = {}
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

function ControllerLoader:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ControllerLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: controllerTypes.Controller
		local lifecycles = module.lifecycles or {}

		module.identifier = module.identifier or `@controllers/{string.gsub(instance.Name, " ", "_")}`

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

		table.insert(self.loadedControllers, module) -- TODO: Add topological sort algorithm
	end

	return true
end

function ControllerLoader:run()
	for _, controller in ipairs(self.loadedControllers) do
		self:callLifecycle(controller, true, "start")
	end

	game.Close:Connect(function()
		for i = #self.loadedControllers, 1, -1 do
			local controller = self.loadedControllers[i]

			self:callLifecycle(controller, false, "destroy")
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, controller in self.loadedControllers do
			self:callLifecycle(controller, true, "onStep", deltaTime)
		end
	end)

	RunService.PostSimulation:Connect(function(deltaTime)
		for _, controller in self.loadedControllers do
			self:callLifecycle(controller, true, "onPhysics", deltaTime)
		end
	end)
end

return ControllerLoader
