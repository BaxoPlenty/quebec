local quebecTypes = script.Parent.Parent.core.QuebecInstance
local loaderTypes = script.Parent.Parent.types["loader.d"]
local serviceTypes = script.Parent.Parent.types["service.d"]

export type TServiceLoader = loaderTypes.TLoader & {
	folder: Folder,
    instance: quebecTypes.TQuebecInstance
}

local logger = require(script.Parent.Parent.internal.logger)

local ServiceLoader: TServiceLoader = {}
ServiceLoader.__index = ServiceLoader

function ServiceLoader.new(instance, folder)
	local self = setmetatable({}, ServiceLoader)

    self.instance = instance
	self.folder = folder

	return self
end

function ServiceLoader:load()
	for _, instance: Instance in next, self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ServiceLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: serviceTypes.TService

        if module.dependencies then
            for _, dependencyName in next, module.dependencies do
                module[dependencyName] = self.instance.loadedModules[dependencyName]
            end
        end

		if module.onStart then
			task.spawn(module.onStart, module)
		end
	end
end

return ServiceLoader
