local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local Types = require(root.types)
local Logger = require(root.internal.logger)
local Registry = require(root.internal.registry)

local isServer = RunService:IsServer()

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

	-- Wait for all existing instances to register their singletons
	Registry.onAllReady(function()
		for _, entry in Registry.queryAll() do
			if entry.init and type(entry.init) == "function" then
				entry:init()
			end
		end

		Logger.debug("singleton initialisation done")

		for _, entry in Registry.queryLifecycleHandlers("start") do
			task.spawn(function()
				entry.singleton[entry.method](entry.singleton)
			end)
		end

		Logger.debug("%q lifecycle invoked on all registered singletons", "start")

		if isServer then
			game:BindToClose(function()
				for _, entry in Registry.queryLifecycleHandlers("stop") do
					entry.singleton[entry.method](entry.singleton)
				end

				Logger.debug("%q lifecycle invoked on all registered singletons", "stop")
			end)
		end

		Logger.debug("connected lifecycles")
	end)
end
