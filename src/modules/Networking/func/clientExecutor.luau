local types = require(script.Parent.types)

local ExecutorMethods = {}

ExecutorMethods.__index = ExecutorMethods

function ExecutorMethods.invoke<Args..., Returns...>(self: types.ClientExecutor<Args..., Returns...>, ...: Args...): Returns...
	return self.instance:InvokeServer(...)
end

function ExecutorMethods.connect<Args..., Returns...>(self: types.ClientExecutor<Args..., Returns...>, callback: (Args...) -> Returns...)
	self.instance.OnClientInvoke = callback
end

return function<Args..., Returns...>(self: types.Func<Args..., Returns...>): types.ClientExecutor<Args..., Returns...>
	return setmetatable({
		instance = self.instance,
	}, ExecutorMethods) :: any
end
