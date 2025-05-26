local loaderTypes = script.Parent.Parent.types["loader.d"]
local serviceTypes = script.Parent.Parent.types["service.d"]

export type TServiceLoader = loaderTypes.TLoader & {
	folder: Folder,
}

local logger = require(script.Parent.Parent.internal.logger)

local ServiceLoader: TServiceLoader = {}
ServiceLoader.__index = ServiceLoader

function ServiceLoader.new(folder)
	local self = setmetatable({}, ServiceLoader)

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

		if module.onStart then
			task.spawn(function()
				module:onStart()
			end)
		end
	end
end

return ServiceLoader
