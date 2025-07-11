local types = require(script.Parent.types)

local ExecutorMethods = {}

ExecutorMethods.__index = ExecutorMethods

function ExecutorMethods.fire<Args...>(self: types.ClientExecutor<Args...>, ...: Args...)
	self.instance:FireServer(...)
end

function ExecutorMethods.connect<Args...>(self: types.ClientExecutor<Args...>, callback: (Args...) -> ()): RBXScriptConnection
	return self.instance.OnClientEvent:Connect(callback)
end

return function<Args...>(self: types.Event<Args...>): types.ClientExecutor<Args...>
	return setmetatable({
		instance = self.instance,
	}, ExecutorMethods) :: any
end
