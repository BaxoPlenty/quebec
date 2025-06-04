local loaderTypes = script.Parent.Parent.types["loader.d"]
local controllerTypes = script.Parent.Parent.types["controller.d"]

export type TControllerLoader = loaderTypes.Loader & {
	folder: Folder,
}

local logger = require(script.Parent.Parent.internal.logger)

local ControllerLoader: TControllerLoader = {}
ControllerLoader.__index = ControllerLoader

function ControllerLoader.new(folder)
	local self = setmetatable({}, ControllerLoader)

	self.folder = folder

	return self
end

function ControllerLoader:load()
	for _, instance: Instance in next, self.folder:GetChildren() do
		if not instance:IsA("ModuleScript") then
			logger:warn("ControllerLoader:load", "unexpected instance of type %q", instance.ClassName)

			continue
		end

		local module = require(instance) :: controllerTypes.Controller

		if module.onStart then
			task.spawn(function()
				module:onStart()
			end)
		end
	end
end

return ControllerLoader
