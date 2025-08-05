local Types = require(script.Parent.Parent.types)
local Logger = require(script.Parent.Parent.internal.logger)

local function getSingletons(self: Types.InternalLifecycle)
	return self.__singletons
end

local function invokeAll(self: Types.InternalLifecycle, ...: any)
	for _, entry in self.__singletons do
		local method = entry.singleton[entry.fn]

		task.spawn(method, entry.singleton, ...)
	end
end

local function invokeAllSameThread(self: Types.InternalLifecycle, ...: any)
	for _, entry in self.__singletons do
		local method = entry.singleton[entry.fn]

		method(entry.singleton, ...)
	end
end

return function<T>(data: T & Types.CustomLifecycleData): T
	if not data.defaultMethod then
		Logger.critical("a lifecycle is missing the `defaultMethod` field!")
	end

	data.__type = "Quebec.Lifecycle"
	data.__singletons = {}

	data.getSingletons = getSingletons
	data.invokeAll = invokeAll
	data.invokeAllSameThread = invokeAllSameThread

	return data
end
