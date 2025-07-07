local root = script.Parent.Parent

local Types = require(root.types)
local Logger = require(root.internal.logger)
local Registry = require(root.internal.registry)

return function(singletonFolder: Folder, config: Types.FrameworkConfiguration?)
	Registry.initialize()

	Logger.debug("registry initialized")

	-- Requiring all the singletons once for them to register via Quebec.singleton
	for _, instance in singletonFolder:GetChildren() do
		if instance:IsA("ModuleScript") then
			require(instance)
		end
	end

	-- Don't connect lifecycles more than one time
	if not Registry.assignMaster() then
		return
	end

	for _, entry in Registry.queryLifecycleHandlers("start") do
		task.spawn(function()
			entry.method(entry.singleton)
		end)
	end

	Registry.enableLateStart()

	Logger.debug("late start is now enabled")
end
