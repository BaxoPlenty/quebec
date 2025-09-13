local types = require(script.types)

local EventMethods = {}

EventMethods.__index = EventMethods

EventMethods.client = require(script.clientExecutor)
EventMethods.server = require(script.serverExecutor)

return function<Args...>(instance: UnreliableRemoteEvent): types.Unreliable<Args...>
	return setmetatable({
		instance = instance,
	}, EventMethods) :: any
end
