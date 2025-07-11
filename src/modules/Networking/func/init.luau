local types = require(script.types)

local FuncMethods = {}

FuncMethods.__index = FuncMethods

FuncMethods.client = require(script.clientExecutor)
FuncMethods.server = require(script.serverExecutor)

return function<Args..., Returns...>(instance: RemoteFunction): types.Func<Args..., Returns...>
	return setmetatable({
		instance = instance,
	}, FuncMethods) :: any
end
