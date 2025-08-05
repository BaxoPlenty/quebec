local root = script.Parent.Parent

local Types = require(root.types)

type InternalData = {
	singletons: { Types.Singleton },
	lifecycleHandlers: { [Types.Lifecycle]: { { singleton: Types.Singleton, method: string } } },
	customLifecycles: { Types.InternalLifecycle },
	instanceCount: number,
	instancesReady: number,
	masterAssigned: boolean,
	readyCallback: (() -> unknown)?,
}

local Registry = {
	data = (nil :: any) :: InternalData?, -- Workaround for unrelated types. Please forgive me
}

function Registry.initialize(instanceCount: number)
	if not shared.__QuebecInternalData then
		shared.__QuebecInternalData = {
			singletons = {},
			lifecycleHandlers = {},
			customLifecycles = {},
			instanceCount = 0,
			instancesReady = 0,
			masterAssigned = false,
			readyCallback = nil,
		} :: InternalData
	end

	if not Registry.data then
		Registry.data = shared.__QuebecInternalData
	end

	Registry.data.instanceCount = instanceCount
end

function Registry.addSingleton<T>(singleton: Types.AsInternalSingleton<T>)
	table.insert(Registry.data.singletons, singleton)

	if singleton.lifecycles then
		for k, v in singleton.lifecycles do
			local method = v
			local lifecycle = if type(k) == "number" then v else k
			local t = Registry.data.lifecycleHandlers[lifecycle]

			if not t then
				Registry.data.lifecycleHandlers[lifecycle] = { { method = method, singleton = singleton } }
			else
				table.insert(t, { method = method, singleton = singleton })
			end
		end
	end
end

function Registry.addCustomLifecycle(lifecycle: Types.InternalLifecycle)
	table.insert(Registry.data.customLifecycles, lifecycle)
end

function Registry.queryAll(): { Types.Singleton }
	return Registry.data.singletons
end

function Registry.queryLifecycleHandlers(lifecycle: Types.Lifecycle): { { method: string, singleton: Types.Singleton } }
	return Registry.data.lifecycleHandlers[lifecycle] or {}
end

function Registry.queryCustomLifecycles(): { Types.InternalLifecycle }
	return Registry.data.customLifecycles
end

function Registry.assignMaster(): boolean
	if not Registry.data.masterAssigned then
		Registry.data.masterAssigned = true

		return true
	else
		return false
	end
end

function Registry.onAllReady(cb)
	if Registry.data.readyCallback ~= nil then
		return
	end

	if Registry.data.instanceCount == Registry.data.instancesReady then
		task.spawn(cb)
	else
		Registry.data.readyCallback = cb
	end
end

function Registry.markReady()
	Registry.data.instancesReady += 1

	if Registry.data.instanceCount == Registry.data.instancesReady and Registry.data.readyCallback ~= nil then
		task.spawn(Registry.data.readyCallback)
	end
end

return Registry
