local root = script.Parent.Parent

local Types = require(root.types)

type InternalData = {
	singletons: { Types.Singleton },
	lifecycleHandlers: { [Types.Lifecycle]: { { singleton: Types.Singleton, method: (...any) -> unknown } } },
	instanceCount: number,
	masterAssigned: boolean,
	startLateServices: boolean,
}

local Registry = {
	data = (nil :: any) :: InternalData?, -- Workaround for unrelated types. Please forgive me
}

function Registry.initialize()
	if not shared.__QuebecInternalData then
		shared.__QuebecInternalData = {
			singletons = {},
			lifecycleHandlers = {},
			instanceCount = 0,
			masterAssigned = false,
			startLateServices = false,
		} :: InternalData
	end

	if not Registry.data then
		Registry.data = shared.__QuebecInternalData
	end

	Registry.data.instanceCount += 1
end

function Registry.addSingleton<T>(singleton: Types.AsInternalSingleton<T>)
	table.insert(Registry.data.singletons, singleton)

	if singleton.lifecycles then
		for k, v in singleton.lifecycles do
			local method = (singleton :: any)[v]
			local lifecycle = if typeof(k) == "number" then v else k
			local t = Registry.data.singletonsByLifecycle[lifecycle]

			if not t then
				Registry.data.singletonsByLifecycle[v] = { method = method, singleton = singleton }
			else
				table.insert(t, method)
			end
		end
	end
end

function Registry.queryAll(): { Types.Singleton }
	return Registry.data.singletons
end

function Registry.queryLifecycleHandlers(
	lifecycle: Types.Lifecycle
): { { method: (...any) -> unknown, singleton: Types.Singleton } }
	return Registry.data.lifecycleHandlers[lifecycle] or {}
end

function Registry.assignMaster(): boolean
	if not Registry.data.masterAssigned then
		Registry.data.masterAssigned = true

		return true
	else
		return false
	end
end

function Registry.enableLateStart()
	Registry.data.startLateServices = true
end

function Registry.isLateStartEnabled(): boolean
	return Registry.data.startLateServices
end

return Registry
