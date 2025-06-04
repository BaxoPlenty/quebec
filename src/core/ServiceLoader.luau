local quebecTypes = script.Parent.Parent.core.QuebecInstance
local loaderTypes = script.Parent.Parent.types["loader.d"]
local serviceTypes = script.Parent.Parent.types["service.d"]

export type ServiceLoader = loaderTypes.Loader & {
	folder: Folder,
	instance: quebecTypes.QuebecInstance,
	loadedServices: { serviceTypes.Service },
}

local logger = require(script.Parent.Parent.internal.logger)

local ServiceLoader: ServiceLoader = {}
ServiceLoader.__index = ServiceLoader

function ServiceLoader.new(instance, folder)
	local self = setmetatable({}, ServiceLoader)

	self.instance = instance
	self.folder = folder
	self.loadedServices = {}

	return self
end

function ServiceLoader:load(): boolean
	for _, instance: Instance in self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ServiceLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: serviceTypes.Service

		module.identifier = module.identifier or `@services/{string.gsub(instance.Name, " ", "_")}`

		if module.dependencies then
			-- TODO: Implement this
		end

		table.insert(self.loadedServices, module) -- TODO: Add topological sorting for a correct load order
	end

	return true
end

function ServiceLoader:run()
	for _, service in ipairs(self.loadedServices) do
		if service.onStart then
			logger:debug("ServiceLoader:run", "invoking onStart of service %q", service.identifier)

			task.spawn(service.onStart, service)
		end
	end
end

return ServiceLoader
