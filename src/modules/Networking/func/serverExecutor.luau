local types = require(script.Parent.types)

local ExecutorMethods = {}

ExecutorMethods.__index = ExecutorMethods

function ExecutorMethods.invoke<Args..., Returns...>(
	self: types.ServerExecutor<Args..., Returns...>,
	player: Player,
	...: Args...
): Returns...
	return self.instance:InvokeClient(player, ...)
end

function ExecutorMethods.connect<Args..., Returns...>(
	self: types.ServerExecutor<Args..., Returns...>,
	callback: (player: Player, Args...) -> Returns...
)
	self.instance.OnServerInvoke = callback
end

return function<Args..., Returns...>(self: types.Func<Args..., Returns...>): types.ServerExecutor<Args..., Returns...>
	return setmetatable({
		instance = self.instance,
	}, ExecutorMethods) :: any
end
