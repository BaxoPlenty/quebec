local types = require(script.types)

local EventMethods = {}

EventMethods.__index = EventMethods

EventMethods.client = require(script.clientExecutor)
EventMethods.server = require(script.serverExecutor)

return function<Args...>(instance: RemoteEvent): types.Event<Args...>
	return setmetatable({
		instance = instance,
	}, EventMethods) :: any
end
