local loaderTypes = script.Parent.Parent.types["loader.d"]
local controllerTypes = script.Parent.Parent.types["controller.d"]

export type ControllerLoader = loaderTypes.Loader & {
	folder: Folder,
	loadedControllers: { controllerTypes.Controller },
}

local logger = require(script.Parent.Parent.internal.logger)

local ControllerLoader: ControllerLoader = {}
ControllerLoader.__index = ControllerLoader

function ControllerLoader.new(folder)
	local self = setmetatable({}, ControllerLoader)

	self.folder = folder
	self.loadedControllers = {}

	return self
end

function ControllerLoader:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ControllerLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: controllerTypes.Controller

		module.identifier = module.identifier or `@controllers/{string.gsub(instance.Name, " ", "_")}`

		table.insert(self.loadedControllers, module) -- TODO: Add topological sort algorithm
	end

	return true
end

function ControllerLoader:run()
	for _, controller in ipairs(self.loadedControllers) do
		if controller.onStart then
			logger:debug("ControllerLoader:run", "invoking onStart of controller %q", controller.identifier)

			task.spawn(controller.onStart, controller)
		end
	end
end

return ControllerLoader
